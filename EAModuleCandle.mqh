//+------------------------------------------------------------------+
//|                                                    MQCandles.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"
#include <Indicators\Trend.mqh>

//+==================================================================+
//+ START OF BASE CLASS                                              +
//+==================================================================+

//=========
class MQCandleBase   {
//=========

//=========
protected:
//=========

   MqlRates          rates[];       // Test DNN

   ENUM_TIMEFRAMES   _timeFrame;
 
   double            o,c,h,l;
   double            o1,c1,h1,l1;
   double            o2,c2,h2,l2;
   double            o3,c3,h3,l3;
   double            o4,c4,h4,l4;
                
   double            highestLowest(int period, EAEnum hhll, int daysAgo);

//=========   
private:
//=========

//=========
public:
//=========
                     MQCandleBase();
                    ~MQCandleBase();
   EACandle          name; 
   unsigned          mask;                
   virtual   bool    getValue(){return false;}; 
   void              setOHLC(int shift);
   void              setTimeFrame(ENUM_TIMEFRAMES t) {_timeFrame=t;};
    
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MQCandleBase::MQCandleBase() {

} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MQCandleBase::~MQCandleBase() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MQCandleBase::setOHLC(int shift) {

   if (shift==0) shift=1;                 // Error check can't ref current candle as Close High Low is undefined !
   
   o=iOpen(_Symbol,_timeFrame,shift);
   c=iClose(_Symbol,_timeFrame,shift);
   h=iHigh(_Symbol,_timeFrame,shift);
   l=iLow(_Symbol,_timeFrame,shift);
   
   o1=iOpen(_Symbol,_timeFrame,shift+1);
   c1=iClose(_Symbol,_timeFrame,shift+1);
   h1=iHigh(_Symbol,_timeFrame,shift+1);
   l1=iLow(_Symbol,_timeFrame,shift+1);
   
   o2=iOpen(_Symbol,_timeFrame,shift+2);
   c2=iClose(_Symbol,_timeFrame,shift+2);
   h2=iHigh(_Symbol,_timeFrame,shift+2);
   l2=iLow(_Symbol,_timeFrame,shift+2);
   
   o3=iOpen(_Symbol,_timeFrame,shift+3);
   c3=iClose(_Symbol,_timeFrame,shift+3);
   h3=iHigh(_Symbol,_timeFrame,shift+3);
   l3=iLow(_Symbol,_timeFrame,shift+3);
   
   o4=iOpen(_Symbol,_timeFrame,shift+4);
   c4=iClose(_Symbol,_timeFrame,shift+4);
   h4=iHigh(_Symbol,_timeFrame,shift+4);
   l4=iLow(_Symbol,_timeFrame,shift+4);

}

//+------------------------------------------------------------------+
double MQCandleBase::highestLowest(int period, EAEnum hhll, int shift) {

   switch (hhll) {
   
      case _LL: return (iLow(_Symbol,_timeFrame,iLowest(_Symbol,_timeFrame,MODE_LOW,period,shift)));
         break;
      case _HH: return (iHigh(_Symbol,_timeFrame,iHighest(_Symbol,_timeFrame,MODE_HIGH,period,shift)));
         break;
      case _LO: return (iLow(_Symbol,_timeFrame,iLowest(_Symbol,_timeFrame,MODE_OPEN,period,shift)));
         break;
   }

   return 0;

}

//+==================================================================+
//+ END OF BASE CLASS                                                +
//+==================================================================+



//+==================================================================+
//+                                                                  +
//+==================================================================+
//=========
class whiteCandle : public MQCandleBase  {
//=========

//=========
private:
//=========

//=========
public:
//=========
                     whiteCandle();
                    ~whiteCandle();

   bool              getValue();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
whiteCandle::whiteCandle() {

   _timeFrame=PERIOD_CURRENT;
   setOHLC(0);
   name=_WHITECANDLE;
   mask=_BULLISH;
} 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
whiteCandle::~whiteCandle() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool whiteCandle::getValue() {
   
   if (c>o) {
      //print("WC",true);
      
      return true;
   }
     
   return false;
}

//+==================================================================+
//+                                                                  +
//+==================================================================+

//=========
class blackCandle : public MQCandleBase {
//=========

//=========
private:
//=========

//=========
public:
//=========
                     blackCandle();
                    ~blackCandle();

