//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"

#include <Indicators\Trend.mqh>

//=========
class EATechnicalsADX : public EATechnicalsBase {
//=========

//=========
private:
   string   ss;

   int      getAbsoluteBarCount(ENUM_TIMEFRAMES period);
   void     ADXGetHistory(ENUM_TIMEFRAMES period);
   CiADX    adx;  

//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsADX(technicals &tech);
   ~EATechnicalsADX();

   void              getValues();                              // lookBack=index value to look at

    // ADX
    // ADX is plotted as a single line with values ranging from a low of zero to a high of 100.
    // ADX is non-directional it registers trend strength whether price is trending up or down
    // When the +DMI is above the -DMI, prices are moving up, and ADX measures the strength of the uptrend. 
    // When the -DMI is above the +DMI, prices are moving down, and ADX measures the strength of the downtrend. 
    //void                ADXtest(ENUM_TIMEFRAMES period );

   //int                 getAbsoluteBarCount(ENUM_TIMEFRAMES period);

   //void                ADXSetParameters(ENUM_TIMEFRAMES period);
   //void                ADXSetParameters(ENUM_TIMEFRAMES period, int maperiod);    
   //double              ADXNormalizedValue(int lookBack, int buffer);      // start=starting point to calc from. count=number number idxes 
   //double              ADXGetValue(int lookBack, int buffer);                              // lookBack=index value to look at
    //void                ADXGetHistory(ENUM_TIMEFRAMES period);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsADX::EATechnicalsADX(technicals &tech) {

   #ifdef _DEBUG_ADX_MODULE
      ss="EATechnicalsADX -> .... using input variables";
      pss
   #endif

   // Set the local instance struct variables
   t.period=tech.period;
   t.movingAverage=tech.movingAverage;

   if (!adx.Create(_Symbol,t.period,t.movingAverage)) {
      #ifdef _DEBUG_ADX_MODULE
            printf("ADXSetParameters -> ERROR");
            ExpertRemove();
      #endif
   } 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsADX::~EATechnicalsADX() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EATechnicalsADX::getAbsoluteBarCount(ENUM_TIMEFRAMES period) {

   int dfSize=2000; //TEMP !!!!!!!!!!!!!

   int barNumber=iBarShift(_Symbol,period,_historyStart,false);

    // If the time period means we exceeded the total history avaliable
    // then just return the max number of bars we have.
   if (dfSize>barNumber) return barNumber-1;

   return dfSize;


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsADX::ADXGetHistory(ENUM_TIMEFRAMES period) {


   double main[];
   double plusDI[];
   double minusDI[];

   adx.Refresh(-1);

    // Determine the last/first bar number where history start based on the period interval. This will determine the absolute number of bars
    // that can be used in the GetData/ history

   int barNumber=getAbsoluteBarCount(period);

   #ifdef _DEBUG_ADX_MODULE
      printf("--> bar history number:%d history start at %s on timeFrame:%s",barNumber,TimeToString(_historyStart),EnumToString(period));
      printf("iBars:%d ",iBars(_Symbol,period));
   #endif

   if (adx.GetData(1,barNumber,0,main)>0) {
      #ifdef _DEBUG_ADX_MODULE
            printf("ADXGetHistory --> Success");
            for (int i=0;i<1999;i++) {
               printf("indx:%d Time %s value:%.2f",i,TimeToString(iTime(_Symbol,period,i)),main[i]);
            }
      #endif
      LOAD_HISTORY=false;
   }

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsADX::getValues() {

   #ifdef _DEBUG_ADX_MODULE
      Print(__FUNCTION__);
   #endif  

   int finalBar;
   double mainVal, plusVal, minusVal;
   double main[];
   double plusDI[];
   double minusDI[];

    // Build history
   #ifdef _DEBUG_ADX_MODULE
      int barNumber=iBarShift(_Symbol,adx.Period(),_historyStart,false);
      printf("ADXGetValue --> bar history number:%d history start at %s on timeFrame:%s",barNumber,TimeToString(_historyStart),EnumToString(adx.Period()));
      printf("ADXGetValue --> iBars:%d ",iBars(_Symbol,adx.Period()));
   #endif


   if (0) {
        // Determine the last/first bar number where history start based on the period interval. This will determine the absolute number of bars
        // that can be used in the GetData/ history
      finalBar=getAbsoluteBarCount(adx.Period());

      if (adx.GetData(1,1,0,main)>0 && 
            adx.GetData(1,1,1,plusDI)>0 && 
            adx.GetData(1,1,2,minusDI)>0) {
            #ifdef _DEBUG_ADX_MODULE
               printf("ADXGetHistory --> Success");
               for (int i=0;i<1999;i++) {
                  printf("MAIN indx:%d Time %s value:%.2f",i,TimeToString(iTime(_Symbol,adx.Period(),i)),main[i]);
                  printf("PLUSDI indx:%d Time %s value:%.2f",i,TimeToString(iTime(_Symbol,adx.Period(),i)),plusDI[i]);
                  printf("MINUSDI indx:%d Time %s value:%.2f",i,TimeToString(iTime(_Symbol,adx.Period(),i)),minusDI[i]);
               }
            #endif
            LOAD_HISTORY=false;
      }
   } else {
        // Getting real values ....
      #ifdef _DEBUG_ADX_MODULE
            printf("ADXGetValue --> getting real values ...");
      #endif
      adx.Refresh(-1);
      iOutputs[0]=adx.Main(1);
      iOutputs[1]=adx.Plus(1);
      iOutputs[2]=adx.Minus(1);

      if (iOutputs[0]==EMPTY_VALUE || iOutputs[1]==EMPTY_VALUE || iOutputs[2]==EMPTY_VALUE) {       
            ss=StringFormat("ADXGetValue --> ERROR bar time:%s period %s get value EMPTY VALUE main:%.4f plus:%.4f minus:%.4f",TimeToString(iTime(_Symbol,adx.Period(),1)),EnumToString(adx.Period()),iOutputs[0],iOutputs[1],iOutputs[2]);
            pss
            writeLog
            return;
      }

      #ifdef _DEBUG_ADX_MODULE
            ss=StringFormat("ADXGetValue --> SUCCESS bar time:%s Main:%.5f Plus:%.5f Minus:%.5f period:%s",TimeToString(iTime(_Symbol,adx.Period(),1)),iOutputs[0],iOutputs[1],iOutputs[2],EnumToString(adx.Period()));
            writeLog
            pss
      #endif 

   }
}
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsADX::ADXNormalizedValue(int lookBack, int buffer) {


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
void EATechnicalsADX::ADXSetParameters(ENUM_TIMEFRAMES period){

   #ifdef _DEBUG_ADX_MODULE
      Print(__FUNCTION__);
   #endif  

   if (!adx.Create(_Symbol,period,14)) {
      #ifdef _DEBUG_ADX_MODULE
         printf(" Failed to create Standard Library ADX with error code:%d", GetLastError());
      #endif 
   } 

} 


*/
