//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


//#define _DEBUG_SHORT
#include "EAEnum.mqh"
#include "EAPosition.mqh"
#include "EAPositionBase.mqh"


class EAShort : public EAPositionBase {

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
EAShort();
~EAShort();

    virtual int Type() const {return _SHORT;};


    virtual bool    execute(EAEnum action);  

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAShort::EAShort() {

    #ifdef _DEBUG_SHORT
        Print (__FUNCTION__);
    #endif 


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAShort::~EAShort() {

    //closeCSVFile(fileHandle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAShort::updateOnInterval(EAEnum interval) {

//----
    #ifdef _DEBUG_SHORT 
    Print (__FUNCTION__); 
    #endif  
  //----

    
        if (interval==_RUN_ONBAR||interval==_RUN_ONTICK) {
            for (int i=0;i<shortPositions.Total();i++) {
                gsp;
                p.calcPositionPnL();
                #ifdef _DEBUG_LONG
                    printf("S,%d,%g",p.ticket,p.currentPnL);
                #endif 
            }
        }


        if (interval==_RUN_ONDAY) {
            for (int i=0;i<shortPositions.Total();i++) {
                gsp;
                p.daysOpen++; 
                p.calcPositionSwapCost();
                #ifdef _DEBUG_LONG
                    printf("S,%d,%d,%g",p.ticket,p.daysOpen,p.swapCosts);
                #endif 
            }
        }
    
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAShort::closeOnFixedTiming() {

    //----
    #ifdef _DEBUG_SHORT 
    Print(__FUNCTION__); string ss; 
    #endif
   //----  
    for (int i=0;i<shortPositions.Total();i++) {
        gsp; 
        //----
        #ifdef _DEBUG_SHORT
            if (p.closingTypes&_CLOSE_AT_EOD&&usp.maxDailyHold>=0) {
                ss=StringFormat(" -> Short position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                Print (ss);
            }
        #endif
        //----

        if (p.closingDateTime<TimeCurrent() && usp.maxDailyHold>=0 && bool(p.closingTypes&_CLOSE_AT_EOD)) {    // Check when current date exceeded future date hence due date passed
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                //----
                #ifdef _DEBUG_SHORT 
                    Print (" -> Short Close EOD"); 
                #endif
                //----
                closeSQLPosition(p);
                if (shortPositions.Delete(i)) {
                    #ifdef _DEBUG_SHORT 
                        Print (" -> Short Close at EOD removed from CList"); 
                    #endif                       
                }
            } 
        }
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAShort::closeOnStealthProfit() {

    //----
    #ifdef _DEBUG_SHORT 
        Print (__FUNCTION__); 
        string ss;
    #endif  
  //----
    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inProfit;

    for (int i=0;i<shortPositions.Total();i++) {
        gsp; 
        p.calcPositionPnL();

        if (last_tick.bid<p.fixedProfitTargetLevel)  {inProfit=true;};
        if (last_tick.bid>p.fixedProfitTargetLevel)  {inProfit=false;}; 

        if (bool (p.closingTypes&_IN_PROFIT_CLOSE_POSITION)) {  
            if (inProfit) {
                if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                //----
                    #ifdef _DEBUG_SHORT 
                        Print (" -> Short Close in profit"); 
                    #endif
                    closeSQLPosition(p);
                    if (shortPositions.Delete(i)) {
                        #ifdef _DEBUG_SHORT 
                            Print (" -> Short Close in profit object removed from CList"); 
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
void EAShort::closeOnStealthLoss() {

    //----
    #ifdef _DEBUG_SHORT 
        Print (__FUNCTION__);
        string ss; 
    #endif  
  //----

    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inLoss;

    for (int i=0;i<shortPositions.Total();i++) {
        gsp; 
        if (last_tick.bid>p.fixedLossTargetLevel)    {inLoss=true;};
        if (last_tick.bid<p.fixedLossTargetLevel)    {inLoss=false;};

        if (bool (p.closingTypes&_IN_LOSS_CLOSE_POSITION)) {
            if (inLoss) {
                /*
                if (p.closingTypes&_IN_LOSS_OPEN_MARTINGALE) {                    // Martingale close in "loss"
                    //Create a copy of the postion to be copied over to martingalePositions
                    // this method used because CLish detach does not work as expected
                    EAPosition *np=new EAPosition(p);       // Create new with copy constructor called
                    martingalePositions.Add(np);            // add to mg list
                    shortPositions.DeleteCurrent();          // delete from current lp list
                    #ifdef _DEBUG_SHORT 
                        ss=StringFormat("-> Total long after move:%d",shortPositions.Total());
                        Print (ss);
                        ss=StringFormat("-> Total mg after move:%d",martingalePositions.Total());
                        Print (ss);
                    #endif
                    return;
                } else {  
                    */                                                                  // Normal close in loss
                    if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                        //----
                        #ifdef _DEBUG_SHORT 
                            Print (" -> Short Close in loss"); 
                        #endif
                        closeSQLPosition(p);
                        if (shortPositions.Delete(i)) {
                            #ifdef _DEBUG_SHORT 
                            Print (" -> Short Close in profit object removed from CList"); 
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
bool EAShort::newPosition() {

    //----
    #ifdef _DEBUG_SHORT 
        string ss;
        Print (__FUNCTION__); 
        for (int i=0;i<shortPositions.Total();i++) {
            gsp;
            ss=StringFormat(" -> T:%d S:%d",p.ticket,p.status);
            Print(ss);
        }
    #endif  
  //----


        if (shortPositions.Total()>=usp.maxShort) {
            // ----
            #ifdef _DEBUG_SHORT
                Print (" -> Max number of SHORT reached");
            #endif 
            // ----
            return false;
        }                     

        // Build a new position object based on defaults
        EAPosition *p=new EAPosition();                     // Create new position object
        p.strategyNumber=usp.strategyNumber;              // copy over strategy defaults
        p.lotSize=usp.lotSize;
        p.status=_SHORT;
        p.entryPrice=getUpdatedPrice(ORDER_TYPE_SELL,_TOOPEN);
        p.orderTypeToOpen=ORDER_TYPE_SELL;                   // type is a SHORT
        p.closingTypes=usp.closingTypes;
        p.fixedProfitTargetLevel=p.entryPrice-usp.fpts;  
        p.fixedLossTargetLevel=p.entryPrice-usp.flts; 
    

        if (openPosition(p)) {
            if (shortPositions.Add(p)!=-1) {
                #ifdef _DEBUG_SHORT
                    Print(" -> New position opened and added to short positions list"); 
                #endif 
                return true;
            }            
        } else {
            #ifdef _DEBUG_SHORT
                Print(" -> New position opened failed"); 
            #endif 
        }
    

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAShort::execute(EAEnum action) {

    //----
    #ifdef _DEBUG_SHORT 
        Print (__FUNCTION__);
        string ss; 
    #endif  

    bool retValue=false;


    if (ACTIVE_HEDGE==_YES) {
        #ifdef _DEBUG_SHORT
            Print(" -> In S Hedge is active ....");
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
        case _OPEN_SHORT:    retValue=newPosition();
        break;
    }
    
    return retValue;

}