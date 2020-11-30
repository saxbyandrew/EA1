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

#ifdef _USE_ADX    #include "EATechnicalsADX.mqh"   #endif //i1a
#ifdef _USE_RSI    #include "EATechnicalsRSI.mqh"   #endif //12a
#ifdef _USE_MFI    #include "EATechnicalsMFI.mqh"   #endif //13a
#ifdef _USE_SAR    #include "EATechnicalsSAR.mqh"   #endif //14a
#ifdef _USE_ICH    #include "EATechnicalsICH.mqh"   #endif //i5a
#ifdef _USE_RVI    #include "EATechnicalsRVI.mqh"   #endif //i6a
#ifdef _USE_STOC   #include "EATechnicalsSTOC.mqh"  #endif //i7a
#ifdef _USE_OSMA   #include "EATechnicalsOSMA.mqh"  #endif //i8a
#ifdef _USE_MACD   #include "EATechnicalsMACD.mqh"  #endif //i9a
#ifdef _USE_MACDJB #include "EATechnicalsJB.mqh"    #endif //i10a
#ifdef _USE_ZIGZAG #include "EATechnicalsZZ.mqh"    #endif 

//=========
class EATechnicalParameters : public EATechnicalsBase {
//=========


//=========
private:
//=========

string            ss;

//=========
protected:
//=========
EANeuralNetwork   *nn;        // The network 
void  createTechnicalObject();
void  copyValuesFromDatabase(int strategyNumber);
void  copyValuesFromOptimizationInputs();
EAEnum getValues();

//=========
public:
//=========
EATechnicalParameters(int strategyNumber);
~EATechnicalParameters();

CArrayDouble   nnIn;    // Values from the indicators fed into the NN
CArrayDouble   nnOut;

virtual EAEnum execute(EAEnum action);  

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalParameters::EATechnicalParameters(int strategyNumber) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      printf ("EATechnicalParameters ->  Constructor ....");
      writeLog
      pss
   #endif

   // create a new network 
   nn=new EANeuralNetwork(strategyNumber); // base refer here in the main NN number
   if (CheckPointer(nn)==POINTER_INVALID) {
      ss="EAStrategyLong -> ERROR created neural network object";
         #ifdef _DEBUG_LONG
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS  
         ss=StringFormat("EAStrategyLong -> Using base strategy number:%d %d",strategyNumber);
         writeLog
         pss
      #endif 
   }

