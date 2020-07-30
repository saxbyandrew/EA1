//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"



#include "EAEnum.mqh"
#include "EAPosition.mqh"
#include "EAPositionBase.mqh"


class EALong : public EAPositionBase {

//=========
private:
//=========

//=========
protected:
//=========

    void    updateOnInterval(EAEnum interval);
    void    closeOnFixedTiming();
    void    closeOnStealthProfit();
    void    closeOnStealthLoss();
    bool    newPosition();
    
//=========
public:
//=========
EALong();
~EALong();

    virtual int Type() const {return _LONG;};


    virtual bool    execute(EAEnum action);  

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EALong::EALong() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("EALong ->  Object Created ....");
        writeLog
        printf(ss);
    #endif


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EALong::~EALong() {


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALong::updateOnInterval(EAEnum interval) {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("updateOnInterval -> ....");
        writeLog
        printf(ss);
    #endif

    
    if (interval==_RUN_ONBAR||interval==_RUN_ONTICK) {
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            p.calcPositionPnL();
            #ifdef _DEBUG_LONG
                ss=StringFormat("ONBAR and ONTICK -> %d,%g",p.ticket,p.currentPnL);
                writeLog
                printf(ss);
            #endif 
        }
    }


    if (interval==_RUN_ONDAY) {
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            p.daysOpen++; 
            p.calcPositionSwapCost();
            #ifdef _DEBUG_LONG
                ss=StringFormat("ONDAY -> %d,%d,%g",p.ticket,p.daysOpen,p.swapCosts);
                writeLog
                printf(ss);
            #endif 
        }      
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALong::closeOnFixedTiming() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("closeOnFixedTiming -> ....");
        writeLog
        printf(ss);
    #endif


    for (int i=0;i<longPositions.Total();i++) {
        glp; 

        //----
        #ifdef _DEBUG_LONG
            if (p.closingTypes&_CLOSE_AT_EOD&&usp.maxDailyHold>=0) {
                ss=StringFormat("closeOnFixedTiming -> Long position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                writeLog
                Print (ss);
            }
        #endif
        //----

        if (p.closingDateTime<TimeCurrent() && usp.maxDailyHold>=0 && bool(p.closingTypes&_CLOSE_AT_EOD)) {    // Check when current date exceeded future date hence due date passed
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                //----
                #ifdef _DEBUG_LONG 
                    ss="closeOnFixedTiming -> Long Close EOD"; 
                    writeLog
                    printf(ss);
                #endif
                //----
                closeSQLPosition(p);
                if (longPositions.Delete(i)) {
                    #ifdef _DEBUG_LONG 
                        ss="closeOnFixedTiming -> Long Close at EOD removed from CList"; 
                        writeLog
                        printf(ss);
                    #endif                      
                }
            } 
        }
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALong::closeOnStealthProfit() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("closeOnStealthProfit -> ....");
        writeLog
        printf(ss);
    #endif

    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inProfit;

    for (int i=0;i<longPositions.Total();i++) {
        glp; 
        p.calcPositionPnL();

        if (last_tick.bid>p.fixedProfitTargetLevel)  {inProfit=true;};
        if (last_tick.bid<p.fixedProfitTargetLevel)  {inProfit=false;}; 

        if (bool (p.closingTypes&_IN_PROFIT_CLOSE_POSITION)) {  
            if (inProfit) {
                if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                //----
                    #ifdef _DEBUG_LONG 
                        ss="closeOnStealthProfit -> Long Close in profit"; 
                        writeLog
                        printf(ss);
                    #endif
                        closeSQLPosition(p);
                    if (longPositions.Delete(i)) {
                        #ifdef _DEBUG_LONG 
                            ss="closeOnStealthProfit -> Long Close in profit object removed from CList"; 
                            writeLog
                            printf(ss);
                        #endif 
                        return;                      
                    }
                } 
            }
        }
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALong::closeOnStealthLoss() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("closeOnStealthLoss -> ....");
        writeLog
        printf(ss);
    #endif

    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inLoss;

    for (int i=0;i<longPositions.Total();i++) {
        glp; 
        
        if (last_tick.bid<p.fixedLossTargetLevel)    {inLoss=true;};
        if (last_tick.bid>p.fixedLossTargetLevel)    {inLoss=false;};

        if (bool (p.closingTypes&_IN_LOSS_CLOSE_POSITION)) {
            if (inLoss) {
                if (p.closingTypes&_IN_LOSS_OPEN_MARTINGALE&&martingalePositions.Total()<usp.maxMg) {                    // Martingale close in "loss"
                    //Create a copy of the postion to be copied over to martingalePositions
                    // this method used because CList detach does not work as expected
                    EAPosition *np=new EAPosition(p);       // Create new with copy constructor called
                    martingalePositions.Add(np);            // add to mg list
                    longPositions.DeleteCurrent();          // delete from current lp list
                    #ifdef _DEBUG_LONG 
                        ss=StringFormat("closeOnStealthLoss -> Total long after move:%d",longPositions.Total());
                        writeLog
                        Print (ss);
                        ss=StringFormat("closeOnStealthLoss -> Total mg after move:%d",martingalePositions.Total());
                        writeLog
                        Print (ss);
                    #endif
                    return;
                } else {                                                                    // Normal close in loss
                    if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                        //----
                        #ifdef _DEBUG_LONG 
                            ss="closeOnStealthLoss -> Long Close in loss"; 
                            writeLog
                            printf(ss);
                        #endif
                        closeSQLPosition(p);
                        if (longPositions.Delete(i)) {
                            #ifdef _DEBUG_LONG 
                                ss="closeOnStealthLoss -> Long Close in profit object removed from CList";
                                writeLog
                                printf(ss); 
                            #endif
                            return;                       
                        }   
                    }  
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EALong::newPosition() {

    #ifdef _DEBUG_LONG 
        string ss;
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            ss=StringFormat("newPosition -> T:%d S:%d",p.ticket,p.status);
            writeLog
            Print(ss);
        }
    #endif  


        if (longPositions.Total()>=usp.maxLong) {
            //showPanel mp.updateInfo2Value(16,StringFormat("%d Maximum Reached",param.maxPositionsLong));
            #ifdef _DEBUG_LONG
                ss="newPosition -> Max number of LONG reached";
                writeLog
                printf(ss);
            #endif 
            return false;
        } else {
            //showPanel mp.updateInfo2Value(16,param.maxPositionsLong);
        }                    

        // Build a new position object based on defaults
        EAPosition *p=new EAPosition();                     // Create new position object
        p.strategyNumber=usp.strategyNumber;              // copy over strategy defaults
        p.lotSize=usp.lotSize;
        p.status=_LONG;
        p.entryPrice=getUpdatedPrice(ORDER_TYPE_BUY,_TOOPEN);
        p.orderTypeToOpen=ORDER_TYPE_BUY;                   // type is a LONG
        p.closingTypes=usp.closingTypes;
        p.fixedProfitTargetLevel=p.entryPrice+usp.fptl;  
        p.fixedLossTargetLevel=p.entryPrice+usp.fltl; 

        if (openPosition(p)) {
            if (longPositions.Add(p)!=-1) {
                #ifdef _DEBUG_LONG
                    ss="newPosition -> New position opened and added to long positions list"; 
                    writeLog
                    printf(ss);
                    ss=StringFormat("strategyNumber:%d lotSize:%.2f status:%s entryPrice:%.2f fixedProfitTargetLevel:%.2f fixedLossTargetLevel:%.2f",
                    p.strategyNumber,p.lotSize,EnumToString(p.status),p.entryPrice,p.fixedProfitTargetLevel,p.fixedLossTargetLevel);
                    writeLog
                    printf(ss);
                #endif 
                return true;
            }            
        } else {
            #ifdef _DEBUG_LONG
                Print("newPosition -> New position opened failed"); 
                writeLog
                printf(ss);
            #endif 
        }
    
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EALong::execute(EAEnum action) {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("execute -> ....");
        writeLog
        printf(ss);
    #endif

    bool retValue=false;

    if (ACTIVE_HEDGE==_YES) {
        #ifdef _DEBUG_LONG
            ss="execute -> In L Hedge is active ....";
            writeLog
            printf(ss);
        #endif   
        return retValue;
    }


    switch (action) {
        case _RUN_ONTICK:   closeOnStealthProfit();
                            closeOnStealthLoss();
                            updateOnInterval(_RUN_ONTICK);
        break;
        case _RUN_ONBAR:    closeOnFixedTiming();
                            updateOnInterval(_RUN_ONBAR);
        break;
        case _RUN_ONDAY:    updateOnInterval(_RUN_ONDAY);
        break;
        case _OPEN_LONG:    retValue=newPosition();
        break;
    }
    
    return retValue;

}

