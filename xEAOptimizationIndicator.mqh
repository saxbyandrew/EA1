//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"


class EAOptimizationIndicator : public CObject {

//=========
private:
//=========

   string ss;

   struct Indicators {
      string   inputPrefix;
      string   indicatorName;
      int      indicatorNumber;
   } i;

//=========
protected:
//=========

//=========
public:
//=========
EAOptimizationIndicator(string inputPrefix, string indicatorName, int indicatorNumber);
~EAOptimizationIndicator();

   void addOptimizationValues(double &val[], int passNumber);


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAOptimizationIndicator::EAOptimizationIndicator(string inputPrefix, string indicatorName, int indicatorNumber) {

   i.inputPrefix=inputPrefix;
   i.indicatorName=indicatorName;
   i.indicatorNumber=indicatorNumber;

   #ifdef _DEBUG_OPTIMIZATION_INDICATOR
      ss=StringFormat("EAOptimizationIndicator -> EAOptimizationIndicator %s %s %d",i.inputPrefix,i.indicatorName, i.indicatorNumber);
      pss
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAOptimizationIndicator::~EAOptimizationIndicator() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAOptimizationIndicator::addOptimizationValues(double &val[], int passNumber) {

   string sql;

   // ----------------------------------------------------------------
   #ifdef _USE_ADX //i1a
   // ----------------------------------------------------------------
      // Match any input prefix of "iax" where x=a or b pr c etc, which is a ADX
      if (StringFind(i.inputPrefix,"i1",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
            "period,movingAverage,upperLevel,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,'%s')", // Checked
               passNumber,"ADX",val[1],val[2],val[3],i.inputPrefix);
               #ifdef _DEBUG_OPTIMIZATION_INDICATOR
                  ss=sql;
                  pss
               #endif
      }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RSI //i2a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i2",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage,appliedPrice,upperLevel,lowerLevel,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"RSI",val[1],val[2],val[3],val[4],val[5],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MFI //i3a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i3",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage,appliedVolume,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,'%s')",
            passNumber,"MFI",val[1],val[2],val[3],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_SAR //i4a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i4",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,stepValue,maxValue,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,'%s')",
            passNumber,"SAR",val[1],val[2],val[3],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ICH //i5a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i5",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,tenkanSen,kijunSen,spanB,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"ICH",val[1],val[2],val[3],val[4],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RVI //i6a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i6",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,'%s')",
            passNumber,"RVI",val[1],val[2],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_STOC //i7a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i7",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,kPeriod,dPeriod,slowMovingAverage,movingAverageMethod,stocPrice,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"STOC",val[1],val[2],val[3],val[4],val[5],val[6],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_OSMA //i8a
   // ----------------------------------------------------------------
      if (StringFind(i.inputPrefix,"i8",0)!=-1) {
         sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,slowMovingAverage,fastMovingAverage,signalPeriod,appliedPrice,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"OSMA",val[1],val[2],val[3],val[4],val[5],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MACD //i8a
   // ----------------------------------------------------------------
   if (StringFind(i.inputPrefix,"i9",0)!=-1) {

      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,slowMovingAverage,fastMovingAverage,signalPeriod,appliedPrice,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"MACD",val[1],val[2],val[3],val[4],val[5],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MACDJB //i10a
   // ----------------------------------------------------------------
   if (StringFind(i.inputPrefix,"i10",0)!=-1) {

      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,slowMovingAverage,fastMovingAverage,signalPeriod,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"MACDJB",val[1],val[2],val[3],val[4],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION_INDICATOR
               ss=sql;
               pss
            #endif
      }
   #endif  
   
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("OnTesterDeinit -> Failed to insert with code %d", GetLastError());
      pss
   } else {
      #ifdef _DEBUG_OPTIMIZATION_INDICATOR
         ss=" -> INSERT INTO TECHNICALS succcess";
         pss
         ss=sql;
         pss
      #endif
   }  
   

}
