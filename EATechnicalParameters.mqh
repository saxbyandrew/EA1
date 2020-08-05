//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_TECHNICAL_PARAMETERS

#include "EAEnum.mqh"
#include "EAOptimizationInputs.mqh"

class EATechnicalParameters {

//=========
private:
//=========

   string      ss;
   int         _baseStrategyReference;


//=========
protected:
//=========
   void        copyValuesFromInputs();
   void        copyValuesFromDatabase();
   int         copyValuesFromDatabase(string tableName);
   void        copyValuesToDatabase();
   
//=========
public:
//=========
EATechnicalParameters(int baseStrategyReference);
~EATechnicalParameters();



   struct ADX {
      int strategyNumber;
      int typeRefernce;
      int useADX;

      ENUM_TIMEFRAMES s_ADXperiod;
      int s_ADXma;
      ENUM_TIMEFRAMES m_ADXperiod;
      int m_ADXma;
      ENUM_TIMEFRAMES l_ADXperiod;
      int l_ADXma;
   } adx;

   struct RSI {
      int strategyNumber;
      int typeRefernce;
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
   } rsi;

   struct MFI {
      int strategyNumber;
      int typeRefernce;
      int useMFI;

      ENUM_TIMEFRAMES s_MFIperiod;
      int s_MFIma;
      ENUM_TIMEFRAMES m_MFIperiod;
      int m_MFIma;
      ENUM_TIMEFRAMES l_MFIperiod;
      int l_MFIma;
   } mfi;

   struct SAR {
      int strategyNumber;
      int typeRefernce;
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
   } sar;

   struct ICH {
      int strategyNumber;
      int typeRefernce;
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
   } ich;

   struct RVI {
      int strategyNumber;
      int idx;
      int useRVI;

      ENUM_TIMEFRAMES s_RVIperiod;
      int s_RVIma;
      ENUM_TIMEFRAMES m_RVIperiod;
      int m_RVIma;
      ENUM_TIMEFRAMES l_RVIperiod;
      int l_RVIma;
   } rvi;

   struct STOC {
      int strategyNumber;
      int typeRefernce;
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
   } stoc;

   struct OSMA {
      int strategyNumber;
      int typeRefernce;
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
   } osma;

   struct MACD {
      int strategyNumber;
      int idx;
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
   } macd;

   struct MACDBULL {
      int strategyNumber;
      int typeRefernce;
      int useMACDBULL;

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
   } macdbull;

   struct MACDBEAR {
      int strategyNumber;
      int typeRefernce;
      int useMACDBEAR;

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
   } macdbear;

   struct ZZ {
      int useZZ;
      ENUM_TIMEFRAMES s_ZZperiod;
      ENUM_TIMEFRAMES m_ZZperiod;
      ENUM_TIMEFRAMES l_ZZperiod;
} zz;
   

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::EATechnicalParameters(int baseStrategyReference) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      printf ("EATechnicalParameters ->  Object Created ....");
      writeLog
      printf(ss);
   #endif

   _baseStrategyReference=baseStrategyReference;
   
