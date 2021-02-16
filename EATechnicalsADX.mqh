//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"


//=========
class EATechnicalsADX : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   int      handle;
   datetime buffer0[];
   double   buffer1[];
   double   buffer2[];
   double   buffer3[];

   double ADXMainLevelCross(double val);


//=========
protected:
//=========

//=========
public:
//=========
   EATechnicalsADX(Technicals &t);
   ~EATechnicalsADX();

   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings);  
   void  setValues();            


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsADX::EATechnicalsADX(Technicals &t) {

   int bars;
   CArrayDouble nnInputs, nnOutputs;

   EATechnicalsBase::copyValues(t);

   handle=iADX(_Symbol,t.period,t.movingAverage);
   if (!handle) {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX -> handle ERROR";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
         pss
         writeLog
         ExpertRemove();
      #endif
   }

   #ifdef _DEBUG_ADX_MODULE
      ss=StringFormat("EATechnicalsADX -> EATechnicalsADX(Technicals &t)  -> bars in terminal history:%d for period:%s with MA:%d barDelay:%d",Bars(_Symbol,tech.period),EnumToString(tech.period),tech.movingAverage,tech.barDelay);
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

   tech.versionNumber++;

   string sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', movingAverage=%d, upperLevel=%.5f, versionNumber=%d, barDelay=%d "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.movingAverage,tech.upperLevel, tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   
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
bool EATechnicalsADX::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */


   #ifdef _DEBUG_ADX_MODULE
      pline
      ss=StringFormat("EATechnicalsADX  -> getValues -> %s barNumber:%d Time:%s barscalculated:%d ",tech.inputPrefix, iBarShift(_Symbol,tech.period,barDateTime,false),TimeToString(barDateTime,TIME_DATE|TIME_MINUTES),BarsCalculated(handle)); 
      writeLog
      pss
   #endif

   if (CopyBuffer(handle,0,barDateTime,tech.barDelay,buffer1)==-1 || 
      CopyBuffer(handle,1,barDateTime,tech.barDelay,buffer2)==-1 ||
      CopyBuffer(handle,2,barDateTime,tech.barDelay,buffer3)==-1) {
         #ifdef _DEBUG_ADX_MODULE
            ss="EATechnicalsADX -> getValues -> copybuffer error";
            pss
            writeLog
         #endif
         return false;
   }

   if (buffer1[tech.barDelay-1]==EMPTY_VALUE || buffer2[tech.barDelay-1]==EMPTY_VALUE || buffer3[tech.barDelay-1]==EMPTY_VALUE) {
      #ifdef _DEBUG_ADX_MODULE
         ss="EATechnicalsADX -> getValues (EMPTY VALUE)";
         pss
         writeLog
      #endif
      return false;
   } else {

      #ifdef _DEBUG_ADX_MODULE
         ss=StringFormat("EATechnicalsADX  -> getValues -> %s B1:%.2f B2:%.2f B3:%.2f %d",TimeToString(barDateTime,TIME_DATE|TIME_MINUTES),buffer1[tech.barDelay-1],buffer2[tech.barDelay-1],buffer3[tech.barDelay-1],tech.barDelay);        
         writeLog
         pss
      #endif
      
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(buffer1[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(buffer2[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(buffer3[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(ADXMainLevelCross(buffer1[tech.barDelay-1])); // Use Main

      // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         if (bool (tech.useBuffers&_BUFFER1)) nnHeadings.Add("ADX Main "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER2)) nnHeadings.Add("ADX Plus "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER3)) nnHeadings.Add("ADX Minus "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER4)) nnHeadings.Add("ADX Cross"+tech.inputPrefix);
      #endif
   }
   return true;
}


