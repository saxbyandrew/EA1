//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"

// ++++++++++++++++++++++++++++++++++++++

class EAPosition;

class EAStrategyParameters {

//=========
private:
//=========

//=========
protected:
//=========

      string      ss;
      void        resetValues();

//=========
public:
//=========
EAStrategyParameters();
~EAStrategyParameters();

      void        loadSQLStrategy();

      // Public data stored in the DB
   struct Strategy {
      int               isActive;

      int               strategyNumber;            // Name of strategy for comment 
      int               magicNumber;
      int               deviationInPoints;          
      int               maxSpread;                 // Limit the spread to non stupid values
      int               entryBars;
      double            brokerAdminPercent;
      double            interBankPercentage;
      int               inProfitClosePosition;
      int               inLossClosePosition;
      int               inLossOpenMartingale;
      int               inLossOpenLongHedge;
      int               baseReference;
      int               longReference;
      int               shortReference;
      int               martingaleReference;
      int               nnType;
      int               layer1;
      int               layer2;
      double            lotSize; 
      double            fptl;       // Dollar Value
      double            fltl;       // same
      double            fpts;       // same
      double            flts;       // Dollar Value
      int               maxLong;
      int               maxShort;
      int               maxDaily;
      int               maxDailyHold;        // 0 close today +1 close tomorrow etc
      int               maxMg;    
      int               mgMultiplier;  
      double            longHLossamt;
      double            swapCosts;
      // Not stored in DB !
      unsigned          closingTypes;
      ENUM_ORDER_TYPE   orderTypeToOpen;           // LONG SHORT etc set by stategy once a trigger occurs !
      EAEnum            triggerReset;
      int               triggerResetCounter; 
      datetime          closingDateTime;
      int               runMode;                   // !!!! not sure if i'll use this
      int               defaultRunMode;
   } sb;

