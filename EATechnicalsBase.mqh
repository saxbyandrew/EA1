//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"



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
      int   instanceType;
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
      int   idx;
   } t;

//=========
public:
//=========
   EATechnicalsBase();
   ~EATechnicalsBase();

   double   iOutputs[];

   virtual void getValues() {};


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsBase::EATechnicalsBase() {

}
EATechnicalsBase::~EATechnicalsBase() {

}
