//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"



#include "EAEnum.mqh"
#include <Indicators\Oscilators.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Volumes.mqh>



//=========
class EAModuleTechnicals : public CIndicator {
//=========

//=========
private:
//=========
    int             lookBackBuffersSize;
    ENUM_TIMEFRAMES SARPeriod;

//=========
protected:
//=========

    CiADX               adx;  
    CiIchimoku          iIchimoku;
    CiBands             bb;
    CiMACD              macd; 
    CiRSI               rsi; 
    CiSAR               sar;
    CiMFI               mfi;
    CiOsMA              osma;
    CiRVI               rvi;
    CiStochastic        stoc;
    


//=========
public:
//=========
    EAModuleTechnicals();
    ~EAModuleTechnicals();

    bool              trendDirection(EAEnum trendType, int lookBack, int buffer);
    //EAEnum            adxCross(int lookBack);
    // ADX
    // ADX is plotted as a single line with values ranging from a low of zero to a high of 100.
    // ADX is non-directional it registers trend strength whether price is trending up or down
    // When the +DMI is above the -DMI, prices are moving up, and ADX measures the strength of the uptrend. 
    // When the -DMI is above the +DMI, prices are moving down, and ADX measures the strength of the downtrend. 
    //void                ADXtest(ENUM_TIMEFRAMES period );
    void                ADXSetParameters(ENUM_TIMEFRAMES period);
    void                ADXSetParameters(ENUM_TIMEFRAMES period, int maperiod);    
    double              ADXNormalizedValue(int lookBack, int buffer);      // start=starting point to calc from. count=number number idxes 
    double              ADXGetValue(int lookBack, int buffer);                              // lookBack=index value to look at

    void                IICHIMOKUSetParameters();
    void                IICHIMOKUSetParameters(ENUM_TIMEFRAMES period, int tenkan_sen, int kijun_sen, int senkou_span_b);
    double              IICHIMOKUGetValue(int lookBack, int buffer);
    void                IICHIMOKUCloudTouches(EAEnum &direction, double &val, ENUM_TIMEFRAMES period,int shift);
    void                IICHIMOKUTenkanKijunWidth(EAEnum &direction, double &val, int shift);
    double              IICHIMOKUNormalizedValue(ENUM_TIMEFRAMES period,int lookBack, int buffer);

    void                MACDSetParameters(ENUM_TIMEFRAMES period,int fastEMA, int slowEMA, int signalPeriod, int priceApplied);               
    double              MACDNormalizedValue(int start, int count, int buffer);             // start=starting point to calc from. count=number number idxes 
    double              MACDGetValue(int lookBack, int buffer);                            // lookBack=index value to look at
    void                MACDGetValueDifference(bool &aboveZero, double &val, int idx);

    void                RSISetParameters(ENUM_TIMEFRAMES period);
    void                RSISetParameters(ENUM_TIMEFRAMES period, int maperiod, int priceApplied);              
    double              RSINormalizedValue(int lookBack);             
    double              RSIGetValue(int lookBack);    

    void                BBSetParameters(ENUM_TIMEFRAMES period,int maperiod, int ma_shift, int deviation, int priceApplied);             
    double              BBNormalizedValue(int start, int count, int buffer);             
    double              BBGetValue(int lookBack,int buffer);  

    void                SARSetParameters(ENUM_TIMEFRAMES period);    
    void                SARSetParameters(ENUM_TIMEFRAMES period, double step, double max);
    double              SARNormalizedValue(int lookBack);
    EAEnum              SARValue(int lookBack);

    void                MFISetParameters();
    void                MFISetParameters(ENUM_TIMEFRAMES period, int maperiod);
    double              MFINormalizedValue(int lookBack);

    void                OSMASetParameters();
    void                OSMASetParameters(ENUM_TIMEFRAMES period,int fastEMA, int slowEMA, int signalPeriod, int priceApplied);               
    double              OSMANormalizedValue(int lookBack);             

    void                RVISetParameters();
    void                RVISetParameters(ENUM_TIMEFRAMES period,int maperiod);              
    double              RVINormalizedValue(int lookBack, int buffer);             

    void                STOCSetParameters();
    void                STOCSetParameters(ENUM_TIMEFRAMES period,int _kPeriod, int _dPeriod, int _slowing, ENUM_MA_METHOD _ma_method,ENUM_STO_PRICE _priceApplied);              
    double              STOCNormalizedValue(int lookBack, int buffer);  

    int                 MACDHandle;
    void                MACDSetupParametersDivergence();
    void                MACDSetupParametersDivergence(ENUM_TIMEFRAMES period,int fastEMA, int slowEMA, int signalPeriod); 
    double              MACDBullishDivergence(int ttl, double weightFactor);
    double              MACDBearishDivergence(int ttldouble, double weightFactor);

    int                 MACDPlatinumHandle;
    void                MACDPlatinumSetupParameters();
    void                MACDPlatinumSetupParameters(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod);
    double              MACDPlatinumBearish(int ttldouble,double weightFactor);
    double              MACDPlatinumBullish(int ttldouble,double weightFactor);

    int                 QQEHandle;
    void                QQEFilterSetupParameters();
    double              QQEFilterSlow(int ttldouble,double weightFactor);
    double              QQEFilterRSIMA(int ttldouble,double weightFactor);

