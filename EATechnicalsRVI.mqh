//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

// The Relative Vigor Index (RVI) is a technical analysis indicator that 
// measures the strength of a trend by comparing a security's closing price 
// to its trading range and smoothing the results. It's based on the tendency 
// for prices to close higher than they open in uptrends and to close 
// lower than they open in downtrends.

#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"


//=========
class EATechnicalsRVI : public EATechnicalsBase {
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
   EATechnicalsRVI(Technicals &t);
   ~EATechnicalsRVI();

   void  setValues();   
   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings);                    
                  


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRVI::EATechnicalsRVI(Technicals &t) {


   EATechnicalsBase::copyValues(t);

   handle=iRVI(_Symbol,t.period,t.movingAverage);
   if (!handle) {
      #ifdef _DEBUG_RVI_MODULE
         ss="EATechnicalsRVI -> handle ERROR";
         pss
         writeLog
         ExpertRemove();
      #endif
   }

   #ifdef _DEBUG_RVI_MODULE
      ss=StringFormat("EATechnicalsRVI -> EATechnicalsRVI(Technicals &t)  -> bars in terminal history:%d for period:%s with MA:%d barDelay:%d",Bars(_Symbol,tech.period),EnumToString(tech.period),tech.movingAverage,tech.barDelay);
      pss
      writeLog
   #endif


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRVI::~EATechnicalsRVI() {

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRVI::setValues() {

   string sql;

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', movingAverage=%d, upperLevel=%.5f, lowerLevel=%.5f, barDelay=%d, versionNumber=%d  "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.movingAverage,tech.upperLevel,tech.lowerLevel, tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   

   EATechnicalsBase::updateValuesToDatabase(sql);

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATechnicalsRVI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */


   if (CopyBuffer(handle,0,barDateTime,tech.barDelay,buffer1)==-1 ||   // MAIN
       CopyBuffer(handle,1,barDateTime,tech.barDelay,buffer2)==-1) {  // SIGNAL
         #ifdef _DEBUG_RVI_MODULE
            ss=StringFormat("EATechnicalsRVI -> getValues(1) %s -> copybuffer error",tech.inputPrefix);
            writeLog
         #endif
         return false;
   }

   if (buffer1[tech.barDelay-1]==EMPTY_VALUE || buffer2[tech.barDelay-1]==EMPTY_VALUE)  {
      #ifdef _DEBUG_RVI_MODULE
         ss=StringFormat("EATechnicalsRVI -> getValues(2) %s (EMPTY VALUE)",tech.inputPrefix);
         writeLog
      #endif
      return false;
   } else {

      #ifdef _DEBUG_RVI_MODULE
         ss=StringFormat("EATechnicalsRVI -> getValues(3) %s -> B1:%.2f",tech.inputPrefix,buffer1[tech.barDelay-1]);        
         writeLog
      #endif
      
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(buffer1[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(buffer2[tech.barDelay-1]);
      // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         if (bool (tech.useBuffers&_BUFFER1)) nnHeadings.Add("RVI Main "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER2)) nnHeadings.Add("RVI Signal "+tech.inputPrefix);
      #endif
   }
   return true;
}


