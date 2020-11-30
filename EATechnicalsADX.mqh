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
   double ADXMainLevelCross(double val);


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsADX(Technicals &t);
   ~EATechnicalsADX();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);  
   void  setValues();            


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsADX::EATechnicalsADX(Technicals &t) {

   EATechnicalsBase::copyValues(t);

   if (!adx.Create(_Symbol,t.period,t.movingAverage)) {
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
void EATechnicalsADX::setValues() {

   string sql;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, movingAverage=%d, upperLevel=%.5f "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, tech.movingAverage,tech.upperLevel,tech.strategyNumber,tech.inputPrefix);
   
   EATechnicalsBase::copyValuesToDatabase(sql);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsADX::ADXMainLevelCross(double val) {

   if (val>tech.upperLevel) return 1;
   return 0;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsADX::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   /*
   #ifdef _DEBUG_ADX_MODULE
      ss="EATechnicalsADX -> getValues -> Entry 2....";
      pss
      writeLog
   #endif 
   */
//ss=StringFormat("EATechnicalsADX  -> getValues -> PLUSDI Time %s value:%.2f barNumber:%d",TimeToString(barDateTime),plusDI[0],barNumber);  
   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1], plusDI[1], minusDI[1];

   // Refresh the indicator and get all the buffers
   adx.Refresh(-1);

   if (adx.GetData(barDateTime,1,0,main)>0 && adx.GetData(barDateTime,1,1,plusDI)>0 && adx.GetData(barDateTime,1,2,minusDI)>0) {
      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX  -> getValues -> PLUSDI:%.2f",plusDI[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX  -> getValues -> MINUSDI:%.2f",minusDI[0]);  
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
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(plusDI[0]);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(minusDI[0]);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(ADXMainLevelCross(main[0]));

   } else {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX   -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsADX::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   double main[1], plusDI[1], minusDI[1];

   // Refresh the indicator and get all the buffers
   adx.Refresh(-1);

   if (adx.GetData(1,1,0,main)>0 && adx.GetData(1,1,1,plusDI)>0 && adx.GetData(1,1,2,minusDI)>0) {
      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX  -> getValues -> PLUSDI:%.2f",plusDI[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsADX  -> getValues -> MINUSDI:%.2f",minusDI[0]);  
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(plusDI[0]);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(minusDI[0]);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(ADXMainLevelCross(main[0]));

   } else {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(0);
   }
}

