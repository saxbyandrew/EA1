
//#define _USE_ADX                  //i1a
//#define _DEBUG_ADX_MODULE 

//#define _USE_RSI                  //i2a
//#define _DEBUG_RSI_MODULE

//#define _USE_MFI                  //i4a               
//#define _DEBUG_MFI_MODULE

//#define _USE_SAR                  //i4a               
//#define _DEBUG_SAR_MODULE

//#define _USE_ICH                  //i5a
//#define _DEBUG_ICH_MODULE

//#define _USE_RVI                  //i6a
//#define _DEBUG_RVI_MODULE

//#define _USE_STOC                 //i7a
//#define _DEBUG_STOC_MODULE

//#define _USE_OSMA                   //i8a
//#define _DEBUG_OSMA_MODULE

//#define _USE_MACD                 //i9a
//#define _DEBUG_MACD_MODULE

#define _USE_MACDJB                 //i10a
#define _DEBUG_MACDJB_MODULE        //i10b


//#define _DEBUG_MACD_DIVERGENCE
//#define _DEBUG_MACDPLAT_BULLISH
//#define _DEBUG_MACDPLAT_BEARISH


//#define _DEBUG_QMP_BULLISH
//#define _DEBUG_QMP_BEARISH
//#define _DEBUG_QQE
//#define _DEBUG_ZIGZAG


//#define _USE_MACDBULL
//#define _USE_MACDBEAR
#define _USE_ZIGZAG

// INPUTS++++++++++++++++++++++++++++++++++++++
input group "Strategy"
sinput double istrategyGrossProfit=100;
input double ilsize=0.1; 
input double ifpt=20;     
input double iflt=-20;        
input int imaxPositions=2;
input int imaxdaily;
input int imaxdailyhold;
input int imaxmg=4;          
input int imgmulti=3; 
input double ihedgeLossAmount=-500;
input int ilookBackBars=1;

input group "NETWORK"
input int inetworkType=3;
input int   idataFrameSize=1000;
input double itriggerThreshold=0.5;  
input int itrainWeightsThreshold=500;
input int innLayer1=5;
input int innLayer2=5;
input int irestarts=2;
input double idecay=0.001;
input double iwStep=0.01;
input int imaxITS=0;
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
input ENUM_TIMEFRAMES i1a_period=PERIOD_CURRENT;    
input int i1a_movingAverage=14;                     

input ENUM_TIMEFRAMES i1b_period=PERIOD_CURRENT;    
input int i1b_movingAverage=14;                     
#endif


#ifdef _USE_RSI
input group "RSI"
input ENUM_TIMEFRAMES i2a_period=PERIOD_CURRENT;    
input int i2a_movingAverage=14;                     
input ENUM_APPLIED_PRICE i2a_appliedPrice=PRICE_CLOSE;   

input ENUM_TIMEFRAMES i2b_period=PERIOD_CURRENT;    
input int i2b_movingAverage=14;                     
input ENUM_APPLIED_PRICE i2b_appliedPrice=PRICE_CLOSE;    
#endif


#ifdef _USE_MFI
input group "MFI"
input ENUM_TIMEFRAMES i3a_period=PERIOD_CURRENT;    
input int i3a_movingAverage=14;                     
input int i3a_appliedVolume=1;

input ENUM_TIMEFRAMES i3b_period=PERIOD_CURRENT;    
input int i3b_movingAverage=14;                     
input int i3b_appliedVolume=1;
#endif
// ----------------------------------------------------------------

#ifdef _USE_SAR
input group "SAR"
input ENUM_TIMEFRAMES i4a_period=PERIOD_CURRENT;    
input double i4a_stepValue=0.02;                   
input double i4a_maxValue=0.2;                     

input ENUM_TIMEFRAMES i4b_period=PERIOD_CURRENT;   
input double i4b_stepValue=0.02;                   
input double i4b_maxValue=0.2;                     
#endif
// ----------------------------------------------------------------

#ifdef _USE_ICH
input group "ICH"
input ENUM_TIMEFRAMES i5a_period=PERIOD_CURRENT;   
input int i5a_tenkanSen=9;                                                
input int i5a_kijunSen=26;                          
input int i5a_spanB=52;                             

