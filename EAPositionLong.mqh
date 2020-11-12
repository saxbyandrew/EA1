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


class EAPositionLong : public EAPositionBase {

//=========
private:
//=========
    string ss;

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
EAPositionLong();
~EAPositionLong();

    Position position; // See EAStructures.mqh

    virtual int     Type() const {return _LONG;};
    virtual void    execute(EAEnum action);  

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionLong::EAPositionLong() {

    #ifdef _DEBUG_LONG
        printf ("EAPositionLong ->  Object Created ....");
        writeLog
        pss
    #endif

    int request=DatabasePrepare(_mainDBHandle,"SELECT strategyNumber,lotSize,fpt,flt,maxPositions,maxDailyHold,maxMg FROM STRATEGY WHERE isActive=1");
    if (!DatabaseRead(request)) {
        ss=StringFormat(" -> EAPositionLong DatabaseRead DB request failed code:%d",GetLastError()); 
        pss
        writeLog
        ExpertRemove();
    } else {
        #ifdef _DEBUG_LONG
        ss="  -> EAPositionLong DatabaseRead -> SUCCESS";
        writeLog
        pss
        #endif 
    }

    DatabaseColumnInteger   (request,0,position.strategyNumber);
    DatabaseColumnDouble    (request,1,position.lotSize);
    DatabaseColumnDouble    (request,2,position.fpt);
    DatabaseColumnDouble    (request,3,position.flt);
    DatabaseColumnInteger   (request,4,position.maxPositions);
    DatabaseColumnInteger   (request,5,position.maxDailyHold);
    DatabaseColumnInteger   (request,6,position.maxMg);

    #ifdef _DEBUG_LONG
        ss=StringFormat("EAPositionLong -> StrategyNumber:%d lotSize:%2.2f fptl:%2.2f maxPositions:%d",position.strategyNumber,position.lotSize,position.fpt,position.maxPositions);
        writeLog
        pss
    #endif 


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionLong::~EAPositionLong() {


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::updateOnInterval(EAEnum interval) {

    #ifdef _DEBUG_LONG
        ss=StringFormat("EAPositionLong -> updateOnInterval -> %d",interval);
        writeLog
        pss
    #endif

    
    if (interval==_RUN_ONBAR||interval==_RUN_ONTICK) {
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            p.calcPositionPnL();
            #ifdef _DEBUG_LONG
                ss=StringFormat("EAPositionLong -> ONBAR and ONTICK -> %d,%g",p.ticket,p.currentPnL);
                writeLog
                pss
            #endif 
        }
    }


    if (interval==_RUN_ONDAY) {
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            p.daysOpen++; 
            p.calcPositionSwapCost();
            #ifdef _DEBUG_LONG
                ss=StringFormat("EAPositionLong -> ONDAY -> %d,%d,%g",p.ticket,p.daysOpen,p.swapCosts);
                writeLog
                pss
            #endif 
        }      
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::closeOnFixedTiming() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("EAPositionLong -> closeOnFixedTiming -> ....");
        writeLog
        pss
    #endif


    for (int i=0;i<longPositions.Total();i++) {
        glp; 

        //----
        #ifdef _DEBUG_LONG
            if (p.closingTypes&_CLOSE_AT_EOD&&position.maxDailyHold>=0) {
                ss=StringFormat("EAPositionLong -> closeOnFixedTiming -> Long position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                writeLog
                Print (ss);
            }
        #endif
        //----

        if (p.closingDateTime<TimeCurrent() && position.maxDailyHold>=0 && bool(p.closingTypes&_CLOSE_AT_EOD)) {    // Check when current date exceeded future date hence due date passed
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                //----
                #ifdef _DEBUG_LONG 
                    ss="EAPositionLong -> closeOnFixedTiming -> Long Close EOD"; 
                    writeLog
                    pss
                #endif
                //----
                closeSQLPosition(p);
                if (longPositions.Delete(i)) {
                    #ifdef _DEBUG_LONG 
                        ss="EAPositionLong -> closeOnFixedTiming -> Long Close at EOD removed from CList"; 
                        writeLog
                        pss
                    #endif                      
                }
            } 
        }
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::closeOnStealthProfit() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("EAPositionLong -> closeOnStealthProfit -> ....");
        writeLog
        pss
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
                        ss="EAPositionLong -> closeOnStealthProfit -> Long Close in profit"; 
                        writeLog
                        pss
                    #endif
                        closeSQLPosition(p);
                    if (longPositions.Delete(i)) {
                        #ifdef _DEBUG_LONG 
                            ss="EAPositionLong -> closeOnStealthProfit -> Long Close in profit object removed from CList"; 
                            writeLog
                            pss
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
void EAPositionLong::closeOnStealthLoss() {

    #ifdef _DEBUG_LONG
        string ss;
        printf ("EAPositionLong -> closeOnStealthLoss -> ....");
        writeLog
        pss
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
                if (p.closingTypes&_IN_LOSS_OPEN_MARTINGALE&&martingalePositions.Total()<position.maxMg) {                    // Martingale close in "loss"
                    //Create a copy of the postion to be copied over to martingalePositions
                    // this method used because CList detach does not work as expected
                    EAPosition *np=new EAPosition(p);       // Create new with copy constructor called
                    martingalePositions.Add(np);            // add to mg list
                    longPositions.DeleteCurrent();          // delete from current lp list
                    #ifdef _DEBUG_LONG 
                        ss=StringFormat("EAPositionLong -> closeOnStealthLoss -> Total long after move:%d",longPositions.Total());
                        writeLog
                        Print (ss);
                        ss=StringFormat("EAPositionLong -> closeOnStealthLoss -> Total mg after move:%d",martingalePositions.Total());
                        writeLog
                        Print (ss);
                    #endif
                    return;
                } else {                                                                    // Normal close in loss
                    if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                        //----
                        #ifdef _DEBUG_LONG 
                            ss="EAPositionLong -> closeOnStealthLoss -> Long Close in loss"; 
                            writeLog
                            pss
                        #endif
                        closeSQLPosition(p);
                        if (longPositions.Delete(i)) {
                            #ifdef _DEBUG_LONG 
                                ss="EAPositionLong -> closeOnStealthLoss -> Long Close in profit object removed from CList";
                                writeLog
                                pss 
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
bool EAPositionLong::newPosition() {

    #ifdef _DEBUG_LONG 
        string ss;
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            ss=StringFormat("EAPositionLong -> newPosition -> T:%d S:%d",p.ticket,p.status);
            writeLog
            Print(ss);
        }
    #endif  


        if (longPositions.Total()>=position.maxPositions) {
            #ifdef _RUN_PANEL
                showPanel ip.updateInfoLabel(17,0,StringFormat("%d Maximum Reached",position.maxPositions));
            #endif
            #ifdef _DEBUG_LONG
                ss="EAPositionLong -> newPosition -> Max number of LONG reached";
                writeLog
                pss
            #endif 
            return false;
        } else {
            #ifdef _RUN_PANEL
                showPanel ip.updateInfoLabel(17,0,"Open Long");
                showPanel ip.updateInfoLabel(17,1,position.maxPositions);
            #endif
        }                    

        // Build a new position object based on defaults
        EAPosition *p=new EAPosition();                     // Create new position object
        p.strategyNumber=position.strategyNumber;              // copy over strategy defaults
        p.lotSize=position.lotSize;
        p.status=_LONG;
        p.entryPrice=getUpdatedPrice(ORDER_TYPE_BUY,_TOOPEN);
        p.orderTypeToOpen=ORDER_TYPE_BUY;                   // type is a LONG
        p.closingTypes=position.closingTypes;
        p.fixedProfitTargetLevel=p.entryPrice+position.fpt;  
        p.fixedLossTargetLevel=p.entryPrice+position.flt; 

        if (openPosition(p)) {
            if (longPositions.Add(p)!=-1) {
                #ifdef _DEBUG_LONG
                    ss="EAPositionLong -> newPosition -> New position opened and added to long positions list"; 
                    writeLog
                    pss
                    ss=StringFormat("EAPositionLong -> strategyNumber:%d lotSize:%.2f status:%s entryPrice:%.2f fixedProfitTargetLevel:%.2f fixedLossTargetLevel:%.2f",
                    p.strategyNumber,p.lotSize,EnumToString(p.status),p.entryPrice,p.fixedProfitTargetLevel,p.fixedLossTargetLevel);
                    writeLog
                    pss
                #endif 
                return true;
            }            
        } else {
            #ifdef _DEBUG_LONG
                Print("EAPositionLong -> newPosition -> New position opened failed"); 
                writeLog
                pss
            #endif 
        }
    
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::execute(EAEnum action) {

    #ifdef _DEBUG_LONG
        ss="EAPositionLong -> execute -> ....";
        writeLog
        pss
    #endif

    if (ACTIVE_HEDGE==_YES) {
        #ifdef _DEBUG_LONG
            ss="EAPositionLong -> execute -> In L Hedge is active ....";
            writeLog
            pss
        #endif   
        return;
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
        case _OPEN_LONG:    {
                newPosition();
                #ifdef _DEBUG_LONG
                    ss="EAPositionLong -> execute -> _OPEN_LONG:";
                    writeLog
                    pss
                #endif
        }
        break;
    }
    
}

