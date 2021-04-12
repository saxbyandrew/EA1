


input group "Strategy"

sinput int iisActive=1;
sinput int istrategyNumber=1;
sinput int imagicNumber=999;
sinput int ideviationInPoints=1;
sinput int imaxSpread=200;

input int  ientryBars=10;
input double ibrokerAdminPercent=0.012;
input double iinterBankPercentage=0.0056;
input int   iinProfitClosePosition=1;
input int   iinLossClosePosition=1;

input int   iinLossOpenMartingale=0;
input int   iinLossOpenLongHedge=0;
input int   icloseAtEOD=1;
input double ilsize=0.1; 
input double ifpt=20;   

input double iflt=-20;        
input int imaxPositions=2;
input int imaxdaily;
input int imaxdailyhold;
input int imaxmg=4; 

input int imgmulti=3; 
input double ihedgeLossAmount=-500;
sinput double iswapCosts=0;
//sinput int irunMode=2;
sinput int iversionNumber=0;

//input int ilookBackBars=1;
sinput double istrategyGrossProfit=100;

input group "NETWORK"
sinput int ifileNumber=1;
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



#ifdef _USE_ADX
input group "ADX"
sinput int iuseADX_A=1;
input ENUM_TIMEFRAMES i1a_period=PERIOD_CURRENT;    
input int i1a_movingAverage=14;   
input int i1a_crossLevel=25;  
input int i1a_barDelay=1;
sinput int i1a_useBuffers=15;
sinput int iuseADX_B=1;
input ENUM_TIMEFRAMES i1b_period=PERIOD_CURRENT;    
input int i1b_movingAverage=14; 
input int i1b_crossLevel=25;  
input int i1b_barDelay=1;
sinput int i1b_useBuffers=15;
#endif

#ifdef _USE_RSI
input group "RSI"
sinput int iuseRSI_A=1;
input ENUM_TIMEFRAMES i2a_period=PERIOD_CURRENT;    
input int i2a_movingAverage=14;                     
input ENUM_APPLIED_PRICE i2a_appliedPrice=PRICE_CLOSE;  
input int i2a_upperLevel=70;  
input int i2a_lowerLevel=30;   
input int i2a_barDelay=1;
sinput int i2a_useBuffers=3;
sinput int iuseRSI_B=1;
input ENUM_TIMEFRAMES i2b_period=PERIOD_CURRENT;    
input int i2b_movingAverage=14;                     
input ENUM_APPLIED_PRICE i2b_appliedPrice=PRICE_CLOSE;    
input int i2b_upperLevel=70;  
input int i2b_lowerLevel=30; 
input int i2b_barDelay=1;  
sinput int i2b_useBuffers=3;
#endif

#ifdef _USE_MFI
input group "MFI"
sinput int iuseMFI_A=1;
input ENUM_TIMEFRAMES i3a_period=PERIOD_CURRENT;    
input int i3a_movingAverage=14;                     
input ENUM_APPLIED_VOLUME i3a_appliedVolume=1;
input int i3a_barDelay=1; 
sinput int i3a_useBuffers=1;
sinput int iuseMFI_B=1;
input ENUM_TIMEFRAMES i3b_period=PERIOD_CURRENT;    
input int i3b_movingAverage=14;                     
input ENUM_APPLIED_VOLUME i3b_appliedVolume=1;
input int i3b_barDelay=1;
sinput int i3b_useBuffers=1; 
#endif

#ifdef _USE_SAR
input group "SAR"
sinput int iuseSAR_A=1;
input ENUM_TIMEFRAMES i4a_period=PERIOD_CURRENT;    
input double i4a_stepValue=0.02;                   
input double i4a_maxValue=0.2;  
input int i4a_barDelay=1;  
sinput int i4a_useBuffers=3;                   
sinput int iuseSAR_B=1;
input ENUM_TIMEFRAMES i4b_period=PERIOD_CURRENT;   
input double i4b_stepValue=0.02;                   
input double i4b_maxValue=0.2;  
input int i4b_barDelay=1;
sinput int i4b_useBuffers=3;                     
#endif

#ifdef _USE_ICH
input group "ICH"
sinput int iuseICH_A=1;
input ENUM_TIMEFRAMES i5a_period=PERIOD_CURRENT;   
input int i5a_tenkanSen=9;                                                
input int i5a_kijunSen=26;                          
input int i5a_spanB=52;    
input int i5a_barDelay=1;  
sinput int i5a_useBuffers=31;                         
sinput int iuseICH_B=1;
input ENUM_TIMEFRAMES i5b_period=PERIOD_CURRENT;   
input int i5b_tenkanSen=9;                         
input int i5b_kijunSen=26;                          
input int i5b_spanB=52; 
input int i5b_barDelay=1;   
sinput int i5b_useBuffers=31;                           
#endif

