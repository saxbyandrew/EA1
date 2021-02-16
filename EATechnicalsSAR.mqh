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
class EATechnicalsSAR : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   int      handle;
   double   buffer1[];
   double   buffer2[];
   double   buffer3[];

   double SARLevelCross(double val);

//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsSAR(Technicals &t);
   ~EATechnicalsSAR();

   void setValues();
   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings);                  



};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsSAR::EATechnicalsSAR(Technicals &t) {


   EATechnicalsBase::copyValues(t);


   handle=iSAR(_Symbol,t.period,t.stepValue,t.maxValue);
   if (!handle) {
      #ifdef _DEBUG_SAR_MODULE
         ss="EATechnicalsSAR -> handle ERROR";
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
void EATechnicalsSAR::setValues() {

   string sql;

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', stepValue=%.5f, maxValue=%.5f, barDelay=%d, versionNumber=%d  "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.stepValue, tech.maxValue, tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   

   EATechnicalsBase::updateValuesToDatabase(sql);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsSAR::SARLevelCross(double val) {

   if (iClose(_Symbol,tech.period,tech.barDelay)>val) return 1;
   return 0;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATechnicalsSAR::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */


   if (CopyBuffer(handle,0,barDateTime,tech.barDelay,buffer1)==-1) { //MAIN
         #ifdef _DEBUG_SAR_MODULE
            ss=StringFormat("EATechnicalsSAR -> getValues(1) %s -> copybuffer error",tech.inputPrefix);
            writeLog
         #endif
         return false;
   }

   if (buffer1[tech.barDelay-1]==EMPTY_VALUE)  {
      #ifdef _DEBUG_SAR_MODULE
         ss=StringFormat("EATechnicalsSAR -> getValues(2) %s (EMPTY VALUE)",tech.inputPrefix);
         writeLog
      #endif
      return false;
   } else {

      #ifdef _DEBUG_SAR_MODULE
         ss=StringFormat("EATechnicalsSAR -> getValues(3) %s -> B1:%.2f",tech.inputPrefix,buffer1[tech.barDelay-1]);        
         writeLog
      #endif
      
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(buffer1[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(SARLevelCross(buffer1[tech.barDelay-1])); // Use Main
      // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         if (bool (tech.useBuffers&_BUFFER1)) nnHeadings.Add("SARMain "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER2)) nnHeadings.Add("SAR Above/Below"+tech.inputPrefix);
      #endif
   }
   return true;
}