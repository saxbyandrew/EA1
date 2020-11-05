//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"
#include "EANeuralNetwork.mqh"
#include "EAOptimizationInputs.mqh"
#include "EATechnicalsBase.mqh"

#ifdef _USE_ADX    #include "EATechnicalsADX.mqh"   #endif
#ifdef _USE_RSI    #include "EATechnicalsRSI.mqh"   #endif
#ifdef _USE_MACD   #include "EATechnicalsMACD.mqh"  #endif
#ifdef _USE_ZIGZAG #include "EATechnicalsZZ.mqh"    #endif
//#include "EATechnicalsRSI.mqh"

/*
#ifdef _USE_ADX    class EATechnicalsADX;    #endif
#ifdef _USE_RSI    class EATechnicalsRSI;    #endif
#ifdef _USE_MACD   class EATechnicalsMACD;   #endif
#ifdef _USE_ZIGZAG class EATechnicalsZZ;     #endif                    
*/
class EATechnicalParameters : public EATechnicalsBase {

//=========
private:
//=========

string            ss;

//=========
protected:
//=========
EANeuralNetwork   *nn;        // The network 
void  createTechnicalObject();
void  copyValuesFromDatabase(int strategyType, int strategyType);
void  copyValuesFromOptimizationInputs();
EAEnum getValues();

//=========
public:
//=========
EATechnicalParameters(int strategyNumber, int strategyType);
~EATechnicalParameters();

CArrayDouble   nnIn;    // Values from the indicators fed into the NN
CArrayDouble   nnOut;

virtual EAEnum execute(EAEnum action);  

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::EATechnicalParameters(int strategyNumber, int strategyType) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      printf ("EATechnicalParameters ->  Constructor ....");
      writeLog
      pss
   #endif

   // create a new network 
   nn=new EANeuralNetwork(strategyNumber,strategyType); // base refer here in the main NN number
   if (CheckPointer(nn)==POINTER_INVALID) {
      ss="EAStrategyLong -> ERROR created neural network object";
         #ifdef _DEBUG_LONG
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS  
         ss=StringFormat("EAStrategyLong -> Using base strategy number:%d %d",strategyNumber, strategyType);
         writeLog
         pss
      #endif 
   }