   // Determine where we get the technicl values from based on if we are in normal running mode
   // on in strategy optimization mode
   
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss="EATechnicalParameters ->  copy input values MQL_OPTIMIZATION ....";
         writeLog
         printf(ss);
      #endif
      copyValuesFromInputs();
   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss="EATechnicalParameters ->  copy DB values ....";
         writeLog
         printf(ss);
      #endif
      copyValuesFromDatabase();
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::~EATechnicalParameters() {


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EATechnicalParameters::copyValuesFromDatabase(string tableName) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="copyValuesFromDatabase -> ....";
      printf(ss);
   #endif

   string sql=StringFormat("SELECT * FROM %s where strategyNumber=%d AND typeReference=%d",tableName,usp.strategyNumber,_baseStrategyReference);
   int request=DatabasePrepare(_mainDBHandle,sql);
   if (!DatabaseRead(request)) {
      ss=StringFormat(" -> EATechnicalParameters copyValuesFromDatabase DB request failed %s %d %d with code:",tableName,usp.strategyNumber,_baseStrategyReference, GetLastError()); 
      printf(ss);
      ExpertRemove();
   }
   return request;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromDatabase() {

   int request;

     // ----------------------------------------------------------------
   request=copyValuesFromDatabase("ADX");
      DatabaseColumnInteger   (request,0,adx.strategyNumber);
      DatabaseColumnInteger   (request,1,adx.typeRefernce);
      DatabaseColumnInteger   (request,2,adx.useADX);
      DatabaseColumnInteger   (request,3,adx.s_ADXperiod);
      DatabaseColumnInteger   (request,4,adx.s_ADXma);
      DatabaseColumnInteger   (request,5,adx.m_ADXperiod);
      DatabaseColumnInteger   (request,6,adx.m_ADXma);
      DatabaseColumnInteger   (request,7,adx.l_ADXperiod);
      DatabaseColumnInteger   (request,8,adx.l_ADXma);
   

  // ----------------------------------------------------------------
   request=copyValuesFromDatabase("RSI");
      DatabaseColumnInteger   (request,0,rsi.strategyNumber);
      DatabaseColumnInteger   (request,1,rsi.typeRefernce);
      DatabaseColumnInteger   (request,2,rsi.useRSI);
      DatabaseColumnInteger   (request,3,rsi.s_RSIperiod);
      DatabaseColumnInteger   (request,4,rsi.s_RSIma);
      DatabaseColumnInteger   (request,5,rsi.s_RSIap);
      DatabaseColumnInteger   (request,6,rsi.m_RSIperiod);
      DatabaseColumnInteger   (request,7,rsi.m_RSIma);
      DatabaseColumnInteger   (request,8,rsi.s_RSIap);
      DatabaseColumnInteger   (request,9,rsi.l_RSIperiod);
      DatabaseColumnInteger   (request,10,rsi.l_RSIma);
      DatabaseColumnInteger   (request,11,rsi.l_RSIap);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("MFI");
      DatabaseColumnInteger   (request,0,mfi.strategyNumber);
      DatabaseColumnInteger   (request,1,mfi.typeRefernce);
      DatabaseColumnInteger   (request,2,mfi.useMFI);
      DatabaseColumnInteger   (request,3,mfi.s_MFIperiod);
      DatabaseColumnInteger   (request,4,mfi.s_MFIma);
      DatabaseColumnInteger   (request,5,mfi.m_MFIperiod);
      DatabaseColumnInteger   (request,6,mfi.m_MFIma);
      DatabaseColumnInteger   (request,7,mfi.l_MFIperiod);
      DatabaseColumnInteger   (request,8,mfi.l_MFIma);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("SAR");
      DatabaseColumnInteger   (request,0,sar.strategyNumber);
      DatabaseColumnInteger   (request,1,sar.typeRefernce);
      DatabaseColumnInteger   (request,2,sar.useSAR);
      DatabaseColumnInteger   (request,3,sar.s_SARperiod);
      DatabaseColumnDouble    (request,4,sar.s_SARstep);
      DatabaseColumnDouble    (request,5,sar.s_SARmax);
      DatabaseColumnInteger   (request,6,sar.m_SARperiod);
      DatabaseColumnDouble    (request,7,sar.m_SARstep);
      DatabaseColumnDouble    (request,8,sar.m_SARmax);
      DatabaseColumnInteger   (request,9,sar.l_SARperiod);
      DatabaseColumnDouble    (request,10,sar.l_SARstep);
      DatabaseColumnDouble    (request,11,sar.l_SARmax);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("ICH");
      DatabaseColumnInteger   (request,0,ich.strategyNumber);
      DatabaseColumnInteger   (request,1,ich.typeRefernce);
      DatabaseColumnInteger   (request,2,ich.useICH);
      DatabaseColumnInteger   (request,3,ich.s_ICHperiod);
      DatabaseColumnInteger   (request,4,ich.s_tenkan_sen);
      DatabaseColumnInteger   (request,5,ich.s_kijun_sen);
      DatabaseColumnInteger   (request,6,ich.s_senkou_span_b);
      DatabaseColumnInteger   (request,7,ich.m_ICHperiod);
      DatabaseColumnInteger   (request,8,ich.m_tenkan_sen);
      DatabaseColumnInteger   (request,9,ich.m_kijun_sen);
      DatabaseColumnInteger   (request,10,ich.m_senkou_span_b);
      DatabaseColumnInteger   (request,11,ich.l_ICHperiod);
      DatabaseColumnInteger   (request,12,ich.l_tenkan_sen);
      DatabaseColumnInteger   (request,13,ich.l_kijun_sen);
      DatabaseColumnInteger   (request,14,ich.l_senkou_span_b);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("RVI");
      DatabaseColumnInteger   (request,0,rvi.strategyNumber);
      DatabaseColumnInteger   (request,1,rvi.typeRefernce);
      DatabaseColumnInteger   (request,2,rvi.useRVI);
      DatabaseColumnInteger   (request,3,rvi.s_RVIperiod);
      DatabaseColumnInteger   (request,4,rvi.s_RVIma);
      DatabaseColumnInteger   (request,5,rvi.m_RVIperiod);
      DatabaseColumnInteger   (request,6,rvi.m_RVIma);
      DatabaseColumnInteger   (request,7,rvi.l_RVIperiod);
      DatabaseColumnInteger   (request,8,rvi.l_RVIma);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("STOC");
      DatabaseColumnInteger   (request,0,stoc.strategyNumber);
      DatabaseColumnInteger   (request,1,stoc.typeRefernce);
      DatabaseColumnInteger   (request,2,stoc.useSTOC);
      DatabaseColumnInteger   (request,3,stoc.s_STOCperiod);
      DatabaseColumnInteger   (request,4,stoc.s_kPeriod);
      DatabaseColumnInteger   (request,5,stoc.s_dPeriod);
      DatabaseColumnInteger   (request,6,stoc.s_slowing);
      DatabaseColumnInteger   (request,7,stoc.s_STOCmamethod);
      DatabaseColumnInteger   (request,8,stoc.s_STOCpa);
      DatabaseColumnInteger   (request,9,stoc.m_STOCperiod);
      DatabaseColumnInteger   (request,10,stoc.m_kPeriod);
      DatabaseColumnInteger   (request,11,stoc.m_dPeriod);
      DatabaseColumnInteger   (request,12,stoc.m_slowing);
      DatabaseColumnInteger   (request,13,stoc.m_STOCmamethod);
      DatabaseColumnInteger   (request,14,stoc.m_STOCpa);
      DatabaseColumnInteger   (request,15,stoc.l_STOCperiod);
      DatabaseColumnInteger   (request,16,stoc.l_kPeriod);
      DatabaseColumnInteger   (request,17,stoc.l_dPeriod);
      DatabaseColumnInteger   (request,18,stoc.l_slowing);
      DatabaseColumnInteger   (request,19,stoc.l_STOCmamethod);
      DatabaseColumnInteger   (request,20,stoc.l_STOCpa);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("OSMA");
      DatabaseColumnInteger   (request,0,osma.strategyNumber);
      DatabaseColumnInteger   (request,1,osma.typeRefernce);
      DatabaseColumnInteger   (request,2,osma.useOSMA);
      DatabaseColumnInteger   (request,3,osma.s_OSMAperiod);
      DatabaseColumnInteger   (request,4,osma.s_OSMAfastEMA);
      DatabaseColumnInteger   (request,5,osma.s_OSMAslowEMA);
      DatabaseColumnInteger   (request,6,osma.s_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,7,osma.s_OSMApa);
      DatabaseColumnInteger   (request,8,osma.m_OSMAperiod);
      DatabaseColumnInteger   (request,9,osma.m_OSMAfastEMA);
      DatabaseColumnInteger   (request,10,osma.m_OSMAslowEMA);
      DatabaseColumnInteger   (request,11,osma.m_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,12,osma.m_OSMApa);
      DatabaseColumnInteger   (request,13,osma.l_OSMAperiod);
      DatabaseColumnInteger   (request,14,osma.l_OSMAfastEMA);
      DatabaseColumnInteger   (request,15,osma.l_OSMAslowEMA);
      DatabaseColumnInteger   (request,16,osma.l_OSMAsignalPeriod);
      DatabaseColumnInteger   (request,17,osma.l_OSMApa);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("MACD");
      DatabaseColumnInteger   (request,0,macd.strategyNumber);
      DatabaseColumnInteger   (request,1,macd.typeRefernce);
      DatabaseColumnInteger   (request,2,macd.useMACD);
      DatabaseColumnInteger   (request,3,macd.s_MACDDperiod);
      DatabaseColumnInteger   (request,4,macd.s_MACDDfastEMA);
      DatabaseColumnInteger   (request,5,macd.s_MACDDslowEMA);
      DatabaseColumnInteger   (request,6,macd.s_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,7,macd.m_MACDDperiod);
      DatabaseColumnInteger   (request,8,macd.m_MACDDfastEMA);
      DatabaseColumnInteger   (request,9,macd.m_MACDDslowEMA);
      DatabaseColumnInteger   (request,10,macd.m_MACDDsignalPeriod);
      DatabaseColumnInteger   (request,11,macd.l_MACDDperiod);
      DatabaseColumnInteger   (request,12,macd.l_MACDDfastEMA);
      DatabaseColumnInteger   (request,13,macd.l_MACDDslowEMA);
      DatabaseColumnInteger   (request,14,macd.l_MACDDsignalPeriod);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("MACDBULL");
      DatabaseColumnInteger   (request,0,macdbull.strategyNumber);
      DatabaseColumnInteger   (request,1,macdbull.typeRefernce);
      DatabaseColumnInteger   (request,2,macdbull.useMACDBULL);
      DatabaseColumnInteger   (request,3,macdbull.s_MACDBULLperiod);
      DatabaseColumnInteger   (request,4,macdbull.s_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,5,macdbull.s_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,6,macdbull.s_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,7,macdbull.m_MACDBULLperiod);
      DatabaseColumnInteger   (request,8,macdbull.m_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,9,macdbull.m_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,10,macdbull.m_MACDBULLsignalPeriod);
      DatabaseColumnInteger   (request,11,macdbull.l_MACDBULLperiod);
      DatabaseColumnInteger   (request,12,macdbull.l_MACDBULLfastEMA);
      DatabaseColumnInteger   (request,13,macdbull.l_MACDBULLslowEMA);
      DatabaseColumnInteger   (request,14,macdbull.l_MACDBULLsignalPeriod);
   

   // ----------------------------------------------------------------
   request=copyValuesFromDatabase("MACDBEAR");
      DatabaseColumnInteger   (request,0,macdbear.strategyNumber);
      DatabaseColumnInteger   (request,1,macdbear.typeRefernce);
      DatabaseColumnInteger   (request,2,macdbear.useMACDBEAR);
      DatabaseColumnInteger   (request,3,macdbear.s_MACDBEARperiod);
      DatabaseColumnInteger   (request,4,macdbear.s_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,5,macdbear.s_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,6,macdbear.s_MACDBEARsignalPeriod);
      DatabaseColumnInteger   (request,7,macdbear.m_MACDBEARperiod);
      DatabaseColumnInteger   (request,8,macdbear.m_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,9,macdbear.m_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,10,macdbear.m_MACDBEARsignalPeriod);
      DatabaseColumnInteger   (request,11,macdbear.l_MACDBEARperiod);
      DatabaseColumnInteger   (request,12,macdbear.l_MACDBEARfastEMA);
      DatabaseColumnInteger   (request,13,macdbear.l_MACDBEARslowEMA);
      DatabaseColumnInteger   (request,14,macdbear.l_MACDBEARsignalPeriod);
   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromInputs() {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="copyValuesFromInputs -> ....";
      printf(ss);
   #endif

   adx.useADX=iuseADX;
   adx.s_ADXperiod=is_ADXperiod;
   adx.s_ADXma=is_ADXma;
   adx.m_ADXperiod=im_ADXperiod;
   adx.m_ADXma=im_ADXma;
   adx.l_ADXperiod=il_ADXperiod;
   adx.l_ADXma=il_ADXma;
   
   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat(" -> copyValuesFromInputs ->\n Short ADX Period:%s\n Short ADX MA:%d\n Medium ADX Period:%s\n Medium ADX MA:%d\n Long ADX Period:%s\n Long ADX MA:%d",
         EnumToString(adx.s_ADXperiod),adx.s_ADXma,EnumToString(adx.m_ADXperiod),adx.m_ADXma,EnumToString(adx.l_ADXperiod),adx.l_ADXma);
      writeLog;
      printf(ss);
   #endif
   
   rsi.useRSI=iuseRSI;
   rsi.s_RSIperiod=is_RSIperiod;
   rsi.s_RSIma=is_RSIma;
   rsi.s_RSIap=is_RSIap;
   rsi.m_RSIperiod=im_RSIperiod;
   rsi.m_RSIma=im_RSIma;
   rsi.s_RSIap=is_RSIap;
   rsi.l_RSIperiod=il_RSIperiod;
   rsi.l_RSIma=il_RSIma;
   rsi.l_RSIap=il_RSIap;

   mfi.useMFI=iuseMFI;
   mfi.s_MFIperiod=is_MFIperiod;
   mfi.s_MFIma=is_MFIma;
   mfi.m_MFIperiod=im_MFIperiod;
   mfi.m_MFIma=im_MFIma;
   mfi.l_MFIperiod=il_MFIperiod;
   mfi.l_MFIma=il_MFIma;

   sar.useSAR=iuseSAR;
   sar.s_SARperiod=is_SARperiod;
   sar.s_SARstep=is_SARstep;
   sar.s_SARmax=is_SARmax;
   sar.m_SARperiod=im_SARperiod;
   sar.m_SARstep=im_SARstep;
   sar.m_SARmax=im_SARmax;
   sar.l_SARperiod=il_SARperiod;
   sar.l_SARstep=il_SARstep;
   sar.l_SARmax=il_SARmax;

   ich.useICH=iuseICH;
   ich.s_ICHperiod=is_ICHperiod;
   ich.s_tenkan_sen=is_tenkan_sen;
   ich.s_kijun_sen=is_kijun_sen;
   ich.s_senkou_span_b=is_senkou_span_b;
   ich.m_ICHperiod=im_ICHperiod;
   ich.m_tenkan_sen=im_tenkan_sen;
   ich.m_kijun_sen=im_kijun_sen;
   ich.m_senkou_span_b=im_senkou_span_b;
   ich.l_ICHperiod=il_ICHperiod;
   ich.l_tenkan_sen=il_tenkan_sen;
   ich.l_kijun_sen=il_kijun_sen;
   ich.l_senkou_span_b=il_senkou_span_b;

   rvi.useRVI=iuseRVI;
   rvi.s_RVIperiod=is_RVIperiod;
   rvi.s_RVIma=is_RVIma;
   rvi.m_RVIperiod=im_RVIperiod;
   rvi.m_RVIma=im_RVIma;
   rvi.l_RVIperiod=il_RVIperiod;
   rvi.l_RVIma=il_RVIma;

   stoc.useSTOC=iuseSTOC;
   stoc.s_STOCperiod=is_STOCperiod;
   stoc.s_kPeriod=is_kPeriod;
   stoc.s_dPeriod=is_dPeriod;
   stoc.s_slowing=is_slowing;
   stoc.s_STOCmamethod=is_STOCmamethod;
   stoc.s_STOCpa=is_STOCpa;
   stoc.m_STOCperiod=im_STOCperiod;
   stoc.m_kPeriod=im_kPeriod;
   stoc.m_dPeriod=im_dPeriod;
   stoc.m_slowing=im_slowing;
   stoc.m_STOCmamethod=im_STOCmamethod;
   stoc.m_STOCpa=im_STOCpa;
   stoc.l_STOCperiod=il_STOCperiod;
   stoc.l_kPeriod=il_kPeriod;
   stoc.l_dPeriod=il_dPeriod;
   stoc.l_slowing=il_slowing;
   stoc.l_STOCmamethod=il_STOCmamethod;
   stoc.l_STOCpa=il_STOCpa;

   osma.useOSMA=iuseOSMA;
   osma.s_OSMAperiod=is_OSMAperiod;
   osma.s_OSMAfastEMA=is_OSMAfastEMA;
   osma.s_OSMAslowEMA=is_OSMAslowEMA;
   osma.s_OSMAsignalPeriod=is_OSMAsignalPeriod;
   osma.s_OSMApa=is_OSMApa;
   osma.m_OSMAperiod=im_OSMAperiod;
   osma.m_OSMAfastEMA=im_OSMAfastEMA;
   osma.m_OSMAslowEMA=im_OSMAslowEMA;
   osma.m_OSMAsignalPeriod=im_OSMAsignalPeriod;
   osma.m_OSMApa=im_OSMApa;
   osma.l_OSMAperiod=il_OSMAperiod;
   osma.l_OSMAfastEMA=il_OSMAfastEMA;
   osma.l_OSMAslowEMA=il_OSMAslowEMA;
   osma.l_OSMAsignalPeriod=il_OSMAsignalPeriod;
   osma.l_OSMApa=il_OSMApa;

   macduseMACD=iuseMACD;
   macd.s_MACDDperiod=is_MACDDperiod;
   macd.s_MACDDfastEMA=is_MACDDfastEMA;
   macd.s_MACDDslowEMA=is_MACDDslowEMA;
   macd.s_MACDDsignalPeriod=is_MACDDsignalPeriod;
   macd.m_MACDDperiod=im_MACDDperiod;
   macd.m_MACDDfastEMA=im_MACDDfastEMA;
   macd.m_MACDDslowEMA=im_MACDDslowEMA;
   macd.m_MACDDsignalPeriod=im_MACDDsignalPeriod;
   macd.l_MACDDperiod=il_MACDDperiod;
   macd.l_MACDDfastEMA=il_MACDDfastEMA;
   macd.l_MACDDslowEMA=il_MACDDslowEMA;
   macd.l_MACDDsignalPeriod=il_MACDDsignalPeriod;

   macdbull.useMACDBULL=iuseMACDBULL;
   macdbull.s_MACDBULLperiod=is_MACDBULLperiod;
   macdbull.s_MACDBULLfastEMA=is_MACDBULLfastEMA;
   macdbull.s_MACDBULLslowEMA=is_MACDBULLslowEMA;
   macdbull.s_MACDBULLsignalPeriod=is_MACDBULLsignalPeriod;
   macdbull.m_MACDBULLperiod=im_MACDBULLperiod;
   macdbull.m_MACDBULLfastEMA=im_MACDBULLfastEMA;
   macdbull.m_MACDBULLslowEMA=im_MACDBULLslowEMA;
   macdbull.m_MACDBULLsignalPeriod=im_MACDBULLsignalPeriod;
   macdbull.l_MACDBULLperiod=il_MACDBULLperiod;
   macdbull.l_MACDBULLfastEMA=il_MACDBULLfastEMA;
   macdbull.l_MACDBULLslowEMA=il_MACDBULLslowEMA;
   macdbull.l_MACDBULLsignalPeriod=il_MACDBULLsignalPeriod;

   macdbear.useMACDBEAR=iuseMACDBEAR;
   macdbear.s_MACDBEARperiod=is_MACDBEARperiod;
   macdbear.s_MACDBEARfastEMA=is_MACDBEARfastEMA;
   macdbear.s_MACDBEARslowEMA=is_MACDBEARslowEMA;
   macdbear.s_MACDBEARsignalPeriod=is_MACDBEARsignalPeriod;
   macdbear.m_MACDBEARperiod=im_MACDBEARperiod;
   macdbear.m_MACDBEARfastEMA=im_MACDBEARfastEMA;
   macdbear.m_MACDBEARslowEMA=im_MACDBEARslowEMA;
   macdbear.m_MACDBEARsignalPeriod=im_MACDBEARsignalPeriod;
   macdbear.l_MACDBEARperiod=il_MACDBEARperiod;
   macdbear.l_MACDBEARfastEMA=il_MACDBEARfastEMA;
   macdbear.l_MACDBEARslowEMA=il_MACDBEARslowEMA;
   macdbear.l_MACDBEARsignalPeriod=il_MACDBEARsignalPeriod;

   t.useZZ=iuseZZ;
   t.s_ZZperiod=is_ZZperiod;
   t.m_ZZperiod=im_ZZperiod;
   t.l_ZZperiod=il_ZZperiod;

   #ifdef _WRITELOG
      ss=StringFormat(" -> copyValuesFromInputs ->\n Short ZZ Period:%s\n Medium ZZ Period:%s\n Long ZZ Period:%s\n",
         EnumToString(t.s_ZZperiod),EnumToString(t.m_ZZperiod),EnumToString(t.l_ZZperiod));
      writeLog;
      printf(ss);
   #endif

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATechnicalParameters::copyValuesToDatabase(string tableName) {

   string sql;
   int cnt, request;

   sql=StringFormat("SELECT COUNT() FROM %s WHERE strategyNumber=% AND typeReference=%d",tableName,usp.strategyNumber,_baseStrategyReference);
   request=DatabasePrepare(_mainDBHandle1,sql); 
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> copyValuesToDatabase copyValuesFromDatabase DB request failed %s %d %d with code:",tableName,usp.strategyNumber,_baseStrategyReference, GetLastError()); 
      printf(ss);
      ExpertRemove();
   }

   if (!DatabaseRead(request)) {
      ss=StringFormat(" -> copyValuesToDatabase copyValuesFromDatabase DB request failed %s %d %d with code:",tableName,usp.strategyNumber,_baseStrategyReference, GetLastError()); 
      printf(ss);
      ExpertRemove();
   } else {
      DatabaseColumnInteger,0,cnt);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesToDatabase() {

   string sql="UPDATE ADX SET useADX=%d,"
      "s_ADXperiod=%d,s_ADXma=%d,"
      "m_ADXperiod=%d,m_ADXma=%d,"
      "l_ADXperiod=%d,l_ADXma=%d" 
      "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE RSI SET useRSI=%d,"
      "s_RSIperiod=%d,s_RSIma=%d,s_RSIap=%d,"
      "m_RSIperiod=%d,m_RSIma=%d,m_RSIap=%d,"
      "l_RSIperiod=%d,l_RSIma=%d,l_RSIap=%d"
      "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE MFI SET useMFI=%d,"
   "s_MFIperiod=%d,s_MFIma=%d,"
   "m_MFIperiod=%d,m_MFIma=%d,"
   "l_MFIperiod=%d,l_MFIma=%d" 
   "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE SAR SET useSAR=%d,"
   "s_SARperiod=%d,s_SARstep=%0.2f,s_SARmax=%2.2f,"
   "m_SARperiod=%d,m_SARstep=%0.2f,m_SARmax=%2.2f,"
   "l_SARperiod=%d,l_SARstep=%0.2f,l_SARmax=%2.2f" 
   "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE ICH SET useICH=%d,"
   "s_ICHperiod=%d,s_tenkan_sen=%d,s_kijun_sen=%d,s_senkou_span_b=%d,"
   "m_ICHperiod=%d,m_tenkan_sen=%d,m_kijun_sen=%d,m_senkou_span_b=%d,"
   "l_ICHperiod=%d,l_tenkan_sen=%d,l_kijun_sen=%d,l_senkou_span_b=%d"
   "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE RVI SET useRVI=%d,"
   "s_RVIperiod,s_RVIma,"
   "m_RVIperiod,m_RVIma,"
   "_RVIperiod,l_RVIma "
   "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE STOC SET useSTOC=%d,"
   "s_STOCperiod=%d,s_kPeriod=%d,s_dPeriod=%d,s_slowing=%d,s_STOCmamethod=%d,s_STOCpa=%d,"
   "m_STOCperiod=%d,m_kPeriod=%d,m_dPeriod=%d,m_slowing=%d,m_STOCmamethod=%d,m_STOCpa=%d,"
   "l_STOCperiod=%d,l_kPeriod=%d,l_dPeriod=%d,l_slowing=%d,l_STOCmamethod=%d,l_STOCpa=%d"
   "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE OSMA SET useOSMA=%d,"
   "s_OSMAperiod=%d,s_OSMAfastEMA=%d,s_OSMAslowEMA=%d,s_OSMAsignalPeriod=%d,s_OSMApa=%d," 
   "m_OSMAperiod=%d,m_OSMAfastEMA=%d,m_OSMAslowEMA=%d,m_OSMAsignalPeriod=%d,m_OSMApa=%d,"
   "l_OSMAperiod=%d,l_OSMAfastEMA=%d,l_OSMAslowEMA=%d,l_OSMAsignalPeriod=%d,l_OSMApa=%d"
   "WHERE strategyNumber=%d AND typeReference=%d",


   string sql="UPDATE MACD SET useMACD=%d,"
   "s_MACDDperiod=%d,s_MACDDfastEMA=%d,s_MACDDslowEMA=%d,s_MACDDsignalPeriod=%d,"
   "m_MACDDperiod=%d,m_MACDDfastEMA=%d,m_MACDDslowEMA=%d,m_MACDDsignalPeriod=%d,"
   "l_MACDDperiod=%d,l_MACDDfastEMA=%d,l_MACDDslowEMA=%d,l_MACDDsignalPeriod=%d"
   "WHERE strategyNumber=%d AND typeReference=%d",

   string sql="UPDATE MACDBULL SET useMACDBULL=%d"
   "s_MACDBULLperiod=%d,s_MACDBULLfastEMA=%d,s_MACDBULLslowEMA=%d,s_MACDBULLsignalPeriod=%d,"
   "m_MACDBULLperiod=%d,m_MACDBULLfastEMA=%d,m_MACDBULLslowEMA=%d,m_MACDBULLsignalPeriod=%d,"
   "l_MACDBULLperiod=%d,l_MACDBULLfastEMA=%d,l_MACDBULLslowEMA=%d,l_MACDBULLsignalPeriod=%d"
   "WHERE strategyNumber=%d AND typeReference=%d",


   string sql="UPDATE MACDBEAR SET useMACDBEAR=%d,"
   "s_MACDBEARperiod=%d,s_MACDBEARfastEMA=%d,s_MACDBEARslowEMA=%d,s_MACDBEARsignalPeriod=%d,"
   "m_MACDBEARperiod=%d,m_MACDBEARfastEMA=%d,m_MACDBEARslowEMA=%d,m_MACDBEARsignalPeriod=%d,"
   "l_MACDBEARperiod=%d,l_MACDBEARfastEMA=%d,l_MACDBEARslowEMA=%d,l_MACDBEARsignalPeriod=%d"
   "WHERE strategyNumber=%d AND typeReference=%d",


string request1a="INSERT INTO ADX ("
         "strategyNumber,typeReference, useADX,"
         "s_ADXperiod,s_ADXma,m_ADXperiod,m_ADXma,l_ADXperiod,l_ADXma"
         ") VALUES (";

         string request1a="INSERT INTO RSI ("
         "strategyNumber,typeReference, useRSI,"
         "s_RSIma,s_RSIap,m_RSIperiod,m_RSIma,m_RSIap,l_RSIperiod,l_RSIma,l_RSIap"
         ") VALUES (";

         string request1a="INSERT INTO MFI ("
         "strategyNumber,typeReference, useMFI,"
         "s_MFIperiod,s_MFIma,m_MFIperiod,m_MFIma,l_MFIperiod,l_MFIma"
         ") VALUES (";

         string request1a="INSERT INTO SAR ("
         "strategyNumber,typeReference, useSAR,"
         "s_SARperiod,s_SARstep,s_SARmax,m_SARperiod,m_SARstep,m_SARmax,l_SARperiod,l_SARstep,l_SARmax"
         ") VALUES (";

         string request1a="INSERT INTO RVI ("
         "strategyNumber,typeReference, useRVI,"
         "s_RVIperiod,s_RVIma,m_RVIperiod,m_RVIma,l_RVIperiod,l_RVIma"
         ") VALUES (";

         string request1a="INSERT INTO STOC ("
         "strategyNumber,typeReference, useSTOC,"
         "s_STOCperiod,s_kPeriod,s_dPeriod,s_slowing,s_STOCmamethod,s_STOCpa,"
         "m_STOCperiod,m_kPeriod,m_dPeriod,m_slowing,m_STOCmamethod,m_STOCpa,"
         "l_STOCperiod,l_kPeriod,l_dPeriod,l_slowing,l_STOCmamethod,l_STOCpa"
         ") VALUES (";

         string request1a="INSERT INTO OSMA ("
         "strategyNumber,typeReference, useOSMA,"
         "s_OSMAperiod,s_OSMAfastEMA,s_OSMAslowEMA,s_OSMAsignalPeriod,s_OSMApa,"
         "m_OSMAperiod,m_OSMAfastEMA,m_OSMAslowEMA,m_OSMAsignalPeriod,m_OSMApa,"
         "l_OSMAperiod,l_OSMAfastEMA,l_OSMAslowEMA,l_OSMAsignalPeriod,l_OSMApa"
         ") VALUES (";

         string request1a="INSERT INTO MACD ("
         "strategyNumber,typeReference, useMACD,"
         "s_MACDDperiod,s_MACDDfastEMA,s_MACDDslowEMA,s_MACDDsignalPeriod,"
         "m_MACDDperiod,m_MACDDfastEMA,m_MACDDslowEMA,m_MACDDsignalPeriod,"
         "l_MACDDperiod,l_MACDDfastEMA,l_MACDDslowEMA,l_MACDDsignalPeriod"
         ") VALUES (";

         string request1a="INSERT INTO MACDBULL ("
         "s_MACDBULLperiod,s_MACDBULLfastEMA,s_MACDBULLslowEMA,s_MACDBULLsignalPeriod,"
         "m_MACDBULLperiod,m_MACDBULLfastEMA,m_MACDBULLslowEMA,m_MACDBULLsignalPeriod,"
         "l_MACDBULLperiod,l_MACDBULLfastEMA,l_MACDBULLslowEMA,l_MACDBULLsignalPeriod"
         ") VALUES (";

         string request1a="INSERT INTO MACDBEAR ("
         "strategyNumber,typeReference, useMACDBEAR,"
         "s_MACDBEARperiod,s_MACDBEARfastEMA,s_MACDBEARslowEMA,s_MACDBEARsignalPeriod,"
         "m_MACDBEARperiod,m_MACDBEARfastEMA,m_MACDBEARslowEMA,m_MACDBEARsignalPeriod,"
         "l_MACDBEARperiod,l_MACDBEARfastEMA,l_MACDBEARslowEMA,l_MACDBEARsignalPeriod"
         ") VALUES (";



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::insertUpdateTable(string tableName, double &values[]) {

   switch (tableName) {
      case ADX: insertUpdateTable
   }

}

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesToDatabase() {


string request1a="INSERT INTO TECHPASSES ("
         "strategyNumber,"
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

      
      if (!DatabaseExecute(_optimizeDBHandle, request1)) {
         printf(" -> Failed to insert PASSES %d with code %d", t.iterationNumber, GetLastError());
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            printf(" -> Insert into PASSES succcess:%d",t.iterationNumber);
         #endif
      }

}
