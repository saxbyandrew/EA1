//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_TECHNICAL_PARAMETERS

#include "EAEnum.mqh"
#include "EAOptimizationInputs.mqh"

class EATechnicalParameters {

//=========
private:
//=========


//=========
protected:
//=========
   void        copyValuesFromInputs();
   void        copyValuesFromDatabase();
   void        copyValuesToDatabase();
   void        createNNArray(EANeuralNetwork &nn);

//=========
public:
//=========
EATechnicalParameters();
~EATechnicalParameters();



   struct technicals {

      int strategyNumber;
      int iterationNumber;
   
      int useADX;
      ENUM_TIMEFRAMES s_ADXperiod;
      int s_ADXma;
      ENUM_TIMEFRAMES m_ADXperiod;
      int m_ADXma;
      ENUM_TIMEFRAMES l_ADXperiod;
      int l_ADXma;

      int useRSI;
      ENUM_TIMEFRAMES s_RSIperiod;
      int s_RSIma;
      ENUM_APPLIED_PRICE s_RSIap;

      ENUM_TIMEFRAMES m_RSIperiod;
      int m_RSIma;
      ENUM_APPLIED_PRICE m_RSIap;

      ENUM_TIMEFRAMES l_RSIperiod;
      int l_RSIma;
      ENUM_APPLIED_PRICE l_RSIap;

      int useMFI;
      ENUM_TIMEFRAMES s_MFIperiod;
      int s_MFIma;
      ENUM_TIMEFRAMES m_MFIperiod;
      int m_MFIma;
      ENUM_TIMEFRAMES l_MFIperiod;
      int l_MFIma;

      int useSAR;
      ENUM_TIMEFRAMES s_SARperiod;
      double s_SARstep;
      double s_SARmax;
      ENUM_TIMEFRAMES m_SARperiod;
      double m_SARstep;
      double m_SARmax;
      ENUM_TIMEFRAMES l_SARperiod;
      double l_SARstep;
      double l_SARmax;

      int useICH;
      ENUM_TIMEFRAMES s_ICHperiod;
      int s_tenkan_sen;
      int s_kijun_sen;
      int s_senkou_span_b;
      ENUM_TIMEFRAMES m_ICHperiod;
      int m_tenkan_sen;
      int m_kijun_sen;
      int m_senkou_span_b;
      ENUM_TIMEFRAMES l_ICHperiod;
      int l_tenkan_sen;
      int l_kijun_sen;
      int l_senkou_span_b;

      int useRVI;
      ENUM_TIMEFRAMES s_RVIperiod;
      int s_RVIma;
      ENUM_TIMEFRAMES m_RVIperiod;
      int m_RVIma;
      ENUM_TIMEFRAMES l_RVIperiod;
      int l_RVIma;

      int useSTOC;
      ENUM_TIMEFRAMES s_STOCperiod;
      int s_kPeriod;
      int s_dPeriod;
      int s_slowing;
      ENUM_MA_METHOD s_STOCmamethod;
      ENUM_STO_PRICE s_STOCpa;

      ENUM_TIMEFRAMES m_STOCperiod;
      int m_kPeriod;
      int m_dPeriod;
      int m_slowing;
      ENUM_MA_METHOD m_STOCmamethod;
      ENUM_STO_PRICE m_STOCpa;

      ENUM_TIMEFRAMES l_STOCperiod;
      int l_kPeriod;
      int l_dPeriod;
      int l_slowing;
      ENUM_MA_METHOD l_STOCmamethod;
      ENUM_STO_PRICE l_STOCpa;

      int useOSMA;
      ENUM_TIMEFRAMES s_OSMAperiod;
      int s_OSMAfastEMA;
      int s_OSMAslowEMA;
      int s_OSMAsignalPeriod;
      int s_OSMApa;

      ENUM_TIMEFRAMES m_OSMAperiod;
      int m_OSMAfastEMA;
      int m_OSMAslowEMA;
      int m_OSMAsignalPeriod;
      int m_OSMApa;
      ENUM_TIMEFRAMES l_OSMAperiod;
      int l_OSMAfastEMA;
      int l_OSMAslowEMA;
      int l_OSMAsignalPeriod;
      int l_OSMApa;