input ENUM_TIMEFRAMES i5b_period=PERIOD_CURRENT;   
input int i5b_tenkanSen=9;                         
input int i5b_kijunSen=26;                          
input int i5b_spanB=52;                             
#endif

// ----------------------------------------------------------------
#ifdef _USE_RVI
input group "RVI"
input ENUM_TIMEFRAMES i6a_period=PERIOD_CURRENT;   
input int i6a_movingAverage=14;                    

input ENUM_TIMEFRAMES i6b_period=PERIOD_CURRENT;   
input int i6b_movingAverage=14;                    
#endif
// ----------------------------------------------------------------

#ifdef _USE_STOC
input group "STOC"
input ENUM_TIMEFRAMES i7a_period=PERIOD_CURRENT;   
input int i7a_kPeriod=5;                           
input int i7a_dPeriod=3;                           
input int i7a_slowing=3;                           
input ENUM_MA_METHOD i7a_maMethod=1;               
input ENUM_STO_PRICE i7a_stocPrice=1;              

input ENUM_TIMEFRAMES i7b_period=PERIOD_CURRENT;   
input int i7b_kPeriod=5;                           
input int i7b_dPeriod=3;                           
input int i7b_slowing=3;                           
input ENUM_MA_METHOD i7b_maMethod=1;               
input ENUM_STO_PRICE i7b_stocPrice=1;              
#endif
// ----------------------------------------------------------------

#ifdef _USE_OSMA
input group "OSMA"
input ENUM_TIMEFRAMES i8a_period=PERIOD_CURRENT;   
input int i8a_fastMovingAverage=12;                 
input int i8a_slowMovingAverage=26;                 
input int i8a_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i8a_appliedPrice=PRICE_CLOSE;   

input ENUM_TIMEFRAMES i8b_period=PERIOD_CURRENT;   
input int i8b_fastMovingAverage=12;                 
input int i8b_slowMovingAverage=26;                 
input int i8b_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i8b_appliedPrice=PRICE_CLOSE; 
#endif
// ----------------------------------------------------------------

#ifdef _USE_MACD
input group "MACD"
input ENUM_TIMEFRAMES i9a_period=PERIOD_CURRENT;   
input int i9a_fastMovingAverage=12;                
input int i9a_slowMovingAverage=26;                
input int i9a_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i9a_appliedPrice=PRICE_CLOSE;   

input ENUM_TIMEFRAMES i9b_period=PERIOD_CURRENT;   
input int i9b_fastMovingAverage=12;                
input int i9b_slowMovingAverage=26;                
input int i9b_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i9b_appliedPrice=PRICE_CLOSE; 
#endif
// ----------------------------------------------------------------

#ifdef _USE_MACDJB
input group "MACD JB"
input ENUM_TIMEFRAMES i10a_period=PERIOD_CURRENT;
input int i10a_slowMovingAverage=26;
input int i10a_fastMovingAverage=12;
input int i10a_signalPeriod=9;

input ENUM_TIMEFRAMES i10b_period=PERIOD_CURRENT;
input int i10b_slowMovingAverage=26;
input int i10b_fastMovingAverage=12;
input int i10b_signalPeriod=9;
#endif
// ----------------------------------------------------------------

#ifdef _USE_MACDBEAR
input group "MACD BEAR DIV"
input ENUM_TIMEFRAMES i11a_period=PERIOD_CURRENT;
input int i11a_slowMovingAverage=0;
input int i11a_fastMovingAverage=0;
input int i11a_signalPeriod=0;

input ENUM_TIMEFRAMES i11b_period=PERIOD_CURRENT;
input int i11b_slowMovingAverage=0;
input int i11b_fastMovingAverage=0;
input int i11b_signalPeriod=0;
#endif
// ----------------------------------------------------------------

#ifdef _USE_ZIGZAG
input group "ZIG ZAG"
input ENUM_TIMEFRAMES i100a_ZZperiod=PERIOD_CURRENT;
//input ENUM_TIMEFRAMES i100b_ZZperiod=PERIOD_H1;
//input ENUM_TIMEFRAMES i100c_ZZperiod=PERIOD_H4;
input int i100a_useBuffers=1;
#endif


