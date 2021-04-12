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
class EATechnicalsMACD : public EATechnicalsBase {
//=========

//=========
private:

   string      ss; 
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
   EATechnicalsMACD(Technicals &t);
   ~EATechnicalsMACD();

   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime, CArrayString &nnHeadings);  
   void  setValues();                   


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMACD::EATechnicalsMACD(Technicals &t) {

   int bars;
   CArrayDouble nnInputs, nnOutputs;

   EATechnicalsBase::copyValues(t);

   handle=iMACD(_Symbol,t.period,t.fastMovingAverage,t.slowMovingAverage,t.signalPeriod,t.appliedPrice);
   if (!handle) {
      #ifdef _DEBUG_MACD_MODULE
         ss="EATechnicalsMACD -> handle ERROR";
         pss
         writeLog
         ExpertRemove();
      #endif
   }

   #ifdef _DEBUG_MACD_MODULE
      ss=StringFormat("EATechnicalsMACD -> EATechnicalsMACD(Technicals &t)  -> bars in terminal history:%d for period:%s with MA:%d barDelay:%d",Bars(_Symbol,tech.period),EnumToString(tech.period),tech.movingAverage,tech.barDelay);
      pss
      writeLog
   #endif


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsMACD::~EATechnicalsMACD() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsMACD::setValues() {

   tech.versionNumber++;

   string sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', fastMovingAverage=%d, slowMovingAverage=%d, signalPeriod=%d, appliedPrice=%d, ENUM_APPLIED_PRICE=%s, upperLevel=%.5f, versionNumber=%d, barDelay=%d "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.fastMovingAverage, tech.slowMovingAverage, tech.signalPeriod, tech.appliedPrice, EnumToString(tech.appliedPrice), tech.upperLevel, tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   
   EATechnicalsBase::updateValuesToDatabase(sql);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATechnicalsMACD::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {


   if (CopyBuffer(handle,0,barDateTime,tech.barDelay,buffer1)==-1 || 
      CopyBuffer(handle,1,barDateTime,tech.barDelay,buffer2)==-1) {
         #ifdef _DEBUG_MACD_MODULE
            ss=StringFormat("EATechnicalsMACD -> getValues(1) %s -> copybuffer error barDelay:%d %d",tech.inputPrefix, tech.barDelay,GetLastError());
            writeLog
         #endif
         return false;
   }

   if (buffer1[tech.barDelay-1]==EMPTY_VALUE || buffer2[tech.barDelay-1]==EMPTY_VALUE) {
      #ifdef _DEBUG_MACD_MODULE
         ss=StringFormat("EATechnicalsMACD -> getValues(2) %s -> (EMPTY VALUE)",tech.inputPrefix);
         writeLog
      #endif
      return false;
   } else {

      #ifdef _DEBUG_MACD_MODULE
         ss=StringFormat("EATechnicalsMACD  -> getValues(3) %s -> %s B1:%.2f  %d",tech.inputPrefix,TimeToString(barDateTime,TIME_DATE|TIME_MINUTES),buffer1[tech.barDelay-1],tech.barDelay);        
         writeLog
      #endif
      
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(buffer1[tech.barDelay-1]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(buffer2[tech.barDelay-1]);

            // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         if (bool (tech.useBuffers&_BUFFER1)) nnHeadings.Add("MACD Main "+tech.inputPrefix);
         if (bool (tech.useBuffers&_BUFFER2)) nnHeadings.Add("MACD Signal "+tech.inputPrefix);
      #endif
   }
   return true;
}

