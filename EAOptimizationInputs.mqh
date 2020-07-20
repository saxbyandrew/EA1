
// INPUTS++++++++++++++++++++++++++++++++++++++
input double ilsize=0.1; 
input double ifptl=20;     
input double ifltl=-20;       
input double ifpts=20;   
input double iflts=-20;  
input int imaxlong=2;
input int imaxshort=2;
input int imaxdaily;
input int imaxdailyhold;
input int imaxmg=4;          
input int imgmulti=3; 
input double ilongHLossamt=-500;
input int idataFrameSize=500;
input int ilookBackBars=1;

input int iuseADX=1;
input ENUM_TIMEFRAMES is_ADXperiod=PERIOD_CURRENT;
input int is_ADXma=14;
input ENUM_TIMEFRAMES im_ADXperiod=PERIOD_H1;
input int im_ADXma=14;
input ENUM_TIMEFRAMES il_ADXperiod=PERIOD_H4;
input int il_ADXma=14;

input int iuseRSI=1;
input ENUM_TIMEFRAMES is_RSIperiod=PERIOD_CURRENT;
input int is_RSIma=14;
input ENUM_APPLIED_PRICE is_RSIap=PRICE_CLOSE;

input ENUM_TIMEFRAMES im_RSIperiod=PERIOD_H1;
input int im_RSIma=14;
input ENUM_APPLIED_PRICE im_RSIap=PRICE_CLOSE;

input ENUM_TIMEFRAMES il_RSIperiod=PERIOD_H4;
input int il_RSIma=14;
input ENUM_APPLIED_PRICE il_RSIap=PRICE_CLOSE;

input int iuseMFI;
input ENUM_TIMEFRAMES is_MFIperiod;
input int is_MFIma;
input ENUM_TIMEFRAMES im_MFIperiod;
input int im_MFIma;
input ENUM_TIMEFRAMES il_MFIperiod;
input int il_MFIma;

input int iuseSAR;
input ENUM_TIMEFRAMES is_SARperiod;
input double is_SARstep=0.02;
input double is_SARmax=0.2;
input ENUM_TIMEFRAMES im_SARperiod;
input double im_SARstep=0.02;
input double im_SARmax=0.2;
input ENUM_TIMEFRAMES il_SARperiod;
input double il_SARstep=0.02;
input double il_SARmax=0.2;

input int iuseICH;
input ENUM_TIMEFRAMES is_ICHperiod;
input int is_tenkan_sen;
input int is_kijun_sen;
input int is_senkou_span_b;
input ENUM_TIMEFRAMES im_ICHperiod;
input int im_tenkan_sen;
input int im_kijun_sen;
input int im_senkou_span_b;
input ENUM_TIMEFRAMES il_ICHperiod;
input int il_tenkan_sen;
input int il_kijun_sen;
input int il_senkou_span_b;

input int iuseRVI;
input ENUM_TIMEFRAMES is_RVIperiod;
input int is_RVIma;
input ENUM_TIMEFRAMES im_RVIperiod;
input int im_RVIma;
input ENUM_TIMEFRAMES il_RVIperiod;
input int il_RVIma;

input int iuseSTOC;
input ENUM_TIMEFRAMES is_STOCperiod;
input int is_kPeriod;
input int is_dPeriod;
input int is_slowing;
input ENUM_MA_METHOD is_STOCmamethod;
input ENUM_STO_PRICE is_STOCpa;

input ENUM_TIMEFRAMES im_STOCperiod;
input int im_kPeriod;
input int im_dPeriod;
input int im_slowing;
input ENUM_MA_METHOD im_STOCmamethod;
input ENUM_STO_PRICE im_STOCpa;

input ENUM_TIMEFRAMES il_STOCperiod;
input int il_kPeriod;
input int il_dPeriod;
input int il_slowing;
input ENUM_MA_METHOD il_STOCmamethod;
input ENUM_STO_PRICE il_STOCpa;

input int iuseOSMA;
input ENUM_TIMEFRAMES is_OSMAperiod;
input int is_OSMAfastEMA;
input int is_OSMAslowEMA;
input int is_OSMAsignalPeriod;
input int is_OSMApa;

input ENUM_TIMEFRAMES im_OSMAperiod;
input int im_OSMAfastEMA;
input int im_OSMAslowEMA;
input int im_OSMAsignalPeriod;
input int im_OSMApa;
input ENUM_TIMEFRAMES il_OSMAperiod;
input int il_OSMAfastEMA;
input int il_OSMAslowEMA;
input int il_OSMAsignalPeriod;
input int il_OSMApa;

input int iuseMACD;
input ENUM_TIMEFRAMES is_MACDDperiod;
input int is_MACDDfastEMA;
input int is_MACDDslowEMA;
input int is_MACDDsignalPeriod;
input ENUM_TIMEFRAMES im_MACDDperiod;
input int im_MACDDfastEMA;
input int im_MACDDslowEMA;
input int im_MACDDsignalPeriod;
input ENUM_TIMEFRAMES il_MACDDperiod;
input int il_MACDDfastEMA;
input int il_MACDDslowEMA;
input int il_MACDDsignalPeriod;

input int iuseMACDBULLDIV;
input ENUM_TIMEFRAMES is_MACDBULLperiod;
input int is_MACDBULLfastEMA;
input int is_MACDBULLslowEMA;
input int is_MACDBULLsignalPeriod;
input ENUM_TIMEFRAMES im_MACDBULLperiod;
input int im_MACDBULLfastEMA;
input int im_MACDBULLslowEMA;
input int im_MACDBULLsignalPeriod;
input ENUM_TIMEFRAMES il_MACDBULLperiod;
input int il_MACDBULLfastEMA;
input int il_MACDBULLslowEMA;
input int il_MACDBULLsignalPeriod;

input bool iuseMACDBEARDIV;
input ENUM_TIMEFRAMES is_MACDBEARperiod;
input int is_MACDBEARfastEMA;
input int is_MACDBEARslowEMA;
input int is_MACDBEARsignalPeriod;
input ENUM_TIMEFRAMES im_MACDBEARperiod;
input int im_MACDBEARfastEMA;
input int im_MACDBEARslowEMA;
input int im_MACDBEARsignalPeriod;
input ENUM_TIMEFRAMES il_MACDBEARperiod;
input int il_MACDBEARfastEMA;
input int il_MACDBEARslowEMA;
input int il_MACDBEARsignalPeriod;

input int iuseZZ=1;
input ENUM_TIMEFRAMES is_ZZperiod=PERIOD_CURRENT;
input ENUM_TIMEFRAMES im_ZZperiod=PERIOD_H1;
input ENUM_TIMEFRAMES il_ZZperiod=PERIOD_H4;

