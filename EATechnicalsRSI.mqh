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
   EATechnicalsRSI(Technicals &tech);
   ~EATechnicalsRSI();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRSI::EATechnicalsRSI(Technicals &tech) {

   /*
   #ifdef _DEBUG_RSI_MODULE
      ss="EATechnicalsRSI -> .... Default Constructor";
      pss
      writeLog
   #endif
   */

   // Set the local instance struct variables
   EATechnicalsBase::copyValues(tech);

   if (!rsi.Create(_Symbol, tech.period, tech.movingAverage, tech.appliedPrice)) {
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

   /*
   #ifdef _DEBUG_RSI_MODULE
      ss="EATechnicalsRSI -> getValues -> Entry 2....";
      pss
      writeLog
   #endif 
   */

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

      if (tech.useBuffers&_BUFFER1) nnInputs.Add(main[0]);
      //if (tech.useBuffers&_BUFFER4) nnInputs.Add(??);
      //if (tech.useBuffers&_BUFFER5) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI  -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (tech.useBuffers&_BUFFER1) nnInputs.Add(0);
   }
   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRSI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   /*
   #ifdef _DEBUG_RSI_MODULE
      ss="EATechnicalsRSI -> getValues -> Entry 1....";
      pss
      writeLog
   #endif 
   */

   double main[1];

   // Refresh the indicator and get all the buffers
   rsi.Refresh(-1);

   if (rsi.GetData(1,1,0,main)>0) {
      #ifdef _DEBUG_RSI_MODULE
         ss=StringFormat("EATechnicalsRSI  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss

      #endif

      if (tech.useBuffers&_BUFFER1) nnInputs.Add(main[0]);
      //if (tech.useBuffers&_BUFFER4) nnInputs.Add(??);
      //if (tech.useBuffers&_BUFFER5) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (tech.useBuffers&_BUFFER1) nnInputs.Add(0);
   }



}
