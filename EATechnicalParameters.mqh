//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"



#include "EAEnum.mqh"
#include "EAOptimizationInputs.mqh"
#include "EATechnicalsBase.mqh"
#include "EATechnicalsADX.mqh"
//#include "EATechnicalsRSI.mqh"

class EATechnicalsADX;
class EATechnicalsRSI;

class EATechnicalParameters : public EATechnicalsBase {

//=========
private:
//=========

   string      ss;

//=========
protected:
//=========

void  createTechnicalObject();
void  copyValuesFromDatabase(int strategyType);
void  copyValuesFromInputs();

   
//=========
public:
//=========
EATechnicalParameters(int strategyType);
~EATechnicalParameters();


};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::EATechnicalParameters(int strategyType) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      printf ("EATechnicalParameters ->  Object Created ....");
      writeLog
      pss
   #endif

   
   // Determine where we get the technicl values from based on if we are in normal running mode
   // on in strategy optimization mode
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="EATechnicalParameters ->  copy input values MQL_OPTIMIZATION ....";
         writeLog
         pss
      #endif
      copyValuesFromInputs();       // Get the inputs under optimization mode only
   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="EATechnicalParameters ->  copy DB values ....";
         writeLog
         pss
      #endif
      copyValuesFromDatabase(strategyType);     // Get Technicals from the DB
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::~EATechnicalParameters() {


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::createTechnicalObject() {

   EATechnicalsBase *i;

   if (t.indicatorName=="ADX")   i=new EATechnicalsADX(t);
   //if (t.indicatorName=="RSI")   i=new EATechnicalsRSI(t);


   // Check the object
   if (CheckPointer(i)==POINTER_INVALID) {
      ss="ERROR adding indicator ";
      writeLog
      pss
      ExpertRemove();
   } 

   // Add indicator object to list of all objects
   if (!indicators.Add(i)) {
      ss="ERROR createTechnicalObject ->";
      writeLog
      pss
   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="SUCCESS createTechnicalObject ->";
         writeLog
         pss
      #endif 
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromDatabase(int strategyType) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="copyValuesFromDatabase -> .... using strategy Type";
      pss
   #endif

   string sql, indicatorName;
   int idx;

   sql=StringFormat("SELECT * FROM TECHNICALS where strategyNumber=%d AND strategyType=%",usp.strategyNumber,strategyType);
   int request=DatabasePrepare(_mainDBHandle,sql);
   if (!DatabaseRead(request)) {
      ss=StringFormat(" -> EATechnicalParameters copyValuesFromDatabase DB request failed %s %d %d with code:%d",indicatorName,usp.strategyNumber,strategyType, GetLastError()); 
      pss
      printf(sql);
      ExpertRemove();
   } else {

      // Loop thru all values for this strategyNumber / strategyType pair
      while (DatabaseRead(request)) {
         DatabaseColumnInteger      (request,0,t.strategyNumber);
         DatabaseColumnInteger      (request,1,t.strategyType);
         DatabaseColumnText         (request,2,t.indicatorName);
         DatabaseColumnInteger      (request,3,t.instanceNumber);
         DatabaseColumnInteger      (request,4,t.instanceType);
         DatabaseColumnInteger      (request,5,t.period);
         DatabaseColumnInteger      (request,6,t.movingAverage);
         DatabaseColumnInteger      (request,7,t.slowMovingAverage);
         DatabaseColumnInteger      (request,8,t.fastMovingAverage);
         DatabaseColumnInteger      (request,9,t.movingAverageMethod);
         DatabaseColumnInteger      (request,10,t.appliedPrice);
         DatabaseColumnDouble       (request,11,t.stepValue);
         DatabaseColumnDouble       (request,12,t.maxValue);
         DatabaseColumnInteger      (request,13,t.signalPeriod);
         DatabaseColumnInteger      (request,15,t.tenkanSen);
         DatabaseColumnInteger      (request,16,t.kijunSen);
         DatabaseColumnInteger      (request,17,t.spanB);
         DatabaseColumnInteger      (request,18,t.kPeriod);
         DatabaseColumnInteger      (request,19,t.dPeriod);
         DatabaseColumnInteger      (request,20,t.idx);
         createTechnicalObject();

         #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss=StringFormat("copyValuesFromDatabase -> StrategyNumber: %d MA:%d",t.strategyNumber,t.movingAverage);
            pss
         #endif
         

      }
   }

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromInputs() {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="copyValuesFromInputs -> ....";
      pss
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ADX

      t.indicatorName="ADX";
      t.period=i1a_period;
      t.movingAverage=i1a_movingAverage;
      createTechnicalObject();

      t.indicatorName="ADX";
      t.period=i1b_period;
      t.movingAverage=i1b_movingAverage;
      createTechnicalObject();

   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RSI

      t.indicatorName="RSI";
      t.period=i2a_period;
      t.movingAverage=i2a_movingAverage;
      t.appliedPrice=i2a_appliedPrice;
      createTechnicalObject();

      t.indicatorName="RSI";
      t.period=i2b_period;
      t.movingAverage=i2b_movingAverage;
      t.appliedPrice=i2b_appliedPrice;
      createTechnicalObject();

   #endif


}