    int                 ZIGZAGHandle;
    void                ZIGZAGSetupParameters(ENUM_TIMEFRAMES period);
    EAEnum              ZIGZAGValue(int lookBack);
    EAEnum              ZIGZAGValue(int ttl, double factor);

    
/* Does not work when using optimization
    int                 QMPHandle;
    void                QMPFilterSetupParameters();
    void                QMPFilterSetupParameters(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod);
    double              QMPFilterBearish(int ttldouble,double weightFactor);
    double              QMPFilterBullish(int ttldouble,double weightFactor);
*/


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAModuleTechnicals::EAModuleTechnicals() {

    lookBackBuffersSize=2000;


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAModuleTechnicals::~EAModuleTechnicals() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::ADXNormalizedValue(int lookBack, int buffer) {


    #ifdef _DEBUG_ADX_MODULE
        Print(__FUNCTION__);
    #endif  

    double min=0.1, max=99, result=0;

    if (lookBack>1) {
        if (adx.GetData(1,50)==EMPTY_VALUE) {
            printf("ADX --> getting a EMPTY VALUE 1");  
        }
    } else {
        adx.Refresh(-1);
    }

    // Sanity check 
    #ifdef _DEBUG_ADX_MODULE
        if (adx.Main(lookBack)==EMPTY_VALUE) {
            printf("BarsCalculated:%d",BarsCalculated());
            printf("ADX --> getting a EMPTY VALUE 2");
        }
    #endif
    if (adx.Main(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {
        case 0: result=(adx.Main(lookBack)-min)/(max-min); 
        break;
        case 1: result=(adx.Plus(lookBack)-min)/(max-min);   
        break;
        case 2: result=(adx.Minus(lookBack)-min)/(max-min);  
        break;
    }

    #ifdef _DEBUG_ADX_MODULE
        string s;
        switch (buffer) {
            case 0: s="Main";
            break;
            case 1: s="DI+";
            break;
            case 2: s="DI-";
            break;
        }
        printf("ADX %s Normalized Value:%1.2f",s,result);
    #endif 

    return result;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::ADXSetParameters(ENUM_TIMEFRAMES period){

    #ifdef _DEBUG_ADX_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!adx.Create(_Symbol,period,14)) {
        #ifdef _DEBUG_ADX_MODULE
            printf(" Failed to create Standard Library ADX with error code:%d", GetLastError());
        #endif 
    } 

} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::ADXSetParameters(ENUM_TIMEFRAMES period, int maperiod) {

    #ifdef _DEBUG_ADX_MODULE
        Print(__FUNCTION__);
        printf("Creating ADX with period:%s and maPeriod:%d",EnumToString(period),maperiod);
        printf("BarsCalculated:%d",adx.BarsCalculated());
    #endif  

    if (!adx.Create(_Symbol,period,maperiod)) {
        #ifdef _DEBUG_ADX_MODULE
            printf("ADXSetParameters -> ERROR");
            ExpertRemove();
        #endif
    } 

    adx.Refresh(OBJ_ALL_PERIODS);
    printf("ADXSetParameters BarsCalculated:%d",adx.BarsCalculated());
    printf("ADXSetParameters STATUS:%s",adx.Status());
    adx.BufferResize(2000);
} 



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::ADXGetValue(int lookBack, int buffer) {

    #ifdef _DEBUG_ADX_MODULE
        Print(__FUNCTION__);
    #endif  

    double val=0;
    
    adx.Refresh(-1);

    if (adx.Main(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {

        case 0:  val=adx.Main(lookBack);
        break;
        case 1:  val=adx.Plus(lookBack);
        break;
        case 2:  val=adx.Minus(lookBack);
        break;
    }

    #ifdef _DEBUG_ADX_MODULE
        printf("Main:%g Lookback:%d Buffer:%d",MathRound(val),lookBack,buffer);
    #endif 

    return val;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::IICHIMOKUTenkanKijunWidth(EAEnum &direction, double &val, int shift) {

    #ifdef _DEBUG_IICHIMOKU_MODULE
        Print(__FUNCTION__);
    #endif  

    double _tenkansen=iIchimoku.TenkanSen(shift);
    double _kijunsen=iIchimoku.KijunSen(shift);

    if (_tenkansen>_kijunsen) {
        direction=_BULLISH;
        val=_tenkansen-_kijunsen;
    } else {
        direction=_BEARISH;
        val=_kijunsen-_tenkansen;
    }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::IICHIMOKUCloudTouches(EAEnum &direction, double &val, ENUM_TIMEFRAMES period,int shift) {

    #ifdef _DEBUG_IICHIMOKU_MODULE
        Print(__FUNCTION__);
    #endif  

    iIchimoku.Refresh(-1);

    double _open=iOpen(_Symbol,period,shift);
    double _close=iClose(_Symbol,period,shift);
    double _high=iHigh(_Symbol,period,shift);
    double _low=iLow(_Symbol,period,shift);

    #ifdef _DEBUG_IICHIMOKU_MODULE
        printf(" ->  h:%g l:%g o:%g c:%g A:%g B:%g",_high,_low,_open,_close,iIchimoku.SenkouSpanA(shift),iIchimoku.SenkouSpanB(shift));
    #endif

    if (_high<iIchimoku.SenkouSpanA(shift)&&_low>iIchimoku.SenkouSpanB(shift)) {
        #ifdef _DEBUG_IICHIMOKU_MODULE
            printf(" -> Candle is inside the cloud");
        #endif
        direction=_NO_ACTION;
        val=0;
    }

    if (_high>iIchimoku.SenkouSpanA(shift)&&_low<iIchimoku.SenkouSpanA(shift)&&_low>iIchimoku.SenkouSpanB(shift)) {
        #ifdef _DEBUG_IICHIMOKU_MODULE
            printf(" -> Candle is across span A line");
        #endif
        direction=_NO_ACTION;
        val=0;
    }

    if (_low>iIchimoku.SenkouSpanA(shift)) {
        #ifdef _DEBUG_IICHIMOKU_MODULE
            printf(" -> Candle is above span A line ");
        #endif
        direction=_BULLISH;
        val=_close-iIchimoku.SenkouSpanA(shift);
    }

    if (_high<iIchimoku.SenkouSpanB(shift)) {
        #ifdef _DEBUG_IICHIMOKU_MODULE
            printf(" -> Candle is below span b line ");
        #endif
        direction=_BEARISH;
        val=_high-iIchimoku.SenkouSpanB(shift);
    }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::IICHIMOKUSetParameters() {

    #ifdef _DEBUG_IICHIMOKU_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!iIchimoku.Create(_Symbol,PERIOD_CURRENT,9,26,52)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::IICHIMOKUSetParameters(ENUM_TIMEFRAMES period,int tenkan_sen, int kijun_sen, int senkou_span_b ) {

    #ifdef _DEBUG_IICHIMOKU_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!iIchimoku.Create(_Symbol,period,tenkan_sen,kijun_sen,senkou_span_b )) {
        ExpertRemove();
    } 
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::IICHIMOKUGetValue(int lookBack, int buffer) {

    #ifdef _DEBUG_IICHIMOKU_MODULE
        Print(__FUNCTION__);
    #endif  

    double val=0;

    iIchimoku.Refresh(-1);
    if (iIchimoku.TenkanSen(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {

        case 0:  val=iIchimoku.TenkanSen(lookBack);
        break;
        case 1:  val=iIchimoku.KijunSen(lookBack);
        break;
        case 2:  val=iIchimoku.SenkouSpanA(lookBack);
        break;
        case 3:  val=iIchimoku.SenkouSpanB(lookBack);
        break;
        case 4:  val=iIchimoku.ChinkouSpan(lookBack);
        break;
    }

    #ifdef _DEBUG_IICHIMOKU_MODULE
        printf("Main:%g Lookback:%d Buffer:%d",MathRound(val),lookBack,buffer);
    #endif 

    return val;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::IICHIMOKUNormalizedValue(ENUM_TIMEFRAMES period,int lookBack, int buffer) {

    #ifdef _DEBUG_IICHIMOKU_MODULE
        Print(__FUNCTION__);
    #endif  

    //double _open=iOpen(_Symbol,period,1);
    double _close=iClose(_Symbol,period,1);
    double _high=iHigh(_Symbol,period,1);
    double _low=iLow(_Symbol,period,1);
    double min, max, result;

    iIchimoku.Refresh(-1);
    if (iIchimoku.TenkanSen(lookBack)==EMPTY_VALUE) return 0;
    if ((max-min)<=0) return 0;

    // Set Min and Max values used for teh normalization based on the buffer needed
    switch (buffer) {

        case 0: if (_close>iIchimoku.TenkanSen(lookBack)) {
                    min=iIchimoku.TenkanSen(lookBack);
                    max=_high;
                    result= (_close-min)/(max-min);
                } else {
                    max=iIchimoku.TenkanSen(lookBack);
                    min=_low;
                    //printf("_close:%2,2f min:%2.2f _low:%2.2f, ") divde by zer??? fix
                    result= -(_close-min)/(max-min);
                }
        break;
        case 1: if (_close>iIchimoku.KijunSen(lookBack)) {
                    min=iIchimoku.KijunSen(lookBack);
                    max=_high;
                    result= (_close-min)/(max-min);
                } else {
                    max=iIchimoku.KijunSen(lookBack);
                    min=_low;
                    result= -(_close-min)/(max-min);
                }

        break;
        case 2: if (_close>iIchimoku.SenkouSpanA(lookBack)) {
                    min=iIchimoku.SenkouSpanA(lookBack);
                    max=_high;
                    result= (_close-min)/(max-min);
                } else {
                    max=iIchimoku.SenkouSpanA(lookBack);
                    min=_low;
                    result= -(_close-min)/(max-min);
                }
        break;
        case 3: if (_close>iIchimoku.SenkouSpanB(lookBack)) {
                    min=iIchimoku.SenkouSpanB(lookBack);
                    max=_high;
                    result= (_close-min)/(max-min);
                } else {
                    max=iIchimoku.SenkouSpanB(lookBack);
                    min=_low;
                    result= -(_close-min)/(max-min);
                }
        break;
        case 4: if (_close>iIchimoku.ChinkouSpan(lookBack)) {
                    min=iIchimoku.ChinkouSpan(lookBack);
                    max=_high;
                    result= (_close-min)/(max-min);
                } else {
                    max=iIchimoku.ChinkouSpan(lookBack);
                    min=_low;
                    result= -(_close-min)/(max-min);
                }
        break;
    }

    #ifdef _DEBUG_IICHIMOKU_MODULE
        string s;
        switch (buffer) {
            case 0: s="TenkanSen";
            break;
            case 1: s="KijunSen";
            break;
            case 2: s="SenkouSpanA";
            break;
            case 3: s="SenkouSpanB";
            break;
            case 4: s="ChinkouSpan";
            break;
        }
        printf("IIchimoku %s val:%1.2f",s,result);
    #endif

    return result;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MACDSetParameters(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod, int _priceApplied) {

    #ifdef _DEBUG_MACD_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!macd.Create(_Symbol,period,_fastEMA,_slowEMA,_signalPeriod,_priceApplied)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MACDGetValueDifference(bool &aboveZero, double &val, int idx) {

    macd.Refresh(-1);
    double v1=macd.Main(idx);
    double v2=macd.Signal(idx);

    // Above Zero line
    if (v1>0) {
        aboveZero=true;
    } else {
        aboveZero=false;
    }
    val=v1-v2;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MACDNormalizedValue(int lookBack, int count, int buffer) {

    #ifdef _DEBUG_MACD_MODULE
        Print(__FUNCTION__);
        string ss;
    #endif  

    int idx0=0, idx1=0;
    double min=0, max=0, result=0;

    macd.Refresh(-1);
    if (macd.Main(lookBack)==EMPTY_VALUE) return 0;

    macd.MinValue(buffer,lookBack,count+lookBack,idx0);  // index value of min/max in buffer
    macd.MaxValue(buffer,lookBack,count+lookBack,idx1);

    switch (buffer) {
        case 0: min=macd.Main(idx0);               // Get actual min/max value from buffer
                max=macd.Main(idx1);
                if (max-min<=0) return 0;  // check for divide by Zero
                result=(macd.Main(lookBack)-min)/(max-min);
                #ifdef _DEBUG_MACD_MODULE
                    ss=StringFormat(" -> Min:%g Max:%g Nor:%g",min,max,result);
                    Print(ss);
                #endif
        break;
        case 1: min=macd.Signal(idx0);
                max=macd.Signal(idx1);
                if (max-min<=0) return 0;  // check for divide by Zero
                result=(macd.Signal(lookBack)-min)/(max-min); 
        break;
    }

    #ifdef _DEBUG_MACD_MODULE
        Print("macd Value:",result);
    #endif 

    return result;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MACDGetValue(int lookBack, int buffer) {

    #ifdef _DEBUG_MACD_MODULE
        Print(__FUNCTION__);
    #endif  

    double val=0;

    macd.Refresh(-1);
    if (macd.Main(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {

        case 0:  val=macd.Main(lookBack);
        break;
        case 1:  val=macd.Signal(lookBack);
        break;
    }

    #ifdef _DEBUG_MACD_MODULE
        string ss=StringFormat("Main:%g Lookback:%d Buffer:%d",MathRound(val),lookBack,buffer);
        Print(ss);
    #endif 
    return val;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::RSISetParameters(ENUM_TIMEFRAMES period) {

    #ifdef _DEBUG_RSI_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!rsi.Create(_Symbol,period,14,PRICE_CLOSE)) {
        ExpertRemove();
    } 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::RSISetParameters(ENUM_TIMEFRAMES period,int maperiod, int priceApplied) {

    #ifdef _DEBUG_RSI_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!rsi.Create(_Symbol,period,maperiod,priceApplied)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::RSIGetValue(int lookBack) {

    #ifdef _DEBUG_RSI_MODULE
        Print(__FUNCTION__);
    #endif  

    rsi.Refresh(-1);
    if (rsi.Main(lookBack)==EMPTY_VALUE) return 0;
    return (rsi.Main(lookBack));

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::RSINormalizedValue(int lookBack) {

    #ifdef _DEBUG_RSI_MODULE
        Print(__FUNCTION__);
    #endif  

    double result=0;
    double max=99.99;
    double min=0.01;

    rsi.Refresh(-1);
    if (rsi.Main(lookBack)==EMPTY_VALUE) return 0;

    result=(rsi.Main(lookBack)-min)/(max-min);

    #ifdef _DEBUG_RSI_MODULE
        printf("RSI Normalised value:%1.2f",result);
    #endif

    return result;

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::RVISetParameters() {

    #ifdef _DEBUG_RVI_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!rvi.Create(_Symbol,PERIOD_CURRENT,14)) {
        ExpertRemove();
    } 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::RVISetParameters(ENUM_TIMEFRAMES period,int maperiod) {

    #ifdef _DEBUG_RVI_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!rvi.Create(_Symbol,period,maperiod)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::RVINormalizedValue(int lookBack, int buffer) {

    #ifdef _DEBUG_RVI_MODULE
        Print(__FUNCTION__);
    #endif  

    double result;
    // RVI is allready in the range of -1 to 1 

    rvi.Refresh(-1);
    if (rvi.Main(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {
        case 0: result=rvi.Main(lookBack);
        break;
        case 1: result=rvi.Signal(lookBack);
        break;
    }

    #ifdef _DEBUG_RVI_MODULE
        string s;
        switch (buffer) {
            case 0: s="Main";
            break;
            case 1: s="Signal";
            break;
        }
        printf("RVI Normalised %s value:%1.2f",s,result);
    #endif

    return result;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::BBNormalizedValue(int start, int count, int buffer) {

    #ifdef _DEBUG_BB_MODULE
        Print(__FUNCTION__);
        string ss;
    #endif  

    int idx0=0, idx1=0;
    double min=0, max=0, result=0;

    bb.Refresh(-1);
    if (bb.Base(start)==EMPTY_VALUE) return 0;

    bb.MinValue(buffer,start,count+start,idx0);  // index value of min/max in buffer
    bb.MaxValue(buffer,start,count+start,idx1);

    switch (buffer) {
        case 0: min=bb.Upper(idx0);               // Get actual min/max value from buffer
                max=bb.Upper(idx1);
                if (max-min<=0) return 0;  // check for divide by Zero
                result=(bb.Upper(start)-min)/(max-min);
                #ifdef _DEBUG_BB_MODULE
                    ss=StringFormat(" -> Min:%g Max:%g Nor:%g",min,max,result);
                    Print(ss);
                #endif
        break;
        case 1: min=bb.Base(idx0);               // Get actual min/max value from buffer
                max=bb.Base(idx1);
                if (max-min<=0) return 0;  // check for divide by Zero
                result=(bb.Base(start)-min)/(max-min);
                #ifdef _DEBUG_BB_MODULE
                    ss=StringFormat(" -> Min:%g Max:%g Nor:%g",min,max,result);
                    Print(ss);
                #endif
        break;
        case 2: min=bb.Upper(idx0);               // Get actual min/max value from buffer
                max=bb.Upper(idx1);
                if (max-min<=0) return 0;  // check for divide by Zero
                result=(bb.Upper(start)-min)/(max-min);
                #ifdef _DEBUG_BB_MODULE
                    ss=StringFormat(" -> Min:%g Max:%g Nor:%g",min,max,result);
                    Print(ss);
                #endif
        break;
        
    }

    #ifdef _DEBUG_BB_MODULE
    Print("BB Value:",result);
    #endif 

    return result;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::BBSetParameters(ENUM_TIMEFRAMES period,int maperiod, int ma_shift, int deviation, int priceApplied) {

    #ifdef _DEBUG_MACD_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!bb.Create(_Symbol,period,maperiod,ma_shift,deviation,priceApplied)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::BBGetValue(int lookBack, int buffer) {

    #ifdef _DEBUG_BB_MODULE
        Print(__FUNCTION__);
    #endif  

    double val=0;

    bb.Refresh(-1);
    if (bb.Base(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {

        case 0:  val=bb.Base(lookBack);
        break;
        case 1:  val=bb.Upper(lookBack);
        break;
        case 2:  val=bb.Lower(lookBack);
        break;
    }

    #ifdef _DEBUG_BB_MODULE
        string ss=StringFormat("Main:%g Lookback:%d Buffer:%d",MathRound(val),lookBack,buffer);
        Print(ss);
    #endif 
    return val;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::SARSetParameters(ENUM_TIMEFRAMES period) {

    #ifdef _DEBUG_SAR_MODULE
        Print(__FUNCTION__);
    #endif  

    SARPeriod=period;

    if (!sar.Create(_Symbol,SARPeriod,0.02,0.2)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::SARSetParameters(ENUM_TIMEFRAMES period, double step, double max) {

    #ifdef _DEBUG_SAR_MODULE
        Print(__FUNCTION__);
    #endif  

    SARPeriod=period;

    if (!sar.Create(_Symbol,SARPeriod,step,max)) {
        ExpertRemove();
    } 
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// using the historic candle determine postion of price open/close and the 
// gap between that and SAR
double EAModuleTechnicals::SARNormalizedValue(int lookBack) {

    #ifdef _DEBUG_SAR_MODULE
        Print(__FUNCTION__);
    #endif 

    double _close=iClose(_Symbol,SARPeriod,lookBack);
    double SARNormalized, min, max;

    sar.Refresh(-1);
    if (sar.Main(lookBack)==EMPTY_VALUE) return 0;

    if (sar.Main(lookBack)>_close) {                   // SAR above current price BEARISH

        min=iLow(_Symbol,SARPeriod,lookBack);
        max=sar.Main(lookBack);

        #ifdef _DEBUG_SAR_MODULE
            s="Above";
        #endif 
        SARNormalized= -(_close-min)/(max-min);

    } else {                                    // SAR below current price BULLISH

        min=sar.Main(lookBack);
        max=iHigh(_Symbol,SARPeriod,lookBack);

        #ifdef _DEBUG_SAR_MODULE
            s="Below";
        #endif 
        SARNormalized= (_close-min)/(max-min);

    }

    #ifdef _DEBUG_SAR_MODULE
        printf(" -> SAR %s price min:%2.2f max:%2.2f norm:%2.2f",s,min,max,SARNormalized);
        
    #endif 

    // Normalised gap between candle and SAR
    return SARNormalized;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// using the historic candle determine postion of price open/close and the 
// gap between that and SAR
EAEnum EAModuleTechnicals::SARValue(int lookBack)  {

    #ifdef _DEBUG_SAR_MODULE
        Print(__FUNCTION__);
    #endif 

    double _close=iClose(_Symbol,SARPeriod,lookBack);

    sar.Refresh(-1);
    if (sar.Main(lookBack)==EMPTY_VALUE) return 0;

    if (sar.Main(1)>_close) {                   // SAR above current price BEARISH

        #ifdef _DEBUG_SAR_MODULE
            s="Above";
        #endif 
        return _DOWN;

    } else {                                    // SAR below current price BULLISH

        #ifdef _DEBUG_SAR_MODULE
            s="Below";
        #endif 
        return _UP;
    }

    return _NO_ACTION;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MFISetParameters() {

    #ifdef _DEBUG_MFI_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!mfi.Create(_Symbol,PERIOD_CURRENT,14,VOLUME_TICK)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MFISetParameters(ENUM_TIMEFRAMES period, int maperiod) {

    #ifdef _DEBUG_MFI_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!mfi.Create(_Symbol,period,maperiod,VOLUME_TICK)) {
        ExpertRemove();
    } 
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MFINormalizedValue(int lookBack) {

    #ifdef _DEBUG_MFI_MODULE
        Print(__FUNCTION__);
    #endif  

    double result=0;
    double max=99.99;
    double min=0.01;

    mfi.Refresh(-1);
    if (mfi.Main(lookBack)==EMPTY_VALUE) return 0;

    result=(mfi.Main(lookBack)-min)/(max-min);
    if (result<0) return 0;  // check for divide by Zero

    #ifdef _DEBUG_MFI_MODULE
        printf("MFI normalized:%2.2f",result);
    #endif  

    return result;
    

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::OSMASetParameters() {

    #ifdef _DEBUG_OSMA_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!osma.Create(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE)) {
        ExpertRemove();
    } 
}    
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::OSMASetParameters(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod, int _priceApplied) {

    #ifdef _DEBUG_OSMA_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!osma.Create(_Symbol,period,_fastEMA,_slowEMA,_signalPeriod,_priceApplied)) {
        ExpertRemove();
    } 
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::OSMANormalizedValue(int lookBack) {

    #ifdef _DEBUG_OSMA_MODULE
        Print(__FUNCTION__);
    #endif  

    double result=0;
    double max=99.99;
    double min=-99;

    osma.Refresh(-1);
    if (osma.Main(lookBack)==EMPTY_VALUE) return 0;

    result=(osma.Main(lookBack)-min)/(max-min);
    
    #ifdef _DEBUG_OSMA_MODULE
        printf("OSMA normalized:%2.2f",result);
    #endif  

    return result;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::STOCSetParameters() {

    #ifdef _DEBUG_STOC_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!stoc.Create(_Symbol,PERIOD_CURRENT,5,3,3,MODE_SMA,STO_LOWHIGH)) {
        ExpertRemove();
    } 
}    
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::STOCSetParameters(ENUM_TIMEFRAMES period,int _kPeriod, int _dPeriod, int _slowing, ENUM_MA_METHOD _ma_method,ENUM_STO_PRICE _priceApplied) {

    #ifdef _DEBUG_STOC_MODULE
        Print(__FUNCTION__);
    #endif  

    if (!stoc.Create(_Symbol,period,_kPeriod,_dPeriod,_slowing,_ma_method,_priceApplied)) {
        ExpertRemove();
    } 
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::STOCNormalizedValue(int lookBack, int buffer) {

    #ifdef _DEBUG_STOC_MODULE
        Print(__FUNCTION__);
        string s;
    #endif  

    double result=0;
    double max=99.99;
    double min=0.01;

    stoc.Refresh(-1);
    if (stoc.Main(lookBack)==EMPTY_VALUE) return 0;

    switch (buffer) {
        case 0: result=(stoc.Main(lookBack)-min)/(max-min);
        break;
        case 1: result=(stoc.Signal(lookBack)-min)/(max-min);
        break;
    }

    if (result<0) return 0;  // check for divide by Zero

    #ifdef _DEBUG_STOC_MODULE
        switch (buffer) {
            case 0: s="Main";
            break;
            case 1: s="Signal";
            break;
        }
        printf("STOCASTIC %s normalized:%2.2f",s,result);
    #endif 

    return result;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MACDSetupParametersDivergence() {

    if (MACDHandle==NULL) 
        MACDHandle=iCustom(_Symbol,PERIOD_CURRENT,"macd_divergence","-",12,26,9,"-",false,false,false);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MACDSetupParametersDivergence(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod) {

    if (MACDHandle==NULL) 
        MACDHandle=iCustom(_Symbol,period,"macd_divergence","-", _fastEMA, _slowEMA, _signalPeriod,"-",false,false,false);


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MACDBearishDivergence(int ttl, double factor) {

    #ifdef _DEBUG_MACD_DIVERGENCE
        Print(__FUNCTION__);
    #endif  

    static double MACDBuffer1[];
    static int ttlCnt=0;
    double weight=1;

    
    if (MACDHandle==NULL) MACDSetupParametersDivergence();
    ArraySetAsSeries(MACDBuffer1,true);
    CopyBuffer(MACDHandle,1,0,lookBackBuffersSize,MACDBuffer1);

        // Allow divergence time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_MACD_DIVERGENCE
            printf("_BEARISH_DIVERGENCE countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 

    if (MACDBuffer1[2]!=EMPTY_VALUE) {
        ttlCnt=ttl;
        return 1;
    }
    
    return 0;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MACDBullishDivergence(int ttl, double factor) {

    #ifdef _DEBUG_MACD_DIVERGENCE
        Print(__FUNCTION__);
    #endif  

    static double MACDBuffer0[]; 
    static int ttlCnt=0;
    double weight=1;

    if (MACDHandle==NULL) MACDSetupParametersDivergence();
    ArraySetAsSeries(MACDBuffer0,true);
    CopyBuffer(MACDHandle,0,0,lookBackBuffersSize,MACDBuffer0);

    // Allow divergence time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_MACD_DIVERGENCE
            printf("_BULLISH_DIVERGENCE countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 

    if (MACDBuffer0[2]!=EMPTY_VALUE) {
        ttlCnt=ttl;
        return 1;
    }
    
    return 0;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MACDPlatinumSetupParameters() {

    if (MACDPlatinumHandle==NULL) 
        MACDPlatinumHandle=iCustom(_Symbol,PERIOD_CURRENT,"MACD_Platinum",12,26,9,true,true,false,false);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::MACDPlatinumSetupParameters(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod) {

    if (MACDPlatinumHandle==NULL) 
        MACDPlatinumHandle=iCustom(_Symbol,period,"MACD_Platinum",_fastEMA,_slowEMA,_signalPeriod,true,true,false,false);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MACDPlatinumBullish(int ttl, double factor) {

    static double MACDBuffer[];
    static int ttlCnt=0;
    double weight=1;
    
    if (MACDPlatinumHandle==NULL) MACDPlatinumSetupParameters(); 

    ArraySetAsSeries(MACDBuffer,true);
    CopyBuffer(MACDPlatinumHandle,2,0,lookBackBuffersSize,MACDBuffer);

            // Allow  time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_MACDPLAT_BULLISH
            printf("_DEBUG_MACDPLAT_BULLISH countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 
    
    if (MACDBuffer[1]!=EMPTY_VALUE) {
        ttlCnt=ttl;
        return 1;
    }
    
    return 0;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::MACDPlatinumBearish(int ttl, double factor) {

    static double MACDBuffer[];
    static int ttlCnt=0;
    double weight=1;
    
    if (MACDPlatinumHandle==NULL) MACDPlatinumSetupParameters(); 

    ArraySetAsSeries(MACDBuffer,true);
    CopyBuffer(MACDPlatinumHandle,3,0,lookBackBuffersSize,MACDBuffer);

            // Allow  time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_MACDPLAT_BULLISH
            printf("_DEBUG_MACDPLAT_BEARISH countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 
    
    if (MACDBuffer[1]!=EMPTY_VALUE) {
        ttlCnt=ttl;
        return 2;
    }
    
    return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::QQEFilterSetupParameters() {
    if (QQEHandle==NULL)
        QQEHandle=iCustom(_Symbol,PERIOD_CURRENT,"QQE Adv",1,8,3);
        
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::QQEFilterSlow(int ttl, double factor) {

    #ifdef _DEBUG_MACD_DIVERGENCE
        Print(__FUNCTION__);
    #endif  

    static double QQEBuffer[];
    static int ttlCnt=0;
    double weight=1;

    
    if (QQEHandle==NULL) QQEFilterSetupParameters();
    ArraySetAsSeries(QQEBuffer,true);
    CopyBuffer(QQEHandle, 1, 0, lookBackBuffersSize, QQEBuffer);

        // Allow divergence time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_QQE
            printf("QQE slow countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 

    if (QQEBuffer[1]!=EMPTY_VALUE) {
        printf("QQE slow buffer:%2.2f",QQEBuffer[1]);
        ttlCnt=ttl;
        return 1;
    }
    
    return 0;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::QQEFilterRSIMA(int ttl, double factor) {

    #ifdef _DEBUG_MACD_DIVERGENCE
        Print(__FUNCTION__);
    #endif  

    static double QQEBuffer[];
    static int ttlCnt=0;
    double weight=1;

    
    if (QQEHandle==NULL) QQEFilterSetupParameters();
    ArraySetAsSeries(QQEBuffer,true);
    CopyBuffer(QQEHandle, 0, 0, lookBackBuffersSize, QQEBuffer);

        // Allow divergence time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_QQE
            printf("QQE RSIMA countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 

    if (QQEBuffer[1]!=EMPTY_VALUE) {
        printf("QQE RSIMA buffer:%2.2f",QQEBuffer[1]);
        ttlCnt=ttl;
        return 1;
    }
    
    return 0;

}

/* Does not work with optimization 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::QMPFilterSetupParameters(ENUM_TIMEFRAMES period,int _fastEMA, int _slowEMA, int _signalPeriod) {
    if (QMPHandle==NULL)
        QMPHandle=iCustom(_Symbol,period,"QMP Filter",0,_fastEMA,_slowEMA,_signalPeriod,true,1,8,3,false,false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::QMPFilterSetupParameters() {
    if (QMPHandle==NULL)
        QMPHandle=iCustom(_Symbol,PERIOD_CURRENT,"QMP Filter",0,12,26,9,true,1,8,3,false,false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::QMPFilterBullish(int ttl, double factor) {

    static double QMPBuffer[];
    static int ttlCnt=0;
    double weight=1;
    
    if (QMPHandle==NULL) QMPFilterSetupParameters();

    ArraySetAsSeries(QMPBuffer,true);
    CopyBuffer(QMPHandle, 0, 0, 5, QMPBuffer);   // Buffer 0
    // Allow  time to live
    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_QMP_BULLISH
            printf("QMPFilterBullish countdown:%d weight:%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 

    if (QMPBuffer[1]!=0) {
        ttlCnt=ttl;
        return 1;
    }

    return 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EAModuleTechnicals::QMPFilterBearish(int ttl, double factor) {

    static double QMPBuffer[];
    static int ttlCnt=0;
    double weight=1;
    
    if (QMPHandle==NULL) QMPFilterSetupParameters();

    ArraySetAsSeries(QMPBuffer,true);     
    CopyBuffer(QMPHandle, 1, 0, 5, QMPBuffer);   // Buffer 1

    if (ttlCnt>0) {
        weight=(ttlCnt-factor)/ttl;
        ttlCnt--;
        #ifdef _DEBUG_QMP_BEARISH
            printf("QMPFilterBearish countdown:%d weightL%1.2f",ttlCnt,weight);
        #endif
        return weight;
    } 

    if (QMPBuffer[1]!=0) {
        ttlCnt=ttl;  
        return 1;  
    } 
    
    return 0;
}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModuleTechnicals::ZIGZAGSetupParameters(ENUM_TIMEFRAMES period) {

    #ifdef _DEBUG_ZIGZAG
        Print(__FUNCTION__);
    #endif 

    if (ZIGZAGHandle==NULL) 
        ZIGZAGHandle=iCustom(_Symbol,period,"deltazigzag",0,0,500,0.5,1);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAModuleTechnicals::ZIGZAGValue(int ttl, double factor) {

    static EAEnum direction=_NO_ACTION;
    static int ttlCnt=0;

    static double ZIGZAGBuffer0[];
    static double ZIGZAGBuffer1[];

    ArraySetAsSeries(ZIGZAGBuffer0,true);
    ArraySetAsSeries(ZIGZAGBuffer1,true);

    CopyBuffer(ZIGZAGHandle,0,0,lookBackBuffersSize,ZIGZAGBuffer0);
    CopyBuffer(ZIGZAGHandle,1,0,lookBackBuffersSize,ZIGZAGBuffer1);

    // Allow indicator time to live
    if (ttlCnt>0) {
        ttlCnt--;
        #ifdef _DEBUG_ZIGZAG
            printf("ZIGZAG countdown:%d ",ttlCnt);
        #endif
        return direction;
    } 


    if (ZIGZAGBuffer0[0]>0) {
        ttlCnt=ttl;
        direction=_DOWN;
        #ifdef _DEBUG_ZIGZAG
            printf("------------------- > DOWN");
        #endif
    }

    if (ZIGZAGBuffer1[0]>0) {
        ttlCnt=ttl;
        direction=_UP;
        #ifdef _DEBUG_ZIGZAG
            
            printf("--------------------> UP");
        #endif
    }

    if (direction==_DOWN) {
        #ifdef _DEBUG_ZIGZAG

            printf("----------------> DOWN");
        #endif
    }

    if (direction==_UP) {
        #ifdef _DEBUG_ZIGZAG

            printf("----------------> UP");
        #endif
    }

    return direction;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAModuleTechnicals::ZIGZAGValue(int pos) {

    static int direction=_NO_ACTION;

    static double ZIGZAGBuffer0[];
    static double ZIGZAGBuffer1[];
    static double ZIGZAGBuffer2[];
    static double ZIGZAGBuffer3[];

    if (!ArraySetAsSeries(ZIGZAGBuffer0,true)) printf("Error1");
    if (!ArraySetAsSeries(ZIGZAGBuffer1,true)) printf("Error2");;
    if (!ArraySetAsSeries(ZIGZAGBuffer2,true)) printf("Error3");;
    if (!ArraySetAsSeries(ZIGZAGBuffer3,true)) printf("Error4");;

    if (CopyBuffer(ZIGZAGHandle,0,0,lookBackBuffersSize,ZIGZAGBuffer0)==-1) printf("Error5");
    if (CopyBuffer(ZIGZAGHandle,1,0,lookBackBuffersSize,ZIGZAGBuffer1)==-1) printf("Error6");
    if (CopyBuffer(ZIGZAGHandle,2,0,lookBackBuffersSize,ZIGZAGBuffer2)==-1) printf("Error7");
    if (CopyBuffer(ZIGZAGHandle,3,0,lookBackBuffersSize,ZIGZAGBuffer3)==-1) printf("Error8");

    printf("SIZE:%d",ArraySize(ZIGZAGBuffer2));
/*
    if (ZIGZAGBuffer0[pos]>0) {
        direction=_DOWN;
        #ifdef _DEBUG_ZIGZAG
            printf("------------------- > 11");
        #endif
    }

    if (ZIGZAGBuffer1[pos]>0) {
        direction=_UP;
        #ifdef _DEBUG_ZIGZAG
            printf("--------------------> 22");
        #endif
    }
*/
    if (ZIGZAGBuffer2[pos]>0) {
        direction=_UP;
        #ifdef _DEBUG_ZIGZAG
            printf("------------------- > CHANGE FOR DOWN --> UP");
        #endif
    }

    if (ZIGZAGBuffer3[pos]>0) {
        direction=_DOWN;
        #ifdef _DEBUG_ZIGZAG
            printf("--------------------> CHANGE FROM UP --> DOWN");
        #endif
    }

    return direction;
}