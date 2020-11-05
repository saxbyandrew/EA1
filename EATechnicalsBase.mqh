//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"
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
   struct technicals {
      int   strategyNumber;
      int   strategyType;
      string   indicatorName;
      int   instanceNumber;
      ENUM_TIMEFRAMES   period;
      int   movingAverage;
      int   slowMovingAverage;
      int   fastMovingAverage;
      int   movingAverageMethod;
      ENUM_APPLIED_PRICE appliedPrice;
      double   stepValue;
      double   maxValue;
      int   signalPeriod;
      int   tenkanSen;
      int   kijunSen;
      int   spanB;
      int   kPeriod;
      int   dPeriod;
      unsigned   useBuffers;
      int   totalBuffers;
      int   ttl;
      string inputPrefix;
      double lowerLevel;
      double upperLevel;
   } t;

   //int getAbsoluteBarCount(ENUM_TIMEFRAMES period);
   int countBuffersUsed();
   //double normalizedValue(double val);

//=========
public:
//=========
   EATechnicalsBase();
   ~EATechnicalsBase();

   void     copyValues(technicals &tt);


   
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, int barNumber) {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime) {};
   //virtual void execute(EAEnum action) {}; 
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
void EATechnicalsBase::copyValues(technicals &tech) {
      
   t.strategyNumber=tech.strategyNumber;
   t.strategyType=tech.strategyType;
   t.indicatorName=tech.indicatorName;
   t.instanceNumber=tech.instanceNumber;
   t.period=tech.period;
   t.movingAverage=tech.movingAverage;
   t.slowMovingAverage=tech.slowMovingAverage;
   t.fastMovingAverage=tech.fastMovingAverage;
   t.movingAverageMethod=tech.movingAverageMethod;
   t.appliedPrice=tech.appliedPrice;
   t.stepValue=tech.stepValue;
   t.maxValue=tech.maxValue;
   t.signalPeriod=tech.signalPeriod;
   t.tenkanSen=tech.tenkanSen;
   t.kijunSen=tech.kijunSen;
   t.spanB=tech.spanB;
   t.kPeriod=tech.kPeriod;
   t.dPeriod=tech.dPeriod;
   t.useBuffers=tech.useBuffers;
   t.ttl=tech.ttl;
   t.inputPrefix=tech.inputPrefix;
   t.lowerLevel=tech.lowerLevel;
   t.upperLevel=tech.upperLevel;

}
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EATechnicalsBase::getAbsoluteBarCount(ENUM_TIMEFRAMES period) {

   int dfSize=2000; //TEMP !!!!!!!!!!!!!
   datetime historyStart=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_SERVER_FIRSTDATE); 

   int barNumber=iBarShift(_Symbol,period,historyStart,false);
   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalsBase -> getAbsoluteBarCount -> .... history start %s bar count:%d", TimeToString(historyStart),barNumber);
      pss
      writeLog
   #endif

    // If the time period means we exceeded the total history avaliable
    // then just return the max number of bars we have.
   if (dfSize>barNumber) return barNumber-1;

   return dfSize;

}
*/

/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsBase::normalizedValue(double val) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalsBase -> normalizedValue:%2.8f",(val-t.normalizedMin)/(t.normalizedMax-t.normalizedMin));
      pss
      writeLog
   #endif

   return (val-t.normalizedMin)/(t.normalizedMax-t.normalizedMin);
}
*/
