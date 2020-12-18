//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>

#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

#include "EAEnum.mqh"
#include "EAPosition.mqh"
#include "EATiming.mqh"
#include "EATechnicalParameters.mqh"


class EAStrategyLong : public CObject {

//=========
private:
//=========
    string ss;
    EATiming                *timing;
    EATechnicalParameters   *tech;

    void        copyValuesFromOptimizationInputs();
    void        updateValuesToDatabase(string sql);
    void        closeSQLPosition(EAPosition &p);
    void        updateSQLSwapCosts(EAPosition &p);
    bool        checkQuantities(EAEnum interval);
    double      getUpdatedPrice(ENUM_ORDER_TYPE orderType, EAEnum positionOpenClose);
    bool        accountInfoChecks();
    bool        openPosition(EAPosition &p);
    
    void        closeOnFixedTiming();
    void        closeOnStealthProfit(EAPosition &p, int idx);
    bool        closeOnStealthLoss(EAPosition &p, int idx);
    void        newPosition();


//=========
protected:
//=========
    
    CAccountInfo        AccountInfo;
    CTrade              Trade;
    CPositionInfo       PositionInfo;
    CSymbolInfo         SymbolInfo;
    Strategy            strategy;     // See EAStructures.mqh




//=========
public:
//=========
EAStrategyLong(int strategyNumber);
~EAStrategyLong();

    virtual int     Type() const {return _POSITION_BASE;};
    virtual void    execute(EAEnum action);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyLong::EAStrategyLong(int strategyNumber) {

    #ifdef _DEBUG_LONG_POSITIONS
        ss=StringFormat("EAStrategyLong -> DEFAULT CONSTRUCTOR -> strategyNumber:%d",strategyNumber);
        writeLog
        pss
    #endif

      // Create the new Technincals object(s) which in this case is the actual strategy run based on 
   // technical triggers
   tech=new EATechnicalParameters(strategyNumber); // Using the base ref as this is the main strategy
    if (CheckPointer(tech)==POINTER_INVALID) {
        #ifdef _DEBUG_LONG_STRATEGY
            ss="EAStrategyLong -> ERROR created technical object";
            writeLog
            pss
        #endif
    ExpertRemove();
    } else {
        #ifdef _DEBUG_LONG_STRATEGY
        ss="EAStrategyLong -> SUCCESS created technical object";
        writeLog
        pss
    #endif
    }

    string sql=StringFormat("SELECT * FROM STRATEGY WHERE strategyNumber=%d",strategyNumber);
    int request=DatabasePrepare(_mainDBHandle,sql);
    if (!DatabaseRead(request)) {
        ss=StringFormat("EAStrategyLong -> DatabaseRead DB request failed code:%d",GetLastError()); 
        pss
        writeLog
        ExpertRemove();
    } else {
        #ifdef _DEBUG_LONG_POSITIONS
        ss="EAStrategyLong -> DatabaseRead -> SUCCESS";
        writeLog
        pss
        #endif 
    }

    DatabaseColumnInteger   (request,0,strategy.isActive);
    DatabaseColumnInteger   (request,1,strategy.strategyNumber);
    DatabaseColumnInteger   (request,2,strategy.magicNumber);
    DatabaseColumnInteger   (request,3,strategy.deviationInPoints);
    DatabaseColumnInteger   (request,4,strategy.maxSpread);
    DatabaseColumnInteger   (request,5,strategy.entryBars);
    DatabaseColumnDouble    (request,6,strategy.brokerAdminPercent);
    DatabaseColumnDouble    (request,7,strategy.interBankPercentage);
    DatabaseColumnInteger   (request,8,strategy.inProfitClosePosition);
    DatabaseColumnInteger   (request,9,strategy.inLossClosePosition);
    DatabaseColumnInteger   (request,10,strategy.inLossOpenMartingale);
    DatabaseColumnInteger   (request,11,strategy.inLossOpenLongHedge);
    DatabaseColumnInteger   (request,12,strategy.closeAtEOD);
    DatabaseColumnDouble    (request,13,strategy.lotSize);
    DatabaseColumnDouble    (request,14,strategy.fpt);
    DatabaseColumnDouble    (request,15,strategy.flt);
    DatabaseColumnInteger   (request,16,strategy.maxPositions);
    DatabaseColumnInteger   (request,17,strategy.maxDaily);
    DatabaseColumnInteger   (request,18,strategy.maxDailyHold);
    DatabaseColumnInteger   (request,19,strategy.maxMg);
    DatabaseColumnDouble    (request,20,strategy.mgMultiplier);
    DatabaseColumnDouble    (request,21,strategy.hedgeLossAmount);
    DatabaseColumnDouble    (request,22,strategy.swapCosts);
    DatabaseColumnInteger   (request,23,strategy.runMode);
    DatabaseColumnInteger   (request,24,strategy.versionNumber);



    // Over write with values given to us during optimization
    if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) {
        copyValuesFromOptimizationInputs();  
        #ifdef _DEBUG_LONG_POSITIONS
            ss="EAStrategyLong -> in MQL_OPTIMIZATION OR MQL_TESTER MODE copy INPUT values";
            writeLog
            pss
        #endif
        
    } else {
        #ifdef _DEBUG_LONG_POSITIONS

            ss="EAStrategyLong -> Using values directly from the DB";
            writeLog
            pss

        #endif
    }
    