      int useMACD;
      ENUM_TIMEFRAMES s_MACDDperiod;
      int s_MACDDfastEMA;
      int s_MACDDslowEMA;
      int s_MACDDsignalPeriod;
      ENUM_TIMEFRAMES m_MACDDperiod;
      int m_MACDDfastEMA;
      int m_MACDDslowEMA;
      int m_MACDDsignalPeriod;
      ENUM_TIMEFRAMES l_MACDDperiod;
      int l_MACDDfastEMA;
      int l_MACDDslowEMA;
      int l_MACDDsignalPeriod;

      int useMACDBULLDIV;
      ENUM_TIMEFRAMES s_MACDBULLperiod;
      int s_MACDBULLfastEMA;
      int s_MACDBULLslowEMA;
      int s_MACDBULLsignalPeriod;
      ENUM_TIMEFRAMES m_MACDBULLperiod;
      int m_MACDBULLfastEMA;
      int m_MACDBULLslowEMA;
      int m_MACDBULLsignalPeriod;
      ENUM_TIMEFRAMES l_MACDBULLperiod;
      int l_MACDBULLfastEMA;
      int l_MACDBULLslowEMA;
      int l_MACDBULLsignalPeriod;

      int useMACDBEARDIV;
      ENUM_TIMEFRAMES s_MACDBEARperiod;
      int s_MACDBEARfastEMA;
      int s_MACDBEARslowEMA;
      int s_MACDBEARsignalPeriod;
      ENUM_TIMEFRAMES m_MACDBEARperiod;
      int m_MACDBEARfastEMA;
      int m_MACDBEARslowEMA;
      int m_MACDBEARsignalPeriod;
      ENUM_TIMEFRAMES l_MACDBEARperiod;
      int l_MACDBEARfastEMA;
      int l_MACDBEARslowEMA;
      int l_MACDBEARsignalPeriod;

      int useZZ;
      ENUM_TIMEFRAMES s_ZZperiod;
      ENUM_TIMEFRAMES m_ZZperiod;
      ENUM_TIMEFRAMES l_ZZperiod;
   } t;

