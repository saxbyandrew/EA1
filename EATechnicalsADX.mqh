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
   int      adxHandle;
   double   mainBuffer[];
   double   plusDIBuffer[];
   double   minusDIBuffer[];

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

   int bars;

   EATechnicalsBase::copyValues(t);

   if (!adx.Create(_Symbol,t.period,t.movingAverage)) {
      #ifdef _DEBUG_ADX_MODULE
            ss="EATechnicalsADX -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 

   adxHandle=iADX(_Symbol,t.period,t.movingAverage);
   if (!adxHandle) {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX -> adxHandle ERROR";
         pss
         writeLog
         ExpertRemove();
      #endif
   }
   SetIndexBuffer(0,mainBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,plusDIBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,minusDIBuffer,INDICATOR_DATA);

   bars=Bars(_Symbol,tech.period);

   #ifdef _DEBUG_ADX_MODULE
      ss=StringFormat("EATechnicalsADX xxxxxxxxxxxxxxxxxxxxx-> bars in terminal history:%d for period:%s",bars,EnumToString(tech.period));
      pss
      writeLog
   #endif

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

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', movingAverage=%d, upperLevel=%.5f, versionNumber=%d, barDelay=%d "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.movingAverage,tech.upperLevel, tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   
   #ifdef _DEBUG_BASE
      ss="EATechnicalsADX -> UPDATE INTO TECHNICALS";
      pss
      writeLog
      ss=sql;
      pss
      writeLog
   #endif
   EATechnicalsBase::updateValuesToDatabase(sql);

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

   #ifdef _DEBUG_ADX_MODULE
      ss=StringFormat("EATechnicalsADX  -> using getValues(1) %s barNumber:%d Time:%s barscalculated:%d",tech.inputPrefix, barNumber,TimeToString(barDateTime,TIME_DATE|TIME_MINUTES),BarsCalculated(adx.Handle())); 
      writeLog
      pss
   #endif

      ArraySetAsSeries(mainBuffer,true);
      ArraySetAsSeries(plusDIBuffer,true);
      ArraySetAsSeries(minusDIBuffer,true);

      CopyBuffer(adxHandle,0,barDateTime,1,mainBuffer);
      CopyBuffer(adxHandle,1,barDateTime,1,plusDIBuffer);
      CopyBuffer(adxHandle,2,barDateTime,1,minusDIBuffer);

      if (mainBuffer[0]==EMPTY_VALUE || plusDIBuffer[0]==EMPTY_VALUE || minusDIBuffer[0]==EMPTY_VALUE) {
         #ifdef _DEBUG_ADX_MODULE
            ss="EATechnicalsADX NEW TYPE -> EMPTY_VALUE";
            pss
            writeLog
         #endif
      } else {
         ss="EATechnicalsADX NEW TYPE -> NOT EMPTY_VALUE !!!!!!!!!!!!!!!";
         #ifdef _DEBUG_ADX_MODULE
            ss=StringFormat("EATechnicalsADX  -> NEW TYPE getValues -> %s MAIN:%.2f PLUSDI:%.2f MINUSDI:%.2f",TimeToString(barDateTime,TIME_DATE|TIME_MINUTES),mainBuffer[0],plusDIBuffer[0],minusDIBuffer[0]);        
            writeLog
            pss
         #endif
      }    

   // Refresh the indicator and get all the buffers
   adx.Refresh(-1);

   if (tech.barDelay>0) {
      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX  -> getValues(1.1) -> barDelay:%d barNumber:%d using Method GetData(buffer,barNumber)",tech.barDelay,barNumber);   
         writeLog
         pss
      #endif
      main[0]=adx.GetData(0,barNumber);
      plusDI[0]=adx.GetData(1,barNumber);
      minusDI[0]=adx.GetData(2,barNumber);
   } else {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX  -> getValues(1.2) -> using GetData(dateTime,buffer,etc)";   
         writeLog
         pss
      #endif
      adx.GetData(barDateTime,1,0,main);
      adx.GetData(barDateTime,1,1,plusDI);
      adx.GetData(barDateTime,1,2,minusDI);
   }

   if (main[0]==EMPTY_VALUE || plusDI[0]==EMPTY_VALUE || minusDI[0]==EMPTY_VALUE) {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX   -> getValues(1) -> EMPTY VALUE will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(0);
      return;

   }

   if (main[0]>0 && plusDI[0]>0 && minusDI[0]>0) {
      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX  -> getValues -> MAIN:%.2f PLUSDI:%.2f MINUSDI:%.2f",main[0],plusDI[0],minusDI[0]);        
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
         ss=StringFormat("EATechnicalsADX   -> getValues(1) -> ERROR will return zeros %d",tech.barDelay); 
         writeLog
         pss

         ss=StringFormat("EATechnicalsADX  -> getValues -> %.2f %.2f %.2f ",main[0],plusDI[0],minusDI[0]);  
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

   #ifdef _DEBUG_ADX_MODULE
      ss="EATechnicalsADX  -> using getValues(2)"; 
      writeLog
      pss
   #endif

   // Refresh the indicator and get all the buffers
   adx.Refresh(-1);

   ss=StringFormat("2 bardelay:%d",tech.barDelay);
   pss
   writeLog


   //if (adx.GetData(1,1,0,main)>0 && adx.GetData(1,1,1,plusDI)>0 && adx.GetData(1,1,2,minusDI)>0) {
   if (adx.GetData(tech.barDelay,1,0,main)>0 && adx.GetData(tech.barDelay,1,1,plusDI)>0 && adx.GetData(tech.barDelay,1,2,minusDI)>0) {
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
         ss="EATechnicalsADX -> getValues(2) -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(0);
   }
}