   struct Timing {
      int               strategyNumber;            
      string            sessionTradingTime;         // "Any Time"" OR _"Session "ime" OR "Fixed Time""   
      string            tradingStart;               // NYSE time is 16:50=8:50 premarket to 23:00=16:00 market close
      string            tradingEnd;   
      string            marketSessions1;  
      string            marketSessions2; 
      string            marketSessions3; 
      int               marketOpenDelay;            // min delay Trade around the actual session times as given by the trade server
      int               marketCloseDelay; 
      int               allowWeekendTrading;        // _YES OR _NO 
      int               closeAtEOD;      
      // Not stored in DB !     
      int               marketSessions[4];         // Local store for YES/NO conversion from tb. values  
   } tb;

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyParameters::EAStrategyParameters() {

   #ifdef _DEBUG_PARAMETERS
      Print ("EAStrategyParameters -> Default Constructor");
      string ss;
   #endif  
   
   resetValues();
   loadSQLStrategy();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyParameters::~EAStrategyParameters() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::resetValues() {

   #ifdef _DEBUG_PARAMETERS
      Print ("EAStrategyParameters -> Reset Values");
      string ss;
   #endif 

      // Reset tp defaults
      sb.orderTypeToOpen=0;
      sb.strategyNumber=10;            // Name of strategy for comment 
      sb.magicNumber=0;
      sb.deviationInPoints=0; 
      sb.maxSpread=0;                 // Limit the spread to non stupid values
      tb.marketOpenDelay=0;           // In minutes                   
      tb.marketCloseDelay=0;          // In minutes  minus -30 to close 30 before end of session  
      tb.marketSessions1="Yes";       // _YES _NO of session to use     
      tb.marketSessions2="No";       
      tb.marketSessions3="No";
      tb.tradingStart="16:50";              // NYSE time is 16:50=8:50 premarket to 23:00=16:00 market close                        
      tb.tradingEnd="08:50";    
      tb.allowWeekendTrading="No" ;         // _YES OR _NO                
      tb.sessionTradingTime="Any Time" ;     // _FIXED_TIME=44, _SESSION_TIME=45, _ANYTIME=46, 
      sb.closingTypes=0; 
      sb.inProfitClosePosition=0;
      sb.inLossClosePosition=0;
      sb.inLossOpenMartingale=0;
      sb.inLossOpenLongHedge=0;
      tb.closeAtEOD="Yes";                               
      sb.entryBars=0;
      sb.triggerReset=_NOTSET ;                        
      sb.triggerResetCounter=0;
      sb.interBankPercentage=0.0;                
      sb.lotSize=0; 
      sb.fptl=0;                 // Dollar Values
      sb.fltl=0;                 // same
      sb.fpts=0;                 // same
      sb.flts=0;                 // Dollar Values
      sb.nnType=0;
      sb.baseReference=0;
      sb.longReference=0;
      sb.shortReference=0;
      sb.martingaleReference=0;
      sb.maxMg=0;          
      sb.longHLossamt=0;
      sb.mgMultiplier=0;  
      sb.maxLong=0;
      sb.maxShort=0;
      sb.maxDaily=0;
      sb.maxDailyHold=0;
      sb.swapCosts=0;
      sb.defaultRunMode=_RUN_NORMAL+_RUN_SHOW_PANEL+_RUN_SAVE_STATE;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::loadSQLStrategy() {

   #ifdef _DEBUG_PARAMETERS
      ss="EAStrategyParameters -> loadSQLStrategy";
      pss
      writeLog
   #endif 
   int request;

   request=DatabasePrepare(_mainDBHandle,"SELECT * FROM STRATEGY WHERE isActive=1");
   if (!DatabaseRead(request)) {
      ss=StringFormat(" -> DatabaseRead DB request failed code:%d",GetLastError()); 
      pss
      writeLog
      ExpertRemove();
   } else {
      #ifdef _DEBUG_PARAMETERS
      ss="  -> DatabaseRead -> SUCCESS";
      writeLog
      pss
      #endif 
   }

      DatabaseColumnInteger   (request,0,sb.isActive);
      DatabaseColumnInteger   (request,1,sb.strategyNumber);
      DatabaseColumnInteger   (request,2,sb.magicNumber);
      DatabaseColumnInteger   (request,3,sb.deviationInPoints);
      DatabaseColumnInteger   (request,4,sb.maxSpread);
      DatabaseColumnInteger   (request,5,sb.entryBars);
      DatabaseColumnDouble    (request,6,sb.brokerAdminPercent);
      DatabaseColumnDouble    (request,7,sb.interBankPercentage);
      DatabaseColumnInteger   (request,8,sb.inProfitClosePosition);
      DatabaseColumnInteger   (request,9,sb.inLossClosePosition);
      DatabaseColumnInteger   (request,10,sb.inLossOpenMartingale);
      DatabaseColumnInteger   (request,11,sb.inLossOpenLongHedge);
      DatabaseColumnInteger   (request,12,sb.baseReference);
      DatabaseColumnInteger   (request,13,sb.longReference);
      DatabaseColumnInteger   (request,14,sb.shortReference);
      DatabaseColumnInteger   (request,15,sb.martingaleReference);
      DatabaseColumnDouble    (request,16,sb.lotSize);
      DatabaseColumnDouble    (request,17,sb.fptl);
      DatabaseColumnDouble    (request,18,sb.fltl);
      DatabaseColumnDouble    (request,19,sb.fpts);
      DatabaseColumnDouble    (request,20,sb.flts);
      DatabaseColumnInteger   (request,21,sb.maxLong);
      DatabaseColumnInteger   (request,22,sb.maxShort);
      DatabaseColumnInteger   (request,23,sb.maxDaily);
      DatabaseColumnInteger   (request,24,sb.maxDailyHold);
      DatabaseColumnInteger   (request,25,sb.maxMg);
      DatabaseColumnInteger   (request,26,sb.mgMultiplier);
      DatabaseColumnDouble    (request,27,sb.longHLossamt);
      DatabaseColumnDouble    (request,28,sb.swapCosts);
   
      #ifdef _DEBUG_PARAMETERS
         ss=StringFormat("Table STRATEGY -> StrategyNumber:%d brokerAdminPercent:%2.2f lotSize:%2.2f fptl:%2.2f maxLong:%d maxLongHedgeLoss:%2.2f ",sb.strategyNumber,sb.brokerAdminPercent,sb.lotSize,sb.fptl,sb.maxLong,sb.longHLossamt);
         writeLog
         pss
      #endif 
   
   request=DatabasePrepare(_mainDBHandle,StringFormat("SELECT * FROM TIMING WHERE strategyNumber=%d",sb.strategyNumber)); 
      DatabaseRead(request);
      DatabaseColumnInteger   (request,0,tb.strategyNumber);
      DatabaseColumnText      (request,1,tb.sessionTradingTime);
      DatabaseColumnText      (request,2,tb.tradingStart);
      DatabaseColumnText      (request,3,tb.tradingEnd);
      DatabaseColumnText      (request,4,tb.marketSessions1);
      DatabaseColumnText      (request,5,tb.marketSessions2);
      DatabaseColumnText      (request,6,tb.marketSessions3);
      DatabaseColumnInteger   (request,7,tb.marketOpenDelay);
      DatabaseColumnInteger   (request,8,tb.marketCloseDelay);
      DatabaseColumnInteger   (request,9,tb.allowWeekendTrading);
      DatabaseColumnInteger   (request,10,tb.closeAtEOD);

      #ifdef _DEBUG_PARAMETERS
         printf("Table TIMING -> StrategyNumber:%d sessionTradingTime:%s  ",tb.strategyNumber,tb.sessionTradingTime);
      #endif 

   // Convert some data fields so the new DB format works with 
   // the older code and does not required extensive changes
   // DB field to local conversion create logical AND mask
   if (sb.inProfitClosePosition) {
      sb.closingTypes=sb.closingTypes+_IN_PROFIT_CLOSE_POSITION;
   }
      
   if (sb.inLossClosePosition) {
      sb.closingTypes=sb.closingTypes+_IN_LOSS_CLOSE_POSITION;
   }
      
   if (sb.inLossOpenMartingale) {
      sb.closingTypes=sb.closingTypes+_IN_LOSS_OPEN_MARTINGALE;
   }
      
   if (sb.inLossOpenLongHedge) {
      sb.closingTypes=sb.closingTypes+_IN_LOSS_OPEN_LONG_HEDGE;
   }
      
   if (tb.closeAtEOD) {
      sb.closingTypes=sb.closingTypes+_CLOSE_AT_EOD;
   }
      
   // Convert the 3 text field to a int Array
   if (tb.marketSessions1=="YES") {
      tb.marketSessions[0]=_YES;
   } else {
      tb.marketSessions[0]=_NO; 
   }     
   if (tb.marketSessions2=="YES") {
      tb.marketSessions[1]=_YES; 
   } else {
      tb.marketSessions[1]=_NO; 
   } 
   if (tb.marketSessions3=="YES") {
      tb.marketSessions[2]=_YES;
   } else {
      tb.marketSessions[2]=_NO; 
   }  

}
