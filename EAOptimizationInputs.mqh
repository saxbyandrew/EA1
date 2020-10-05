
#define _USE_ADX
//#define _USE_RSI
//#define _USE_MFI
//#define _USE_RVI
//#define _USE_OSMA
//#define _USE_ICH
//#define _USE_SAR
//#define _USE_STOC
//#define _USE_MACD
//#define _USE_MACDBULL
//#define _USE_MACDBEAR

// INPUTS++++++++++++++++++++++++++++++++++++++
input group "Strategy"
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

sinput int numberOfInputs;
/*
// =========================================
// Duplicate this block for each input 
// comment out unused fields
// use i1a_ i2a_ i3a_ etc
input int i1a_indicatorNumber;
input ENUM_TIMEFRAMES i1a_period=PERIOD_CURRENT;
input int i1a_movingAverage=14;
input int i1a_slowMovingAverage=0;
input int i1a_fastMovingAverage=0;
input ENUM_MA_METHOD i1a_movingAverageMethod=0;
input ENUM_APPLIED_PRICE i1a_appliedPrice=PRICE_CLOSE;
input double i1a_stepValue=0;
input double i1a_maxValue=0;
input int i1a_signalPeriod=0;
input int i1a_tenkanSen=0;
input int i1a_kijunSem=0;
input int i1a_spanB=0;
input int i1a_kPeriod=0;
input int i1a_dPeriod=0;
input ENUM_STO_PRICE i1a_STOCpa;
// =========================================
*/ 

#ifdef _USE_ADX
input group "ADX"
sinput int i1a_indicatorNumber=1;                // ADX
input ENUM_TIMEFRAMES i1a_period=PERIOD_CURRENT;
input int i1a_movingAverage=14;

sinput int i1b_indicatorNumber=1;                // ADX
input ENUM_TIMEFRAMES i1b_period=PERIOD_CURRENT;
input int i1b_movingAverage=14;
#endif
// ----------------------------------------------------------------

#ifdef _USE_RSI
input group "RSI"
sinput int i2a_indicatorNumber=2;                // RSI
input ENUM_TIMEFRAMES i2a_period=PERIOD_CURRENT;
input int i2a_movingAverage=14;
input ENUM_APPLIED_PRICE i2a_appliedPrice=PRICE_CLOSE;

sinput int i2b_indicatorNumber=2;                // RSI
input ENUM_TIMEFRAMES i2b_period=PERIOD_CURRENT;
input int i2b_movingAverage=14;
input ENUM_APPLIED_PRICE i2b_appliedPrice=PRICE_CLOSE;
#endif
// ----------------------------------------------------------------

#ifdef _USE_MFI
input group "MFI"
sinput int i3a_indicatorNumber=3;                // MFI
input ENUM_TIMEFRAMES i3a_period=PERIOD_CURRENT;
input int i3a_movingAverage=14;

sinput int i3b_indicatorNumber=3;                // MFI
input ENUM_TIMEFRAMES i3b_period=PERIOD_CURRENT;
input int i3b_movingAverage=14;
#endif
// ----------------------------------------------------------------

#ifdef _USE_SAR
input group "SAR"
sinput int i4a_indicatorNumber=4;                // SAR
input ENUM_TIMEFRAMES i4a_period=PERIOD_CURRENT;
input double i4a_stepValue=0;
input double i4a_maxValue=0;

sinput int i4b_indicatorNumber=4;                // SAR
input ENUM_TIMEFRAMES i4b_period=PERIOD_CURRENT;
input double i4b_stepValue=0;
input double i4b_maxValue=0;
#endif
// ----------------------------------------------------------------

#ifdef _USE_ICH
input group "ICH"
sinput int i5a_indicatorNumber=5;                // ICH
input ENUM_TIMEFRAMES i5a_period=PERIOD_CURRENT;
input int i5a_tenkanSen=0;
input int i5a_kijunSen=0;
input int i5a_spanB=0;

sinput int i5b_indicatorNumber=5;                // ICH
input ENUM_TIMEFRAMES i5b_period=PERIOD_CURRENT;
input int i5b_tenkanSen=0;
input int i5b_kijunSen=0;
input int i5b_spanB=0;
#endif
// ----------------------------------------------------------------

#ifdef _USE_RVI
input group "RVI"
sinput int i6a_indicatorNumber=6;                // RVI
input ENUM_TIMEFRAMES i6a_period=PERIOD_CURRENT;
input int i6a_movingAverage=14;

