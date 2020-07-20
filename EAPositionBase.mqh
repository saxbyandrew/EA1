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

    Trade.SetAsyncMode(false);     
    Trade.SetExpertMagicNumber(usingStrategyValue.magicNumber);            
    Trade.SetDeviationInPoints(usingStrategyValue.deviationInPoints);  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPositionBase::~EAPositionBase() {

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

        if (SymbolInfo.Spread()>param.maxSpread) {
            s[3]=StringFormat("%d/%d",SymbolInfo.Spread(),param.maxSpread);
            c[3]=false;
        } else {
            s[3]=s[3]=StringFormat("%d/%d",SymbolInfo.Spread(),param.maxSpread);
            c[3]=true;
        }
    
        ss=StringFormat("%s -- %s",s[0],s[1]);
        mp.updateInfo2Label(27,ss);
        ss=StringFormat("%s -- Spread %s",s[2],s[3]);
        mp.updateInfo2Label(28,ss);
        mp.updateInfo2Value(27,"");
        mp.updateInfo2Value(28,"");
    
        for (int i=0;i<ArraySize(c);i++) {
            if (c[0]==false) return false;
        }
    } else {
        if (AccountInfo.TradeAllowed()==false) return false;
        if (AccountInfo.TradeExpert()==false) return false;
        if (SymbolInfo.IsSynchronized()==false) return false;
        if (SymbolInfo.Spread()>param.maxSpread) return false;
    }


    return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAPositionBase::openPosition(EAPosition *p) {

          //----
    #ifdef _DEBUG_POSITION_ORDERS 
        Print(__FUNCTION__); 
        string ss;
    #endif 
   //----

    if (accountInfoChecks()==false) return false;

   bool tradeStatus=false;                                                  // Status to monitor success from trade server
   int retries=5;                                                           // Attempts to open a new position   

    while (retries>0) {
        if (AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) {  
            if (p.orderTypeToOpen==ORDER_TYPE_BUY) { // Market Order Buy
               //----
                #ifdef _DEBUG_POSITION_ORDERS  
                    Print(" -> Open buy order");            
                #endif 
               //----
                tradeStatus=Trade.Buy(p.lotSize,_Symbol,p.entryPrice,0.0,0.0,IntegerToString(p.strategyNumber));
                if (tradeStatus) { 
                    break;
                }
            }
            if (p.orderTypeToOpen==ORDER_TYPE_SELL) { // Market Order Buy
               //----
                #ifdef _DEBUG_POSITION_ORDERS 
                    ss=StringFormat(" -> Lots:%d Price:%d",p.lotSize,p.entryPrice);
                    Print(ss); 
                    Print(" -> Open sell order");            
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
        #ifdef _DEBUG_POSITION_ORDERS   
            Print (" -> Trade submitted - OK");
        #endif  
        //----
        MqlTradeRequest lastRequest;
        MqlTradeResult lastResult;   
        Trade.Request(lastRequest); 
        Trade.Result(lastResult); 

        p.ticket=Trade.ResultOrder();                      // Overwrite with trade server actual results
        p.orderTypeToOpen=Trade.RequestType();
        p.entryPrice=Trade.RequestPrice(); 

        if (bool (p.closingTypes&_CLOSE_AT_EOD)) {            // Set EOD close value if being used
            p.closingDateTime=t.sessionTimes(_CLOSE_AT_EOD);
        //----
        #ifdef _DEBUG_POSITION_ORDERS
            string ss=StringFormat(" -> Ticket:%d Using future Closing date of:%s",p.ticket,TimeToString(p.closingDateTime));
            Print(ss);
        #endif
         //----
        }

        if (bool (usingStrategyValue.runMode&_RUN_SAVE_STATE)) usingStrategyValue.saveSQLState(p);

        return true;
    }

    return false;

}
