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
class EATechnicalsSTOC : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   int      handle;
   double   buffer1[];
   double   buffer2[];
   double   buffer3[];


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsSTOC(Technicals &t);
   ~EATechnicalsSTOC();

   void  setValues();   
   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsSTOC::EATechnicalsSTOC(Technicals &t) {

   EATechnicalsBase::copyValues(t);

   handle=iStochastic(_Symbol,t.period,t.kPeriod,t.dPeriod,t.slowMovingAverage,t.movingAverageMethod,t.stocPrice);
   if (!handle) {
      #ifdef _DEBUG_STOC_MODULE
         ss="EATechnicalsSTOC -> handle ERROR";
         pss
         writeLog
         ExpertRemove();
      #endif
   }

   #ifdef _DEBUG_STOC_MODULE
      ss=StringFormat("EATechnicalsSTOC -> EATechnicalsSTOC(Technicals &t)  -> bars in terminal history:%d for period:%s with MA:%d barDelay:%d",Bars(_Symbol,tech.period),EnumToString(tech.period),tech.movingAverage,tech.barDelay);
      pss
      writeLog
   #endif

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsSTOC::~EATechnicalsSTOC() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsSTOC::setValues() {

   string sql;

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', kPeriod=%d, dPeriod=%d, slowMovingAverage=%d, movingAverageMethod=%d, ENUM_MA_METHOD='%s', barDelay=%d, versionNumber=%d  "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.kPeriod, tech.dPeriod, tech.slowMovingAverage, tech.movingAverageMethod, EnumToString(tech.movingAverageMethod), tech.barDelay, tech.versionNumber, tech.strategyNumber,tech.inputPrefix);

   EATechnicalsBase::updateValuesToDatabase(sql);

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATechnicalsSTOC::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */


   if (CopyBuffer(handle,0,barDateTime,tech.barDelay,buffer1)==-1 ||
       CopyBuffer(handle,1,barDateTime,tech.barDelay,buffer2)==-1) {   //MAIN
         #ifdef _DEBUG_RVI_MODULE
            ss=StringFormat("EATechnicalsSTOC -> getValues(1) %s -> copybuffer error",tech.inputPrefix);
            writeLog
         #endif
         return false;
   }

   if (buffer1[tech.barDelay-1]==EMPTY_VALUE || buffer2[tech.barDelay-1]==EMPTY_VALUE)  {
      #ifdef _DEBUG_RVI_MODULE
         ss=StringFormat("EATechnicalsSTOC -> getValues(2) %s (EMPTY VALUE)",tech.inputPrefix);
         writeLog
      #endif
      return false;
   } else {

      #ifdef _DEBUG_RVI_MODULE
         ss=StringFormat("EATechnicalsSTOC -> getValues(3) %s -> B1:%.2f",tech.inputPrefix,buffer1[tech.barDelay-1]);        
         writeLog
      #endif
      
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(buffer1[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(buffer2[tech.barDelay-1]);
      // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         if (bool (tech.useBuffers&_BUFFER1)) nnHeadings.Add("STOC Main "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER2)) nnHeadings.Add("STOC Signal "+tech.inputPrefix);
      #endif
   }
   return true;
}