   copyValuesFromDatabase(strategyNumber);     // Get Technicals from the DB
   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> Number of loaded technical objects:%d",indicators.Total());
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
void EATechnicalParameters::copyValuesFromDatabase(int strategyNumber) {


   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> copyValuesFromDatabase -> .... %d",strategyNumber);
      pss
   #endif

   string sql=StringFormat("SELECT * FROM TECHNICALS where strategyNumber=%d",strategyNumber);
   int request=DatabasePrepare(_mainDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> EATechnicalParameters -> copyValuesFromDatabase DB request failed %d with code:%d",strategyNumber, GetLastError()); 
      writeLog
      pss
      ss=sql;
      writeLog
      pss
      ExpertRemove();
   } else {

      // Loop thru all values for this strategyNumber / strategyType pair
      while (DatabaseRead(request)) {
         DatabaseColumnInteger      (request,0,tech.strategyNumber);
         DatabaseColumnText         (request,1,tech.indicatorName);
         DatabaseColumnInteger      (request,2,tech.instanceNumber);
         DatabaseColumnInteger      (request,3,tech.period);
         DatabaseColumnInteger      (request,4,tech.movingAverage);
         DatabaseColumnInteger      (request,5,tech.slowMovingAverage);
         DatabaseColumnInteger      (request,6,tech.fastMovingAverage);
         DatabaseColumnInteger      (request,7,tech.movingAverageMethod);
         DatabaseColumnInteger      (request,8,tech.appliedPrice);
         DatabaseColumnDouble       (request,9,tech.stepValue);
         DatabaseColumnDouble       (request,10,tech.maxValue);
         DatabaseColumnInteger      (request,11,tech.signalPeriod);
         DatabaseColumnInteger      (request,12,tech.tenkanSen);
         DatabaseColumnInteger      (request,13,tech.kijunSen);
         DatabaseColumnInteger      (request,14,tech.spanB);
         DatabaseColumnInteger      (request,15,tech.kPeriod);
         DatabaseColumnInteger      (request,16,tech.dPeriod);
         DatabaseColumnInteger      (request,17,tech.stocPrice);
         DatabaseColumnInteger      (request,18,tech.appliedVolume);
         DatabaseColumnInteger      (request,19,tech.useBuffers);
         DatabaseColumnInteger      (request,20,tech.ttl);
         DatabaseColumnDouble       (request,21,tech.incDecFactor);
         DatabaseColumnText         (request,22,tech.inputPrefix);
         DatabaseColumnDouble       (request,23,tech.lowerLevel);
         DatabaseColumnDouble       (request,24,tech.upperLevel);

         // Over write with values given to us during optimization
         if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER)) {
            #ifdef _DEBUG_TECHNICAL_PARAMETERS
               ss="EATechnicalParameters ->  copy input values MQL_OPTIMIZATION OR MQL_TESTER ....";
               writeLog
               pss
            #endif
            copyValuesFromOptimizationInputs();     
         } else {
            #ifdef _DEBUG_TECHNICAL_PARAMETERS
               ss="EATechnicalParameters ->  Using values directly from the DB";
               writeLog
               pss
            #endif
         }

         createTechnicalObject();
         #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss=StringFormat("EATechnicalParameters -> copyValuesFromDatabase -> StrategyNumber:%d Indicator Name:%s",tech.strategyNumber,tech.indicatorName);
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
      ss=StringFormat("EATechnicalParameters -> copyValuesFromOptimizationInputs -> .... for input prefix:%s",tech.inputPrefix);
      writeLog
      pss
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ADX //i1a

   if (StringFind("i1a_",tech.inputPrefix,0)!=-1) {

      tech.indicatorName="ADX";
      tech.period=i1a_period;
      tech.movingAverage=i1a_movingAverage;
      tech.upperLevel=i1a_crossLevel;
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters-> i1a_ Period:%d MA:%d CrossLevel:%d",tech.period,tech.movingAverage,tech.upperLevel);
         writeLog
      #endif
      return;
   }

   if (StringFind("i1b_",tech.inputPrefix,0)!=-1) {

      tech.indicatorName="ADX";
      tech.period=i1b_period;
      tech.movingAverage=i1b_movingAverage;
      tech.upperLevel=i1b_crossLevel;
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters-> i1b_ Period:%d MA:%d CrossLevel:%d",tech.period,tech.movingAverage,tech.upperLevel);
         writeLog
      #endif

      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RSI //i2a
   if (StringFind("i2a_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="RSI";
      tech.period=i2a_period;
      tech.movingAverage=i2a_movingAverage;
      tech.appliedPrice=i2a_appliedPrice;
      tech.upperLevel=i2a_upperLevel;
      tech.lowerLevel=i2a_lowerLevel;
      return;
   }
   if (StringFind("i2b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="RSI";
      tech.period=i2b_period;
      tech.movingAverage=i2b_movingAverage;
      tech.appliedPrice=i2b_appliedPrice;
      tech.upperLevel=i2b_upperLevel;
      tech.lowerLevel=i2b_lowerLevel;
      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MFI //i3a
   if (StringFind("i3a_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="MFI";
      tech.period=i3a_period;
      tech.movingAverage=i3a_movingAverage;
      tech.appliedVolume=i3a_appliedVolume;
      return;
   }
   if (StringFind("i3b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="MFI";
      tech.period=i3b_period;
      tech.movingAverage=i3b_movingAverage;
      tech.appliedVolume=i3b_appliedVolume;
      return;
   }

   #endif

      // ----------------------------------------------------------------
   #ifdef _USE_SAR //i4a
   if (StringFind("i4a_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="SAR";
      tech.period=i4a_period;
      tech.stepValue=i4a_stepValue;
      tech.maxValue=i4a_maxValue;
      return;
   }
   if (StringFind("i4b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="SAR";
      tech.period=i4b_period;
      tech.stepValue=i4b_stepValue;
      tech.maxValue=i4b_maxValue;
      return;
   }

   #endif

      // ----------------------------------------------------------------
   #ifdef _USE_ICH //i5a
   if (StringFind("i5a_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="ICH";
      tech.period=i5a_period;
      tech.tenkanSen=i5a_tenkanSen;
      tech.kijunSen=i5a_kijunSen;
      tech.spanB=i5a_spanB;
      return;
   }
   if (StringFind("i5b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="ICH";
      tech.period=i5b_period;
      tech.tenkanSen=i5b_tenkanSen;
      tech.kijunSen=i5b_kijunSen;
      tech.spanB=i5b_spanB;
      return;
   }

   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RVI //i6a

   if (StringFind("i6a_",tech.inputPrefix,0)!=-1) {

      tech.indicatorName="RVI";
      tech.period=i6a_period;
      tech.movingAverage=i6a_movingAverage;
      return;
   }

   if (StringFind("i6b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="RVI";
      tech.period=i6b_period;
      tech.movingAverage=i6b_movingAverage;
      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_STOC //i7a
      
      if (StringFind("i7a_",tech.inputPrefix,0)!=-1) {
         tech.indicatorName="STOC";
         tech.period=i7a_period;
         tech.dPeriod=i7a_kPeriod;
         tech.kPeriod=i7a_dPeriod;
         tech.slowMovingAverage=i7a_slowing;
         tech.movingAverageMethod=i7a_maMethod;
         tech.stocPrice=i7a_stocPrice;
         return;
      }
      if (StringFind("i7b_",tech.inputPrefix,0)!=-1) {
         tech.indicatorName="STOC";
         tech.period=i7b_period;
         tech.dPeriod=i7b_kPeriod;
         tech.kPeriod=i7b_dPeriod;
         tech.slowMovingAverage=i7b_slowing;
         tech.movingAverageMethod=i7b_maMethod;
         tech.stocPrice=i7b_stocPrice;
         return;
      }

   #endif

      // ----------------------------------------------------------------
   #ifdef _USE_OSMA //i8a
      if (StringFind("i8a_",tech.inputPrefix,0)!=-1) {
         tech.indicatorName="OSMA";
         tech.period=i8a_period;
         tech.slowMovingAverage=i8a_slowMovingAverage;
         tech.fastMovingAverage=i8a_fastMovingAverage;
         tech.signalPeriod=i8a_signalPeriod;
         tech.appliedPrice=i8a_appliedPrice;
         return;
      }
      if (StringFind("i8b_",tech.inputPrefix,0)!=-1) {
         tech.indicatorName="OSMA";
         tech.period=i8b_period;
         tech.slowMovingAverage=i8b_slowMovingAverage;
         tech.fastMovingAverage=i8b_fastMovingAverage;
         tech.signalPeriod=i8b_signalPeriod;
         tech.appliedPrice=i8b_appliedPrice;
         return;
      }

   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MACD //i9a
   if (StringFind("i9a_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="MACD";
      tech.period=i9a_period;
      tech.slowMovingAverage=i9a_slowMovingAverage;
      tech.fastMovingAverage=i9a_fastMovingAverage;
      tech.signalPeriod=i9a_signalPeriod;
      tech.appliedPrice=i9a_appliedPrice;
      //tech.useBuffer1=i2a_useBuffer1;

      return;
   }
   if (StringFind("i9b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="MACD";
      tech.period=i9b_period;
      tech.slowMovingAverage=i9b_slowMovingAverage;
      tech.fastMovingAverage=i9b_fastMovingAverage;
      tech.signalPeriod=i9b_signalPeriod;
      tech.appliedPrice=i9b_appliedPrice;

      //tech.useBuffer1=i2b_useBuffer1;

      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MACDJB //i10a
   if (StringFind("i10a_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="MACDJB";
      tech.period=i10a_period;
      tech.slowMovingAverage=i10a_slowMovingAverage;
      tech.fastMovingAverage=i10a_fastMovingAverage;
      tech.signalPeriod=i10a_signalPeriod;
      return;
   }
   if (StringFind("i10b_",tech.inputPrefix,0)!=-1) {
      tech.indicatorName="MACDJB";
      tech.period=i10b_period;
      tech.slowMovingAverage=i10b_slowMovingAverage;
      tech.fastMovingAverage=i10b_fastMovingAverage;
      tech.signalPeriod=i10b_signalPeriod;
      return;
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ZIGZAG

   if (StringFind("i100a_",tech.inputPrefix,0)!=-1) {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="-----------------------> i100a_";
         writeLog
      #endif
      tech.indicatorName="ZIGZAG";
      tech.period=i100a_ZZperiod;
      //tech.useBuffer1=i100a_useBuffer1;
      return;
   }

   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::createTechnicalObject() {

   /*
   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="EATechnicalParameters -> createTechnicalObject -> ....";
      pss
   #endif
   */

   EATechnicalsBase *i;

   #ifdef _USE_ADX   if (tech.indicatorName=="ADX")         i=new EATechnicalsADX(tech);  #endif
   #ifdef _USE_RSI   if (tech.indicatorName=="RSI")         i=new EATechnicalsRSI(tech);  #endif
   #ifdef _USE_MFI   if (tech.indicatorName=="MFI")         i=new EATechnicalsMFI(tech);  #endif
   #ifdef _USE_SAR   if (tech.indicatorName=="SAR")         i=new EATechnicalsSAR(tech);  #endif
   #ifdef _USE_ICH   if (tech.indicatorName=="ICH")         i=new EATechnicalsICH(tech);  #endif
   #ifdef _USE_RVI   if (tech.indicatorName=="RVI")         i=new EATechnicalsRVI(tech);  #endif
   #ifdef _USE_STOC  if (tech.indicatorName=="STOC")        i=new EATechnicalsSTOC(tech);  #endif
   #ifdef _USE_OSMA  if (tech.indicatorName=="OSMA")        i=new EATechnicalsOSMA(tech);  #endif
   #ifdef _USE_MACD  if (tech.indicatorName=="MACD")        i=new EATechnicalsMACD(tech);  #endif
   #ifdef _USE_MACDJB if (tech.indicatorName=="MACDJB")     i=new EATechnicalsJB(tech);   #endif
   #ifdef _USE_ZIGZAG if (tech.indicatorName=="ZIGZAG")     i=new EATechnicalsZZ(tech);   #endif
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
         ss=StringFormat("EATechnicalParameters -> createTechnicalObject -> SUCCESS createTechnicalObject -> %s",tech.indicatorName);
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
   int optimizationStartBar, barCnt;
   /*
   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      pline
      ss=StringFormat("EATechnicalParameters -> getValues -> Entry .... runMode:%d",_runMode);
      writeLog
      pline
   #endif
   */

   // Start with a blank slate on every bar we clear the nn input/output arrays
   nnIn.Clear(); nnOut.Clear();


   //==========================
   if (_systemState==_STATE_NORMAL) {
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

      return _NO_ACTION;
   }

   //================================
   if (_systemState==_STATE_BUILD_DATAFRAME) {
   //================================
      // Loop through all object and get the object to return the value as a input to the NN
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="EATechnicalParameters -> getValues -> getting values in _RUN_OPTIMIZATION mode....";
         writeLog
      #endif

      for (int i=0;i<indicators.Total();i++) {
         EATechnicalsBase *indicator=indicators.At(i);
         indicator.getValues(nnIn, nnOut);            // Build in/out from indicators
      }
      nn.buildDataFrame(nnIn,nnOut);                  // Add to DF which will the be used in training

      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters -> getValues -> Total Inputs:%d ",nnIn.Total());
         writeLog
         ss=" >>>>> Inputs: ";
         for (int l=0;l<nnIn.Total();l++) {
            ss=StringFormat("%.5f",nnIn.At(l));
            writeLog
         }
         
         ss=StringFormat("EATechnicalParameters -> getValues -> Total Outputs:%d ",nnOut.Total());
         writeLog
         ss=" >>>>>> Outputs: ";
         for (int m=0;m<nnIn.Total();m++) {
            ss=StringFormat("%.5f",nnIn.At(m));
         }
         writeLog
      #endif
      return _NO_ACTION;
   }
   

   //==============================
   if (_systemState==_STATE_REBUILD_NETWORK) {
   //==============================
      #ifdef _DEBUG_NN_TRAINING
         ss=StringFormat("EATechnicalParameters -> getValues -> REBUILD NN optimization start time:%s start bar:%d DF Size:%d",
            TimeToString(nn.getOptimizationStartDateTime(),TIME_DATE|TIME_MINUTES),iBarShift(_Symbol,PERIOD_CURRENT,nn.getOptimizationStartDateTime(),false),nn.getDataFrameSize());
         writeLog
         pss
      #endif

      barCnt=nn.getDataFrameSize();

      // Get the bar number based on the previously saved optimizations run and date/time
      optimizationStartBar=iBarShift(_Symbol,PERIOD_CURRENT,nn.getOptimizationStartDateTime(),false);  
      if (optimizationStartBar<barCnt) optimizationStartBar=barCnt;

      #ifdef _DEBUG_NN_TRAINING
         ss=StringFormat("EATechnicalParameters -> getValues -> REBUILD NETWORK optimization start bar:%d",
            optimizationStartBar);
         writeLog
         pss
      #endif

      while (barCnt>0) {

         // Start with a blank slate on every bar we clear the nn input/output arrays
         nnIn.Clear(); nnOut.Clear();
         for (int i=0;i<indicators.Total();i++) {
            EATechnicalsBase *indicator=indicators.At(i);
            indicator.getValues(nnIn,nnOut,iTime(_Symbol,PERIOD_CURRENT,optimizationStartBar));
         }
         nn.buildDataFrame(nnIn,nnOut);               // build the dataframe by adding inputs and outputs
         --barCnt; --optimizationStartBar;            // bump counters

         #ifdef _DEBUG_NN_TRAINING
            ss=StringFormat("EATechnicalParameters -> getValues -> barCnt:%d Optimization Bar Number:%d Optimization Bar Date/Time:%s",barCnt,optimizationStartBar,TimeToString(iTime(_Symbol,PERIOD_CURRENT,optimizationStartBar),TIME_DATE|TIME_MINUTES));
            writeLog
            pss
         #endif
      }
      // How update the DB with values used in this single test run.
      for (int i=0;i<indicators.Total();i++) {
         EATechnicalsBase *indicator=indicators.At(i);
         indicator.setValues();
         #ifdef _DEBUG_NN_TRAINING
            ss="EATechnicalParameters -> getValues -> Updating DB TECHNICALS";
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
      ss="EATechnicalParameters -> execute -> ";
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