   bool              getValue();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
blackCandle::blackCandle() {

   _timeFrame=PERIOD_CURRENT;
   setOHLC(0);
   name=_BLACKCANDLE;
   mask=_BEARISH;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
blackCandle::~blackCandle() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool blackCandle::getValue() {
   
   if (c<o) {
      //print("WC",true);
      
      return true;
   }
     
   return false;
}

//+==================================================================+
//+                                                                  +
//+==================================================================+
class bullishDragonflyDoji : public MQCandleBase {

//=========
private:
//=========

//=========
public:
//=========
                     bullishDragonflyDoji();
                    ~bullishDragonflyDoji();

   bool              getValue();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bullishDragonflyDoji::bullishDragonflyDoji() {

   _timeFrame=PERIOD_CURRENT;
   setOHLC(0);
   name=_BULLISHDRAGONFLYDOJI;
   mask=_BULLISH+_REVERSAL+_BOTTOM+_DOWNTREND;
}
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bullishDragonflyDoji::~bullishDragonflyDoji() {}

//+------------------------------------------------------------------+
bool bullishDragonflyDoji::getValue() {
   
   if (((h-l) > 3*MathAbs(o-c)) && ((c-l) > 0.8*(h-l)) && ((o-l)>0.8*(h-l))) {
      
      return true;
   }
   
   return false;
}

//+==================================================================+
//+                                                                  +
//+==================================================================+
class bearishDragonflyDoji : public MQCandleBase {

//=========
private:
//=========

//=========
public:
//=========
                     bearishDragonflyDoji();
                    ~bearishDragonflyDoji();
                    
   bool              getValue();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bearishDragonflyDoji::bearishDragonflyDoji() {

   _timeFrame=PERIOD_CURRENT;
   setOHLC(0);
   name=_BEARISHDRAGONFLYDOJI;
   mask=_BEARISH+_REVERSAL+_TOP+_UPTREND;
}
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bearishDragonflyDoji::~bearishDragonflyDoji() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearishDragonflyDoji::getValue() {

   if ((((c<=o)*o)+((c>o)*c))>(h*0.95)&&((((c<=o)*c)+((c>o)*o))-l)>(h-l)*0.75) {
      
      return true;
   
   }
    
   return false;
}

//+==================================================================+
//+                                                                  +
//+==================================================================+
class bullishGraveStoneDoji : public MQCandleBase {

//=========
private:
//=========

//=========
public:
//=========
                     bullishGraveStoneDoji();
                    ~bullishGraveStoneDoji();
                    
   bool              getValue();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bullishGraveStoneDoji::bullishGraveStoneDoji() {

   _timeFrame=PERIOD_CURRENT;
   setOHLC(0);
   name=_BULLISHGRAVESTONEDOJI;
   mask=_UNDEFINED;
}
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bullishGraveStoneDoji::~bullishGraveStoneDoji() {}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bullishGraveStoneDoji::getValue() {

   static CiMA  *ma1, *ma2;
   
   if (ma1==NULL||ma2==NULL) {
      ma1=new CiMA;
      ma2=new CiMA;
      ma1.Create(_Symbol,_timeFrame,10,1,MODE_EMA,PRICE_HIGH);
      ma2.Create(_Symbol,_timeFrame,10,1,MODE_EMA,PRICE_LOW);
      
   }
   
   ma1.Refresh(-1);
   ma2.Refresh(-1);

   // Bullish reversal in a downtrend
   //if (trend.currentTrend(0,candleTrendPeriod,candleLookBack)==_UP || trend.currentTrend(0,candleTrendPeriod,candleLookBack)==_FLAT) return _UNDEFINED;
   
   if ((MathAbs(o-c)<=0.01*(h-l))&&
      ((h-c)>=0.95*(h-l))&&
      (h>l)&&
      (l<=l1+0.3*(h1-l1))&&
      ((h-l)>=(ma1.Main(1)-ma2.Main(1)))) {
      
      return true;
   }
   
   return false;
}


//+==================================================================+
//+                                                                  +
//+==================================================================+
class bearishGraveStoneDoji : public MQCandleBase {

//=========
private:
//=========

//=========
public:
//=========
                     bearishGraveStoneDoji();
                    ~bearishGraveStoneDoji();
                    
   bool              getValue();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bearishGraveStoneDoji::bearishGraveStoneDoji() {
   
   _timeFrame=PERIOD_CURRENT;
   setOHLC(0);
   name=_BEARISHGRAVESTONEDOJI;
   mask=_UNDEFINED;
}
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bearishGraveStoneDoji::~bearishGraveStoneDoji() {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bearishGraveStoneDoji::getValue() {

   static CiMA  *ma1, *ma2;

   if (ma1==NULL||ma2==NULL) {
      ma1=new CiMA;
      ma2=new CiMA;
      ma1.Create(_Symbol,_timeFrame,10,1,MODE_EMA,PRICE_HIGH);
      ma2.Create(_Symbol,_timeFrame,10,1,MODE_EMA,PRICE_LOW);
      
   }
   
   
   ma1.Refresh(-1);
   ma2.Refresh(-1);
  
   if ((MathAbs(o-c)<=0.01*(h-l))&&
   ((h-c)>=0.95*(h-l))&&
   (h>l)&&
   (h==highestLowest(10,_HH,1))&&
   ((h-l)>=(ma1.Main(1)-ma2.Main(1)))) {
      
      return true;
   }
   
   return false;
}

