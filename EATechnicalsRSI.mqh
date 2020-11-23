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
class EATechnicalsRSI : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   CiRSI    rsi;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsRSI(Technicals &t);
   ~EATechnicalsRSI();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRSI::EATechnicalsRSI(Technicals &t) {

   EATechnicalsBase::copyValues(t);

   if (!rsi.Create(_Symbol, t.period, t.movingAverage, t.appliedPrice)) {
      #ifdef _DEBUG_RSI_MODULE
            ss="RSISetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRSI::~EATechnicalsRSI() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRSI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {


   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1];

   // Refresh the indicator and get all the buffers
   rsi.Refresh(-1);

   if (rsi.GetData(barDateTime,1,0,main)>0) {
      #ifdef _DEBUG_RSI_MODULE
         ss=StringFormat("EATechnicalsRSI  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss

      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);

   } else {
      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI  -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }
   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRSI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {


   double main[1];

   // Refresh the indicator and get all the buffers
   rsi.Refresh(-1);

   if (rsi.GetData(1,1,0,main)>0) {
      #ifdef _DEBUG_RSI_MODULE
         ss=StringFormat("EATechnicalsRSI  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss

      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);

   } else {
      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }



}