sinput int i6b_indicatorNumber=6;                // RVI
input ENUM_TIMEFRAMES i6b_period=PERIOD_CURRENT;
input int i6b_movingAverage=14;
#endif
// ----------------------------------------------------------------

#ifdef _USE_STOC
input group "STOC"
sinput int i7a_indicatorNumber=7;                // STOC
input ENUM_TIMEFRAMES i7a_period=PERIOD_CURRENT;
input int i7a_kPeriod=0;
input int i7a_dPeriod=0;
input ENUM_MA_METHOD i7a_movingAverageMethod=0;
input ENUM_STO_PRICE i7a_STOCpa;

sinput int i7b_indicatorNumber=7;                // STOC
input ENUM_TIMEFRAMES i7b_period=PERIOD_CURRENT;
input int i7b_kPeriod=0;
input int i7b_dPeriod=0;
input ENUM_MA_METHOD i7b_movingAverageMethod=0;
input ENUM_STO_PRICE i7b_STOCpa;
#endif
// ----------------------------------------------------------------


#ifdef _USE_OSMA
input group "OSMA"
sinput int i8a_indicatorNumber=8;                // OSMA
input ENUM_TIMEFRAMES i8a_period=PERIOD_CURRENT;
input int i8a_slowMovingAverage=0;
input int i8a_fastMovingAverage=0;
input int i8a_signalPeriod=0;
input ENUM_APPLIED_PRICE i8a_appliedPrice=PRICE_CLOSE;

sinput int i8b_indicatorNumber=8;                // OSMA
input ENUM_TIMEFRAMES i8b_period=PERIOD_CURRENT;
input int i8b_slowMovingAverage=0;
input int i8b_fastMovingAverage=0;
input int i8b_signalPeriod=0;
input ENUM_APPLIED_PRICE i8b_appliedPrice=PRICE_CLOSE;
#endif
// ----------------------------------------------------------------


#ifdef _USE_MACD
input group "MACD"
sinput int i9a_indicatorNumber=9;                // MACD
input ENUM_TIMEFRAMES i9a_period=PERIOD_CURRENT;
input int i9a_slowMovingAverage=0;
input int i9a_fastMovingAverage=0;
input int i9a_signalPeriod=0;

sinput int i9b_indicatorNumber=9;                // MACD
input ENUM_TIMEFRAMES i9b_period=PERIOD_CURRENT;
input int i9b_slowMovingAverage=0;
input int i9b_fastMovingAverage=0;
input int i9b_signalPeriod=0;
#endif
// ----------------------------------------------------------------

#ifdef _USE_MACDBULL
input group "MACD BULL DIV"
sinput int i10a_indicatorNumber=10;                // MACD BULL DIV
input ENUM_TIMEFRAMES i10a_period=PERIOD_CURRENT;
input int i10a_slowMovingAverage=0;
input int i10a_fastMovingAverage=0;
input int i10a_signalPeriod=0;

sinput int i10b_indicatorNumber=10;                // MACD BULL DIV
input ENUM_TIMEFRAMES i10b_period=PERIOD_CURRENT;
input int i10b_slowMovingAverage=0;
input int i10b_fastMovingAverage=0;
input int i10b_signalPeriod=0;
#endif
// ----------------------------------------------------------------

#ifdef _USE_MACDBEAR
input group "MACD BEAR DIV"
sinput int i11a_indicatorNumber=11;                // MACD BEAR DIV
input ENUM_TIMEFRAMES i11a_period=PERIOD_CURRENT;
input int i11a_slowMovingAverage=0;
input int i11a_fastMovingAverage=0;
input int i11a_signalPeriod=0;

sinput int i11b_indicatorNumber=11;                // MACD BEAR DIV
input ENUM_TIMEFRAMES i11b_period=PERIOD_CURRENT;
input int i11b_slowMovingAverage=0;
input int i11b_fastMovingAverage=0;
input int i11b_signalPeriod=0;
#endif
// ----------------------------------------------------------------

















input int iuseZZ=1;
input ENUM_TIMEFRAMES i_1_ZZperiod=PERIOD_CURRENT;
input ENUM_TIMEFRAMES i_2_ZZperiod=PERIOD_H1;
input ENUM_TIMEFRAMES i_3_ZZperiod=PERIOD_H4;

