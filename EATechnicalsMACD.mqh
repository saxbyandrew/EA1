//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"

#include <Indicators\Oscilators.mqh>

//=========
class EATechnicalsMACD : public EATechnicalsBase {
//=========

//=========
private:

   string      ss;
   CiMACD      macd;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsMACD(technicals &tech);
   ~EATechnicalsMACD();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMACD::EATechnicalsMACD(technicals &tech) {

   #ifdef _DEBUG_MACD_MODULE
      ss="EATechnicalsMACD -> .... Default Constructor";
      pss
      writeLog
   #endif

   // Set the local instance struct variables
   EATechnicalsBase::copyValues(tech);

   if (!macd.Create(_Symbol, tech.period, tech.fastMovingAverage, tech.slowMovingAverage, tech.signalPeriod, tech.appliedPrice)) {
      #ifdef _DEBUG_MACD_MODULE
            ss="MACDSetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMACD::~EATechnicalsMACD() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsMACD::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   #ifdef _DEBUG_MACD_MODULE
      ss="EATechnicalsMACD -> getValues -> Entry 2....";
      pss
      writeLog
   #endif 

   int      barNumber=iBarShift(_Symbol,t.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1], signal[1];

   // Refresh the indicator and get all the buffers
   macd.Refresh(-1);

   if (macd.GetData(barDateTime,1,0,main)>0 && macd.GetData(barDateTime,1,0,signal)>0) {
      #ifdef _DEBUG_MACD_MODULE
         ss=StringFormat("EATechnicalsMACD -> getValues MAIN:%.2f SIGNAL:%.5f",main[0],signal[0]);        
         writeLog
         pss
      #endif

      if (t.useBuffers&_BUFFER1) nnInputs.Add(main[0]);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(signal[0]);
      //if (t.useBuffers&_BUFFER5) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_MACD_MODULE
         ss="EATechnicalsMACD -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsMACD::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   #ifdef _DEBUG_MACD_MODULE
      ss="EATechnicalsMACD -> getValues -> Entry 1....";
      pss
      writeLog
   #endif 

   double main[1], signal[1];

   // Refresh the indicator and get all the buffers
   macd.Refresh(-1);

   if (macd.GetData(1,1,0,main)>0 && macd.GetData(1,1,0,signal)>0) {
      #ifdef _DEBUG_MACD_MODULE
         ss=StringFormat("EATechnicalsMACD -> getValues MAIN:%.2f SIGNAL:%.5f",main[0],signal[0]);        
         writeLog
         pss
      #endif

      if (t.useBuffers&_BUFFER1) nnInputs.Add(main[0]);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(signal[0]);
      //if (t.useBuffers&_BUFFER5) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_MACD_MODULE
         ss="EATechnicalsMACD -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (t.useBuffers&_BUFFER1) nnInputs.Add(0);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(0);

   }



}