   copyValuesFromDatabase(strategyNumber, strategyType);     // Get Technicals from the DB
   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters  -> Number of loaded technical objects:%d",indicators.Total());
      writeLog
      pss
   #endif 

   

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::~EATechnicalParameters() {

      // Clean up
   for (int i=0;i<indicators.Total();i++) {
      delete(indicators.At(i));
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromDatabase(int strategyNumber, int strategyType) {


   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> copyValuesFromDatabase -> .... %d %d",strategyNumber,strategyType);
      pss
   #endif

   string sql=StringFormat("SELECT * FROM TECHNICALS where strategyNumber=%d AND strategyType=%d",strategyNumber,strategyType);
   int request=DatabasePrepare(_mainDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> EATechnicalParameters -> copyValuesFromDatabase DB request failed %s %d with code:%d",strategyNumber,strategyType, GetLastError()); 
      writeLog
      pss
      ss=sql;
      writeLog
      pss
      ExpertRemove();
   } else {

      // Loop thru all values for this strategyNumber / strategyType pair
      while (DatabaseRead(request)) {
         DatabaseColumnInteger      (request,0,t.strategyNumber);
         DatabaseColumnInteger      (request,1,t.strategyType);
         DatabaseColumnText         (request,2,t.indicatorName);
         DatabaseColumnInteger      (request,3,t.instanceNumber);
         DatabaseColumnInteger      (request,4,t.period);
         DatabaseColumnInteger      (request,5,t.movingAverage);
         DatabaseColumnInteger      (request,6,t.slowMovingAverage);
         DatabaseColumnInteger      (request,7,t.fastMovingAverage);
         DatabaseColumnInteger      (request,8,t.movingAverageMethod);
         DatabaseColumnInteger      (request,9,t.appliedPrice);
         DatabaseColumnDouble       (request,10,t.stepValue);
         DatabaseColumnDouble       (request,11,t.maxValue);
         DatabaseColumnInteger      (request,12,t.signalPeriod);
         DatabaseColumnInteger      (request,13,t.tenkanSen);
         DatabaseColumnInteger      (request,14,t.kijunSen);
         DatabaseColumnInteger      (request,15,t.spanB);
         DatabaseColumnInteger      (request,16,t.kPeriod);
         DatabaseColumnInteger      (request,17,t.dPeriod);
         DatabaseColumnInteger      (request,18,t.useBuffers);
         DatabaseColumnInteger      (request,19,t.ttl);
         DatabaseColumnText         (request,20,t.inputPrefix);
         DatabaseColumnDouble       (request,21,t.lowerLevel);
         DatabaseColumnDouble       (request,22,t.upperLevel);

         // Over write with values given to us during optimization
         if (_runMode==_RUN_OPTIMIZATION) {
            #ifdef _DEBUG_TECHNICAL_PARAMETERS
               ss="EATechnicalParameters ->  copy input values MQL_OPTIMIZATION ....";
               writeLog
               pss
            #endif
            copyValuesFromOptimizationInputs();     
         }  

         createTechnicalObject();
         #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss=StringFormat("EATechnicalParameters -> copyValuesFromDatabase -> StrategyNumber:%d Indicator Name:%s",t.strategyNumber,t.indicatorName);
            writeLog
            pss
         #endif
      }
   }

   // do an initial polling of each of the objects to get a count from of the buffers
   // in use
   for (int i=0;i<indicators.Total();i++) {
      EATechnicalsBase *indicator=indicators.At(i);
      indicator.getValues(nnIn, nnOut);
   }
   nn.setDataFrameArraySizes(nnIn.Total(),nnOut.Total());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromOptimizationInputs() {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> copyValuesFromOptimizationInputs -> .... for input prefix:%s",t.inputPrefix);
      writeLog
      pss
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ADX

   if (StringFind("i1a_",t.inputPrefix,0)!=-1) {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="-----------------------> i1a_";
         writeLog
      #endif

      t.indicatorName="ADX";
      t.period=i1a_period;
      t.movingAverage=i1a_movingAverage;
      //t.useBuffers=i1a_useBuffers; // logical AND 1,2,4,8
      return;
   }

   if (StringFind("i1b_",t.inputPrefix,0)!=-1) {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="-----------------------> i1b_";
         writeLog
      #endif

      t.indicatorName="ADX";
      t.period=i1b_period;
      t.movingAverage=i1b_movingAverage;
      //t.useBuffers=i1b_useBuffers;

      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RSI
   if (StringFind("i2a_",t.inputPrefix,0)!=-1) {
      t.indicatorName="RSI";
      t.period=i2a_period;
      t.movingAverage=i2a_movingAverage;
      t.appliedPrice=i2a_appliedPrice;
      //t.useBuffer1=i2a_useBuffer1;

      return;
   }
   if (StringFind("i2b_",t.inputPrefix,0)!=-1) {
      t.indicatorName="RSI";
      t.period=i2b_period;
      t.movingAverage=i2b_movingAverage;
      t.appliedPrice=i2b_appliedPrice;
      //t.useBuffer1=i2b_useBuffer1;

      return;
   }
   #endif


   // ----------------------------------------------------------------
   #ifdef _USE_MACD
   if (StringFind("i9a_",t.inputPrefix,0)!=-1) {
      t.indicatorName="MACD";
      t.period=i9a_period;
      t.slowMovingAverage=i9a_slowMovingAverage;
      t.fastMovingAverage=i9a_fastMovingAverage;
      t.signalPeriod=i9a_signalPeriod;
      t.appliedPrice=i9a_appliedPrice;
      //t.useBuffer1=i2a_useBuffer1;

      return;
   }
   if (StringFind("i9b_",t.inputPrefix,0)!=-1) {
      t.indicatorName="MACD";
      t.period=i9b_period;
      t.slowMovingAverage=i9b_slowMovingAverage;
      t.fastMovingAverage=i9b_fastMovingAverage;
      t.signalPeriod=i9b_signalPeriod;
      t.appliedPrice=i9b_appliedPrice;

      //t.useBuffer1=i2b_useBuffer1;

      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ZIGZAG

   if (StringFind("i100a_",t.inputPrefix,0)!=-1) {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="-----------------------> i100a_";
         writeLog
      #endif
      t.indicatorName="ZIGZAG";
      t.period=i100a_ZZperiod;
      //t.useBuffer1=i100a_useBuffer1;
      return;
   }

   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::createTechnicalObject() {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="EATechnicalParameters -> createTechnicalObject -> ....";
      pss
   #endif

   EATechnicalsBase *i;

   #ifdef _USE_ADX   if (t.indicatorName=="ADX")         i=new EATechnicalsADX(t);  #endif
   #ifdef _USE_RSI   if (t.indicatorName=="RSI")         i=new EATechnicalsRSI(t);  #endif
   #ifdef _USE_MACD  if (t.indicatorName=="MACD")        i=new EATechnicalsMACD(t);  #endif
   #ifdef _USE_ZIGZAG if (t.indicatorName=="ZIGZAG")     i=new EATechnicalsZZ(t);   #endif
   // etc

   // Check the object
   if (CheckPointer(i)==POINTER_INVALID) {
      ss="EATechnicalParameters -> ERROR adding indicator ";
      writeLog
      pss
      ExpertRemove();
   } 

   // Add indicator object to list of all objects
   if (!indicators.Add(i)) {
      ss="EATechnicalParameters -> createTechnicalObject -> ERROR";
      writeLog
      pss
   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters -> createTechnicalObject -> SUCCESS createTechnicalObject -> %s",t.indicatorName);
         writeLog
         pss
      #endif 
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EATechnicalParameters::getValues() {

   static int barNumber=1;

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      pline
      ss=StringFormat("EATechnicalParameters -> getValues -> Entry .... runMode:%d",_runMode);
      writeLog
      pline
   #endif

   // Start with a blank slate on every bar we clear the nn input/output arrays
   nnIn.Clear(); nnOut.Clear();


   //==========================
   if (_runMode==_RUN_NORMAL) {
   //==========================
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="EATechnicalParameters -> getValues -> Entry RUN NORMAL";
         writeLog
      #endif

      double prediction[1];

      for (int i=0;i<indicators.Total();i++) {
         EATechnicalsBase *indicator=indicators.At(i);
         indicator.getValues(nnIn, nnOut);
      }

      if (nn.networkForcast(nnIn, nnOut, prediction)==_OPEN_NEW_POSITION) {
         return _OPEN_NEW_POSITION;
      }
   }

   //================================
   if (_runMode==_RUN_OPTIMIZATION) {
   //================================
      // Loop through all object and get the object to return the value as a input to the NN
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="EATechnicalParameters -> getValues -> getting values in dataframe mode....";
         writeLog
      #endif

      for (int i=0;i<indicators.Total();i++) {
         EATechnicalsBase *indicator=indicators.At(i);
         indicator.getValues(nnIn, nnOut);            // Build in/out from indicators
      }
      nn.buildDataFrame(nnIn,nnOut);                  // Add to DF which will the be used in training

      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters -> getValues -> Inputs:%d ",nnIn.Total());
         for (int l=0;l<nnIn.Total();l++) {
            ss=DoubleToString(nnIn.At(l),5);
            writeLog
         }
         ss=StringFormat("EATechnicalParameters -> getValues -> Outputs:%d ",nnOut.Total());
         for (int m=0;m<nnIn.Total();m++) {
            ss=DoubleToString(nnIn.At(m),5);
            writeLog
         }
      #endif
      return _NO_ACTION;
   }
   

   //==============================
   if (_runMode==_RUN_REBUILD_NN) {
   //==============================
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters -> getValues -> REBUILD NN optimization start time:%s start bar:%d DF Size:%d",
            TimeToString(nn.getOptimizationStartDateTime(),TIME_DATE|TIME_MINUTES),iBarShift(_Symbol,PERIOD_CURRENT,nn.getOptimizationStartDateTime(),false),nn.getDataFrameSize());
         writeLog
         pss
      #endif

      // Get the bar number based on the previously saved optimizations run and date/time
      int optimizationStartBar=iBarShift(_Symbol,PERIOD_CURRENT,nn.getOptimizationStartDateTime(),false);  
      int barCnt=nn.getDataFrameSize(); 

      while (barCnt>0) {

         // Start with a blank slate on every bar we clear the nn input/output arrays
         nnIn.Clear(); nnOut.Clear();
         for (int i=0;i<indicators.Total();i++) {
            EATechnicalsBase *indicator=indicators.At(i);
            indicator.getValues(nnIn,nnOut,iTime(_Symbol,PERIOD_CURRENT,optimizationStartBar));
         }
         nn.buildDataFrame(nnIn,nnOut);               // build the dataframe by adding inputs and outputs
         --barCnt; --optimizationStartBar;            // bump counters

         #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss=StringFormat("EATechnicalParameters -> getValues -> barCnt:%d Optimization Bar Number:%d Optimization Bar Date/Time:%s",barCnt,optimizationStartBar,TimeToString(iTime(_Symbol,PERIOD_CURRENT,optimizationStartBar),TIME_DATE|TIME_MINUTES));
            writeLog
            pss
         #endif
      }
      
   }

   return _NO_ACTION;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EATechnicalParameters::execute(EAEnum action) {


   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="EATechnicalParameters -> execute -> ....";
      writeLog
   #endif

   switch (action) {
      case _RUN_ONTICK:  
      break;
      case _RUN_ONBAR: return(getValues());
      break;
      case _RUN_ONDAY:     
      break;
   }

   return -1;
}

