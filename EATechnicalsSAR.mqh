//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"

#include <Indicators\Trend.mqh>

//=========
class EATechnicalsSAR : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   CiSAR    sar;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsSAR(Technicals &t);
   ~EATechnicalsSAR();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsSAR::EATechnicalsSAR(Technicals &t) {


   EATechnicalsBase::copyValues(t);

   if (!sar.Create(_Symbol,t.period,t.stepValue,t.maxValue)) {
      #ifdef _DEBUG_SAR_MODULE
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
EATechnicalsSAR::~EATechnicalsSAR() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsSAR::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1];

   // Refresh the indicator and get all the buffers
   sar.Refresh(-1);

   if (sar.GetData(barDateTime,1,0,main)>0) {

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */

      if (bool (tech.useBuffers&_BUFFER1)) {
         if (main[0]>iClose(_Symbol,tech.period,barNumber)) {
            nnInputs.Add(0);     // SAR above current price BEARISH
            #ifdef _DEBUG_SAR_MODULE
               ss=StringFormat("EATechnicalsSAR  -> getValues(HISTORY) -> BEARISH barNumber:%d Period:%d Price:%.2f",barNumber,tech.period,iClose(_Symbol,tech.period,barNumber));        
               writeLog
               pss
            #endif
         } else {
            nnInputs.Add(1);     // SAR below current price BULLISH
            #ifdef _DEBUG_SAR_MODULE
               ss=StringFormat("EATechnicalsSAR  -> getValues(HISTORY) -> BULLISH barNumber:%d Period:%d Price:%.2f",barNumber,tech.period,iClose(_Symbol,tech.period,barNumber));     
               writeLog
               pss
            #endif
         }
      }
   } else {
      #ifdef _DEBUG_SAR_MODULE
         ss="EATechnicalsSAR   -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsSAR::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   double main[1];

   // Refresh the indicator and get all the buffers
   sar.Refresh(-1);

   if (sar.GetData(1,1,0,main)>0) {


   if (bool (tech.useBuffers&_BUFFER1)) {
         if (main[0]>iClose(_Symbol,tech.period,1)) {
            nnInputs.Add(0);     // SAR above current price BEARISH
            #ifdef _DEBUG_SAR_MODULE
               ss=StringFormat("EATechnicalsSAR  -> getValues(CURRENT) -> BEARISH Period:%d",tech.period);        
               writeLog
               pss
            #endif
         } else {
            nnInputs.Add(1);     // SAR below current price BULLISH
            #ifdef _DEBUG_SAR_MODULE
               ss=StringFormat("EATechnicalsSAR  -> getValues(CURRENT) -> BULLISH Period:%d",tech.period);     
               writeLog
               pss
            #endif
         }
      }

   } else {
      #ifdef _DEBUG_SAR_MODULE
         ss="EATechnicalsSAR -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }
}
