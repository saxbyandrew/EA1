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

    void    updatesOnInterval(EAEnum interval);
    void    closeOnFixedTiming();
    void    closeOnStealthProfit(EAPosition &p);
    void    closeOnStealthLoss(EAPosition &p);
    bool    newPosition();
    void    copyValuesFromOptimizationInputs();
    
//=========
public:
//=========
EAPositionLong();
~EAPositionLong();

    Strategy strategy; // See EAStructures.mqh

    virtual int     Type() const {return _LONG;};
    virtual void    execute(EAEnum action);  

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionLong::EAPositionLong(int strategyNumber) {

    



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionLong::~EAPositionLong() {


}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::updatesOnInterval(EAEnum interval) {

    #ifdef _DEBUG_LONG_RUN_LOOP 
        ss=StringFormat("EAPositionLong -> updatesOnInterval -> %d",interval);
        writeLog
        pss
    #endif

    // Manage the number of positions which can be opened within the stategy determined interval
    if (interval==_RUN_ONBAR) {
        closeOnFixedTiming();
        if (reentryBarCountdown(_COUNT)) {
            #ifdef _DEBUG_LONG_RUN_LOOP
                ss="EAPositionLong -> updatesOnInterval count down in progress";
                writeLog
                pss
            #endif
        }; 
    }

    // Manage and calculate position $$ amounts
    if (interval==_RUN_ONTICK) {

        for (int i=0;i<longPositions.Total();i++) {
            glp;

            p.calcPositionPnL();
            closeOnStealthLoss(p);
            closeOnStealthProfit(p);

            #ifdef _DEBUG_LONG_RUN_LOOP 
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
            #ifdef _DEBUG_LONG_RUN_LOOP 
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

    #ifdef _DEBUG_LONG_RUN_LOOP 
        ss="EAPositionLong -> closeOnFixedTiming -> ....";
        writeLog
        pss
    #endif

    for (int i=0;i<longPositions.Total();i++) {
        glp; 

        #ifdef _DEBUG_LONG_RUN_LOOP 
            if (p.closeAtEOD && strategy.maxDailyHold>=0) {
                ss=StringFormat("EAPositionLong -> closeOnFixedTiming -> Long position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                writeLog
                Print (ss);
            }
        #endif

        if (p.closingDateTime<TimeCurrent() && strategy.maxDailyHold>=0 && p.closeAtEOD) {    // Check when current date exceeded future date hence due date passed
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
                #ifdef _DEBUG_LONG_RUN_LOOP  
                    ss="EAPositionLong -> closeOnFixedTiming -> Long Close EOD"; 
                    writeLog
                    pss
                #endif
                closeSQLPosition(p);
                if (longPositions.Delete(i)) {
                    #ifdef _DEBUG_LONG_RUN_LOOP  
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
void EAPositionLong::closeOnStealthProfit(EAPosition &p) {


    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inProfit;

    if (last_tick.bid>p.fixedProfitTargetLevel)  {inProfit=true;};
    if (last_tick.bid<p.fixedProfitTargetLevel)  {inProfit=false;}; 

    if (p.inProfitClosePosition) {                       
        if (inProfit) {
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
            //----
                #ifdef _DEBUG_LONG_RUN_LOOP  
                    ss="EAPositionLong -> closeOnStealthProfit -> Long Close in profit"; 
                    writeLog
                    pss
                #endif
                    closeSQLPosition(p);
                if (longPositions.Delete(i)) {
                    #ifdef _DEBUG_LONG_RUN_LOOP  
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::closeOnStealthLoss(EAPosition &p) {


    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inLoss;

        
    if (last_tick.bid<p.fixedLossTargetLevel)    {inLoss=true;};
    if (last_tick.bid>p.fixedLossTargetLevel)    {inLoss=false;};

    if (p.inLossClosePosition) {
        if (inLoss) {
            if (p.inLossOpenMartingale&&martingalePositions.Total()<strategy.maxMg) {                    // Martingale close in "loss"
                //Create a copy of the postion to be copied over to martingalePositions
                // this method used because CList detach does not work as expected
                EAPosition *np=new EAPosition(p);       // Create new with copy constructor called
                martingalePositions.Add(np);            // add to mg list
                longPositions.DeleteCurrent();          // delete from current lp list
                #ifdef _DEBUG_LONG_RUN_LOOP  
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
                    #ifdef _DEBUG_LONG_RUN_LOOP  
                        ss="EAPositionLong -> closeOnStealthLoss -> Long Close in loss"; 
                        writeLog
                        pss
                    #endif
                    closeSQLPosition(p);
                    if (longPositions.Delete(i)) {
                        #ifdef _DEBUG_LONG_RUN_LOOP  
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAPositionLong::newPosition() {

    #ifdef _DEBUG_LONG 
        string ss;
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            ss=StringFormat("EAPositionLong -> newPosition -> Ticket:%d Status:%d",p.ticket,p.status);
            writeLog
            pss;
        }
    #endif  

    // Manage the number of positions which can be opened within a stategy determined interval
    if (reentryBarCountdown(_CHECK)) {
        #ifdef _DEBUG_LONG
            ss="EAPositionLong -> NewPosition bar count=0 allow new position";
            pss
            writeLog
        #endif

        if (longPositions.Total()>=strategy.maxPositions) {     // Monitor max position for entire strategy
            #ifdef _RUN_PANEL
                showPanel ip.updateInfoLabel(17,0,StringFormat("%d Maximum Reached",strategy.maxPositions));
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
                showPanel ip.updateInfoLabel(17,1,strategy.maxPositions);
            #endif
        }                    

        // Build a new position object based on strategy defaults
        EAPosition *p=new EAPosition(strategy.strategyNumber);     
        p.orderTypeToOpen=ORDER_TYPE_BUY;
        p.status=_LONG;  


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
                ss="EAPositionLong -> newPosition -> New position opened failed"; 
                writeLog
                pss
            #endif 
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionLong::execute(EAEnum action) {


    if (ACTIVE_HEDGE==_YES) {
        #ifdef _DEBUG_LONG_RUN_LOOP 
            ss="EAPositionLong -> execute -> In L Hedge is active ....";
            writeLog
            pss
        #endif   
        return;
    }

    switch (action) {
        case _RUN_ONTICK:   updatesOnInterval(_RUN_ONTICK);
        break;
        case _RUN_ONBAR:    updatesOnInterval(_RUN_ONBAR);
        break;
        case _RUN_ONDAY:    updatesOnInterval(_RUN_ONDAY);
        break;
        case _OPEN_LONG:    {
                if (newPosition()) {
                    if (reentryBarCountdown(_START)) {
                        #ifdef _DEBUG_LONG
                            ss="EAPositionLong -> execute -> starting bar count down after new position OPEN ";
                            writeLog
                            pss
                        #endif
                    }    // New position open SUCCESS now start the counter
                }
                #ifdef _DEBUG_LONG
                    ss="EAPositionLong -> execute -> _OPEN_LONG:";
                    writeLog
                    pss
                #endif
        }
        break;
    }
    
}