#ifdef _USE_RVI
input group "RVI"
sinput int iuseRVI_A=1;
input ENUM_TIMEFRAMES i6a_period=PERIOD_CURRENT;   
input int i6a_movingAverage=14;    
input int i6a_barDelay=1; 
sinput int i6a_useBuffers=3;                 
sinput int iuseRVI_B=1;
input ENUM_TIMEFRAMES i6b_period=PERIOD_CURRENT;   
input int i6b_movingAverage=14;  
input int i6b_barDelay=1; 
sinput int i6b_useBuffers=3;                   
#endif

#ifdef _USE_STOC
input group "STOC"
sinput int iuseSTOC_A=1;
input ENUM_TIMEFRAMES i7a_period=PERIOD_CURRENT;   
input int i7a_kPeriod=5;                           
input int i7a_dPeriod=3;                           
input int i7a_slowing=3;                           
input ENUM_MA_METHOD i7a_maMethod=1;               
input ENUM_STO_PRICE i7a_stocPrice=1;   
input int i7a_barDelay=1;   
sinput int i7a_useBuffers=3;          
sinput int iuseSTOC_B=1;
input ENUM_TIMEFRAMES i7b_period=PERIOD_CURRENT;   
input int i7b_kPeriod=5;                           
input int i7b_dPeriod=3;                           
input int i7b_slowing=3;                           
input ENUM_MA_METHOD i7b_maMethod=1;               
input ENUM_STO_PRICE i7b_stocPrice=1;   
input int i7b_barDelay=1;  
sinput int i7b_useBuffers=3;           
#endif

#ifdef _USE_OSMA
input group "OSMA"
sinput int iuseOSMA_A=1;
input ENUM_TIMEFRAMES i8a_period=PERIOD_CURRENT;   
input int i8a_fastMovingAverage=12;                 
input int i8a_slowMovingAverage=26;                 
input int i8a_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i8a_appliedPrice=PRICE_CLOSE;  
input int i8a_barDelay=1;  
sinput int i8a_useBuffers=1; 
sinput int iuseOSMA_=1;
input ENUM_TIMEFRAMES i8b_period=PERIOD_CURRENT;   
input int i8b_fastMovingAverage=12;                 
input int i8b_slowMovingAverage=26;                 
input int i8b_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i8b_appliedPrice=PRICE_CLOSE; 
input int i8b_barDelay=1;  
sinput int i8b_useBuffers=1;
#endif

#ifdef _USE_MACD
input group "MACD"
sinput int iuseMACD_A=1;
input ENUM_TIMEFRAMES i9a_period=PERIOD_CURRENT;   
input int i9a_fastMovingAverage=12;                
input int i9a_slowMovingAverage=26;                
input int i9a_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i9a_appliedPrice=PRICE_CLOSE;  
input int i9a_barDelay=1;  
sinput int i9a_useBuffers=3;
sinput int iuseMACD_B=1;
input ENUM_TIMEFRAMES i9b_period=PERIOD_CURRENT;   
input int i9b_fastMovingAverage=12;                
input int i9b_slowMovingAverage=26;                
input int i9b_signalPeriod=9;                      
input ENUM_APPLIED_PRICE i9b_appliedPrice=PRICE_CLOSE; 
input int i9b_barDelay=1; 
sinput int i9b_useBuffers=3;
#endif

#ifdef _USE_MACDJB
input group "MACD JB"
sinput int iuseMACDJB_A=1;
input ENUM_TIMEFRAMES i10a_period=PERIOD_CURRENT;
input int i10a_slowMovingAverage=26;
input int i10a_fastMovingAverage=12;
input int i10a_signalPeriod=9;
input int i10a_barDelay=1;
sinput int i10a_useBuffers=3;  
sinput int iuseMACDJB_B=1;
input ENUM_TIMEFRAMES i10b_period=PERIOD_CURRENT;
input int i10b_slowMovingAverage=26;
input int i10b_fastMovingAverage=12;
input int i10b_signalPeriod=9;
input int i10b_barDelay=1;  
sinput int i0b_useBuffers=3;
#endif

#ifdef _USE_MACDBEAR
input group "MACD BEAR DIV"
sinput int iuseMAC_A=1;
input ENUM_TIMEFRAMES i11a_period=PERIOD_CURRENT;
input int i11a_slowMovingAverage=0;
input int i11a_fastMovingAverage=0;
input int i11a_signalPeriod=0;
input int i11a_barDelay=1;  

input ENUM_TIMEFRAMES i11b_period=PERIOD_CURRENT;
input int i11b_slowMovingAverage=0;
input int i11b_fastMovingAverage=0;
input int i11b_signalPeriod=0;
input int i11b_barDelay=1;  
#endif

#ifdef _USE_ZIGZAG
input group "ZIG ZAG"
sinput int iuseZZ_A=1;
input ENUM_TIMEFRAMES i100a_ZZperiod=PERIOD_CURRENT;
input int i100a_useBuffers=1;
input int i100a_ZZttl;
input int i100a_ZZReversal;
input int i100a_ZZLevels;
#endif


