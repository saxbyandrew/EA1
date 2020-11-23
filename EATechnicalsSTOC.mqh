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
class EATechnicalsSTOC : public EATechnicalsBase {
//=========

//=========
private:

   string         ss;
   CiStochastic   stoc;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsSTOC(Technicals &t);
   ~EATechnicalsSTOC();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsSTOC::EATechnicalsSTOC(Technicals &t) {


   EATechnicalsBase::copyValues(t);

   if (!stoc.Create(_Symbol,t.period,t.kPeriod,t.dPeriod,t.slowMovingAverage,t.movingAverageMethod,t.stocPrice)) {
      #ifdef _DEBUG_STOC_MODULE
            ss="SARSetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsSTOC::~EATechnicalsSTOC() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsSTOC::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

 
   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1], signal[1];

   // Refresh the indicator and get all the buffers
   stoc.Refresh(-1);

   if (stoc.GetData(barDateTime,1,0,main)>0 && stoc.GetData(barDateTime,1,1,signal)>0) {
      #ifdef _DEBUG_STOC_MODULE
         ss=StringFormat("EATechnicalsSTOC  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsSTOC  -> getValues -> SIGNAL:%.2f",signal[0]);    
         writeLog
         pss

      #endif

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */

      if (bool (bool (tech.useBuffers&_BUFFER1))) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(signal[0]);

   } else {
      #ifdef _DEBUG_STOC_MODULE
         ss="EATechnicalsSTOC   -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsSTOC::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {


   // Refresh the indicator and get all the buffers
   stoc.Refresh(-1);

   double main[1], signal[1];

   // Refresh the indicator and get all the buffers
   stoc.Refresh(-1);

   if (stoc.GetData(1,1,0,main)>0 && stoc.GetData(1,1,1,signal)>0) {
      #ifdef _DEBUG_STOC_MODULE
         ss=StringFormat("EATechnicalsSTOC  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsSTOC  -> getValues -> SIGNAL:%.2f",signal[0]);    
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(signal[0]);


   } else {
      #ifdef _DEBUG_STOC_MODULE
         ss="EATechnicalsSTOC -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
   }
}