//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_PARAMETERS
//#define _DEBUG_OPTIMIZATIONCOPY


#include "EAEnum.mqh"
#include "EAOptimizationInputs.mqh"


// ++++++++++++++++++++++++++++++++++++++

class EAPosition;

class EAStrategyParameters {

//=========
private:
//=========
   void        optimizationCreateValues(int strategyNumber,int iterationNumber,int techNumber,int dnnType);
   void        copyOptimizationResults();
//=========
protected:
//=========
   void        resetValues();
   void        updateSQLSwapCosts(EAPosition *p);
   void        deleteSQLPosition(int ticket);
   


//=========
public:
//=========
EAStrategyParameters();
~EAStrategyParameters();


      void        closeSQLPosition(EAPosition *p);
      void        loadSQLState(); 
      void        saveSQLState(EAPosition *p);

      void        copyValuesFromInputs();
      void        openSQLDatabase();
      void        closeSQLDatabase(); 
      void        loadSQLStrategy();

      void        loadSQLValues();
      void        checkSQLDatabase();

      // Public data not stored in DB
      ENUM_ORDER_TYPE   orderTypeToOpen;           // LONG SHORT etc set by stategy !
      datetime          closingDateTime;
      unsigned          closingTypes;
      EAEnum            marketSessions[4];
      EAEnum            triggerReset;
      int               triggerResetCounter; 
      string            runOnFrequency;             // _RUN_ONTICK=1, _RUN_ONBAR=2,_RUN_ONDAY=4, _RUN_ONTIMER=8 LOGICAL AND  
      //--------------------------------

      // Public data stored in the DB
      int               isActive;
      int               runMode;                   // Allows for various types of on or off
      string            strategyName;
      int               strategyNumber;            // Name of strategy for comment 
      int               magicNumber;
      int               deviationInPoints;          

      int               maxSpread;                 // Limit the spread to non stupid values
      int               entryBars;

      double            brokerAdminPercent;
      double            interBankPercentage;

      int               sessionTradingTime;         // _ANYTIME OR _SESSION_TIME OR _FIXED_TIME   
      string            tradingStart;               // NYSE time is 16:50=8:50 premarket to 23:00=16:00 market close
      string            tradingEnd;   
      string            marketSessions1;  
      string            marketSessions2; 
      string            marketSessions3; 

      int               marketOpenDelay;            // min delay Trade around the actual session times as given by the trade server
      int               marketCloseDelay; 
      int               inProfitClosePosition;
      int               inLossClosePosition;
      int               inLossOpenMartingale;
      int               inLossOpenLongHedge;
      int               closeAtEOD;      
      int               allowWeekendTrading;        // _YES OR _NO    

      double            lotSize; 
      double            fixedProfitTargetLong;     // Dollar Value
      double            fixedLossTargetLong;       // same
      double            fixedProfitTargetShort;    // same
      double            fixedLossTargetShort;      // Dollar Value

      int               dataFrameSize;
      int               lookBackBars;
      int               dnnType;
      int               dnnIn;
      int               dnnLayer1;
      int               dnnLayer2;
      int               dnnOut;
      int               dnnHedgeNumber;
      int               dnnMartingaleNumber;
      int               dnnLongNumber;
      int               dnnShortNumber;

      int               maxMartingalePositions;          
      double            maxLongHedgeLossAmountAllowed;
      int               martingaleMultiplier;  
      int               maxPositionsLong;
      int               maxPositionsShort;
      int               maxTotalDailyPositions;
      int               maxTotalDaysToHold;        // 0 close today +1 close tomorrow etc
      int               defaultRunMode;
      int               optimizationLong;
      int               optimizationShort;
      int               optimizationMartingale;
      int               optimizationHedge;
      double            swapCosts;

      string            strategyComment;
      int               techNumber;

      int useADX;
      ENUM_TIMEFRAMES s_ADXperiod;
      int s_ADXma;
      ENUM_TIMEFRAMES m_ADXperiod;
      int m_ADXma;
      ENUM_TIMEFRAMES l_ADXperiod;
      int l_ADXma;

      int useRSI;
      ENUM_TIMEFRAMES s_RSIperiod;
      int s_RSIma;
      ENUM_APPLIED_PRICE s_RSIap;

      ENUM_TIMEFRAMES m_RSIperiod;
      int m_RSIma;
      ENUM_APPLIED_PRICE m_RSIap;

      ENUM_TIMEFRAMES l_RSIperiod;
      int l_RSIma;
      ENUM_APPLIED_PRICE l_RSIap;

      int useMFI;
      ENUM_TIMEFRAMES s_MFIperiod;
      int s_MFIma;
      ENUM_TIMEFRAMES m_MFIperiod;
      int m_MFIma;
      ENUM_TIMEFRAMES l_MFIperiod;
      int l_MFIma;

      int useSAR;
      ENUM_TIMEFRAMES s_SARperiod;
      double s_SARstep;
      double s_SARmax;
      ENUM_TIMEFRAMES m_SARperiod;
      double m_SARstep;
      double m_SARmax;
      ENUM_TIMEFRAMES l_SARperiod;
      double l_SARstep;
      double l_SARmax;

      int useICH;
      ENUM_TIMEFRAMES s_ICHperiod;
      int s_tenkan_sen;
      int s_kijun_sen;
      int s_senkou_span_b;
      ENUM_TIMEFRAMES m_ICHperiod;
      int m_tenkan_sen;
      int m_kijun_sen;
      int m_senkou_span_b;
      ENUM_TIMEFRAMES l_ICHperiod;
      int l_tenkan_sen;
      int l_kijun_sen;
      int l_senkou_span_b;

      int useRVI;
      ENUM_TIMEFRAMES s_RVIperiod;
      int s_RVIma;
      ENUM_TIMEFRAMES m_RVIperiod;
      int m_RVIma;
      ENUM_TIMEFRAMES l_RVIperiod;
      int l_RVIma;

      int useSTOC;
      ENUM_TIMEFRAMES s_STOCperiod;
      int s_kPeriod;
      int s_dPeriod;
      int s_slowing;
      ENUM_MA_METHOD s_STOCmamethod;
      ENUM_STO_PRICE s_STOCpa;

      ENUM_TIMEFRAMES m_STOCperiod;
      int m_kPeriod;
      int m_dPeriod;
      int m_slowing;
      ENUM_MA_METHOD m_STOCmamethod;
      ENUM_STO_PRICE m_STOCpa;

      ENUM_TIMEFRAMES l_STOCperiod;
      int l_kPeriod;
      int l_dPeriod;
      int l_slowing;
      ENUM_MA_METHOD l_STOCmamethod;
      ENUM_STO_PRICE l_STOCpa;

      int useOSMA;
      ENUM_TIMEFRAMES s_OSMAperiod;
      int s_OSMAfastEMA;
      int s_OSMAslowEMA;
      int s_OSMAsignalPeriod;
      int s_OSMApa;

      ENUM_TIMEFRAMES m_OSMAperiod;
      int m_OSMAfastEMA;
      int m_OSMAslowEMA;
      int m_OSMAsignalPeriod;
      int m_OSMApa;
      ENUM_TIMEFRAMES l_OSMAperiod;
      int l_OSMAfastEMA;
      int l_OSMAslowEMA;
      int l_OSMAsignalPeriod;
      int l_OSMApa;

      int useMACD;
      ENUM_TIMEFRAMES s_MACDDperiod;
      int s_MACDDfastEMA;
      int s_MACDDslowEMA;
      int s_MACDDsignalPeriod;
      ENUM_TIMEFRAMES m_MACDDperiod;
      int m_MACDDfastEMA;
      int m_MACDDslowEMA;
      int m_MACDDsignalPeriod;
      ENUM_TIMEFRAMES l_MACDDperiod;
      int l_MACDDfastEMA;
      int l_MACDDslowEMA;
      int l_MACDDsignalPeriod;

      int useMACDBULLDIV;
      ENUM_TIMEFRAMES s_MACDBULLperiod;
      int s_MACDBULLfastEMA;
      int s_MACDBULLslowEMA;
      int s_MACDBULLsignalPeriod;
      ENUM_TIMEFRAMES m_MACDBULLperiod;
      int m_MACDBULLfastEMA;
      int m_MACDBULLslowEMA;
      int m_MACDBULLsignalPeriod;
      ENUM_TIMEFRAMES l_MACDBULLperiod;
      int l_MACDBULLfastEMA;
      int l_MACDBULLslowEMA;
      int l_MACDBULLsignalPeriod;

      int useMACDBEARDIV;
      ENUM_TIMEFRAMES s_MACDBEARperiod;
      int s_MACDBEARfastEMA;
      int s_MACDBEARslowEMA;
      int s_MACDBEARsignalPeriod;
      ENUM_TIMEFRAMES m_MACDBEARperiod;
      int m_MACDBEARfastEMA;
      int m_MACDBEARslowEMA;
      int m_MACDBEARsignalPeriod;
      ENUM_TIMEFRAMES l_MACDBEARperiod;
      int l_MACDBEARfastEMA;
      int l_MACDBEARslowEMA;
      int l_MACDBEARsignalPeriod;