   double nnData[];

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::EATechnicalParameters() {


   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EATechnicalParameters Object Created ....";
      writeLog;
   #endif
   
   // Determine where we get the technicl values from based on if we are in normal running mode
   // on in strategy optimization mode
   if (MQLInfoInteger(MQL_TESTER)) {
      copyValuesFromInputs();
   } else {
      copyValuesFromDatabase();
   }

   #ifdef _WRITELOG
      ss=StringFormat(" -> Run Mode is:%d",_runMode);
      writeLog;
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::~EATechnicalParameters() {


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromDatabase() {

   #ifdef _WRITELOG
      string ss;
   #endif

   int request=DatabasePrepare(_dbHandle,"SELECT * FROM STRATEGIES WHERE isActive=1");
   if (!DatabaseRead(request)) {
      Print(" -> DB request failed with code:", GetLastError()); 
      ExpertRemove();
   } else {
      DatabaseColumnInteger   (request,55,t.s_ADXperiod);
      DatabaseColumnInteger   (request,56,t.s_ADXma);
      DatabaseColumnInteger   (request,57,t.m_ADXperiod);
      DatabaseColumnInteger   (request,58,t.m_ADXma);
      DatabaseColumnInteger   (request,59,t.l_ADXperiod);
      DatabaseColumnInteger   (request,60,t.l_ADXma);
      DatabaseColumnInteger   (request,61,t.s_RSIperiod);
      DatabaseColumnInteger   (request,62,t.s_RSIma);
      DatabaseColumnInteger   (request,63,t.s_RSIap);
      DatabaseColumnInteger   (request,64,t.m_RSIperiod);
      DatabaseColumnInteger   (request,65,t.m_RSIma);
      DatabaseColumnInteger   (request,66,t.s_RSIap);
      DatabaseColumnInteger   (request,67,t.l_RSIperiod);
      DatabaseColumnInteger   (request,68,t.l_RSIma);
      DatabaseColumnInteger   (request,69,t.l_RSIap);
      DatabaseColumnInteger   (request,70,t.s_MFIperiod);
      DatabaseColumnInteger   (request,71,t.s_MFIma);
      DatabaseColumnInteger   (request,72,t.m_MFIperiod);
      DatabaseColumnInteger   (request,73,t.m_MFIma);
      DatabaseColumnInteger   (request,74,t.l_MFIperiod);
      DatabaseColumnInteger   (request,75,t.l_MFIma);
      DatabaseColumnInteger   (request,76,t.s_SARperiod);
      DatabaseColumnDouble    (request,77,t.s_SARstep);
      DatabaseColumnDouble    (request,78,t.s_SARmax);
      DatabaseColumnInteger   (request,79,t.m_SARperiod);
      DatabaseColumnDouble    (request,80,t.m_SARstep);
      DatabaseColumnDouble    (request,81,t.m_SARmax);
      DatabaseColumnInteger   (request,82,t.l_SARperiod);
      DatabaseColumnDouble    (request,83,t.l_SARstep);
      DatabaseColumnDouble    (request,84,t.l_SARmax);
      DatabaseColumnInteger   (request,85,t.s_ICHperiod);
      DatabaseColumnInteger   (request,86,t.s_tenkan_sen);
      DatabaseColumnInteger   (request,87,t.s_kijun_sen);
      DatabaseColumnInteger   (request,88,t.s_senkou_span_b);
      DatabaseColumnInteger   (request,89,t.m_ICHperiod);
      DatabaseColumnInteger   (request,90,t.m_tenkan_sen);
      DatabaseColumnInteger   (request,91,t.m_kijun_sen);
      DatabaseColumnInteger   (request,92,t.m_senkou_span_b);
      DatabaseColumnInteger   (request,93,t.l_ICHperiod);
      DatabaseColumnInteger   (request,94,t.l_tenkan_sen);
      DatabaseColumnInteger   (request,95,t.l_kijun_sen);
      DatabaseColumnInteger   (request,96,t.l_senkou_span_b);
      DatabaseColumnInteger   (request,97,t.s_RVIperiod);
      DatabaseColumnInteger   (request,98,t.s_RVIma);
      DatabaseColumnInteger   (request,99,t.m_RVIperiod);
      DatabaseColumnInteger   (request,100,t.m_RVIma);
      DatabaseColumnInteger   (request,101,t.l_RVIperiod);
      DatabaseColumnInteger   (request,102,t.l_RVIma);
      DatabaseColumnInteger   (request,103,t.s_STOCperiod);
      DatabaseColumnInteger   (request,104,t.s_kPeriod);
      DatabaseColumnInteger   (request,105,t.s_dPeriod);
      DatabaseColumnInteger   (request,106,t.s_slowing);
      DatabaseColumnInteger   (request,107,t.s_STOCmamethod);
      DatabaseColumnInteger   (request,108,t.s_STOCpa);
      DatabaseColumnInteger   (request,109,t.m_STOCperiod);
      DatabaseColumnInteger   (request,110,t.m_kPeriod);
      DatabaseColumnInteger   (request,111,t.m_dPeriod);
      DatabaseColumnInteger   (request,112,t.m_slowing);
      DatabaseColumnInteger   (request,113,t.m_STOCmamethod);
      DatabaseColumnInteger   (request,114,t.m_STOCpa);
      DatabaseColumnInteger   (request,115,t.l_STOCperiod);
      DatabaseColumnInteger   (request,116,t.l_kPeriod);
      DatabaseColumnInteger   (request,117,t.l_dPeriod);
      DatabaseColumnInteger   (request,118,t.l_slowing);
      DatabaseColumnInteger   (request,119,t.l_STOCmamethod);
      DatabaseColumnInteger   (request,120,t.l_STOCpa);
      DatabaseColumnInteger   (request,121,t.s_OSMAperiod);
      DatabaseColumnInteger   (request,122,t.s_OSMAfastEMA);
      DatabaseColumnInteger   (request,123,t.s_OSMAslowEMA);
      DatabaseColumnInteger   (request,124,t.s_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,125,t.s_OSMApa);
      DatabaseColumnInteger   (request,126,t.m_OSMAperiod);
      DatabaseColumnInteger   (request,127,t.m_OSMAfastEMA);
      DatabaseColumnInteger   (request,128,t.m_OSMAslowEMA);
      DatabaseColumnInteger   (request,129,t.m_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,130,t.m_OSMApa);
      DatabaseColumnInteger   (request,131,t.l_OSMAperiod);
      DatabaseColumnInteger   (request,132,t.l_OSMAfastEMA);
      DatabaseColumnInteger   (request,133,t.l_OSMAslowEMA);
      DatabaseColumnInteger   (request,134,t.l_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,135,t.l_OSMApa);
      DatabaseColumnInteger   (request,136,t.s_MACDDperiod);
      DatabaseColumnInteger   (request,137,t.s_MACDDfastEMA);
      DatabaseColumnInteger   (request,138,t.s_MACDDslowEMA);
      DatabaseColumnInteger   (request,139,t.s_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,140,t.m_MACDDperiod);
      DatabaseColumnInteger   (request,141,t.m_MACDDfastEMA);
      DatabaseColumnInteger   (request,142,t.m_MACDDslowEMA);
      DatabaseColumnInteger   (request,143,t.m_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,144,t.l_MACDDperiod);
      DatabaseColumnInteger   (request,145,t.l_MACDDfastEMA);
      DatabaseColumnInteger   (request,146,t.l_MACDDslowEMA);
      DatabaseColumnInteger   (request,147,t.l_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,148,t.s_MACDBULLperiod);
      DatabaseColumnInteger   (request,149,t.s_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,150,t.s_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,151,t.s_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,152,t.m_MACDBULLperiod);
      DatabaseColumnInteger   (request,153,t.m_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,154,t.m_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,155,t.m_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,156,t.l_MACDBULLperiod);
      DatabaseColumnInteger   (request,157,t.l_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,158,t.l_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,159,t.l_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,160,t.s_MACDBEARperiod);
      DatabaseColumnInteger   (request,161,t.s_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,162,t.s_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,163,t.s_MACDBEARsignalPeriod);
      DatabaseColumnInteger   (request,164,t.m_MACDBEARperiod);
      DatabaseColumnInteger   (request,165,t.m_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,166,t.m_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,167,t.m_MACDBEARsignalPeriod);
      DatabaseColumnInteger   (request,168,t.l_MACDBEARperiod);
      DatabaseColumnInteger   (request,169,t.l_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,170,t.l_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,171,t.l_MACDBEARsignalPeriod);
      //DatabaseColumnInteger   (request,172,useADX);
      //DatabaseColumnInteger   (request,173,useRSI);
      //DatabaseColumnInteger   (request,174,useMFI);
      //DatabaseColumnInteger   (request,175,useSAR);
      //DatabaseColumnInteger   (request,176,useICH);
      //DatabaseColumnInteger   (request,177,useRVI);
      //DatabaseColumnInteger   (request,178,useSTOC);
      //DatabaseColumnInteger   (request,179,useOSMA);
      //DatabaseColumnInteger   (request,180,useMACD);
      //DatabaseColumnInteger   (request,181,useMACDBULLDIV);
      //DatabaseColumnInteger   (request,182,useMACDBEARDIV);
      
   }

   #ifdef _WRITELOG
      commentLine;
      ss=" -> copyValuesFromDatabase ....";
      writeLog;
   #endif


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromInputs() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EATechnicalParameters Copy values from inputs (Optimization)";
      writeLog;
   #endif


   t.useADX=iuseADX;
   t.s_ADXperiod=is_ADXperiod;
   t.s_ADXma=is_ADXma;
   t.m_ADXperiod=im_ADXperiod;
   t.m_ADXma=im_ADXma;
   t.l_ADXperiod=il_ADXperiod;
   t.l_ADXma=il_ADXma;
   
   #ifdef _WRITELOG
      commentLine;
      ss=StringFormat(" -> copyValuesFromInputs ->\nShort ADX Period:%s\n Short ADX MA:%d\n Medium ADX Period:%s\n Medium ADX MA:%d\n Long ADX Period:%s\n Long ADX MA:%d",
         EnumToString(t.s_ADXperiod),t.s_ADXma,EnumToString(t.m_ADXperiod),t.m_ADXma,EnumToString(t.l_ADXperiod),t.l_ADXma);
      writeLog;
   #endif
   
   t.useRSI=iuseRSI;
   t.s_RSIperiod=is_RSIperiod;
   t.s_RSIma=is_RSIma;
   t.s_RSIap=is_RSIap;
   t.m_RSIperiod=im_RSIperiod;
   t.m_RSIma=im_RSIma;
   t.s_RSIap=is_RSIap;
   t.l_RSIperiod=il_RSIperiod;
   t.l_RSIma=il_RSIma;
   t.l_RSIap=il_RSIap;

   t.useMFI=iuseMFI;
   t.s_MFIperiod=is_MFIperiod;
   t.s_MFIma=is_MFIma;
   t.m_MFIperiod=im_MFIperiod;
   t.m_MFIma=im_MFIma;
   t.l_MFIperiod=il_MFIperiod;
   t.l_MFIma=il_MFIma;

   t.useSAR=iuseSAR;
   t.s_SARperiod=is_SARperiod;
   t.s_SARstep=is_SARstep;
   t.s_SARmax=is_SARmax;
   t.m_SARperiod=im_SARperiod;
   t.m_SARstep=im_SARstep;
   t.m_SARmax=im_SARmax;
   t.l_SARperiod=il_SARperiod;
   t.l_SARstep=il_SARstep;
   t.l_SARmax=il_SARmax;

   t.useICH=iuseICH;
   t.s_ICHperiod=is_ICHperiod;
   t.s_tenkan_sen=is_tenkan_sen;
   t.s_kijun_sen=is_kijun_sen;
   t.s_senkou_span_b=is_senkou_span_b;
   t.m_ICHperiod=im_ICHperiod;
   t.m_tenkan_sen=im_tenkan_sen;
   t.m_kijun_sen=im_kijun_sen;
   t.m_senkou_span_b=im_senkou_span_b;
   t.l_ICHperiod=il_ICHperiod;
   t.l_tenkan_sen=il_tenkan_sen;
   t.l_kijun_sen=il_kijun_sen;
   t.l_senkou_span_b=il_senkou_span_b;

   t.useRVI=iuseRVI;
   t.s_RVIperiod=is_RVIperiod;
   t.s_RVIma=is_RVIma;
   t.m_RVIperiod=im_RVIperiod;
   t.m_RVIma=im_RVIma;
   t.l_RVIperiod=il_RVIperiod;
   t.l_RVIma=il_RVIma;

   t.useSTOC=iuseSTOC;
   t.s_STOCperiod=is_STOCperiod;
   t.s_kPeriod=is_kPeriod;
   t.s_dPeriod=is_dPeriod;
   t.s_slowing=is_slowing;
   t.s_STOCmamethod=is_STOCmamethod;
   t.s_STOCpa=is_STOCpa;
   t.m_STOCperiod=im_STOCperiod;
   t.m_kPeriod=im_kPeriod;
   t.m_dPeriod=im_dPeriod;
   t.m_slowing=im_slowing;
   t.m_STOCmamethod=im_STOCmamethod;
   t.m_STOCpa=im_STOCpa;
   t.l_STOCperiod=il_STOCperiod;
   t.l_kPeriod=il_kPeriod;
   t.l_dPeriod=il_dPeriod;
   t.l_slowing=il_slowing;
   t.l_STOCmamethod=il_STOCmamethod;
   t.l_STOCpa=il_STOCpa;

   t.useOSMA=iuseOSMA;
   t.s_OSMAperiod=is_OSMAperiod;
   t.s_OSMAfastEMA=is_OSMAfastEMA;
   t.s_OSMAslowEMA=is_OSMAslowEMA;
   t.s_OSMAsignalPeriod=is_OSMAsignalPeriod;
   t.s_OSMApa=is_OSMApa;
   t.m_OSMAperiod=im_OSMAperiod;
   t.m_OSMAfastEMA=im_OSMAfastEMA;
   t.m_OSMAslowEMA=im_OSMAslowEMA;
   t.m_OSMAsignalPeriod=im_OSMAsignalPeriod;
   t.m_OSMApa=im_OSMApa;
   t.l_OSMAperiod=il_OSMAperiod;
   t.l_OSMAfastEMA=il_OSMAfastEMA;
   t.l_OSMAslowEMA=il_OSMAslowEMA;
   t.l_OSMAsignalPeriod=il_OSMAsignalPeriod;
   t.l_OSMApa=il_OSMApa;

   t.useMACD=iuseMACD;
   t.s_MACDDperiod=is_MACDDperiod;
   t.s_MACDDfastEMA=is_MACDDfastEMA;
   t.s_MACDDslowEMA=is_MACDDslowEMA;
   t.s_MACDDsignalPeriod=is_MACDDsignalPeriod;
   t.m_MACDDperiod=im_MACDDperiod;
   t.m_MACDDfastEMA=im_MACDDfastEMA;
   t.m_MACDDslowEMA=im_MACDDslowEMA;
   t.m_MACDDsignalPeriod=im_MACDDsignalPeriod;
   t.l_MACDDperiod=il_MACDDperiod;
   t.l_MACDDfastEMA=il_MACDDfastEMA;
   t.l_MACDDslowEMA=il_MACDDslowEMA;
   t.l_MACDDsignalPeriod=il_MACDDsignalPeriod;
   t.s_MACDBULLperiod=is_MACDBULLperiod;
   t.s_MACDBULLfastEMA=is_MACDBULLfastEMA;
   t.s_MACDBULLslowEMA=is_MACDBULLslowEMA;
   t.s_MACDBULLsignalPeriod=is_MACDBULLsignalPeriod;
   t.m_MACDBULLperiod=im_MACDBULLperiod;
   t.m_MACDBULLfastEMA=im_MACDBULLfastEMA;
   t.m_MACDBULLslowEMA=im_MACDBULLslowEMA;
   t.m_MACDBULLsignalPeriod=im_MACDBULLsignalPeriod;
   t.l_MACDBULLperiod=il_MACDBULLperiod;
   t.l_MACDBULLfastEMA=il_MACDBULLfastEMA;
   t.l_MACDBULLslowEMA=il_MACDBULLslowEMA;
   t.l_MACDBULLsignalPeriod=il_MACDBULLsignalPeriod;
   t.s_MACDBEARperiod=is_MACDBEARperiod;
   t.s_MACDBEARfastEMA=is_MACDBEARfastEMA;
   t.s_MACDBEARslowEMA=is_MACDBEARslowEMA;
   t.s_MACDBEARsignalPeriod=is_MACDBEARsignalPeriod;
   t.m_MACDBEARperiod=im_MACDBEARperiod;
   t.m_MACDBEARfastEMA=im_MACDBEARfastEMA;
   t.m_MACDBEARslowEMA=im_MACDBEARslowEMA;
   t.m_MACDBEARsignalPeriod=im_MACDBEARsignalPeriod;
   t.l_MACDBEARperiod=il_MACDBEARperiod;
   t.l_MACDBEARfastEMA=il_MACDBEARfastEMA;
   t.l_MACDBEARslowEMA=il_MACDBEARslowEMA;
   t.l_MACDBEARsignalPeriod=il_MACDBEARsignalPeriod;

   t.useZZ=iuseZZ;
   t.s_ZZperiod=is_ZZperiod;
   t.m_ZZperiod=im_ZZperiod;
   t.l_ZZperiod=il_ZZperiod;

   #ifdef _WRITELOG
      commentLine;
      ss=StringFormat(" -> copyValuesFromInputs ->\nShort ZZ Period:%s\n Medium ZZ Period:%s\n Long ZZ Period:%s\n",
         EnumToString(t.s_ZZperiod),EnumToString(t.m_ZZperiod),EnumToString(t.l_ZZperiod));
      writeLog;

   #endif

   t.useMACDBULLDIV=iuseMACDBULLDIV;
   t.useMACDBEARDIV=iuseMACDBEARDIV;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::createNNArray(EANeuralNetwork &nn) {


   ArrayResize(nnData,nn.nnArray.Total());
   
   for (int i=0;i<nn.nnArray.Total(); i++) {
      nnData[i]=nn.nnArray.At(i);
   }
   

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesToDatabase() {


string request1a="INSERT INTO TECHPASSES ("
         "strategyNumber,iterationNumber"
         "s_ADXperiod,s_ADXma,m_ADXperiod,m_ADXma,l_ADXperiod,l_ADXma,s_RSIperiod,s_RSIma,s_RSIap,m_RSIperiod,m_RSIma,m_RSIap,l_RSIperiod,l_RSIma,l_RSIap,s_MFIperiod,"
         "s_MFIma,m_MFIperiod,m_MFIma,l_MFIperiod,l_MFIma,s_SARperiod,s_SARstep,s_SARmax,m_SARperiod,m_SARstep,m_SARmax,l_SARperiod,l_SARstep,l_SARmax,s_ICHperiod,"
         "s_tenkan_sen,s_kijun_sen,s_senkou_span_b,m_ICHperiod,m_tenkan_sen,m_kijun_sen,m_senkou_span_b,l_ICHperiod,l_tenkan_sen,l_kijun_sen,l_senkou_span_b,s_RVIperiod,"
         "s_RVIma,m_RVIperiod,m_RVIma,l_RVIperiod,l_RVIma,s_STOCperiod,s_kPeriod,s_dPeriod,s_slowing,s_STOCmamethod,s_STOCpa,m_STOCperiod,m_kPeriod,m_dPeriod,m_slowing,"
         "m_STOCmamethod,m_STOCpa,l_STOCperiod,l_kPeriod,l_dPeriod,l_slowing,l_STOCmamethod,l_STOCpa,s_OSMAperiod,s_OSMAfastEMA,s_OSMAslowEMA,s_OSMAsignalPeriod,s_OSMApa,m_OSMAperiod,"
         "m_OSMAfastEMA,m_OSMAslowEMA,m_OSMAsignalPeriod,m_OSMApa,l_OSMAperiod,l_OSMAfastEMA,l_OSMAslowEMA,l_OSMAsignalPeriod,l_OSMApa,s_MACDDperiod,s_MACDDfastEMA,"
         "s_MACDDslowEMA,s_MACDDsignalPeriod,m_MACDDperiod,m_MACDDfastEMA,m_MACDDslowEMA,m_MACDDsignalPeriod,l_MACDDperiod,l_MACDDfastEMA,l_MACDDslowEMA,l_MACDDsignalPeriod,"
         "s_MACDBULLperiod,s_MACDBULLfastEMA,s_MACDBULLslowEMA,s_MACDBULLsignalPeriod,m_MACDBULLperiod,m_MACDBULLfastEMA,m_MACDBULLslowEMA,m_MACDBULLsignalPeriod,l_MACDBULLperiod,"
         "l_MACDBULLfastEMA,l_MACDBULLslowEMA,l_MACDBULLsignalPeriod,s_MACDBEARperiod,s_MACDBEARfastEMA,s_MACDBEARslowEMA,s_MACDBEARsignalPeriod,m_MACDBEARperiod,m_MACDBEARfastEMA,"
         "m_MACDBEARslowEMA,m_MACDBEARsignalPeriod,l_MACDBEARperiod,l_MACDBEARfastEMA,l_MACDBEARslowEMA,l_MACDBEARsignalPeriod"
         ") VALUES (";

         

      string request1b=StringFormat("%d,%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", t.strategyNumber,t.iterationNumber,   
      t.s_ADXperiod,t.s_ADXma,t.m_ADXperiod,t.m_ADXma,t.l_ADXperiod,t.l_ADXma);

      string request1c=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_RSIperiod,t.s_RSIma,t.s_RSIap,t.m_RSIperiod,t.m_RSIma,t.s_RSIap,t.l_RSIperiod,t.l_RSIma,t.l_RSIap);

      string request1d=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_MFIperiod,t.s_MFIma,t.m_MFIperiod,t.m_MFIma,t.l_MFIperiod,t.l_MFIma);

      string request1e=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_SARperiod,t.s_SARstep,t.s_SARmax,t.m_SARperiod,t.m_SARstep,t.m_SARmax,t.l_SARperiod,t.l_SARstep,t.l_SARmax);

      string request1f=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_ICHperiod,t.s_tenkan_sen,t.s_kijun_sen,t.s_senkou_span_b,t.m_ICHperiod,t.m_tenkan_sen,t.m_kijun_sen,t.m_senkou_span_b,t.l_ICHperiod,t.l_tenkan_sen,t.l_kijun_sen,t.l_senkou_span_b);

      string request1g=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_RVIperiod,t.s_RVIma,t.m_RVIperiod,t.m_RVIma,t.l_RVIperiod,t.l_RVIma);

