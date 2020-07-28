//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#define  _DEBUG_NN_INPUTS_OUTPUTS


#include "EAEnum.mqh"
#include "EAModuleTechnicals.mqh"

class EATechnicalParameters;


//=========
class EAInputsOutputs  {
//=========


//=========
private:
//=========

   EAModuleTechnicals   *shortTerm;
   EAModuleTechnicals   *mediumTerm;
   EAModuleTechnicals   *longTerm;


//=========
protected:
//=========

   void  setupTechnicalParameters(EATechnicalParameters &t);

//=========
public:
//=========
EAInputsOutputs(EATechnicalParameters &t);
~EAInputsOutputs();

   virtual int Type() const {return _STRATEGY;};


   double            inputs[];       
   double            outputs[];      

   void  getInputs(int currentBar);
   void  getOutputs(int currentBar);


};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAInputsOutputs::EAInputsOutputs(EATechnicalParameters &tech) {


   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EAInputsOutputs Object Created ....";
      writeLog;
   #endif 

   shortTerm=new EAModuleTechnicals;
   mediumTerm=new EAModuleTechnicals;
   longTerm=new EAModuleTechnicals;

   if (CheckPointer(shortTerm)==POINTER_INVALID||CheckPointer(mediumTerm)==POINTER_INVALID||CheckPointer(longTerm)==POINTER_INVALID) {
         printf("-> Error creating technical shortTerm mediumTerm or longTerm objects");
         ExpertRemove();
   } 

   setupTechnicalParameters(tech);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAInputsOutputs::~EAInputsOutputs() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::setupTechnicalParameters(EATechnicalParameters &tech) {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> setupTechnicalParameters ....";
      writeLog;
   #endif 

    //if (tech.t.useADX) {
      #ifdef _WRITELOG
         ss=StringFormat("Short ADX Period:%s\n Short ADX MA:%d\n Medium ADX Period:%s\n Medium ADX MA:%d\n Long ADX Period:%s\n Long ADX MA:%d\n",
         EnumToString(tech.t.s_ADXperiod),tech.t.s_ADXma,EnumToString(tech.t.m_ADXperiod),tech.t.m_ADXma,EnumToString(tech.t.l_ADXperiod),tech.t.l_ADXma);
         writeLog;
      #endif
      // ADX      ADXNormalizedValue(int start, int buffer) 0=Main 1=DI+ 2=DI-
      shortTerm.ADXSetParameters(tech.t.s_ADXperiod,tech.t.s_ADXma);
      mediumTerm.ADXSetParameters(tech.t.m_ADXperiod,tech.t.m_ADXma);
      longTerm.ADXSetParameters(tech.t.l_ADXperiod,tech.t.l_ADXma);

   //}

   //if (tech.t.useRSI) {
      // RSI     RSINormalizedValue(int start)
      shortTerm.RSISetParameters(tech.t.s_RSIperiod,tech.t.s_RSIma,tech.t.s_RSIap);
      mediumTerm.RSISetParameters(tech.t.m_RSIperiod,tech.t.m_RSIma,tech.t.m_RSIap);
      longTerm.RSISetParameters(tech.t.l_RSIperiod,tech.t.l_RSIma,tech.t.l_RSIap);
   //}
/*
   if (tech.t.useMFI) {
      // MFI MFINormalizedValue(int start) 
      shortTerm.MFISetParameters(tech.t.s_MFIperiod,tech.t.s_MFIma);
      mediumTerm.MFISetParameters(tech.t.m_MFIperiod,tech.t.m_MFIma);
      longTerm.MFISetParameters(tech.t.l_MFIperiod,tech.t.l_MFIma);
   }

   if (tech.t.useSAR) {
      // SAR  SARNormalizedValue(ENUM_TIMEFRAMES period)
      shortTerm.SARSetParameters(tech.t.s_SARperiod,tech.t.s_SARstep,tech.t.s_SARmax);
      mediumTerm.SARSetParameters(tech.t.m_SARperiod,tech.t.m_SARstep,tech.t.m_SARmax);
      longTerm.SARSetParameters(tech.t.l_SARperiod,tech.t.l_SARstep,tech.t.l_SARmax);
   }

   if (tech.t.useICH) {
      // ICH  IICHIMOKUNormalizedValue(ENUM_TIMEFRAMES period,int lookBack, int buffer)
      // Buffer 0=TenkanSen, buffer 1=KijunSen buffer 2=SenkouSpanA buffer 3=SenkouSpanB  buffer 4=ChinkouSpan
      shortTerm.IICHIMOKUSetParameters(tech.t.s_ICHperiod,tech.t.s_tenkan_sen,tech.t.s_kijun_sen,tech.t.s_senkou_span_b);
      mediumTerm.IICHIMOKUSetParameters(tech.t.m_ICHperiod,tech.t.m_tenkan_sen,tech.t.m_kijun_sen,tech.t.m_senkou_span_b);
      longTerm.IICHIMOKUSetParameters(tech.t.l_ICHperiod,tech.t.l_tenkan_sen,tech.t.l_kijun_sen,tech.t.l_senkou_span_b);
   }

   if (tech.t.useRVI) {
      // RVI   RVINormalizedValue(int start, int buffer) 
      shortTerm.RVISetParameters(tech.t.s_RVIperiod,tech.t.s_RVIma);
      mediumTerm.RVISetParameters(tech.t.m_RVIperiod,tech.t.m_RVIma);
      longTerm.RVISetParameters(tech.t.l_RVIperiod,tech.t.l_RVIma);
   }

   if(tech.t.useSTOC) {
       //STOC STOCNormalizedValue(int start, int buffer) 
      shortTerm.STOCSetParameters(tech.t.s_STOCperiod,tech.t.s_kPeriod,tech.t.s_dPeriod,tech.t.s_slowing,tech.t.s_STOCmamethod,tech.t.s_STOCpa);
      mediumTerm.STOCSetParameters(tech.t.m_STOCperiod,tech.t.m_kPeriod,tech.t.m_dPeriod,tech.t.m_slowing,tech.t.m_STOCmamethod,tech.t.m_STOCpa);
      longTerm.STOCSetParameters(tech.t.l_STOCperiod,tech.t.l_kPeriod,tech.t.l_dPeriod,tech.t.l_slowing,tech.t.l_STOCmamethod,tech.t.l_STOCpa);
   }

   if (tech.t.useOSMA) {
      // OSMA OSMANormalizedValue(int start)
      shortTerm.OSMASetParameters(tech.t.s_OSMAperiod,tech.t.s_OSMAfastEMA,tech.t.s_OSMAslowEMA,tech.t.s_OSMAsignalPeriod,tech.t.s_OSMApa);
      mediumTerm.OSMASetParameters(tech.t.m_OSMAperiod,tech.t.m_OSMAfastEMA,tech.t.m_OSMAslowEMA,tech.t.m_OSMAsignalPeriod,tech.t.m_OSMApa);
      longTerm.OSMASetParameters(tech.t.l_OSMAperiod,tech.t.l_OSMAfastEMA,tech.t.l_OSMAslowEMA,tech.t.l_OSMAsignalPeriod,tech.t.l_OSMApa);
   }

   if (tech.t.useMACD||tech.t.useMACDBULLDIV||tech.t.useMACDBEARDIV) {
      shortTerm.MACDSetupParametersDivergence(tech.t.s_MACDDperiod,tech.t.s_MACDDfastEMA,tech.t.s_MACDDslowEMA,tech.t.s_MACDDsignalPeriod);
      mediumTerm.MACDSetupParametersDivergence(tech.t.m_MACDDperiod,tech.t.m_MACDDfastEMA,tech.t.m_MACDDslowEMA,tech.t.m_MACDDsignalPeriod);
      longTerm.MACDSetupParametersDivergence(tech.t.l_MACDDperiod,tech.t.l_MACDDfastEMA,tech.t.l_MACDDslowEMA,tech.t.l_MACDDsignalPeriod);
   }
*/
   //if (tech.t.useZZ) {
      #ifdef _WRITELOG
         ss=StringFormat("Short ZZ Period:%s\nMedium ZZ Period:%s\nLong ZZ Period:%s\n",
         EnumToString(tech.t.s_ZZperiod),EnumToString(tech.t.m_ZZperiod),EnumToString(tech.t.l_ZZperiod));
         writeLog;
      #endif
      shortTerm.ZIGZAGSetupParameters(tech.t.s_ZZperiod);
      mediumTerm.ZIGZAGSetupParameters(tech.t.m_ZZperiod);
      longTerm.ZIGZAGSetupParameters(tech.t.l_ZZperiod);
   //}

   // Prime the input and output arrays
   getInputs(1);
   getOutputs(1);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::getInputs(int currentBar) {




   double   i[100];
   int      j=0;

   // This is wehere the inputs to the NN are mapped at every tick or bar
   // simply comment out any lines to remove a input

   // ADX 
   // ADXNormalizedValue(int start, int buffer) 0=Main 1=DI+ 2=DI-
   //if (tech.t.useADX) {
      i[j++]=shortTerm.ADXNormalizedValue(currentBar,0);
      i[j++]=shortTerm.ADXNormalizedValue(currentBar,0); // MAIN
      i[j++]=shortTerm.ADXNormalizedValue(currentBar,1); // DI+
      i[j++]=mediumTerm.ADXNormalizedValue(currentBar,0); // MAIN
      i[j++]=mediumTerm.ADXNormalizedValue(currentBar,1); // DI+
      i[j++]=longTerm.ADXNormalizedValue(currentBar,0); // MAIN
      i[j++]=longTerm.ADXNormalizedValue(currentBar,1); // DI+
      // ADX
   //}
   
   // RSI
   //if (tech.t.useRSI) {
      i[j++]=shortTerm.RSINormalizedValue(currentBar);
      i[j++]=mediumTerm.RSINormalizedValue(currentBar);
      i[j++]=longTerm.RSINormalizedValue(currentBar);
   //}


   // Create a new array only with the correct input values
   ArrayCopy(inputs,i,0,0,j);
   /*
   #ifdef _WRITELOG
      string ss=StringFormat(" -> Neural Network Inputs:%d\n",ArraySize(inputs)); 
      writeLog;
   #endif
   */
   


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::getOutputs(int currentBar) {

   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      Print(__FUNCTION__);
   #endif 

   double  o[2];
   int     j=0;

   // Output are the reference we will try and train the model to
   
   //outputs[0]=mediumTerm.SARValue(tech.t.m_SARperiod);
   //outputs[1]=longTerm.SARValue(tech.t.l_SARperiod);

   EAEnum x = shortTerm.ZIGZAGValue(currentBar);

   if (x==_UP) {
      o[j++]=1;
      o[j++]=0;
   }
   if (x==_DOWN) {
      o[j++]=0;
      o[j++]=1;
   }

   ArrayCopy(outputs,o,0,0,j);
   /*
   #ifdef _WRITELOG
      string ss=StringFormat(" -> Neural Network Outputs:%d\n",ArraySize(outputs)); 
      writeLog;
   #endif
   */

}