      int useZZ;
      ENUM_TIMEFRAMES s_ZZperiod;
      ENUM_TIMEFRAMES m_ZZperiod;
      ENUM_TIMEFRAMES l_ZZperiod;

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyParameters::EAStrategyParameters() {

   #ifdef _DEBUG_PARAMETERS
      Print (" -> Default Constructor");
   #endif

   openSQLDatabase();
   loadSQLStrategy();

   
   // If we are running optimizations close the DB for this EA instance
   if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) {
      //copyValuesFromInputs();                               // Copy over values fed in from optimization
   }

   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyParameters::~EAStrategyParameters() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::openSQLDatabase() {

   //--- create or open the database in the common terminal folder
   _dbHandle=DatabaseOpen(_dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
   if (_dbHandle==INVALID_HANDLE) {
      printf(" -> DB open failed to open:%d",GetLastError());
      ExpertRemove();
   } else {
      Print(" -> DB: ", _dbName, " opened successfully");
   }

   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::closeSQLDatabase() {
   DatabaseClose(_dbHandle);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::loadSQLStrategy() {

   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
   #endif
   int request, count;

   resetValues();
   
   //--- create a query and get a handle for it
   request=DatabasePrepare(_dbHandle,"SELECT COUNT(), * FROM STRATEGIES WHERE isActive=1"); 
   if(request==INVALID_HANDLE) {
      Print(" -> 1 DB request failed with code:", GetLastError());
      ExpertRemove();
   }
   if (!DatabaseRead(request)) {
      Print(" -> 2 DB request failed with code:", GetLastError()); 
      ExpertRemove();
   } 

   DatabaseColumnInteger(request,0,count);               // Sanity check that only one stategy is marked as isActive
   if (count>1) {
      Print(" -> 3 DB request failed with:",count);
      ExpertRemove();
   } else {
      DatabaseColumnInteger   (request,2,isActive);
      DatabaseColumnText      (request,3,strategyComment);
      DatabaseColumnInteger   (request,4,strategyNumber);
      DatabaseColumnInteger   (request,5,runMode);
      DatabaseColumnInteger   (request,6,defaultRunMode);
      DatabaseColumnInteger   (request,7,magicNumber);
      DatabaseColumnInteger   (request,8,deviationInPoints);
      DatabaseColumnInteger   (request,9,maxSpread);
      DatabaseColumnInteger   (request,10,entryBars);
      DatabaseColumnDouble    (request,11,brokerAdminPercent);
      DatabaseColumnDouble    (request,12,interBankPercentage);
      DatabaseColumnInteger   (request,13,sessionTradingTime);
      DatabaseColumnText      (request,14,tradingStart);
      DatabaseColumnText      (request,15,tradingEnd);
      DatabaseColumnText      (request,16,marketSessions1);
      DatabaseColumnText      (request,17,marketSessions2);
      DatabaseColumnText      (request,18,marketSessions3);
      DatabaseColumnInteger   (request,19,marketOpenDelay);
      DatabaseColumnInteger   (request,20,marketCloseDelay);
      DatabaseColumnInteger   (request,21,inProfitClosePosition);
      DatabaseColumnInteger   (request,22,inLossClosePosition);
      DatabaseColumnInteger   (request,23,inLossOpenMartingale);
      DatabaseColumnInteger   (request,24,inLossOpenLongHedge);
      DatabaseColumnInteger   (request,25,closeAtEOD);
      DatabaseColumnInteger   (request,26,allowWeekendTrading);
      DatabaseColumnInteger   (request,27,dnnHedgeNumber);
      DatabaseColumnInteger   (request,28,dnnMartingaleNumber);
      DatabaseColumnInteger   (request,29,dnnLongNumber);
      DatabaseColumnInteger   (request,30,dnnShortNumber);
      DatabaseColumnInteger   (request,31,optimizationLong);
      DatabaseColumnInteger   (request,32,optimizationShort);
      DatabaseColumnInteger   (request,33,optimizationMartingale);
      DatabaseColumnInteger   (request,34,optimizationHedge);
      DatabaseColumnDouble    (request,35,swapCosts);
      DatabaseColumnInteger   (request,36,dnnType);
      DatabaseColumnInteger   (request,37,dnnIn);
      DatabaseColumnInteger   (request,38,dnnLayer1);
      DatabaseColumnInteger   (request,39,dnnLayer2);
      DatabaseColumnInteger   (request,40,dnnOut);
      DatabaseColumnInteger   (request,41,dataFrameSize);
      DatabaseColumnInteger   (request,42,lookBackBars);
      DatabaseColumnDouble    (request,43,lotSize);
      DatabaseColumnDouble    (request,44,fixedProfitTargetLong);
      DatabaseColumnDouble    (request,45,fixedLossTargetLong);
      DatabaseColumnDouble    (request,46,fixedProfitTargetShort);
      DatabaseColumnDouble    (request,47,fixedLossTargetShort);
      DatabaseColumnInteger   (request,48,maxPositionsLong);
      DatabaseColumnInteger   (request,49,maxPositionsShort);
      DatabaseColumnInteger   (request,50,maxTotalDailyPositions);
      DatabaseColumnInteger   (request,51,maxTotalDaysToHold);
      DatabaseColumnInteger   (request,52,maxMartingalePositions);
      DatabaseColumnInteger   (request,53,martingaleMultiplier);
      DatabaseColumnDouble    (request,54,maxLongHedgeLossAmountAllowed);
      DatabaseColumnInteger   (request,55,s_ADXperiod);
      DatabaseColumnInteger   (request,56,s_ADXma);
      DatabaseColumnInteger   (request,57,m_ADXperiod);
      DatabaseColumnInteger   (request,58,m_ADXma);
      DatabaseColumnInteger   (request,59,l_ADXperiod);
      DatabaseColumnInteger   (request,60,l_ADXma);
      DatabaseColumnInteger   (request,61,s_RSIperiod);
      DatabaseColumnInteger   (request,62,s_RSIma);
      DatabaseColumnInteger   (request,63,s_RSIap);
      DatabaseColumnInteger   (request,64,m_RSIperiod);
      DatabaseColumnInteger   (request,65,m_RSIma);
      DatabaseColumnInteger   (request,66,s_RSIap);
      DatabaseColumnInteger   (request,67,l_RSIperiod);
      DatabaseColumnInteger   (request,68,l_RSIma);
      DatabaseColumnInteger   (request,69,l_RSIap);
      DatabaseColumnInteger   (request,70,s_MFIperiod);
      DatabaseColumnInteger   (request,71,s_MFIma);
      DatabaseColumnInteger   (request,72,m_MFIperiod);
      DatabaseColumnInteger   (request,73,m_MFIma);
      DatabaseColumnInteger   (request,74,l_MFIperiod);
      DatabaseColumnInteger   (request,75,l_MFIma);
      DatabaseColumnInteger   (request,76,s_SARperiod);
      DatabaseColumnDouble    (request,77,s_SARstep);
      DatabaseColumnDouble    (request,78,s_SARmax);
      DatabaseColumnInteger   (request,79,m_SARperiod);
      DatabaseColumnDouble    (request,80,m_SARstep);
      DatabaseColumnDouble    (request,81,m_SARmax);
      DatabaseColumnInteger   (request,82,l_SARperiod);
      DatabaseColumnDouble    (request,83,l_SARstep);
      DatabaseColumnDouble    (request,84,l_SARmax);
      DatabaseColumnInteger   (request,85,s_ICHperiod);
      DatabaseColumnInteger   (request,86,s_tenkan_sen);
      DatabaseColumnInteger   (request,87,s_kijun_sen);
      DatabaseColumnInteger   (request,88,s_senkou_span_b);
      DatabaseColumnInteger   (request,89,m_ICHperiod);
      DatabaseColumnInteger   (request,90,m_tenkan_sen);
      DatabaseColumnInteger   (request,91,m_kijun_sen);
      DatabaseColumnInteger   (request,92,m_senkou_span_b);
      DatabaseColumnInteger   (request,93,l_ICHperiod);
      DatabaseColumnInteger   (request,94,l_tenkan_sen);
      DatabaseColumnInteger   (request,95,l_kijun_sen);
      DatabaseColumnInteger   (request,96,l_senkou_span_b);
      DatabaseColumnInteger   (request,97,s_RVIperiod);
      DatabaseColumnInteger   (request,98,s_RVIma);
      DatabaseColumnInteger   (request,99,m_RVIperiod);
      DatabaseColumnInteger   (request,100,m_RVIma);
      DatabaseColumnInteger   (request,101,l_RVIperiod);
      DatabaseColumnInteger   (request,102,l_RVIma);
      DatabaseColumnInteger   (request,103,s_STOCperiod);
      DatabaseColumnInteger   (request,104,s_kPeriod);
      DatabaseColumnInteger   (request,105,s_dPeriod);
      DatabaseColumnInteger   (request,106,s_slowing);
      DatabaseColumnInteger   (request,107,s_STOCmamethod);
      DatabaseColumnInteger   (request,108,s_STOCpa);
      DatabaseColumnInteger   (request,109,m_STOCperiod);
      DatabaseColumnInteger   (request,110,m_kPeriod);
      DatabaseColumnInteger   (request,111,m_dPeriod);
      DatabaseColumnInteger   (request,112,m_slowing);
      DatabaseColumnInteger   (request,113,m_STOCmamethod);
      DatabaseColumnInteger   (request,114,m_STOCpa);
      DatabaseColumnInteger   (request,115,l_STOCperiod);
      DatabaseColumnInteger   (request,116,l_kPeriod);
      DatabaseColumnInteger   (request,117,l_dPeriod);
      DatabaseColumnInteger   (request,118,l_slowing);
      DatabaseColumnInteger   (request,119,l_STOCmamethod);
      DatabaseColumnInteger   (request,120,l_STOCpa);
      DatabaseColumnInteger   (request,121,s_OSMAperiod);
      DatabaseColumnInteger   (request,122,s_OSMAfastEMA);
      DatabaseColumnInteger   (request,123,s_OSMAslowEMA);
      DatabaseColumnInteger   (request,124,s_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,125,s_OSMApa);
      DatabaseColumnInteger   (request,126,m_OSMAperiod);
      DatabaseColumnInteger   (request,127,m_OSMAfastEMA);
      DatabaseColumnInteger   (request,128,m_OSMAslowEMA);
      DatabaseColumnInteger   (request,129,m_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,130,m_OSMApa);
      DatabaseColumnInteger   (request,131,l_OSMAperiod);
      DatabaseColumnInteger   (request,132,l_OSMAfastEMA);
      DatabaseColumnInteger   (request,133,l_OSMAslowEMA);
      DatabaseColumnInteger   (request,134,l_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,135,l_OSMApa);
      DatabaseColumnInteger   (request,136,s_MACDDperiod);
      DatabaseColumnInteger   (request,137,s_MACDDfastEMA);
      DatabaseColumnInteger   (request,138,s_MACDDslowEMA);
      DatabaseColumnInteger   (request,139,s_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,140,m_MACDDperiod);
      DatabaseColumnInteger   (request,141,m_MACDDfastEMA);
      DatabaseColumnInteger   (request,142,m_MACDDslowEMA);
      DatabaseColumnInteger   (request,143,m_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,144,l_MACDDperiod);
      DatabaseColumnInteger   (request,145,l_MACDDfastEMA);
      DatabaseColumnInteger   (request,146,l_MACDDslowEMA);
      DatabaseColumnInteger   (request,147,l_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,148,s_MACDBULLperiod);
      DatabaseColumnInteger   (request,149,s_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,150,s_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,151,s_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,152,m_MACDBULLperiod);
      DatabaseColumnInteger   (request,153,m_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,154,m_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,155,m_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,156,l_MACDBULLperiod);
      DatabaseColumnInteger   (request,157,l_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,158,l_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,159,l_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,160,s_MACDBEARperiod);
      DatabaseColumnInteger   (request,161,s_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,162,s_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,163,s_MACDBEARsignalPeriod);
      DatabaseColumnInteger   (request,164,m_MACDBEARperiod);
      DatabaseColumnInteger   (request,165,m_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,166,m_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,167,m_MACDBEARsignalPeriod);
      DatabaseColumnInteger   (request,168,l_MACDBEARperiod);
      DatabaseColumnInteger   (request,169,l_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,170,l_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,171,l_MACDBEARsignalPeriod);
      //DatabaseColumnInteger   (request,172,useADX);
      //DatabaseColumnInteger   (request,173,useRSI);
      //DatabaseColumnInteger   (request,174,useMFI);
      //DatabaseColumnInteger   (request,175,useSAR);
      //DatabaseColumnInteger   (request,176,useICH);
      //DatabaseColumnInteger   (request,177,useRVI);
      //DatabaseColumnInteger   (request,178,useSTOC);
      //DatabaseColumnInteger   (request,179,useOSMA);
      //DatabaseColumnInteger   (request,180,useMACD);
      //DatabaseColumnInteger   (request,181,useMACDBULLDIV);
      //DatabaseColumnInteger   (request,182,useMACDBEARDIV);

   #ifdef _WRITELOG
      string ss;
      if (bool (runMode&_RUN_NORMAL)) {
         ss="eaLog.txt";
         _txtHandle=FileOpen(ss,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);  
         commentLine;
         writeLog;

      }

      if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) {
         int rnd1 = 1000 + MathRand()%1000; // this gives 1000 - 1999 random number
         int rnd2 = 2000 + MathRand()%2000; // this gives 1000 - 1999 random number
         int rnd3 = 3000 + MathRand()%3000; // this gives 1000 - 1999 random number
         ss=StringFormat("%d%d%d.txt",rnd1,rnd2,rnd3);
         _txtHandle=FileOpen(ss,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);  
         writeLog;
      }
   #endif


   #ifdef _WRITELOG
      commentLine;
      ss=" -> Copy values from Database";
      writeLog;
      ss=StringFormat("lotSize:%.2f\n fixedProfitTargetLong:%.2f\n fixedLossTargetLong:%.2f\n fixedProfitTargetShort:%.2f\n maxPositionsLong:%d\n maxPositionsShort:%d\n "
         "maxTotalDailyPositions:%d\n maxTotalDaysToHold:%d\n maxLongHedgeLossAmountAllowed:%3.2f\n maxMartingalePositions:%d\n martingaleMultiplier%d\n",
         lotSize,fixedProfitTargetLong,fixedLossTargetLong,fixedProfitTargetShort,maxPositionsLong,maxPositionsShort,maxTotalDailyPositions,maxTotalDaysToHold,
         maxLongHedgeLossAmountAllowed,maxMartingalePositions,martingaleMultiplier);
      writeLog;
      ss=StringFormat("Short ADX Period:%s\n Short ADX MA:%d\n Medium ADX Period:%s\n Medium ADX MA:%d\n Long ADX Period:%s\n Long ADX MA:%d\n",
         EnumToString(s_ADXperiod),s_ADXma,EnumToString(m_ADXperiod),m_ADXma,EnumToString(l_ADXperiod),l_ADXma);
      writeLog;
   #endif



   }

   // Convert some data fields so the new DB format works with 
   // the older code and does not required extensive changes
   // DB field to local conversion create logical AND mask
   if (inProfitClosePosition) {
      closingTypes=closingTypes+_IN_PROFIT_CLOSE_POSITION;
   }
      
   if (inLossClosePosition) {
      closingTypes=closingTypes+_IN_LOSS_CLOSE_POSITION;
   }
      
   if (inLossOpenMartingale) {
      closingTypes=closingTypes+_IN_LOSS_OPEN_MARTINGALE;
   }
      
   if (inLossOpenLongHedge) {
      closingTypes=closingTypes+_IN_LOSS_OPEN_LONG_HEDGE;
   }
      
   if (closeAtEOD) {
      closingTypes=closingTypes+_CLOSE_AT_EOD;
   }
      

   if (marketSessions1=="YES") {
      marketSessions[0]=_YES;
   } else {
      marketSessions[0]=_NO; 
   }     
   if (marketSessions2=="YES") {
      marketSessions[1]=_YES; 
   } else {
      marketSessions[1]=_NO; 
   } 
   if (marketSessions3=="YES") {
      marketSessions[2]=_YES;
   } else {
      marketSessions[2]=_NO; 
   }  

   switch (dnnType) {
      case 1:  dnnType=_LONG;
      break;
      case 2:  dnnType=_SHORT;
      break;
      case 4:  dnnType=_HEDGE;
      break;
      case 8:  dnnType=_MARTINGALE;
      break;
   }

   if (runMode&_RUN_COPY_OPTIMIZATION) copyOptimizationResults();

   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::resetValues() {

      runMode=0;
      orderTypeToOpen=0;
      strategyNumber=0;            // Name of strategy for comment 
      magicNumber=0;
      deviationInPoints=0; 
      maxSpread=0;                 // Limit the spread to non stupid values
      runOnFrequency=0; 
      marketOpenDelay=0;           // In minutes                   
      marketCloseDelay=0;          // In minutes  minus -30 to close 30 before end of session  
      marketSessions[_FIRST_SESSION]=_NO;   // _YES _NO of session to use     
      marketSessions[_SECOND_SESSION]=_NO;       
      marketSessions[_THIRD_SESSION]=_NO;
      tradingStart="";           // NYSE time is 16:50=8:50 premarket to 23:00=16:00 market close                        
      tradingEnd="";    
      allowWeekendTrading=_NOTSET ;     // _YES OR _NO                
      sessionTradingTime=0 ;     // _ANYTIME OR _SESSION_TIME OR _FIXED_TIME
      closingTypes=0; 
      inProfitClosePosition=0;
      inLossClosePosition=0;
      inLossOpenMartingale=0;
      inLossOpenLongHedge=0;
      closeAtEOD=0;                               
      entryBars=0;
      triggerReset=_NOTSET ;                        
      triggerResetCounter=0;
      interBankPercentage=0.0;                
      lotSize=0; 
      fixedProfitTargetLong=0;      // Dollar Value
      fixedLossTargetLong=00;       // same
      fixedProfitTargetShort=0;     // same
      fixedLossTargetShort=0;       // Dollar Valu
      lookBackBars=1;
      dataFrameSize=500;
      dnnType=0;
      dnnHedgeNumber=0;
      dnnMartingaleNumber=0;
      dnnLongNumber=0;
      dnnShortNumber=0;
      maxMartingalePositions=0;          
      maxLongHedgeLossAmountAllowed=0;
      martingaleMultiplier=0;  
      maxPositionsLong=0;
      maxPositionsShort=0;
      maxTotalDailyPositions=0;
      maxTotalDaysToHold=0;
      optimizationLong=0;
      optimizationShort=0;
      optimizationMartingale=0;
      optimizationHedge=0;
      swapCosts=0;
      defaultRunMode=_RUN_NORMAL+_RUN_SHOW_PANEL+_RUN_SAVE_STATE;
      strategyComment="";


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::checkSQLDatabase() {

   return;

   int request1, request2;
   string sqlString;
   
   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
      string ss;
   #endif 

   if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) return;   // No updates during optimizations

   sqlString=StringFormat("SELECT runMode, defaultRunMode FROM STRATEGIES WHERE strategyNumber=%d",strategyNumber);
   #ifdef _DEBUG_PARAMETERS
      Print (" -> ",sqlString);
   #endif 

   //--- create a query and get a handle for it
   request1=DatabasePrepare(_dbHandle, sqlString);
   if (request1==INVALID_HANDLE) {
      #ifdef _DEBUG_PARAMETERS
         Print(" -> DatabasePrepare: request failed with code ", GetLastError());
      #endif
      return;
   }

   if (!DatabaseRead(request1)) {
      #ifdef _DEBUG_PARAMETERS
         Print(" -> DatabaseRead: request failed with code ", GetLastError());
      #endif   
      return;
   } 
   DatabaseColumnInteger(request1,0,runMode);
   DatabaseColumnInteger(request1,1,defaultRunMode);
   DatabaseFinalize(request1);
   Print(runMode);
   Print(defaultRunMode);

   if (bool (runMode&_RUN_UPDATE)||bool (runMode&_RUN_COPY_OPTIMIZATION)) {
      // Now Update DB back to a normal state so we dont re-read the same over and over
      sqlString=StringFormat("UPDATE STRATEGIES SET runMode=%d WHERE strategyNumber=%d",defaultRunMode,strategyNumber);
      #ifdef _DEBUG_PARAMETERS
         Print(" -> ",sqlString);
      #endif
      request2=DatabasePrepare(_dbHandle,sqlString); 
      if (request2==INVALID_HANDLE) {
         #ifdef _DEBUG_PARAMETERS
            Print(" -> DatabasePrepare failed with code ", GetLastError());
         #endif
         return;
      }
      if (!DatabaseExecute(_dbHandle,sqlString)) {
         #ifdef _DEBUG_PARAMETERS
            Print(" -> DB request failed with code ", GetLastError());
         #endif
         return;
      }
      DatabaseFinalize(request2);

      // Now reload the strategy because it has changes in it
      if (bool (runMode&_RUN_UPDATE)) {
         loadSQLStrategy();
      }
      if (bool (runMode&_RUN_COPY_OPTIMIZATION)) {
         #ifdef _DEBUG_OPTIMIZATIONCOPY
            Print(" -> Optimization copy initiated");
         #endif 
         copyOptimizationResults();
      }

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::copyValuesFromInputs() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> Copy values from inputs (Optimization)";
      writeLog;
   #endif

   lotSize=ilsize;
   fixedProfitTargetLong=ifptl;
   fixedLossTargetLong=ifltl;
   fixedProfitTargetShort=ifpts;
   fixedLossTargetShort=iflts;
   maxPositionsLong=imaxlong;
   maxPositionsShort=imaxshort;
   maxTotalDailyPositions=imaxdaily;
   maxTotalDaysToHold=imaxdailyhold;   
   maxLongHedgeLossAmountAllowed=ilongHLossamt;
   maxMartingalePositions=imaxmg;
   martingaleMultiplier=imgmulti;
   
   #ifdef _WRITELOG
      commentLine;
      ss=StringFormat("lotSize:%.2f\n fixedProfitTargetLong:%.2f\n fixedLossTargetLong:%.2f\n fixedProfitTargetShort:%.2f\n fixedLossTargetShort:%.2f\n maxPositionsLong:%d\n maxPositionsShort:%d\n "
         "maxTotalDailyPositions:%d\n maxTotalDaysToHold:%d\n maxLongHedgeLossAmountAllowed:%3.2f\n maxMartingalePositions:%d\n martingaleMultiplier%d",
         lotSize,fixedProfitTargetLong,fixedLossTargetLong,fixedProfitTargetShort,fixedLossTargetShort,maxPositionsLong,maxPositionsShort,maxTotalDailyPositions,maxTotalDaysToHold,
         maxLongHedgeLossAmountAllowed,maxMartingalePositions,martingaleMultiplier);
      writeLog;
   #endif
   

   useADX=iuseADX;
   s_ADXperiod=is_ADXperiod;
   s_ADXma=is_ADXma;
   m_ADXperiod=im_ADXperiod;
   m_ADXma=im_ADXma;
   l_ADXperiod=il_ADXperiod;
   l_ADXma=il_ADXma;
   
   #ifdef _WRITELOG
      commentLine;
      ss=StringFormat("Short ADX Period:%s\n Short ADX MA:%d\n Medium ADX Period:%s\n Medium ADX MA:%d\n Long ADX Period:%s\n Long ADX MA:%d",
         EnumToString(s_ADXperiod),s_ADXma,EnumToString(m_ADXperiod),m_ADXma,EnumToString(l_ADXperiod),l_ADXma);
      writeLog;
   #endif
   

   useRSI=iuseRSI;
   s_RSIperiod=is_RSIperiod;
   s_RSIma=is_RSIma;
   s_RSIap=is_RSIap;
   m_RSIperiod=im_RSIperiod;
   m_RSIma=im_RSIma;
   s_RSIap=is_RSIap;
   l_RSIperiod=il_RSIperiod;
   l_RSIma=il_RSIma;
   l_RSIap=il_RSIap;

   useMFI=iuseMFI;
   s_MFIperiod=is_MFIperiod;
   s_MFIma=is_MFIma;
   m_MFIperiod=im_MFIperiod;
   m_MFIma=im_MFIma;
   l_MFIperiod=il_MFIperiod;
   l_MFIma=il_MFIma;

   useSAR=iuseSAR;
   s_SARperiod=is_SARperiod;
   s_SARstep=is_SARstep;
   s_SARmax=is_SARmax;
   m_SARperiod=im_SARperiod;
   m_SARstep=im_SARstep;
   m_SARmax=im_SARmax;
   l_SARperiod=il_SARperiod;
   l_SARstep=il_SARstep;
   l_SARmax=il_SARmax;

   useICH=iuseICH;
   s_ICHperiod=is_ICHperiod;
   s_tenkan_sen=is_tenkan_sen;
   s_kijun_sen=is_kijun_sen;
   s_senkou_span_b=is_senkou_span_b;
   m_ICHperiod=im_ICHperiod;
   m_tenkan_sen=im_tenkan_sen;
   m_kijun_sen=im_kijun_sen;
   m_senkou_span_b=im_senkou_span_b;
   l_ICHperiod=il_ICHperiod;
   l_tenkan_sen=il_tenkan_sen;
   l_kijun_sen=il_kijun_sen;
   l_senkou_span_b=il_senkou_span_b;

   useRVI=iuseRVI;
   s_RVIperiod=is_RVIperiod;
   s_RVIma=is_RVIma;
   m_RVIperiod=im_RVIperiod;
   m_RVIma=im_RVIma;
   l_RVIperiod=il_RVIperiod;
   l_RVIma=il_RVIma;

   useSTOC=iuseSTOC;
   s_STOCperiod=is_STOCperiod;
   s_kPeriod=is_kPeriod;
   s_dPeriod=is_dPeriod;
   s_slowing=is_slowing;
   s_STOCmamethod=is_STOCmamethod;
   s_STOCpa=is_STOCpa;
   m_STOCperiod=im_STOCperiod;
   m_kPeriod=im_kPeriod;
   m_dPeriod=im_dPeriod;
   m_slowing=im_slowing;
   m_STOCmamethod=im_STOCmamethod;
   m_STOCpa=im_STOCpa;
   l_STOCperiod=il_STOCperiod;
   l_kPeriod=il_kPeriod;
   l_dPeriod=il_dPeriod;
   l_slowing=il_slowing;
   l_STOCmamethod=il_STOCmamethod;
   l_STOCpa=il_STOCpa;

   useOSMA=iuseOSMA;
   s_OSMAperiod=is_OSMAperiod;
   s_OSMAfastEMA=is_OSMAfastEMA;
   s_OSMAslowEMA=is_OSMAslowEMA;
   s_OSMAsignalPeriod=is_OSMAsignalPeriod;
   s_OSMApa=is_OSMApa;
   m_OSMAperiod=im_OSMAperiod;
   m_OSMAfastEMA=im_OSMAfastEMA;
   m_OSMAslowEMA=im_OSMAslowEMA;
   m_OSMAsignalPeriod=im_OSMAsignalPeriod;
   m_OSMApa=im_OSMApa;
   l_OSMAperiod=il_OSMAperiod;
   l_OSMAfastEMA=il_OSMAfastEMA;
   l_OSMAslowEMA=il_OSMAslowEMA;
   l_OSMAsignalPeriod=il_OSMAsignalPeriod;
   l_OSMApa=il_OSMApa;

   useMACD=iuseMACD;
   s_MACDDperiod=is_MACDDperiod;
   s_MACDDfastEMA=is_MACDDfastEMA;
   s_MACDDslowEMA=is_MACDDslowEMA;
   s_MACDDsignalPeriod=is_MACDDsignalPeriod;
   m_MACDDperiod=im_MACDDperiod;
   m_MACDDfastEMA=im_MACDDfastEMA;
   m_MACDDslowEMA=im_MACDDslowEMA;
   m_MACDDsignalPeriod=im_MACDDsignalPeriod;
   l_MACDDperiod=il_MACDDperiod;
   l_MACDDfastEMA=il_MACDDfastEMA;
   l_MACDDslowEMA=il_MACDDslowEMA;
   l_MACDDsignalPeriod=il_MACDDsignalPeriod;
   s_MACDBULLperiod=is_MACDBULLperiod;
   s_MACDBULLfastEMA=is_MACDBULLfastEMA;
   s_MACDBULLslowEMA=is_MACDBULLslowEMA;
   s_MACDBULLsignalPeriod=is_MACDBULLsignalPeriod;
   m_MACDBULLperiod=im_MACDBULLperiod;
   m_MACDBULLfastEMA=im_MACDBULLfastEMA;
   m_MACDBULLslowEMA=im_MACDBULLslowEMA;
   m_MACDBULLsignalPeriod=im_MACDBULLsignalPeriod;
   l_MACDBULLperiod=il_MACDBULLperiod;
   l_MACDBULLfastEMA=il_MACDBULLfastEMA;
   l_MACDBULLslowEMA=il_MACDBULLslowEMA;
   l_MACDBULLsignalPeriod=il_MACDBULLsignalPeriod;
   s_MACDBEARperiod=is_MACDBEARperiod;
   s_MACDBEARfastEMA=is_MACDBEARfastEMA;
   s_MACDBEARslowEMA=is_MACDBEARslowEMA;
   s_MACDBEARsignalPeriod=is_MACDBEARsignalPeriod;
   m_MACDBEARperiod=im_MACDBEARperiod;
   m_MACDBEARfastEMA=im_MACDBEARfastEMA;
   m_MACDBEARslowEMA=im_MACDBEARslowEMA;
   m_MACDBEARsignalPeriod=im_MACDBEARsignalPeriod;
   l_MACDBEARperiod=il_MACDBEARperiod;
   l_MACDBEARfastEMA=il_MACDBEARfastEMA;
   l_MACDBEARslowEMA=il_MACDBEARslowEMA;
   l_MACDBEARsignalPeriod=il_MACDBEARsignalPeriod;

   useZZ=iuseZZ;
   s_ZZperiod=is_ZZperiod;
   m_ZZperiod=im_ZZperiod;
   l_ZZperiod=il_ZZperiod;

   useMACDBULLDIV=iuseMACDBULLDIV;
   useMACDBEARDIV=iuseMACDBEARDIV;
   //dataFrameSize=idataFrameSize;
   //lookBackBars=ilookBackBars;



   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::closeSQLPosition(EAPosition *p) {

   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
      string ss;
   #endif 

   updateSQLSwapCosts(p);
   deleteSQLPosition(p.ticket);

   #ifdef _DEBUG_PARAMETERS
      Print(" -> Normal Mode update Swap and SQL position table");
   #endif 
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::loadSQLState() { 

   EAPosition  *p;
   string      closingDateTime;
   int         request;         

   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
   #endif

   if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) return;   // No state saving during optimizations
   if (!bool (runMode&_RUN_SAVE_STATE)) return;             // No state saving enabled

   string sqlString=StringFormat("SELECT * FROM STATE WHERE strategyNumber=%d",strategyNumber);
   #ifdef _DEBUG_PARAMETERS
      Print(sqlString);
   #endif
   
      //--- create a query and get a handle for it
      request=DatabasePrepare(_dbHandle,sqlString); 
      
      if(request==INVALID_HANDLE) {
         #ifdef _DEBUG_PARAMETERS
            Print(" -> DB request failed with code ", GetLastError());
         #endif
         return;
      }

      for(int i=0; DatabaseRead(request); i++) {
         p=new EAPosition();

         if (DatabaseColumnInteger     (request,1,p.strategyNumber) && 
            DatabaseColumnInteger      (request,2,p.ticket) &&
            DatabaseColumnDouble       (request,3,p.entryPrice) && 
            DatabaseColumnDouble       (request,4,p.lotSize) && 
            DatabaseColumnInteger      (request,5,p.orderTypeToOpen) && 
            DatabaseColumnDouble       (request,6, p.fixedProfitTargetLevel) &&
            DatabaseColumnDouble       (request,7,p.fixedLossTargetLevel)&&
            DatabaseColumnInteger      (request,8,p.daysOpen)&&
            DatabaseColumnDouble       (request,9,p.currentPnL)&&
            DatabaseColumnDouble       (request,10,p.swapCosts)&&
            DatabaseColumnInteger      (request,11,p.status)&&
            DatabaseColumnText         (request,12, closingDateTime)&& 
            DatabaseColumnInteger      (request,13,p.closingTypes)&&
            DatabaseColumnInteger      (request,14,p.deviationInPoints)) {

               #ifdef _DEBUG_PARAMETERS
                  printf(" -> Loaded ticket:%d success",p.ticket);
               #endif
               p.closingDateTime=StringToTime(closingDateTime);

               switch (p.status) {
                  case _LONG:       longPositions.Add(p); 
                  break;
                  case _SHORT:      shortPositions.Add(p); 
                  break;
                  case _MARTINGALE: martingalePositions.Add(p); 
                  break;
                  case _HEDGE:      longHedgePositions.Add(p); 
                  break;
            }
         } 
      }

      DatabaseFinalize(request); 
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::saveSQLState(EAPosition *p) { 

   string sqlString;
   int request;

   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
   #endif

   if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) return;   // No state saving during optimizations
   if (!bool (runMode&_RUN_SAVE_STATE)) return;             // No state saving enabled

   sqlString=StringFormat("INSERT INTO STATE ("
      "strategyName,strategyNumber,ticket,entryPrice,lotSize,orderTypeToOpen,fixedProfitTargetLevel,"
      "fixedLossTargetLevel,daysOpen,currentPnL,swapCosts,status,closingDateTime,closingTypes,deviationInPoints)"
      " VALUES ('%s',%d,%d,%g,%g,%d,%g,%g,%d,%g,%g,%d,'%s',%d,%d)",usingStrategyValue.strategyName,usingStrategyValue.strategyNumber, p.ticket,p.entryPrice,p.lotSize,p.orderTypeToOpen,p.fixedProfitTargetLevel,p.fixedLossTargetLevel,p.daysOpen,
      p.currentPnL,p.swapCosts,p.status,TimeToString(p.closingDateTime,TIME_DATE),p.closingTypes,p.deviationInPoints);
      
   #ifdef _DEBUG_PARAMETERS
      Print(sqlString);
   #endif
   

   request=DatabasePrepare(_dbHandle,sqlString); 
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_PARAMETERS
         Print(" -> DB request failed with code ", GetLastError());
      #endif
      return;
   }

   if(!DatabaseExecute(_dbHandle,sqlString)) {
      #ifdef _DEBUG_PARAMETERS
         Print("DB: insert failed with code ", GetLastError());
      #endif
      return;
   }
   
   DatabaseFinalize(request); 

} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::deleteSQLPosition(int ticket) {

   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
   #endif

   string sqlString;
   int request;

   if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) return;   // No state saving during optimizations
   if (!bool (runMode&_RUN_SAVE_STATE)) return;             // No state saving enabled
   
   sqlString=StringFormat("DELETE FROM STATE WHERE ticket=%d",ticket);
   #ifdef _DEBUG_PARAMETERS
      Print(" -> ",sqlString);
   #endif

   request=DatabasePrepare(_dbHandle,sqlString); 
   if (request==INVALID_HANDLE) {
      Print(" -> DB request failed with code ", GetLastError());
         return;
   }
   if (!DatabaseExecute(_dbHandle,sqlString)) {
      Print(" -> DB request failed with code ", GetLastError());
   }
   
   DatabaseFinalize(request); 

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::updateSQLSwapCosts(EAPosition *p) {


   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
   #endif

   int request;
   double swapCosts;
   string sqlString;
   
      if (bool (runMode&_RUN_STRATEGY_OPTIMIZATION)) return;   // No state saving during optimizations

      sqlString=StringFormat("SELECT swapCosts FROM STRATEGIES WHERE strategyNumber=%d",strategyNumber);
      #ifdef _DEBUG_PARAMETERS
            Print(" -> ",sqlString);
      #endif

        //--- create a query and get a handle for it
      request=DatabasePrepare(_dbHandle,sqlString); 
      if (request==INVALID_HANDLE) {
         Print(" -> DB request failed with code ", GetLastError());
         return;
      }

      DatabaseRead(request);
      DatabaseColumnDouble(request,0,swapCosts); 
      DatabaseFinalize(request); 

      // Bump the swap costs
      double result=swapCosts+p.swapCosts;
      TesterWithdrawal(p.swapCosts);  // withdraw from account when testing

      // Update DB
      sqlString=StringFormat("UPDATE STRATEGIES SET swapCosts=%g WHERE strategyNumber=%d",result, usingStrategyValue.strategyNumber);
      #ifdef _DEBUG_PARAMETERS
         Print(" -> ",sqlString);
      #endif

      request=DatabasePrepare(_dbHandle,sqlString); 
      if( request==INVALID_HANDLE) {
         Print(" -> DB request failed with code ", GetLastError());
         return;
      }
      if (!DatabaseExecute(_dbHandle,sqlString)) {
         Print(" -> DB request failed with code ", GetLastError());
      }
      
      DatabaseFinalize(request); 
      
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::copyOptimizationResults() {


   #ifdef _DEBUG_PARAMETERS
      Print(__FUNCTION__);
   #endif


   //--- create or open the database in the common terminal folder
   _dbHandle1=DatabaseOpen("optimization", DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
   if (_dbHandle1==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         printf(" -> DB open failed with code %d",GetLastError());
      #endif 
   } else {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         printf(" -> DB optimization open success");
      #endif 
   }


      //--- create a query and get a handle for it
      int request=DatabasePrepare(_dbHandle1,"SELECT * from PASSES where selection=1"); 
      if(request==INVALID_HANDLE) {
         #ifdef _DEBUG_OPTIMIZATIONCOPY
            printf(" -> DB query failed with code %d",GetLastError());
         #endif 
         return;
      }

      if (!DatabaseRead(request)) {
         #ifdef _DEBUG_OPTIMIZATIONCOPY
            printf(" -> DB read failed with code %d",GetLastError());
         #endif   
         return;

      } else {

      
         DatabaseColumnDouble(request,23,lotSize);
         DatabaseColumnDouble(request,24,fixedProfitTargetLong);
         DatabaseColumnDouble(request,25,fixedLossTargetLong);
         DatabaseColumnDouble(request,26,fixedProfitTargetShort);
         DatabaseColumnDouble(request,27,fixedLossTargetShort);
         DatabaseColumnInteger(request,28,maxPositionsLong);
         DatabaseColumnInteger(request,29,maxPositionsShort);
         DatabaseColumnInteger(request,30,maxTotalDailyPositions);
         DatabaseColumnInteger(request,31,maxTotalDaysToHold);
         DatabaseColumnInteger(request,32,maxMartingalePositions);
         DatabaseColumnInteger(request,33,martingaleMultiplier);
         DatabaseColumnDouble(request,34,maxLongHedgeLossAmountAllowed                                                                            );
         DatabaseColumnInteger(request,35,s_ADXperiod);
         DatabaseColumnInteger(request,36,s_ADXma);
         DatabaseColumnInteger(request,37,m_ADXperiod);
         DatabaseColumnInteger(request,38,m_ADXma);
         DatabaseColumnInteger(request,39,l_ADXperiod);
         DatabaseColumnInteger(request,40,l_ADXma);
         DatabaseColumnInteger(request,41,s_RSIperiod);
         DatabaseColumnInteger(request,42,s_RSIma);
         DatabaseColumnInteger(request,43,s_RSIap);
         DatabaseColumnInteger(request,44,m_RSIperiod);
         DatabaseColumnInteger(request,45,m_RSIma);
         DatabaseColumnInteger(request,46,m_RSIap);
         DatabaseColumnInteger(request,47,l_RSIperiod);
         DatabaseColumnInteger(request,48,l_RSIma);
         DatabaseColumnInteger(request,49,l_RSIap);
         DatabaseColumnInteger(request,50,s_MFIperiod);
         DatabaseColumnInteger(request,51,s_MFIma);
         DatabaseColumnInteger(request,52,m_MFIperiod);
         DatabaseColumnInteger(request,53,m_MFIma);
         DatabaseColumnInteger(request,54,l_MFIperiod);
         DatabaseColumnInteger(request,55,l_MFIma);
         DatabaseColumnInteger(request,56,s_SARperiod);
         DatabaseColumnDouble(request,57,s_SARstep);
         DatabaseColumnDouble(request,58,s_SARmax);
         DatabaseColumnInteger(request,59,m_SARperiod);
         DatabaseColumnDouble(request,60,m_SARstep);
         DatabaseColumnDouble(request,61,m_SARmax);
         DatabaseColumnInteger(request,62,l_SARperiod);
         DatabaseColumnDouble(request,63,l_SARstep);
         DatabaseColumnDouble(request,64,l_SARmax);
         DatabaseColumnInteger(request,65,s_ICHperiod);
         DatabaseColumnInteger(request,66,s_tenkan_sen);
         DatabaseColumnInteger(request,67,s_kijun_sen);
         DatabaseColumnInteger(request,68,s_senkou_span_b);
         DatabaseColumnInteger(request,69,m_ICHperiod);
         DatabaseColumnInteger(request,70,m_tenkan_sen);
         DatabaseColumnInteger(request,71,m_kijun_sen);
         DatabaseColumnInteger(request,72,m_senkou_span_b);
         DatabaseColumnInteger(request,73,l_ICHperiod);
         DatabaseColumnInteger(request,74,l_tenkan_sen);
         DatabaseColumnInteger(request,75,l_kijun_sen);
         DatabaseColumnInteger(request,76,l_senkou_span_b);
         DatabaseColumnInteger(request,77,s_RVIperiod);
         DatabaseColumnInteger(request,78,s_RVIma);
         DatabaseColumnInteger(request,79,m_RVIperiod);
         DatabaseColumnInteger(request,80,m_RVIma);
         DatabaseColumnInteger(request,81,l_RVIperiod);
         DatabaseColumnInteger(request,82,l_RVIma);
         DatabaseColumnInteger(request,83,s_STOCperiod);
         DatabaseColumnInteger(request,84,s_kPeriod);
         DatabaseColumnInteger(request,85,s_dPeriod);
         DatabaseColumnInteger(request,86,s_slowing);
         DatabaseColumnInteger(request,87,s_STOCmamethod);
         DatabaseColumnInteger(request,88,s_STOCpa);
         DatabaseColumnInteger(request,89,m_STOCperiod);
         DatabaseColumnInteger(request,90,m_kPeriod);
         DatabaseColumnInteger(request,91,m_dPeriod);
         DatabaseColumnInteger(request,92,m_slowing);
         DatabaseColumnInteger(request,93,m_STOCmamethod);
         DatabaseColumnInteger(request,94,m_STOCpa);
         DatabaseColumnInteger(request,95,l_STOCperiod);
         DatabaseColumnInteger(request,96,l_kPeriod);
         DatabaseColumnInteger(request,97,l_dPeriod);
         DatabaseColumnInteger(request,98,l_slowing);
         DatabaseColumnInteger(request,99,l_STOCmamethod);
         DatabaseColumnInteger(request,100,l_STOCpa);
         DatabaseColumnInteger(request,101,s_OSMAperiod);
         DatabaseColumnInteger(request,102,s_OSMAfastEMA);
         DatabaseColumnInteger(request,103,s_OSMAslowEMA);
         DatabaseColumnInteger(request,104,s_OSMAsignalPeriod);
         DatabaseColumnInteger(request,105,s_OSMApa);
         DatabaseColumnInteger(request,106,m_OSMAperiod);
         DatabaseColumnInteger(request,107,m_OSMAfastEMA);
         DatabaseColumnInteger(request,108,m_OSMAslowEMA);
         DatabaseColumnInteger(request,109,m_OSMAsignalPeriod);
         DatabaseColumnInteger(request,110,m_OSMApa);
         DatabaseColumnInteger(request,111,l_OSMAperiod);
         DatabaseColumnInteger(request,112,l_OSMAfastEMA);
         DatabaseColumnInteger(request,113,l_OSMAslowEMA);
         DatabaseColumnInteger(request,114,l_OSMAsignalPeriod);
         DatabaseColumnInteger(request,115,l_OSMApa);
         DatabaseColumnInteger(request,116,s_MACDDperiod);
         DatabaseColumnInteger(request,117,s_MACDDfastEMA);
         DatabaseColumnInteger(request,118,s_MACDDslowEMA);
         DatabaseColumnInteger(request,119,s_MACDDsignalPeriod);
         DatabaseColumnInteger(request,120,m_MACDDperiod);
         DatabaseColumnInteger(request,121,m_MACDDfastEMA);
         DatabaseColumnInteger(request,122,m_MACDDslowEMA);
         DatabaseColumnInteger(request,123,m_MACDDsignalPeriod);
         DatabaseColumnInteger(request,124,l_MACDDperiod);
         DatabaseColumnInteger(request,125,l_MACDDfastEMA);
         DatabaseColumnInteger(request,126,l_MACDDslowEMA);
         DatabaseColumnInteger(request,127,l_MACDDsignalPeriod);
         DatabaseColumnInteger(request,128,s_MACDBULLperiod);
         DatabaseColumnInteger(request,129,s_MACDBULLfastEMA);
         DatabaseColumnInteger(request,130,s_MACDBULLslowEMA);
         DatabaseColumnInteger(request,131,s_MACDBULLsignalPeriod);
         DatabaseColumnInteger(request,132,m_MACDBULLperiod);
         DatabaseColumnInteger(request,133,m_MACDBULLfastEMA);
         DatabaseColumnInteger(request,134,m_MACDBULLslowEMA);
         DatabaseColumnInteger(request,135,m_MACDBULLsignalPeriod);
         DatabaseColumnInteger(request,136,l_MACDBULLperiod);
         DatabaseColumnInteger(request,137,l_MACDBULLfastEMA);
         DatabaseColumnInteger(request,138,l_MACDBULLslowEMA);
         DatabaseColumnInteger(request,139,l_MACDBULLsignalPeriod);
         DatabaseColumnInteger(request,140,s_MACDBEARperiod);
         DatabaseColumnInteger(request,141,s_MACDBEARfastEMA);
         DatabaseColumnInteger(request,142,s_MACDBEARslowEMA);
         DatabaseColumnInteger(request,143,s_MACDBEARsignalPeriod);
         DatabaseColumnInteger(request,144,m_MACDBEARperiod);
         DatabaseColumnInteger(request,145,m_MACDBEARfastEMA);
         DatabaseColumnInteger(request,146,m_MACDBEARslowEMA);
         DatabaseColumnInteger(request,147,m_MACDBEARsignalPeriod);
         DatabaseColumnInteger(request,148,l_MACDBEARperiod);
         DatabaseColumnInteger(request,149,l_MACDBEARfastEMA);
         DatabaseColumnInteger(request,150,l_MACDBEARslowEMA);
         DatabaseColumnInteger(request,151,l_MACDBEARsignalPeriod);
         
         #ifdef _DEBUG_OPTIMIZATIONCOPY
            printf(" -> Values read from passed lotsize:%2.2f maxlong:%d %d %d %d",lotSize,maxPositionsLong,s_kijun_sen,m_OSMAsignalPeriod,l_MACDBEARsignalPeriod);
         #endif 

      }

      // =====Update Stategies 
/*
      // Determine the so we can save the appropriate dnn details
      switch (_dnnType) {
         case 1:sql2=StringFormat("dnnLongNumber=%d",_dnnNumber);
         break;
         case 2:sql2=StringFormat("dnnShortNumber=%d",_dnnNumber);
         break;
         case 3:sql2=StringFormat("dnnMartingaleNumber=%d",_dnnNumber);
         break;
         case 4:sql2=StringFormat("dnnHedgeNumber=%d",_dnnNumber);
         break;
      }
*/
      string sql1a=StringFormat("UPDATE STRATEGIES SET "
         "lotSize=%0.2f,fptl=%3.2f,fltl=%3.2f,fpts=%3.2f,flts=%3.2f,maxlong=%d,maxshort=%d,maxdaily=%d,maxdailyhold=%d,maxmg=%d,mgmulti=%d,longHLossamt=%3.2f,",
         lotSize,fixedLossTargetLong,fixedLossTargetLong,fixedProfitTargetShort,fixedLossTargetShort,maxPositionsLong,maxPositionsShort,maxTotalDailyPositions,
         maxTotalDaysToHold,maxMartingalePositions,martingaleMultiplier,maxLongHedgeLossAmountAllowed);
         printf("%s",sql1a);

      string sql1b=StringFormat("s_ADXperiod=%d,s_ADXma=%d,m_ADXperiod=%d,m_ADXma=%d,l_ADXperiod=%d,l_ADXma=%d,s_RSIperiod=%d,s_RSIma=%d,s_RSIap=%d,m_RSIperiod=%d,m_RSIma=%d,m_RSIap=%d,l_RSIperiod=%d,l_RSIma=%d,l_RSIap=%d,s_MFIperiod=%d,"
         "s_MFIma=%d,m_MFIperiod=%d,m_MFIma=%d,l_MFIperiod=%d,l_MFIma=%d,",s_ADXperiod,s_ADXma,m_ADXperiod,m_ADXma,l_ADXperiod,l_ADXma,s_RSIperiod,s_RSIma,s_RSIap,m_RSIperiod,
         m_RSIma,m_RSIap,l_RSIperiod,l_RSIma,l_RSIap,s_MFIperiod,s_MFIma,m_MFIperiod,m_MFIma,l_MFIperiod,l_MFIma);
         printf("%s",sql1b);
         
      string sql1c=StringFormat("s_SARperiod=%d,s_SARstep=%0.2f,s_SARmax=%2.2f,m_SARperiod=%d,m_SARstep=%0.2f,m_SARmax=%2.2f,l_SARperiod=%d,l_SARstep=%0.2f,l_SARmax=%2.2f,s_ICHperiod=%d,"
         "s_tenkan_sen=%d,s_kijun_sen=%d,s_senkou_span_b=%d,m_ICHperiod=%d,m_tenkan_sen=%d,m_kijun_sen=%d,m_senkou_span_b=%d,l_ICHperiod=%d,l_tenkan_sen=%d,l_kijun_sen=%d,l_senkou_span_b=%d,s_RVIperiod=%d,"
         "s_RVIma=%d,m_RVIperiod=%d,m_RVIma=%d,l_RVIperiod=%d,l_RVIma=%d,",s_SARperiod,s_SARstep,s_SARmax,m_SARperiod,m_SARstep,m_SARmax,l_SARperiod,l_SARstep,l_SARmax,s_ICHperiod,s_tenkan_sen,
         s_kijun_sen,s_senkou_span_b,m_ICHperiod,m_tenkan_sen,m_kijun_sen,m_senkou_span_b,l_ICHperiod,l_tenkan_sen,l_kijun_sen,l_senkou_span_b,s_RVIperiod,s_RVIma,m_RVIperiod,m_RVIma,l_RVIperiod,l_RVIma);
         printf("%s",sql1c);
         
      string sql1d=StringFormat("s_STOCperiod=%d,s_kPeriod=%d,s_dPeriod=%d,s_slowing=%d,s_STOCmamethod=%d,s_STOCpa=%d,m_STOCperiod=%d,m_kPeriod=%d,m_dPeriod=%d,m_slowing=%d,"
         "m_STOCmamethod=%d,m_STOCpa=%d,l_STOCperiod=%d,l_kPeriod=%d,l_dPeriod=%d,l_slowing=%d,l_STOCmamethod=%d,l_STOCpa=%d,s_OSMAperiod=%d,s_OSMAfastEMA=%d,s_OSMAslowEMA=%d,s_OSMAsignalPeriod=%d,s_OSMApa=%d,m_OSMAperiod=%d,"
         "m_OSMAfastEMA=%d,m_OSMAslowEMA=%d,m_OSMAsignalPeriod=%d,m_OSMApa=%d,l_OSMAperiod=%d,l_OSMAfastEMA=%d,l_OSMAslowEMA=%d,l_OSMAsignalPeriod=%d,l_OSMApa=%d,",s_STOCperiod,s_kPeriod,s_dPeriod,
         s_slowing,s_STOCmamethod,s_STOCpa,m_STOCperiod,m_kPeriod,m_dPeriod,m_slowing,m_STOCmamethod,m_STOCpa,l_STOCperiod,l_kPeriod,l_dPeriod,l_slowing,l_STOCmamethod,l_STOCpa,s_OSMAperiod,
         s_OSMAfastEMA,s_OSMAslowEMA,s_OSMAsignalPeriod,s_OSMApa,m_OSMAperiod,m_OSMAfastEMA,m_OSMAslowEMA,m_OSMAsignalPeriod,m_OSMApa,l_OSMAperiod,l_OSMAfastEMA,l_OSMAslowEMA,l_OSMAsignalPeriod,l_OSMApa);
         printf("%s",sql1d);

      string sql1e=StringFormat("s_MACDDperiod=%d,s_MACDDfastEMA=%d,s_MACDDslowEMA=%d,s_MACDDsignalPeriod=%d,m_MACDDperiod=%d,m_MACDDfastEMA=%d,m_MACDDslowEMA=%d,m_MACDDsignalPeriod=%d,l_MACDDperiod=%d,l_MACDDfastEMA=%d,l_MACDDslowEMA=%d,l_MACDDsignalPeriod=%d,"
         "s_MACDBULLperiod=%d,s_MACDBULLfastEMA=%d,s_MACDBULLslowEMA=%d,s_MACDBULLsignalPeriod=%d,m_MACDBULLperiod=%d,m_MACDBULLfastEMA=%d,m_MACDBULLslowEMA=%d,m_MACDBULLsignalPeriod=%d,l_MACDBULLperiod=%d,"
         "l_MACDBULLfastEMA=%d,l_MACDBULLslowEMA=%d,l_MACDBULLsignalPeriod=%d,s_MACDBEARperiod=%d,s_MACDBEARfastEMA=%d,s_MACDBEARslowEMA=%d,s_MACDBEARsignalPeriod=%d,m_MACDBEARperiod=%d,m_MACDBEARfastEMA=%d,"
         "m_MACDBEARslowEMA=%d,m_MACDBEARsignalPeriod=%d,l_MACDBEARperiod=%d,l_MACDBEARfastEMA=%d,l_MACDBEARslowEMA=%d,l_MACDBEARsignalPeriod=%d WHERE strategyNumber=%d",s_MACDDperiod,
         s_MACDDfastEMA,s_MACDDslowEMA,s_MACDDsignalPeriod,m_MACDDperiod,m_MACDDfastEMA,m_MACDDslowEMA,m_MACDDsignalPeriod,l_MACDDperiod,l_MACDDfastEMA,l_MACDDslowEMA,l_MACDDsignalPeriod,s_MACDBULLperiod,
         s_MACDBULLfastEMA,s_MACDBULLslowEMA,s_MACDBULLsignalPeriod,m_MACDBULLperiod,m_MACDBULLfastEMA,m_MACDBULLslowEMA,m_MACDBULLsignalPeriod,l_MACDBULLperiod,l_MACDBULLfastEMA,l_MACDBULLslowEMA,
         l_MACDBULLsignalPeriod,s_MACDBEARperiod,s_MACDBEARfastEMA,s_MACDBEARslowEMA,s_MACDBEARsignalPeriod,m_MACDBEARperiod,m_MACDBEARfastEMA,m_MACDBEARslowEMA,m_MACDBEARsignalPeriod,l_MACDBEARperiod,l_MACDBEARfastEMA,
         l_MACDBEARslowEMA,l_MACDBEARsignalPeriod,strategyNumber);
         printf("%s",sql1e);

      string sql1=StringFormat("%s%s%s%s%s",sql1a,sql1b,sql1c,sql1d,sql1e);

   int request1=DatabasePrepare(_dbHandle,sql1); 
   if (request1==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print(" -> DB request failed with code ", GetLastError());
      #endif
      return;
   }

   if(!DatabaseExecute(_dbHandle,sql1)) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print("DB: udpate failed with code ", GetLastError());
      #endif
      return;
   }
         




}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyParameters::optimizationCreateValues(int strategyNumber, int iterationNumber, int techNumber, int dnnType) {

   string sql1, sql1a, sql1b,sql1c,sql1d,sql2, sql3, sql4, sql5, sql6;
   int req1, req2;
   // =====Get _VALUES Table from optimization
   sql1=StringFormat("SELECT * from _VALUES where iterationNumber=%d",iterationNumber);
   #ifdef _DEBUG_OPTIMIZATIONCOPY
      Print(sql1);
   #endif 
   
   // =====create a query and get a handle for it
   req1=DatabasePrepare(_dbHandle1,sql1); 
   if(req1==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         printf(" -> DB query failed with code %d",GetLastError());
      #endif 
      return;
   }

   if (!DatabaseRead(req1)) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         printf(" -> DB read failed with code %d",GetLastError());
      #endif  
      return;
   } 
   
   // =====Populate the TECH table
   double tech[140]; // ignore first 2 fields strategyNumber and iterationNumber
   for (int i=2;i<140;i++) {   // Then grab the fields
      DatabaseColumnDouble   (req1,i,tech[i-2]);
      printf(" -> Tech:%g",tech[i-2]);
   }
   DatabaseFinalize(req1);

         sql1a="INSERT INTO TECH (strategyNumber,iterationNumber,techNumber,dnnType,"                                
            "lotSize,fptl,fltl,fpts,flts,maxlong,maxshort,maxdaily,maxdailyhold,maxmg,mgmulti,longHLossamt,"                                                                           
            "s_ADXperiod,s_ADXma,m_ADXperiod,m_ADXma,l_ADXperiod,l_ADXma,s_RSIperiod,s_RSIma,s_RSIap,m_RSIperiod,m_RSIma,m_RSIap,l_RSIperiod,l_RSIma,l_RSIap,s_MFIperiod,"
            "s_MFIma,m_MFIperiod,m_MFIma,l_MFIperiod,l_MFIma,s_SARperiod,s_SARstep,s_SARmax,m_SARperiod,m_SARstep,m_SARmax,l_SARperiod,l_SARstep,l_SARmax,s_ICHperiod,";
         sql1b="s_tenkan_sen,s_kijun_sen,s_senkou_span_b,m_ICHperiod,m_tenkan_sen,m_kijun_sen,m_senkou_span_b,l_ICHperiod,l_tenkan_sen,l_kijun_sen,l_senkou_span_b,s_RVIperiod,"
            "s_RVIma,m_RVIperiod,m_RVIma,l_RVIperiod,l_RVIma,s_STOCperiod,s_kPeriod,s_dPeriod,s_slowing,s_STOCmamethod,s_STOCpa,m_STOCperiod,m_kPeriod,m_dPeriod,m_slowing,"
            "m_STOCmamethod,m_STOCpa,l_STOCperiod,l_kPeriod,l_dPeriod,l_slowing,l_STOCmamethod,l_STOCpa,s_OSMAperiod,s_OSMAfastEMA,s_OSMAslowEMA,s_OSMAsignalPeriod,s_OSMApa,m_OSMAperiod,";
         sql1c="m_OSMAfastEMA,m_OSMAslowEMA,m_OSMAsignalPeriod,m_OSMApa,l_OSMAperiod,l_OSMAfastEMA,l_OSMAslowEMA,l_OSMAsignalPeriod,l_OSMApa,s_MACDDperiod,s_MACDDfastEMA,"
            "s_MACDDslowEMA,s_MACDDsignalPeriod,m_MACDDperiod,m_MACDDfastEMA,m_MACDDslowEMA,m_MACDDsignalPeriod,l_MACDDperiod,l_MACDDfastEMA,l_MACDDslowEMA,l_MACDDsignalPeriod,";
         sql1d="s_MACDBULLperiod,s_MACDBULLfastEMA,s_MACDBULLslowEMA,s_MACDBULLsignalPeriod,m_MACDBULLperiod,m_MACDBULLfastEMA,m_MACDBULLslowEMA,m_MACDBULLsignalPeriod,l_MACDBULLperiod,"
            "l_MACDBULLfastEMA,l_MACDBULLslowEMA,l_MACDBULLsignalPeriod,s_MACDBEARperiod,s_MACDBEARfastEMA,s_MACDBEARslowEMA,s_MACDBEARsignalPeriod,m_MACDBEARperiod,m_MACDBEARfastEMA,"
            "m_MACDBEARslowEMA,m_MACDBEARsignalPeriod,l_MACDBEARperiod,l_MACDBEARfastEMA,l_MACDBEARslowEMA,l_MACDBEARsignalPeriod,useADX,useRSI,useMFI,useSAR,useICH,useRVI,useSTOC,useOSMA,useMACD,useMACDBULLDIV,useMACDBEARDIV VALUES(";  

         sql2=StringFormat("%d,%d,%d,%d,",strategyNumber,iterationNumber,techNumber,dnnType);
         sql3=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
                           tech[0], tech[1], tech[2], tech[3], tech[4], tech[5], tech[6], tech[7], tech[8], tech[9],
                           tech[10],tech[11],tech[12],tech[13],tech[14],tech[15],tech[16],tech[17],tech[18],tech[19],
                           tech[20],tech[21],tech[22],tech[23],tech[24],tech[25],tech[26],tech[27],tech[28],tech[29],
                           tech[30],tech[31],tech[32],tech[33],tech[34],tech[35],tech[36],tech[37],tech[38],tech[39]);
            
                           
         sql4=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
                           tech[40],tech[41],tech[42],tech[43],tech[44],tech[45],tech[46],tech[47],tech[48],tech[49],
                           tech[50],tech[51],tech[52],tech[53],tech[54],tech[55],tech[56],tech[57],tech[58],tech[59],
                           tech[60],tech[61],tech[62],tech[63],tech[64],tech[65],tech[66],tech[67],tech[68],tech[69],
                           tech[70],tech[71],tech[72],tech[73],tech[74],tech[75],tech[76],tech[77],tech[78],tech[79]);
                           
                           
         sql5=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"
                           "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f)",
                           tech[80],tech[81],tech[82],tech[83],tech[84],tech[85],tech[86],tech[87],tech[88],tech[89],
                           tech[90],tech[91],tech[92],tech[93],tech[94],tech[95],tech[96],tech[97],tech[98],tech[99],
                           tech[100],tech[101],tech[102],tech[103],tech[104],tech[105],tech[106],tech[107],tech[108],tech[109],
                           tech[110],tech[111],tech[112],tech[113],tech[114],tech[115],tech[116],tech[117],tech[118],tech[119],
                           tech[120],tech[121],tech[122],tech[123],tech[124],tech[125],tech[126],tech[127],tech[128],tech[129],
                           tech[130],tech[131],tech[132],tech[133],tech[134],tech[135],tech[136],tech[137],tech[138],tech[139]);

      sql6=StringFormat("%s%s%s%s%s%s%s%s",sql1a,sql1b,sql1c,sql1d,sql2,sql3,sql4,sql5);

   #ifdef _DEBUG_OPTIMIZATIONCOPY
      printf("%s",sql1a);
      printf("%s",sql1b);
      printf("%s",sql1c);
      printf("%s",sql1d);

      printf("%s",sql2);
      printf("%s",sql3);
      printf("%s",sql4);
      printf("%s",sql5);
   #endif
   

   req2=DatabasePrepare(_dbHandle,sql6); 
   if (req2==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print(" -> DB request failed with code ", GetLastError());
      #endif
      return;
   }

   if(!DatabaseExecute(_dbHandle,sql6)) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print("DB: insert failed with code ", GetLastError());
      #endif
      return;
   }
   
   DatabaseFinalize(req2); 

}

