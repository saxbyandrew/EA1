
/*
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
   request1=DatabasePrepare(_mainDBHandle, sqlString);
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
      request2=DatabasePrepare(_mainDBHandle,sqlString); 
      if (request2==INVALID_HANDLE) {
         #ifdef _DEBUG_PARAMETERS
            Print(" -> DatabasePrepare failed with code ", GetLastError());
         #endif
         return;
      }
      if (!DatabaseExecute(_mainDBHandle,sqlString)) {
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
      request=DatabasePrepare(_mainDBHandle,sqlString); 
      
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
      " VALUES ('%s',%d,%d,%g,%g,%d,%g,%g,%d,%g,%g,%d,'%s',%d,%d)",pb.strategyName,pb.strategyNumber, p.ticket,p.entryPrice,p.lotSize,p.orderTypeToOpen,p.fixedProfitTargetLevel,p.fixedLossTargetLevel,p.daysOpen,
      p.currentPnL,p.swapCosts,p.status,TimeToString(p.closingDateTime,TIME_DATE),p.closingTypes,p.deviationInPoints);
      
   #ifdef _DEBUG_PARAMETERS
      Print(sqlString);
   #endif
   

   request=DatabasePrepare(_mainDBHandle,sqlString); 
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_PARAMETERS
         Print(" -> DB request failed with code ", GetLastError());
      #endif
      return;
   }

   if(!DatabaseExecute(_mainDBHandle,sqlString)) {
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

   request=DatabasePrepare(_mainDBHandle,sqlString); 
   if (request==INVALID_HANDLE) {
      Print(" -> DB request failed with code ", GetLastError());
         return;
   }
   if (!DatabaseExecute(_mainDBHandle,sqlString)) {
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
      request=DatabasePrepare(_mainDBHandle,sqlString); 
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
      sqlString=StringFormat("UPDATE STRATEGIES SET swapCosts=%g WHERE strategyNumber=%d",result, pb.strategyNumber);
      #ifdef _DEBUG_PARAMETERS
         Print(" -> ",sqlString);
      #endif

      request=DatabasePrepare(_mainDBHandle,sqlString); 
      if( request==INVALID_HANDLE) {
         Print(" -> DB request failed with code ", GetLastError());
         return;
      }
      if (!DatabaseExecute(_mainDBHandle,sqlString)) {
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
   _mainDBHandle1=DatabaseOpen("optimization", DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
   if (_mainDBHandle1==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         printf(" -> DB open failed with code %d",GetLastError());
      #endif 
   } else {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         printf(" -> DB optimization open success");
      #endif 
   }


      //--- create a query and get a handle for it
      int request=DatabasePrepare(_mainDBHandle1,"SELECT * from PASSES where selection=1"); 
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
/*
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

   int request1=DatabasePrepare(_mainDBHandle,sql1); 
   if (request1==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print(" -> DB request failed with code ", GetLastError());
      #endif
      return;
   }

   if(!DatabaseExecute(_mainDBHandle,sql1)) {
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
   req1=DatabasePrepare(_mainDBHandle1,sql1); 
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
   

   req2=DatabasePrepare(_mainDBHandle,sql6); 
   if (req2==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print(" -> DB request failed with code ", GetLastError());
      #endif
      return;
   }

   if(!DatabaseExecute(_mainDBHandle,sql6)) {
      #ifdef _DEBUG_OPTIMIZATIONCOPY
         Print("DB: insert failed with code ", GetLastError());
      #endif
      return;
   }
   
   DatabaseFinalize(req2); 

}

*/