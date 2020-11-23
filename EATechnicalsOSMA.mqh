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
class EATechnicalsOSMA : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   CiOsMA   osma;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsOSMA(Technicals &tech);
   ~EATechnicalsOSMA();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsOSMA::EATechnicalsOSMA(Technicals &tech) {

   /*
   #ifdef _DEBUG_OSMA_MODULE
      ss="EATechnicalsOSMA -> .... Default Constructor";
      pss
   #endif
   */

   // Set the local instance struct variables
   EATechnicalsBase::copyValues(tech);

   if (!osma.Create(_Symbol,tech.period,tech.fastMovingAverage,tech.slowMovingAverage,tech.signalPeriod,tech.appliedPrice)) {
      #ifdef _DEBUG_OSMA_MODULE
            ss="OSMASetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsOSMA::~EATechnicalsOSMA() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsOSMA::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   /*
   #ifdef _DEBUG_OSMA_MODULE
      ss="EATechnicalsOSMA -> getValues -> Entry 2....";
      pss
      writeLog
   #endif 
   */
//ss=StringFormat("EATechnicalsOSMA  -> getValues -> PLUSDI Time %s value:%.2f barNumber:%d",TimeToString(barDateTime),plusDI[0],barNumber);  
   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1];

   // Refresh the indicator and get all the buffers
   osma.Refresh(-1);

   if (osma.GetData(barDateTime,1,0,main)>0) {
      #ifdef _DEBUG_OSMA_MODULE
         ss=StringFormat("EATechnicalsOSMA  -> getValues -> MAIN:%.2f",main[0]);        
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
      //if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(normalizedValue(main[0]));
      //if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(normalizedValue(plusDI[0]));
      //if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(normalizedValue(minusDI[0]));
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      //if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(??);
      //if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_OSMA_MODULE
         ss="EATechnicalsOSMA   -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsOSMA::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {



   double main[1];
   
   // Refresh the indicator and get all the buffers
   osma.Refresh(-1);

   if (osma.GetData(1,1,0,main)>0) {
      #ifdef _DEBUG_OSMA_MODULE
         ss=StringFormat("EATechnicalsOSMA  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      //if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(??);
      //if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_OSMA_MODULE
         ss="EATechnicalsOSMA -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
   }
}