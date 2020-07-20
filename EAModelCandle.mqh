//+------------------------------------------------------------------+
//|                                                EAModelCandle.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_CANDLE_MODEL


#include "EAModelBase.mqh"
#include "EAModuleCandle.mqh"


//=========
class EAModelCandle : public EAModelBase {
//=========

//=========
private:
//=========

//=========
protected:
//=========



//=========
public:
//=========
EAModelCandle();
~EAModelCandle();

   EAEnum            candleWeights(double &inputs[], ENUM_TIMEFRAMES period); // For DNN
   

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAModelCandle::EAModelCandle() {

   #ifdef _DEBUG_CANDLE_MODEL
      Print(__FUNCTION__);
   #endif  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAModelCandle::~EAModelCandle() {

   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAModelCandle::candleWeights(double &inputs[],ENUM_TIMEFRAMES period ) { 

   #ifdef _DEBUG_CANDLE_MODEL
      Print(__FUNCTION__);
   #endif   

   #ifdef _DEBUG_CANDLE_MODEL
   string ss;
   string values[5];
   values[0]="-";
   values[1]="-";
   values[2]="-";
   values[3]="-"; 
   #endif 

   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,PERIOD_CURRENT,1,5,rates);
   
   double high=rates[0].high;
   double low=rates[0].low;
   double open=rates[0].open;
   double close=rates[0].close;
   double uod=rates[0].close-rates[0].open;
   
   
   #ifdef _DEBUG_CANDLE_MODULE
      ArrayPrint(rates);
      values[4]=StringFormat("O:%g H:%g L:%g C:%g UOD:%g",NormalizeDouble(open,2),NormalizeDouble(high,2),NormalizeDouble(low,2),NormalizeDouble(close,2),NormalizeDouble(uod,2));
   #endif 

   double p100=high-low;
   double highPer=0;
   double lowPer=0;
   double bodyPer=0;
   double trend=-1;

   if(uod>0) {   
      highPer=high-close;
      lowPer=open-low;
      bodyPer=close-open;
      trend=1;             
   } else {    
      highPer=high-open;
      lowPer=close-low;
      bodyPer=open-close;
      trend=0;        
   } 

   if (p100==0||trend==-1) return _NOTSET;

   // Work out the % values
   inputs[0]=highPer/p100;
   inputs[1]=lowPer/p100;
   inputs[2]=bodyPer/p100;
   inputs[3]=trend;
   
   #ifdef _DEBUG_CANDLE_MODEL
      values[0]=StringFormat("%g",highPer);
      values[1]=StringFormat("%g",lowPer);
      values[2]=StringFormat("%g",bodyPer);
      if (inputs[3]==1) values[3]="Bullish";
      if (inputs[3]==0) values[3]="Bearish";     
      panel.setValues(values);
   #endif 
   
   return _SET;

}