      string request1h=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_STOCperiod,t.s_kPeriod,t.s_dPeriod,t.s_slowing,t.s_STOCmamethod,t.s_STOCpa,t.m_STOCperiod,t.m_kPeriod,t.m_dPeriod,t.m_slowing,t.m_STOCmamethod,t.m_STOCpa,t.l_STOCperiod,t.l_kPeriod,t.l_dPeriod,t.l_slowing,t.l_STOCmamethod,t.l_STOCpa);

      string request1i=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,,%.5f,%.5f,%.5f", 
      t.s_OSMAperiod,t.s_OSMAfastEMA,t.s_OSMAslowEMA,t.s_OSMAsignalPeriod,t.s_OSMApa,t.m_OSMAperiod,t.m_OSMAfastEMA,t.m_OSMAslowEMA,t.m_OSMAsignalPeriod,t.m_OSMApa,t.l_OSMAperiod,t.l_OSMAfastEMA,t.l_OSMAslowEMA,t.l_OSMAsignalPeriod,t.l_OSMApa);

      string request1j=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_MACDDperiod,t.s_MACDDfastEMA,t.s_MACDDslowEMA,t.s_MACDDsignalPeriod,t.m_MACDDperiod,t.m_MACDDfastEMA,t.m_MACDDslowEMA,t.m_MACDDsignalPeriod,t.l_MACDDperiod,t.l_MACDDfastEMA,t.l_MACDDslowEMA,t.l_MACDDsignalPeriod);

      string request1k=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_MACDBULLperiod,t.s_MACDBULLfastEMA,t.s_MACDBULLslowEMA,t.s_MACDBULLsignalPeriod,t.m_MACDBULLperiod,t.m_MACDBULLfastEMA,t.m_MACDBULLslowEMA,t.m_MACDBULLsignalPeriod,t.l_MACDBULLperiod,t.l_MACDBULLfastEMA,t.l_MACDBULLslowEMA,t.l_MACDBULLsignalPeriod);

      string request1l=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f", 
      t.s_MACDBEARperiod,t.s_MACDBEARfastEMA,t.s_MACDBEARslowEMA,t.s_MACDBEARsignalPeriod,t.m_MACDBEARperiod,t.m_MACDBEARfastEMA,t.m_MACDBEARslowEMA,t.m_MACDBEARsignalPeriod,t.l_MACDBEARperiod,t.l_MACDBEARfastEMA,t.l_MACDBEARslowEMA,t.l_MACDBEARsignalPeriod);


      string request1=StringFormat("%s%s%s%s%s%s%s%s%s%s%s%s",request1a,request1b,request1c,request1d,request1e,request1f,request1g,request1h,request1i,request1j,request1k,request1l);

      
      if (!DatabaseExecute(_optimizeHandle, request1)) {
         printf(" -> Failed to insert PASSES %d with code %d", t.iterationNumber, GetLastError());
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            printf(" -> Insert into PASSES succcess:%d",t.iterationNumber);
         #endif
      }


string request2 = StringFormat("UPDATE TECHPASSES SET nnData=?1 WHERE strategyNumber=%d AND iterationNumber=%d",t.strategyNumber,t.iterationNumber);

int prepare1=DatabasePrepare(_optimizeHandle, request2);
DatabaseBindArray(prepare1, 0, nnData); // Will this work as its a CArrayDouble not a Array/Double
DatabaseFinalize(prepare1);

}
