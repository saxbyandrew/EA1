//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"

#include <Indicators\Volumes.mqh>

//=========
class EATechnicalsMFI : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   CiMFI    mfi;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsMFI(Technicals &tech);
   ~EATechnicalsMFI();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMFI::EATechnicalsMFI(Technicals &tech) {

   EATechnicalsBase::copyValues(tech);

   if (!mfi.Create(_Symbol,tech.period,tech.movingAverage,tech.appliedVolume)) {
      #ifdef _DEBUG_MFI_MODULE
            ss="MFISetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMFI::~EATechnicalsMFI() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsMFI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1];

   // Refresh the indicator and get all the buffers
   mfi.Refresh(-1);

   if (mfi.GetData(barDateTime,1,0,main)>0) {
      #ifdef _DEBUG_MFI_MODULE
         ss=StringFormat("EATechnicalsMFI  -> getValues -> MAIN:%.2f",main[0]);        
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

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);

   } else {
      #ifdef _DEBUG_MFI_MODULE
         ss="EATechnicalsMFI   -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsMFI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   double main[1];

   // Refresh the indicator and get all the buffers
   mfi.Refresh(-1);

   if (mfi.GetData(1,1,0,main)>0) {
      #ifdef _DEBUG_MFI_MODULE
         ss=StringFormat("EATechnicalsMFI  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);


   } else {
      #ifdef _DEBUG_MFI_MODULE
         ss="EATechnicalsMFI -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }
}