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

   #ifdef _DEBUG_OPTIMIZATION
      ss=StringFormat("EAOptimizationIndicator -> EAOptimizationIndicator %s %s",i.inputPrefix,i.indicatorName);
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
   if (StringFind(i.inputPrefix,"i1",0)!=-1) {
   // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,'%s')",
            passNumber,"ADX",val[1],val[2],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION
               ss=sql;
               pss
            #endif
      }

   // ----------------------------------------------------------------
   if (StringFind(i.inputPrefix,"i2",0)!=-1) {
   // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage,appliedPrice,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,'%s')",
            passNumber,"RSI",val[1],val[2],val[3],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION
               ss=sql;
               pss
            #endif
      }

   // ----------------------------------------------------------------
   if (StringFind(i.inputPrefix,"i9",0)!=-1) {
   // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,slowMovingAverage,fastMovingAverage,signalPeriod,appliedPrice,inputPrefix) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,%.5f,'%s')",
            passNumber,"MACD",val[1],val[2],val[3],val[4],val[5],i.inputPrefix);
            #ifdef _DEBUG_OPTIMIZATION
               ss=sql;
               pss
            #endif
      }
      
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("OnTesterDeinit -> Failed to insert with code %d", GetLastError());
      pss
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss=" -> INSERT INTO TECHNICALS succcess";
         pss
         ss=sql;
         pss
      #endif
   }  
}
