//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"
#include "EAStructures.mqh"
#include <Arrays\ArrayDouble.mqh>

class EANeuralNetwork;

//=========
class EATechnicalsBase : public CObject {
//=========

//=========
private:
//=========

   string ss;
   

//=========
protected:
//=========

   Technicals tech;     // See EAStructures.mqh
   void  copyValuesToDatabase(string sql);
   int   countBuffersUsed();

//=========
public:
//=========
   EATechnicalsBase();
   ~EATechnicalsBase();

   void     copyValues(Technicals &tt);
   
   virtual void setValues() {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, int barNumber) {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime) {};
   virtual EAEnum execute(EAEnum action) {return _NO_ACTION;}; 

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsBase::EATechnicalsBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsBase::~EATechnicalsBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsBase::copyValues(Technicals &t) {
      
   tech.strategyNumber=t.strategyNumber;
   tech.indicatorName=t.indicatorName;
   tech.instanceNumber=t.instanceNumber;
   tech.period=t.period;
   tech.movingAverage=t.movingAverage;
   tech.slowMovingAverage=t.slowMovingAverage;
   tech.fastMovingAverage=t.fastMovingAverage;
   tech.movingAverageMethod=t.movingAverageMethod;
   tech.appliedPrice=t.appliedPrice;
   tech.stepValue=t.stepValue;
   tech.maxValue=t.maxValue;
   tech.signalPeriod=t.signalPeriod;
   tech.tenkanSen=t.tenkanSen;
   tech.kijunSen=t.kijunSen;
   tech.spanB=t.spanB;
   tech.kPeriod=t.kPeriod;
   tech.dPeriod=t.dPeriod;
   tech.useBuffers=t.useBuffers;
   tech.stocPrice=t.stocPrice;
   tech.ttl=t.ttl;
   tech.inputPrefix=t.inputPrefix;
   tech.lowerLevel=t.lowerLevel;
   tech.upperLevel=t.upperLevel;

   #ifdef _DEBUG_OSMA_MODULE 
      ss=StringFormat("EATechnicalsBase -> copyValues -> fastMovingAverage:%d slowMovingAverage:%d signalPeriod appliedPrice:%d",t.fastMovingAverage,t.slowMovingAverage,t.signalPeriod,t.appliedPrice);
      writeLog
   #endif
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsBase::copyValuesToDatabase(string sql) {

   if (!DatabaseExecute(_mainDBHandle, sql)) {
      ss=StringFormat("copyValuesToDatabase -> Failed to insert with code %d", GetLastError());
      pss
      ss=sql;
      pss
      writeLog
   } else {
      #ifdef _DEBUG_BASE
         ss="copyValuesToDatabase -> UPDATE INTO TECHNICALS succcess";
         pss
         ss=sql;
         pss
      #endif
   }  

}