    #ifdef _DEBUG_LONG_POSITIONS
        ss=StringFormat("EAStrategyLong -> StrategyNumber:%d magicNumber:%2.2f deviationInPoints:%2.2f maxLong:%d maxDaily:%d versionNumber:%d closeATEOD:%d",
            strategy.strategyNumber,strategy.magicNumber,strategy.deviationInPoints,strategy.maxPositions,strategy.maxDaily,strategy.versionNumber, strategy.closeAtEOD);
        writeLog
        pss
    #endif 

    timing=new EATiming(strategy.strategyNumber);                                                                            
    if (CheckPointer(timing)==POINTER_INVALID) {
        #ifdef _DEBUG_LONG_POSITIONS
            ss="EAStrategyLong -> Error instantiating TIMING object";
            writeLog
            pss
        #endif 
        ExpertRemove();
    } 

    Trade.SetAsyncMode(false);     
    Trade.SetExpertMagicNumber(strategy.magicNumber);            
    Trade.SetDeviationInPoints(strategy.deviationInPoints);  

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyLong::~EAStrategyLong() {

    delete tech;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::copyValuesFromOptimizationInputs() {

    #ifdef _DEBUG_LONG_POSITIONS
        pline
        ss="EAStrategyLong -> copyValuesFromOptimizationInputs";
        writeLog
        pss
        pline
    #endif

    strategy.lotSize=ilsize;
    strategy.fpt=ifpt;
    strategy.flt=iflt;
    strategy.maxPositions=imaxPositions;
    strategy.maxDailyHold=imaxdailyhold;
    strategy.maxMg=imaxmg;
    strategy.maxDaily=imaxdaily;

       // If we are running a single tester line then update the DB
    if (MQLInfoInteger(MQL_TESTER)) {
        strategy.versionNumber++;
        string sql=StringFormat("UPDATE STRATEGY SET lotSize=%.2f, fpt=%.2f, flt=%.2f, maxPositions=%d, maxDailyHold=%d, maxMg=%d, maxDaily=%d, versionNumber=%d "
            "WHERE strategyNumber=%d",
            strategy.lotSize, strategy.fpt,strategy.flt, strategy.maxPositions, strategy.maxDailyHold, strategy.maxMg, strategy.maxDaily, strategy.versionNumber, strategy.strategyNumber);
        updateValuesToDatabase(sql);
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::updateValuesToDatabase(string sql) {

    if (!DatabaseExecute(_mainDBHandle, sql)) {
        ss=StringFormat("copyValuesToDatabase -> Failed to insert with code %d", GetLastError());
        pss
        ss=sql;
        pss
        writeLog
    } else {
        #ifdef _DEBUG_LONG_POSITIONS
            ss="copyValuesToDatabase -> UPDATE succcess";
            pss
            ss=sql;
            pss
        #endif
    }  
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::execute(EAEnum interval) {

    static int reentryBarCountdown=0;


// Manage and calculate position $$ amounts
    if (interval==_RUN_ONTICK) {
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            p.calcPositionPnL();
            if(closeOnStealthLoss(p,i)) continue;   // Dont check for profit if p closed in loss p=null !
            closeOnStealthProfit(p,i);

            //#ifdef _DEBUG_LONG 
                //ss=StringFormat("EAStrategyLong -> ONBAR and ONTICK -> Ticket:%d PnL:%g",p.ticket,p.currentPnL);
                //writeLog
                //pss
            //#endif 
        }
    }

    // Manage the number of positions which can be opened within the stategy determined interval
    if (interval==_RUN_ONBAR) {

        // Close positions regardless of PnL after a specified time 
        closeOnFixedTiming();   
        
        // Always run the actual strategy
        if (tech.execute(_RUN_ONBAR)==_OPEN_NEW_POSITION) {
            #ifdef _DEBUG_LONG_POSITIONS 
                ss="EAStrategyLong -> execute -> recieved _OPEN_NEW_POSITION";
                writeLog
                pss
            #endif
            // check delay counter between position openings
            if (reentryBarCountdown==0) {
                #ifdef _DEBUG_LONG_POSITIONS 
                    ss="EAStrategyLong -> execute -> recieved reentryBarCountdown==0";
                    writeLog
                    pss
                #endif
                if (checkQuantities(interval) && timing.tradingTimes()) {
                    newPosition();
                    reentryBarCountdown=strategy.entryBars;
                }
            }
        }  
        // Manange the counter
        if (reentryBarCountdown>0) {
            #ifdef _DEBUG_LONG_POSITIONS 
                ss=StringFormat("EAStrategyLong -> execute -> recieved reentryBarCountdown:%d",reentryBarCountdown);
                writeLog
                pss
            #endif
            --reentryBarCountdown;
        }
    }
    
    if (interval==_RUN_ONDAY) {
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            p.daysOpen++; 
            p.calcPositionSwapCost();
            #ifdef _DEBUG_LONG_POSITIONS 
                ss=StringFormat("EAStrategyLong -> ONDAY -> %d,%d,%g",p.ticket,p.daysOpen,p.swapCosts);
                writeLog
                pss
            #endif 
        }  

        // Reset quatities counters after a new day
        checkQuantities(interval);    
    }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::closeSQLPosition(EAPosition &p) {

    #ifdef _DEBUG_LONG_POSITIONS
        ss=StringFormat("EAStrategyLong -> closeSQLPosition ticket:%d",p.ticket);
        writeLog
    #endif

    updateSQLSwapCosts(p);

    string sql=StringFormat("DELETE FROM STATE WHERE ticket=%d",p.ticket);
    if (!DatabaseExecute(_mainDBHandle,sql)) {
        #ifdef _DEBUG_LONG_POSITIONS
            string ss=StringFormat("EAStrategyLong -> closeSQLPosition DB request failed with code ", GetLastError());
            writeLog;
        #endif
    }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::updateSQLSwapCosts(EAPosition &p) {

    double swapCosts;

    if (p.swapCosts==0) return;     // No update if we have zero costs

    if (MQLInfoInteger(MQL_OPTIMIZATION))  return;   // No state saving during optimizations

    string sql=StringFormat("SELECT swapCosts FROM STRATEGY WHERE strategyNumber=%d",strategy.strategyNumber);
    int request=DatabasePrepare(_mainDBHandle,sql); 
    DatabaseRead(request);
    DatabaseColumnDouble(request,0,swapCosts); 

    #ifdef _DEBUG_LONG_POSITIONS
        ss=StringFormat("EAStrategyLong -> updateSQLSwapCosts  total swap costs todate:%.2f",swapCosts);
        writeLog
    #endif


    // Bump the swap costs
    double result=swapCosts+p.swapCosts;
    TesterWithdrawal(p.swapCosts);  // withdraw from account when testing

    // Update DB
    sql=StringFormat("UPDATE STRATEGY SET swapCosts=%.2f WHERE strategyNumber=%d",result, strategy.strategyNumber);
    if (!DatabaseExecute(_mainDBHandle,sql)) {
        #ifdef _DEBUG_LONG_POSITIONS
            ss=sql;
            writeLog
            string ss=StringFormat("EAStrategyLong -> updateSQLSwapCosts DB request failed with code ", GetLastError());
            writeLog;
        #endif
    }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAStrategyLong::checkQuantities(EAEnum interval) {

    static MqlDateTime start, end;   
    static  datetime newDay;
    int ticket;
    static int cnt=0;

    // Check for a day change
    if (interval==_RUN_ONDAY) {
        #ifdef _DEBUG_LONG_POSITIONS 
            ss="EAStrategyLong -> checkQuantities -> New Day !";
            writeLog
            pss
        #endif 

        TimeToStruct(TimeCurrent(),start);
        TimeToStruct(TimeCurrent(),end);
        // Modify the times
        start.hour=0; start.min=0; end.hour=23; end.min=59;
        cnt=0;
    }

    if (interval==_RUN_ONBAR) {
        // Monitor max position for THIS strategy
        if (longPositions.Total()>=strategy.maxPositions) {     
            #ifdef _RUN_PANEL
                showPanel ip.updateInfoLabel(17,0,StringFormat("%d Maximum Reached",strategy.maxPositions));
            #endif
            #ifdef _DEBUG_LONG_POSITIONS
                ss="EAStrategyLong -> checkQuantities -> Max number of LONG reached";
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

        //showPanel ip.updateInfoLabel(18,0, "Max Positions/Day");  
        // No maximum daily qty
        if (strategy.maxDaily<=0) {
            #ifdef _DEBUG_LONG_POSITIONS 
                ss="EAStrategyLong -> checkQuantities -> No max number of daily positions specfied";
                writeLog
                pss
            #endif    
            //showPanel ip.updateInfoLabel(18,1,"No Maximum");
            return true;           // No max daily qty
        }

        // Count daily qty and return if > than allowed amount
        if (cnt>=strategy.maxDaily) {
            #ifdef _DEBUG_LONG_POSITIONS
                ss=StringFormat("EAStrategyLong -> checkQuantities -> %s %s %d Max Reached",TimeToString(StructToTime(start),TIME_DATE|TIME_MINUTES),TimeToString(StructToTime(end),TIME_DATE|TIME_MINUTES),HistoryDealsTotal());
                writeLog
                pss
            #endif
            //showPanel ip.updateInfoLabel(18,1,s);
            return false;  
        }

        pline
        HistorySelect(StructToTime(start),StructToTime(end));
        ss=StringFormat("deals total:%d",HistoryDealsTotal());
        pss
        pline

        // Reset the counter
        cnt=0;
        for (int i=0;i<HistoryDealsTotal();i++) {
            ticket=HistoryDealGetTicket(i);
            if (StringToInteger(HistoryDealGetString(ticket,DEAL_COMMENT))==strategy.strategyNumber) ++cnt;
            ss=StringFormat("-------- %d %d",ticket,cnt);
            pss
        }
        
    }
    return true;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAStrategyLong::getUpdatedPrice(ENUM_ORDER_TYPE orderType, EAEnum positionOpenClose) {


    double thePrice=0.0;
    MqlTick last_tick;

   SymbolInfoTick(Symbol(),last_tick); // Also STD lib is RefreshRates()

    if (positionOpenClose==_TOOPEN) {
      // To OPEN a position
        switch (orderType) {
            case ORDER_TYPE_BUY: thePrice=(SymbolInfoDouble(_Symbol,SYMBOL_ASK)); break; // Open long at the ASK
            case ORDER_TYPE_SELL:thePrice=(SymbolInfoDouble(_Symbol,SYMBOL_BID)); break; // Open short at the BID
        }
    }
    if (positionOpenClose==_TOCLOSE) {
      // To CLOSE a position
        switch (orderType) {
            case ORDER_TYPE_BUY: thePrice=(SymbolInfoDouble(_Symbol,SYMBOL_BID)); break; // Close long at the BID
            case ORDER_TYPE_SELL:thePrice=(SymbolInfoDouble(_Symbol,SYMBOL_ASK)); break; // Close short at the ASK
        }
    }   

    #ifdef _DEBUG_LONG_POSITIONS 
        ss=StringFormat("EAStrategyLong -> getUpdatedPrice -> Price:%.2f",thePrice); 
        writeLog
        pss
    #endif 
    return thePrice;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAStrategyLong::accountInfoChecks() {



    #ifdef _DEBUG_POSITION_ACC_CHECKS Print(__FUNCTION__); string ss; #endif 

    bool c[4];
    string s[4];
    string ss;

/*
    showPanel {

        if (AccountInfo.TradeAllowed()==false) {
            s[0]="TradeAllowed=N";
            c[0]=false;
        } else {
            s[0]="TradeAllowed=Y";
            c[0]=true;
        }
    
        if (AccountInfo.TradeExpert()==false) {
            s[1]="TradeExpert=N";
            c[1]=false;
        } else {
            s[1]="TradeExpert=Y";
            c[1]=true;
        }

        if (SymbolInfo.IsSynchronized()==false) {
            s[2]="IsSynchronized=N";
            c[2]=false;
        } else {
            s[2]="IsSynchronized=Y";
            c[2]=true;
        }

        if (SymbolInfo.Spread()>pbp.maxSpread) {
            s[3]=StringFormat("%d/%d",SymbolInfo.Spread(),pbp.maxSpread);
            c[3]=false;
        } else {
            s[3]=s[3]=StringFormat("%d/%d",SymbolInfo.Spread(),pbp.maxSpread);
            c[3]=true;
        }
    
        ss=StringFormat("%s -- %s",s[0],s[1]);
        infoPanel.updateInfo2Label(27,ss);
        ss=StringFormat("%s -- Spread %s",s[2],s[3]);
        infoPanel.updateInfo2Label(28,ss);
        infoPanel.updateInfo2Value(27,"");
        infoPanel.updateInfo2Value(28,"");
    
        for (int i=0;i<ArraySize(c);i++) {
            if (c[0]==false) return false;
        }
    } else {
        if (AccountInfo.TradeAllowed()==false) return false;
        if (AccountInfo.TradeExpert()==false) return false;
        if (SymbolInfo.IsSynchronized()==false) return false;
        if (SymbolInfo.Spread()>pbp.maxSpread) return false;
    }
*/

    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAStrategyLong::openPosition(EAPosition &p) {

    #ifdef _DEBUG_LONG_OPEN_CLOSE
        string ss;
        ss="EAStrategyLong -> openPosition ....";
        writeLog;
        pss
    #endif

    if (accountInfoChecks()==false) return false;

   bool tradeStatus=false;                                                  // Status to monitor success from trade server
   int retries=5;                                                           // Attempts to open a new position   

    while (retries>0) {
        if (AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {  
            if (p.orderTypeToOpen==ORDER_TYPE_BUY) { // Market Order Buy
               //----
                #ifdef _DEBUG_LONG_OPEN_CLOSE  
                    ss=StringFormat("EAStrategyLong -> openPosition -> Open buy order lotsize:%.2f Price:%.2f Comment:%s",p.strategy.lotSize,p.entryPrice,IntegerToString(p.strategy.strategyNumber));
                    writeLog; 
                    pss         
                #endif 
               //----
                tradeStatus=Trade.Buy(p.strategy.lotSize,_Symbol,p.entryPrice,0.0,0.0,IntegerToString(p.strategy.strategyNumber));
                if (tradeStatus) { 
                    break;
                }
            }
            if (p.orderTypeToOpen==ORDER_TYPE_SELL) { // Market Order Buy
               //----
                #ifdef _DEBUG_LONG_OPEN_CLOSE
                    ss=StringFormat("EAStrategyLong ->  openPosition -> Lots:%d Price:%d",p.strategy.lotSize,p.entryPrice);
                    writeLog;
                    pss           
                #endif 
               //----
                tradeStatus=Trade.Sell(p.strategy.lotSize,_Symbol,p.entryPrice,0.0,0.0,IntegerToString(p.strategy.strategyNumber));
                if (tradeStatus) { 
                    break;
                } else {
                    Print (GetLastError());
                }
            }
        }                
        retries--;  
    }

    // Seems to have succeeded
    if (tradeStatus) { 
        //----
        #ifdef _DEBUG_LONG_OPEN_CLOSE  
            ss="EAStrategyLong ->  openPosition -> -> Trade submitted - OK";
            writeLog;
            pss
        #endif  
        //----
        MqlTradeRequest lastRequest;
        MqlTradeResult lastResult;   
        Trade.Request(lastRequest); 
        Trade.Result(lastResult); 

        // Set some additional position object properties
        p.ticket=Trade.ResultOrder();            
        p.orderTypeToOpen=Trade.RequestType();
        p.entryPrice=Trade.RequestPrice(); 
        return true;
    }
    return false;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::closeOnFixedTiming() {

    for (int i=0;i<longPositions.Total();i++) {
        glp; 
        ss=StringFormat("==================%d %d %d",strategy.closeAtEOD, p.closeAtEOD,strategy.maxDailyHold);
        pss
        #ifdef _DEBUG_TIME  
            if (p.closeAtEOD && strategy.maxDailyHold>=0) {
                ss=StringFormat("EAStrategyLong -> closeOnFixedTiming -> Long position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                writeLog
                Print (ss);
            }
        #endif

        if (p.closingDateTime<TimeCurrent() && strategy.maxDailyHold>=0 && p.closeAtEOD) {    // Check when current date exceeded future date hence due date passed
            if (Trade.PositionClose(p.ticket,p.strategy.deviationInPoints)) {
                #ifdef _DEBUG_TIME   
                    ss="EAStrategyLong -> closeOnFixedTiming -> Long Close EOD"; 
                    writeLog
                    pss
                #endif
                closeSQLPosition(p);
                if (longPositions.Delete(i)) {
                    #ifdef _DEBUG_TIME   
                        ss="EAStrategyLong -> closeOnFixedTiming -> Long Close at EOD removed from CList"; 
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
void EAStrategyLong::closeOnStealthProfit(EAPosition &p,int idx) {


    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inProfit;


    if (last_tick.bid>p.fixedProfitTargetLevel)  {inProfit=true;};
    if (last_tick.bid<p.fixedProfitTargetLevel)  {inProfit=false;}; 

    if (p.strategy.inProfitClosePosition) {                       
        if (inProfit) {
            if (Trade.PositionClose(p.ticket,p.strategy.deviationInPoints)) {
            //----
                #ifdef _DEBUG_LONG_OPEN_CLOSE   
                    ss=StringFormat("EAStrategyLong -> closeOnStealthProfit -> Long Close in PROFIT Time:%s Ticket:%d PnL:%.2f",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES), p.ticket,p.currentPnL); 
                    writeLog
                    pss
                #endif
                    closeSQLPosition(p);
                if (longPositions.Delete(idx)) {
                    #ifdef _DEBUG_LONG_OPEN_CLOSE   
                        ss="EAStrategyLong -> closeOnStealthProfit -> Long Close in PROFIT object removed from CList"; 
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
bool EAStrategyLong::closeOnStealthLoss(EAPosition &p,int idx) {


    MqlTick last_tick;
    SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
    bool inLoss;

        
    if (last_tick.bid<p.fixedLossTargetLevel)    {inLoss=true;};
    if (last_tick.bid>p.fixedLossTargetLevel)    {inLoss=false;};

    if (p.strategy.inLossClosePosition) {
        if (inLoss) {
            if (p.strategy.inLossOpenMartingale&&martingalePositions.Total()<strategy.maxMg) {                    // Martingale close in "loss"
                //Create a copy of the postion to be copied over to martingalePositions
                // this method used because CList detach does not work as expected
                EAPosition *np=new EAPosition(p);       // Create new with copy constructor called
                martingalePositions.Add(np);            // add to mg list
                longPositions.DeleteCurrent();          // delete from current lp list
                #ifdef _DEBUG_LONG_OPEN_CLOSE   
                    ss=StringFormat("EAStrategyLong -> closeOnStealthLoss -> Total long after move:%d",longPositions.Total());
                    writeLog
                    Print (ss);
                    ss=StringFormat("EAStrategyLong -> closeOnStealthLoss -> Total mg after move:%d",martingalePositions.Total());
                    writeLog
                    Print (ss);
                #endif
                return true;
            } else {                                                                    // Normal close in loss
                if (Trade.PositionClose(p.ticket,p.strategy.deviationInPoints)) {
                    //----
                    #ifdef _DEBUG_LONG_OPEN_CLOSE   
                        ss=StringFormat("EAStrategyLong -> closeOnStealthLoss -> Long Close in LOSS Time:%s Ticket:%d PnL:%.2f",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES), p.ticket,p.currentPnL); 
                        writeLog
                        pss
                    #endif
                    closeSQLPosition(p);
                    if (longPositions.Delete(idx)) {
                        #ifdef _DEBUG_LONG_OPEN_CLOSE   
                            ss="EAStrategyLong -> closeOnStealthLoss -> Long Close in LOSS object removed from CList";
                            writeLog
                            pss 
                        #endif
                        return true;                       
                    }   
                }  
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::newPosition() {

    #ifdef _DEBUG_LONG_OPEN_CLOSE 
        string ss;
        for (int i=0;i<longPositions.Total();i++) {
            glp;
            ss=StringFormat("EAStrategyLong -> newPosition -> Ticket:%d Status:%d",p.ticket,p.status);
            writeLog
            pss;
        } 
    #endif  

    // Build a new position object based on strategy defaults
    EAPosition *p=new EAPosition(strategy, ORDER_TYPE_BUY, _LONG, getUpdatedPrice(ORDER_TYPE_BUY,_TOOPEN));     

    // Set EOD close value if being used
    if (strategy.closeAtEOD) {  
        p.closingDateTime=timing.tradingTimes(_CLOSE_AT_EOD);
            #ifdef _DEBUG_LONG_OPEN_CLOSE 
                ss=StringFormat("EAStrategyLong -> newPosition -> Long position flagged to close at a future date:%s",TimeToString(p.closingDateTime));
                writeLog
                pss
            #endif
    } else {
        p.closingDateTime=NULL;
    }

    if (openPosition(p)) {
        if (longPositions.Add(p)!=-1) {
            #ifdef _DEBUG_LONG_OPEN_CLOSE
                ss="EAStrategyLong -> newPosition -> New position opened and added to long positions list"; 
                writeLog
                pss
                ss=StringFormat("EAStrategyLong -> strategyNumber:%d lotSize:%.2f status:%s entryPrice:%.2f fixedProfitTargetLevel:%.2f fixedLossTargetLevel:%.2f",
                p.strategy.strategyNumber,p.strategy.lotSize,EnumToString(p.status),p.entryPrice,p.fixedProfitTargetLevel,p.fixedLossTargetLevel);
                writeLog
                pss
            #endif 
        }            
    } else {
        #ifdef _DEBUG_LONG_OPEN_CLOSE
            ss="EAStrategyLong -> newPosition -> New position opened failed"; 
            writeLog
            pss
        #endif 
    }

}


