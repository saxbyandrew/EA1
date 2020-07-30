//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_POSITION_LIST
//#define _DEBUG_POSITION_BASE
//#define _DEBUG_POSITION_ACC_CHECKS
//#define _DEBUG_POSITION_ORDERS


#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

#include "EAEnum.mqh"
#include "EAPosition.mqh"
#include "EATimingBase.mqh"


class EAPositionBase : public CObject {

//=========
private:
//=========

    EATimingBase t;


//=========
protected:
//=========
    

    CAccountInfo        AccountInfo;
    CTrade              Trade;
    CPositionInfo       PositionInfo;
    CSymbolInfo         SymbolInfo;

    
    bool        accountInfoChecks();
    double      getUpdatedPrice(ENUM_ORDER_TYPE orderType, EAEnum positionOpenClose);
    bool        openPosition(EAPosition *p);
    void        deleteSQLPosition(int ticket);
    void        closeSQLPosition(EAPosition *p);
    void        updateSQLSwapCosts(EAPosition *p);

//=========
public:
//=========
EAPositionBase();
~EAPositionBase();

    virtual int Type() const {return _POSITION_BASE;};


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionBase::EAPositionBase() {

    #ifdef _WRITELOG
        string ss;
        ss=" -> EAPositionBase Object Created ....";
        writeLog;
    #endif
    

    Trade.SetAsyncMode(false);     
    Trade.SetExpertMagicNumber(usp.magicNumber);            
    Trade.SetDeviationInPoints(usp.deviationInPoints);  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionBase::~EAPositionBase() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionBase::closeSQLPosition(EAPosition *p) {

    updateSQLSwapCosts(p);
    deleteSQLPosition(p.ticket);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionBase::deleteSQLPosition(int ticket) {


   if (bool (usp.runMode&_RUN_STRATEGY_OPTIMIZATION)) return;   // No state saving during optimizations
   if (!bool (usp.runMode&_RUN_SAVE_STATE)) return;             // No state saving enabled

    string sql=StringFormat("DELETE FROM STATE WHERE ticket=%d",ticket);
    if (!DatabaseExecute(_mainDBHandle,sql)) {
        #ifdef _WRITELOG
            string ss=StringFormat(" -> DB request failed with code ", GetLastError());
            writeLog;
        #endif
    }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPositionBase::updateSQLSwapCosts(EAPosition *p) {


    int request;
    double swapCosts;
    string sql;

    if (MQLInfoInteger(MQL_OPTIMIZATION))  return;   // No state saving during optimizations

    sql=StringFormat("SELECT swapCosts FROM STRATEGIES WHERE strategyNumber=%d",usp.strategyNumber);
    request=DatabasePrepare(_mainDBHandle,sql); 
    DatabaseRead(request);
    DatabaseColumnDouble(request,0,swapCosts); 


    // Bump the swap costs
    double result=swapCosts+p.swapCosts;
    TesterWithdrawal(p.swapCosts);  // withdraw from account when testing

    // Update DB
    sql=StringFormat("UPDATE STRATEGIES SET swapCosts=%g WHERE strategyNumber=%d",result, usp.strategyNumber);
    if (!DatabaseExecute(_mainDBHandle,sql)) {
        #ifdef _WRITELOG
            string ss=StringFormat(" -> DB request failed with code ", GetLastError());
            writeLog;
        #endif
    }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAPositionBase::getUpdatedPrice(ENUM_ORDER_TYPE orderType, EAEnum positionOpenClose) {

    #ifdef _DEBUG_POSITION_BASE 
        Print (__FUNCTION__); 
    #endif

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
    return thePrice;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAPositionBase::accountInfoChecks() {



    #ifdef _DEBUG_POSITION_ACC_CHECKS Print(__FUNCTION__); string ss; #endif 

    bool c[4];
    string s[4];
    string ss;


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

        if (SymbolInfo.Spread()>usp.maxSpread) {
            s[3]=StringFormat("%d/%d",SymbolInfo.Spread(),usp.maxSpread);
            c[3]=false;
        } else {
            s[3]=s[3]=StringFormat("%d/%d",SymbolInfo.Spread(),usp.maxSpread);
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
        if (SymbolInfo.Spread()>usp.maxSpread) return false;
    }


    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAPositionBase::openPosition(EAPosition *p) {

    #ifdef _WRITELOG
        string ss;
        ss=" -> openPosition ....";
        writeLog;
    #endif

    if (accountInfoChecks()==false) return false;

   bool tradeStatus=false;                                                  // Status to monitor success from trade server
   int retries=5;                                                           // Attempts to open a new position   

    while (retries>0) {
        if (AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {  
            if (p.orderTypeToOpen==ORDER_TYPE_BUY) { // Market Order Buy
               //----
                #ifdef _WRITELOG  
                    ss=" -> Open buy order";  
                    writeLog;          
                #endif 
               //----
                tradeStatus=Trade.Buy(p.lotSize,_Symbol,p.entryPrice,0.0,0.0,IntegerToString(p.strategyNumber));
                if (tradeStatus) { 
                    break;
                }
            }
            if (p.orderTypeToOpen==ORDER_TYPE_SELL) { // Market Order Buy
               //----
                #ifdef _WRITELOG
                    ss=StringFormat(" -> Lots:%d Price:%d",p.lotSize,p.entryPrice);
                    writeLog;           
                #endif 
               //----
                tradeStatus=Trade.Sell(p.lotSize,_Symbol,p.entryPrice,0.0,0.0,IntegerToString(p.strategyNumber));
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
        #ifdef _WRITELOG  
            ss=" -> Trade submitted - OK";
            writeLog;
        #endif  
        //----
        MqlTradeRequest lastRequest;
        MqlTradeResult lastResult;   
        Trade.Request(lastRequest); 
        Trade.Result(lastResult); 

        p.ticket=Trade.ResultOrder();                           // Overwrite with trade server actual results
        p.orderTypeToOpen=Trade.RequestType();
        p.entryPrice=Trade.RequestPrice(); 

        if (bool (p.closingTypes&_CLOSE_AT_EOD)) {              // Set EOD close value if being used
            p.closingDateTime=t.sessionTimes(_CLOSE_AT_EOD);
        //----
        #ifdef _DEBUG_POSITION_ORDERS
            string ss=StringFormat(" -> Ticket:%d Using future Closing date of:%s",p.ticket,TimeToString(p.closingDateTime));
            Print(ss);
        #endif
         //----
        }

        //if (bool (usp.runMode&_RUN_SAVE_STATE)) usp.saveSQLState(p);

        return true;
    }

    return false;

}
