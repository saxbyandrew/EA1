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
class EATechnicalsMFI : public EATechnicalsBase {
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
   EATechnicalsMFI(Technicals &tech);
   ~EATechnicalsMFI();

   void setValues();
   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings);                  


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMFI::EATechnicalsMFI(Technicals &t) {

   EATechnicalsBase::copyValues(t);

   handle=iMFI(_Symbol,t.period,t.movingAverage,t.appliedVolume);
   if (!handle) {
      #ifdef _DEBUG_MFI_MODULE
         ss="EATechnicalsMFI -> handle ERROR";
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
void EATechnicalsMFI::setValues() {

   string sql;

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', movingAverage=%d, upperLevel=%.5f, lowerLevel=%.5f, appliedVolume=%d, ENUM_APPLIED_PRICE='%s', barDelay=%d, versionNumber=%d  "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.movingAverage,tech.upperLevel,tech.lowerLevel,tech.appliedVolume, EnumToString(tech.appliedPrice), tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   

   EATechnicalsBase::updateValuesToDatabase(sql);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATechnicalsMFI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */


   if (CopyBuffer(handle,0,barDateTime,tech.barDelay,buffer1)==-1) { //MAIN
         #ifdef _DEBUG_MFI_MODULE
            ss=StringFormat("EATechnicalsMFI -> getValues(1) %s -> copybuffer error",tech.inputPrefix);
            writeLog
         #endif
         return false;
   }

   if (buffer1[tech.barDelay-1]==EMPTY_VALUE)  {
      #ifdef _DEBUG_MFI_MODULE
         ss=StringFormat("EATechnicalsMFI -> getValues(2) %s (EMPTY VALUE)",tech.inputPrefix);
         writeLog
      #endif
      return false;
   } else {

      #ifdef _DEBUG_MFI_MODULE
         ss=StringFormat("EATechnicalsMFI -> getValues(3) %s -> B1:%.2f",tech.inputPrefix,buffer1[tech.barDelay-1]);        
         writeLog
      #endif
      
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(buffer1[tech.barDelay-1]);
      // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         if (bool (tech.useBuffers&_BUFFER1)) nnHeadings.Add("MFIMain");
      #endif
   }
   return true;
}

