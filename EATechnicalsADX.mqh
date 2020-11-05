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
class EATechnicalsADX : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   CiADX    adx;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsADX(technicals &tech);
   ~EATechnicalsADX();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsADX::EATechnicalsADX(technicals &tech) {

   #ifdef _DEBUG_ADX_MODULE
      ss="EATechnicalsADX -> .... Default Constructor";
      pss
   #endif

   // Set the local instance struct variables
   EATechnicalsBase::copyValues(tech);

   if (!adx.Create(_Symbol,tech.period,tech.movingAverage)) {
      #ifdef _DEBUG_ADX_MODULE
            printf("ADXSetParameters -> ERROR");
            ExpertRemove();
      #endif
   } 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsADX::~EATechnicalsADX() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsADX::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   #ifdef _DEBUG_ADX_MODULE
      ss="EATechnicalsADX -> getValues -> Entry 2....";
      pss
      writeLog
   #endif 

   int      barNumber=iBarShift(_Symbol,t.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1], plusDI[1], minusDI[1];

   // Refresh the indicator and get all the buffers
   adx.Refresh(-1);

   if (adx.GetData(barDateTime,1,0,main)>0 && adx.GetData(barDateTime,1,1,plusDI)>0 && adx.GetData(barDateTime,1,2,minusDI)>0) {
      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX -> getValues 3 MAIN Time %s value:%.2f barNumber:%d",TimeToString(barDateTime),main[0],barNumber);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX -> getValues 3 PLUSDI Time %s value:%.2f barNumber:%d",TimeToString(barDateTime),plusDI[0],barNumber);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX -> getValues 3 MINUSDI Time %s value:%.2f barNumber:%d",TimeToString(barDateTime),minusDI[0],barNumber);  
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
      //if (t.useBuffers&_BUFFER1) nnInputs.Add(normalizedValue(main[0]));
      //if (t.useBuffers&_BUFFER2) nnInputs.Add(normalizedValue(plusDI[0]));
      //if (t.useBuffers&_BUFFER3) nnInputs.Add(normalizedValue(minusDI[0]));
      if (t.useBuffers&_BUFFER1) nnInputs.Add(main[0]);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(plusDI[0]);
      if (t.useBuffers&_BUFFER3) nnInputs.Add(minusDI[0]);
      //if (t.useBuffers&_BUFFER4) nnInputs.Add(??);
      //if (t.useBuffers&_BUFFER5) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (t.useBuffers&_BUFFER1) nnInputs.Add(0);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(0);
      if (t.useBuffers&_BUFFER3) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsADX::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   #ifdef _DEBUG_ADX_MODULE
      ss="EATechnicalsADX -> getValues -> Entry 1....";
      pss
      writeLog
   #endif 

   double main[1], plusDI[1], minusDI[1];

   // Refresh the indicator and get all the buffers
   adx.Refresh(-1);

   if (adx.GetData(1,1,0,main)>0 && adx.GetData(1,1,1,plusDI)>0 && adx.GetData(1,1,2,minusDI)>0) {
      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX -> getValues 3 MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX -> getValues 3 PLUSDI:%.2f",plusDI[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX -> getValues 3 MINUSDI:%.2f",minusDI[0]);  
         writeLog
         pss
      #endif

      if (t.useBuffers&_BUFFER1) nnInputs.Add(main[0]);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(plusDI[0]);
      if (t.useBuffers&_BUFFER3) nnInputs.Add(minusDI[0]);
      //if (t.useBuffers&_BUFFER4) nnInputs.Add(??);
      //if (t.useBuffers&_BUFFER5) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (t.useBuffers&_BUFFER1) nnInputs.Add(0);
      if (t.useBuffers&_BUFFER2) nnInputs.Add(0);
      if (t.useBuffers&_BUFFER3) nnInputs.Add(0);
   }
}

