//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_LONG 

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
        Print (__FUNCTION__);
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

//----
    #ifdef _DEBUG_LONG 
    Print (__FUNCTION__); 
    #endif  
  //----

    
        if (interval==_RUN_ONBAR||interval==_RUN_ONTICK) {
            for (int i=0;i<longPositions.Total();i++) {
                glp;
                p.calcPositionPnL();
                #ifdef _DEBUG_LONG
                    printf("L,%d,%g",p.ticket,p.currentPnL);
                #endif 
            }
        }


        if (interval==_RUN_ONDAY) {
            for (int i=0;i<longPositions.Total();i++) {
                glp;
                p.daysOpen++; 
                p.calcPositionSwapCost();
                #ifdef _DEBUG_LONG
                    printf("L,%d,%d,%g",p.ticket,p.daysOpen,p.swapCosts);
                #endif 
            }
        
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALong::closeOnFixedTiming() {

    //----
    #ifdef _DEBUG_LONG 
    Print(__FUNCTION__); string ss; 
    #endif
   //----  
    for (int i=0;i<longPositions.Total();i++) {
        glp; 

        //----
        #ifdef _DEBUG_LONG
            if (p.closingTypes&_CLOSE_AT_EOD&&usp.maxDailyHold>=0) {
                ss=StringFormat(" -> Long position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                Print (ss);
            }
        #endif
        //----

        if (p.closingDateTime<TimeCurrent() && usp.maxDailyHold>=0 && bool(p.closingTypes&_CLOSE_AT_EOD)) {    // Check when current date exceeded future date hence due date passed
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                //----
                #ifdef _DEBUG_LONG 
                    Print (" -> Long Close EOD"); 
                #endif
                //----
                closeSQLPosition(p);
                if (longPositions.Delete(i)) {
                    #ifdef _DEBUG_LONG 
                        Print (" -> Long Close at EOD removed from CList"); 
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

    //----
    #ifdef _DEBUG_LONG 
        Print (__FUNCTION__); 
        string ss;
    #endif  
  //----
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
                        Print (" -> Long Close in profit"); 
                    #endif
                        closeSQLPosition(p);
                    if (longPositions.Delete(i)) {
                        #ifdef _DEBUG_LONG 
                            Print (" -> Long Close in profit object removed from CList"); 
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

    //----
    #ifdef _DEBUG_LONG 
        Print (__FUNCTION__);
        string ss; 
    #endif  
  //----

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
                        ss=StringFormat("-> Total long after move:%d",longPositions.Total());
                        Print (ss);
                        ss=StringFormat("-> Total mg after move:%d",martingalePositions.Total());
                        Print (ss);
                    #endif
                    return;
                } else {                                                                    // Normal close in loss
                    if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                        //----
                        #ifdef _DEBUG_LONG 
                            Print (" -> Long Close in loss"); 
                        #endif
                        closeSQLPosition(p);
                        if (longPositions.Delete(i)) {
                            #ifdef _DEBUG_LONG 
                            Print (" -> Long Close in profit object removed from CList"); 
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

    //----
    #ifdef _DEBUG_LONG 
        string ss;
        Print (__FUNCTION__); 
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            ss=StringFormat(" -> T:%d S:%d",p.ticket,p.status);
            Print(ss);
        }
    #endif  
  //----


        if (longPositions.Total()>=usp.maxLong) {
            //showPanel mp.updateInfo2Value(16,StringFormat("%d Maximum Reached",param.maxPositionsLong));
            // ----
            #ifdef _DEBUG_LONG
                Print (" -> Max number of LONG reached");
            #endif 
            // ----
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
                    Print(" -> New position opened and added to long positions list"); 
                #endif 
                return true;
            }            
        } else {
            #ifdef _DEBUG_LONG
                Print(" -> New position opened failed"); 
            #endif 
        }
    
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EALong::execute(EAEnum action) {

    

    //----
    #ifdef _DEBUG_LONG 
        Print (__FUNCTION__);
        string ss; 
    #endif  

    bool retValue=false;


    if (ACTIVE_HEDGE==_YES) {
        #ifdef _DEBUG_LONG
            Print(" -> In L Hedge is active ....");
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

