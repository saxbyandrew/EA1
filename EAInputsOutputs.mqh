//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EAEnum.mqh"
#include "EAModuleTechnicals.mqh"

class EATechnicalParameters;

//=========
class EAInputsOutputs  {
//=========


//=========
private:
//=========
   string               ss;
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


   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss="EAInputsOutputs ->  Object Created ....";
      writeLog
      pss
   #endif 

   shortTerm=new EAModuleTechnicals;
   mediumTerm=new EAModuleTechnicals;
   longTerm=new EAModuleTechnicals;

   if (CheckPointer(shortTerm)==POINTER_INVALID||CheckPointer(mediumTerm)==POINTER_INVALID||CheckPointer(longTerm)==POINTER_INVALID) {
      #ifdef _DEBUG_NN_INPUTS_OUTPUTS
         ss="-> ERROR creating technical shortTerm mediumTerm longTerm objects";
         writeLog
      #endif
      pss
      ExpertRemove();
   } else {
      #ifdef _DEBUG_NN_INPUTS_OUTPUTS
         ss="-> SUCCESS creating technical shortTerm mediumTerm longTerm objects";
         writeLog
         pss
      #endif
   }

   setupTechnicalParameters(tech);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAInputsOutputs::~EAInputsOutputs() {

   delete shortTerm;
   delete mediumTerm;
   delete longTerm;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::setupTechnicalParameters(EATechnicalParameters &tech) {

   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss="setupTechnicalParameters ->  ....";
      writeLog
      pss
   #endif 

    //if (tech.t.useADX) {
      #ifdef _DEBUG_NN_INPUTS_OUTPUTS
         ss=StringFormat(" Short ADX Period:%s\n Short ADX MA:%d\n Medium ADX Period:%s\n Medium ADX MA:%d\n Long ADX Period:%s\n Long ADX MA:%d\n",
         EnumToString(tech.adx.s_ADXperiod),tech.adx.s_ADXma,EnumToString(tech.adx.m_ADXperiod),tech.adx.m_ADXma,EnumToString(tech.adx.l_ADXperiod),tech.adx.l_ADXma);
         writeLog
         pss
      #endif
      // ADX      ADXNormalizedValue(int start, int buffer) 0=Main 1=DI+ 2=DI-
      shortTerm.ADXSetParameters(tech.adx.s_ADXperiod,tech.adx.s_ADXma);
      mediumTerm.ADXSetParameters(tech.adx.m_ADXperiod,tech.adx.m_ADXma);
      longTerm.ADXSetParameters(tech.adx.l_ADXperiod,tech.adx.l_ADXma);

   //}

   //if (tech.t.useRSI) {
      #ifdef _DEBUG_NN_INPUTS_OUTPUTS
         ss=StringFormat(" Short RSI Period:%s\n Short RSI MA:%d\n Medium RSI Period:%s\n Medium RSI MA:%d\n Long RSI Period:%s\n Long RSI MA:%d\n",
         EnumToString(tech.rsi.s_RSIperiod),tech.rsi.s_RSIma,EnumToString(tech.rsi.m_RSIperiod),tech.rsi.m_RSIma,EnumToString(tech.rsi.l_RSIperiod),tech.rsi.l_RSIperiod);
         writeLog
         pss
      #endif
      // RSI     RSINormalizedValue(int start)
      shortTerm.RSISetParameters(tech.rsi.s_RSIperiod, tech.rsi.s_RSIma, tech.rsi.s_RSIap);
      mediumTerm.RSISetParameters(tech.rsi.m_RSIperiod,tech.rsi.m_RSIma,tech.rsi.m_RSIap);
      longTerm.RSISetParameters(tech.rsi.l_RSIperiod, tech.rsi.l_RSIperiod, tech.rsi.l_RSIap);
   //}
/*
   if (tech.t.useMFI) {
      // MFI MFINormalizedValue(int start) 
      shortTerm.MFISetParameters(tech.adx.s_MFIperiod,tech.adx.s_MFIma);
      mediumTerm.MFISetParameters(tech.adx.m_MFIperiod,tech.adx.m_MFIma);
      longTerm.MFISetParameters(tech.adx.l_MFIperiod,tech.adx.l_MFIma);
   }

   if (tech.t.useSAR) {
      // SAR  SARNormalizedValue(ENUM_TIMEFRAMES period)
      shortTerm.SARSetParameters(tech.adx.s_SARperiod,tech.adx.s_SARstep,tech.adx.s_SARmax);
      mediumTerm.SARSetParameters(tech.adx.m_SARperiod,tech.adx.m_SARstep,tech.adx.m_SARmax);
      longTerm.SARSetParameters(tech.adx.l_SARperiod,tech.adx.l_SARstep,tech.adx.l_SARmax);
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
      shortTerm.RVISetParameters(tech.adx.s_RVIperiod,tech.adx.s_RVIma);
      mediumTerm.RVISetParameters(tech.adx.m_RVIperiod,tech.adx.m_RVIma);
      longTerm.RVISetParameters(tech.adx.l_RVIperiod,tech.adx.l_RVIma);
   }

   if(tech.t.useSTOC) {
       //STOC STOCNormalizedValue(int start, int buffer) 
      shortTerm.STOCSetParameters(tech.t.s_STOCperiod,tech.t.s_kPeriod,tech.t.s_dPeriod,tech.t.s_slowing,tech.t.s_STOCmamethod,tech.t.s_STOCpa);
      mediumTerm.STOCSetParameters(tech.t.m_STOCperiod,tech.t.m_kPeriod,tech.t.m_dPeriod,tech.t.m_slowing,tech.t.m_STOCmamethod,tech.t.m_STOCpa);
      longTerm.STOCSetParameters(tech.t.l_STOCperiod,tech.t.l_kPeriod,tech.t.l_dPeriod,tech.t.l_slowing,tech.t.l_STOCmamethod,tech.t.l_STOCpa);
   }

   if (tech.t.useOSMA) {
      // OSMA OSMANormalizedValue(int start)
      shortTerm.OSMASetParameters(tech.adx.s_OSMAperiod,tech.adx.s_OSMAfastEMA,tech.adx.s_OSMAslowEMA,tech.adx.s_OSMAsignalPeriod,tech.adx.s_OSMApa);
      mediumTerm.OSMASetParameters(tech.adx.m_OSMAperiod,tech.adx.m_OSMAfastEMA,tech.adx.m_OSMAslowEMA,tech.adx.m_OSMAsignalPeriod,tech.adx.m_OSMApa);
      longTerm.OSMASetParameters(tech.adx.l_OSMAperiod,tech.adx.l_OSMAfastEMA,tech.adx.l_OSMAslowEMA,tech.adx.l_OSMAsignalPeriod,tech.adx.l_OSMApa);
   }

   if (tech.t.useMACD||tech.t.useMACDBULLDIV||tech.t.useMACDBEARDIV) {
      shortTerm.MACDSetupParametersDivergence(tech.adx.s_MACDDperiod,tech.adx.s_MACDDfastEMA,tech.adx.s_MACDDslowEMA,tech.adx.s_MACDDsignalPeriod);
      mediumTerm.MACDSetupParametersDivergence(tech.adx.m_MACDDperiod,tech.adx.m_MACDDfastEMA,tech.adx.m_MACDDslowEMA,tech.adx.m_MACDDsignalPeriod);
      longTerm.MACDSetupParametersDivergence(tech.adx.l_MACDDperiod,tech.adx.l_MACDDfastEMA,tech.adx.l_MACDDslowEMA,tech.adx.l_MACDDsignalPeriod);
   }
*/
   //if (tech.t.useZZ) {
      #ifdef _DEBUG_NN_INPUTS_OUTPUTS
         ss=StringFormat(" Short ZZ Period:%s\n Medium ZZ Period:%s\n Long ZZ Period:%s\n",
         EnumToString(tech.zz.s_ZZperiod),EnumToString(tech.zz.m_ZZperiod),EnumToString(tech.zz.l_ZZperiod));
         writeLog
         pss
      #endif

      shortTerm.ZIGZAGSetupParameters(tech.zz.s_ZZperiod);
      mediumTerm.ZIGZAGSetupParameters(tech.zz.m_ZZperiod);
      longTerm.ZIGZAGSetupParameters(tech.zz.l_ZZperiod);
   //}

   // Prime the input and output arrays we do this so that the DF and NN objects know
   // the matrix size we are deailing with.
   
   getInputs(1);
   getOutputs(1);
   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      printf(" ************ setupTechnicalParameters -> ");
      ArrayPrint(inputs);
      ArrayPrint(outputs);
   #endif

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::getInputs(int currentBar) {

   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss=StringFormat("getInputs -> for bar number:%d",currentBar);
      writeLog
      pss
   #endif 

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
   
   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss="getInputs -> ";
      for (int i=0;i<ArraySize(inputs);i++) {
         ss=ss+"  "+DoubleToString(inputs[i]);
      }
      writeLog
      pss
   #endif
   
   


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::getOutputs(int currentBar) {

   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss=StringFormat("getOutputs ->for bar number:%d",currentBar);
      writeLog
      pss
   #endif  

   double  o[2];
   int     j=0;

   // Output are the reference we will try and train the model to
   
   //outputs[0]=mediumTerm.SARValue(tech.adx.m_SARperiod);
   //outputs[1]=longTerm.SARValue(tech.adx.l_SARperiod);

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
   
   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss="getOutputs -> ";
      for (int i=0;i<ArraySize(outputs);i++) {
         ss=ss+"  "+DoubleToString(outputs[i]);
      }
      writeLog
      pss
   #endif

}

