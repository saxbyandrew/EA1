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
class EATechnicalsRSI : public EATechnicalsBase {
//=========

//=========
private:

   string   ss;
   CiRSI    rsi;  

   double overSoldOverBought(double currentValue);
   


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsRSI(Technicals &t);
   ~EATechnicalsRSI();

   void  setValues();
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRSI::EATechnicalsRSI(Technicals &t) {

   EATechnicalsBase::copyValues(t);

   if (!rsi.Create(_Symbol, t.period, t.movingAverage, t.appliedPrice)) {
      #ifdef _DEBUG_RSI_MODULE
            ss="RSISetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsRSI::~EATechnicalsRSI() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRSI::setValues() {

   string sql;

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', movingAverage=%d, upperLevel=%.5f, lowerLevel=%.5f, appliedPrice=%d, ENUM_APPLIED_PRICE='%s', barDelay=%d, versionNumber=%d  "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.movingAverage,tech.upperLevel,tech.lowerLevel,tech.appliedPrice, EnumToString(tech.appliedPrice), tech.versionNumber, tech.barDelay, tech.strategyNumber,tech.inputPrefix);
   
   #ifdef _DEBUG_BASE
      ss="EATechnicalsRSI -> UPDATE INTO TECHNICALS";
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
double EATechnicalsRSI::overSoldOverBought(double currentValue) {

   if (currentValue>tech.upperLevel) return 1;
   if (currentValue<tech.lowerLevel) return -1;
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRSI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1];

      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI  -> using getValues(1)"; 
         writeLog
         pss
      #endif

   // Refresh the indicator and get all the buffers
   rsi.Refresh(-1);

   if (rsi.GetData(barDateTime,1,0,main)>0) {
      #ifdef _DEBUG_RSI_MODULE
         ss=StringFormat("EATechnicalsRSI  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss

      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(overSoldOverBought(main[0]));

   } else {
      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI  -> getValues(1) -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsRSI::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {


   double main[1];

      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI  -> using getValues(2)"; 
         writeLog
         pss
      #endif

   // Refresh the indicator and get all the buffers
   rsi.Refresh(-1);

   if (rsi.GetData(1,1,0,main)>0) {
      #ifdef _DEBUG_RSI_MODULE
         ss=StringFormat("EATechnicalsRSI  -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss

      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(overSoldOverBought(main[0]));

   } else {
      #ifdef _DEBUG_RSI_MODULE
         ss="EATechnicalsRSI -> getValues(2) -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);

   }

}
