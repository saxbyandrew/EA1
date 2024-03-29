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

#ifdef _USE_ADX    #include "EATechnicalsADX.mqh"   #endif //i1a Y
#ifdef _USE_RSI    #include "EATechnicalsRSI.mqh"   #endif //12a Y
#ifdef _USE_MFI    #include "EATechnicalsMFI.mqh"   #endif //13a Y
#ifdef _USE_SAR    #include "EATechnicalsSAR.mqh"   #endif //14a 
#ifdef _USE_ICH    #include "EATechnicalsICH.mqh"   #endif //i5a
#ifdef _USE_RVI    #include "EATechnicalsRVI.mqh"   #endif //i6a // to be tested
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
void showTechnicalValues();

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

// Values from the indicators fed into the NN
CArrayDouble   nnIn, nnOut; 
CArrayString   nnHeadings;

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
         ss=StringFormat("EATechnicalParameters -> Using base strategy number:%d",strategyNumber);
         writeLog
         pss
      #endif 
   }

   if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER)) {
      copyValuesFromOptimizationInputs();  
   } else {
      copyValuesFromDatabase(strategyNumber);     // Get Technicals from the DB 
   }

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> Number of loaded technical objects:%d",indicators.Total());
      writeLog
      pss
   #endif

   // do an initial polling of each of the objects to get a count from of the buffers
   // in use
   for (int i=0;i<indicators.Total();i++) {
      EATechnicalsBase *indicator=indicators.At(i);
      indicator.getValues(nnIn, nnOut, TimeCurrent(), nnHeadings);
      pline
   }

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> Number of inputs %d outputs %d",nnIn.Total(),nnOut.Total());
      writeLog
      pss
   #endif

   nn.setDataFrameArraySizes(nnIn.Total(),nnOut.Total());

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
#ifdef _DEBUG_TECHNICAL_PARAMETERS
void EATechnicalParameters::showTechnicalValues() {

   pline
   ss=StringFormat("inputPrefix :%s",tech.inputPrefix) ; writeLog
   pline
   ss=StringFormat("strategyNumber :%d",tech.strategyNumber) ; writeLog
   ss=StringFormat("indicatorName :%s",tech.indicatorName) ; writeLog
   ss=StringFormat("instanceNumber :%d",tech.instanceNumber) ; writeLog
   ss=StringFormat("period :%d",tech.period) ; writeLog
   ss=StringFormat("enumTimeFrames :%s",tech.enumTimeFrames) ; writeLog
   ss=StringFormat("movingAverage :%d",tech.movingAverage) ; writeLog
   ss=StringFormat("slowMovingAverage :%d",tech.slowMovingAverage) ; writeLog
   ss=StringFormat("fastMovingAverage :%d",tech.fastMovingAverage) ; writeLog
   ss=StringFormat("movingAverageMethod :%d",tech.movingAverageMethod) ; writeLog
   ss=StringFormat("enumMAMethod :%s",tech.enumMAMethod) ; writeLog
   ss=StringFormat("appliedPrice :%d",tech.appliedPrice) ; writeLog
   ss=StringFormat("enumAppliedPrice :%s",tech.enumAppliedPrice) ; writeLog
   ss=StringFormat("stepValue :%.5f",tech.stepValue) ; writeLog
   ss=StringFormat("maxValue :%.5f",tech.maxValue) ; writeLog
   ss=StringFormat("signalPeriod :%d",tech.signalPeriod) ; writeLog
   ss=StringFormat("tenkanSen :%d",tech.tenkanSen) ; writeLog
   ss=StringFormat("kijunSen :%d",tech.kijunSen) ; writeLog
   ss=StringFormat("spanB :%d",tech.spanB) ; writeLog
   ss=StringFormat("kPeriod :%d",tech.kPeriod) ; writeLog
   ss=StringFormat("dPeriod :%d",tech.dPeriod) ; writeLog
   ss=StringFormat("stocPrice :%d",tech.stocPrice) ; writeLog
   ss=StringFormat("enumStoPrice :%s",tech.enumStoPrice) ; writeLog
   ss=StringFormat("appliedVolume :%d",tech.appliedVolume) ; writeLog
   ss=StringFormat("enumAppliedVolume :%s",tech.enumAppliedVolume) ; writeLog
   ss=StringFormat("useBuffers :%d",tech.useBuffers) ; writeLog
   ss=StringFormat("ttl :%d",tech.ttl) ; writeLog
   ss=StringFormat("incDecFactor :%.5f",tech.incDecFactor) ; writeLog

   ss=StringFormat("lowerLevel :%.5f",tech.lowerLevel) ; writeLog
   ss=StringFormat("upperLevel :%.5f",tech.upperLevel) ; writeLog
   ss=StringFormat("barDelay :%d",tech.barDelay) ; writeLog
   ss=StringFormat("versionNumber :%d",tech.versionNumber) ; writeLog

}
#endif

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromDatabase(int strategyNumber) {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EATechnicalParameters -> selectValuesFromDatabase -> .... %d",strategyNumber);
      pss
   #endif

   // Only using ORDER BY so the log file looks more readable! 
   string sql=StringFormat("SELECT * FROM TECHNICALS where strategyNumber=%d ORDER BY inputPrefix",strategyNumber);
   int request=DatabasePrepare(_mainDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> EATechnicalParameters -> selectValuesFromDatabase DB request failed %d with code:%d",strategyNumber, GetLastError()); 
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
         DatabaseColumnText         (request,4,tech.enumTimeFrames);

         DatabaseColumnInteger      (request,5,tech.movingAverage);
         DatabaseColumnInteger      (request,6,tech.slowMovingAverage);
         DatabaseColumnInteger      (request,7,tech.fastMovingAverage);
         DatabaseColumnInteger      (request,8,tech.movingAverageMethod);
         DatabaseColumnText         (request,9,tech.enumMAMethod);

         DatabaseColumnInteger      (request,10,tech.appliedPrice);
         DatabaseColumnText         (request,11,tech.enumAppliedPrice);
         DatabaseColumnDouble       (request,12,tech.stepValue);
         DatabaseColumnDouble       (request,13,tech.maxValue);
         DatabaseColumnInteger      (request,14,tech.signalPeriod);

         DatabaseColumnInteger      (request,15,tech.tenkanSen);
         DatabaseColumnInteger      (request,16,tech.kijunSen);
         DatabaseColumnInteger      (request,17,tech.spanB);
         DatabaseColumnInteger      (request,18,tech.kPeriod);
         DatabaseColumnInteger      (request,19,tech.dPeriod);

         DatabaseColumnInteger      (request,20,tech.stocPrice);
         DatabaseColumnText         (request,21,tech.enumStoPrice);
         DatabaseColumnInteger      (request,22,tech.appliedVolume);
         DatabaseColumnText         (request,23,tech.enumAppliedVolume);
         DatabaseColumnInteger      (request,24,tech.useBuffers);

         DatabaseColumnInteger      (request,25,tech.ttl);
         DatabaseColumnDouble       (request,26,tech.incDecFactor);
         DatabaseColumnText         (request,27,tech.inputPrefix);
         DatabaseColumnDouble       (request,28,tech.lowerLevel);
         DatabaseColumnDouble       (request,29,tech.upperLevel);

         DatabaseColumnInteger      (request,30,tech.barDelay);
         DatabaseColumnInteger      (request,31,tech.versionNumber);

         createTechnicalObject();
         #ifdef _DEBUG_TECHNICAL_PARAMETERS
            showTechnicalValues();
         #endif
      }
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::copyValuesFromOptimizationInputs() {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      pline
      ss="EATechnicalParameters -> copyValuesFromOptimizationInputs";
      writeLog
      pss
      pline
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ADX //i1a

   //if (StringFind("i1a_",tech.inputPrefix,0)!=-1) {
   if (iuseADX_A) {
      tech.indicatorName="ADX";
      tech.period=i1a_period;
      tech.movingAverage=i1a_movingAverage;
      tech.upperLevel=i1a_crossLevel;
      tech.barDelay=i1a_barDelay;
      tech.useBuffers=15;
      createTechnicalObject();
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters -> copyValuesFromOptimizationInputs -> Period:%d MA:%d CrossLevel:%.5f barDelay:%d",tech.period,tech.movingAverage,tech.upperLevel,tech.barDelay);
         writeLog
      #endif
   }

   //if (StringFind("i1b_",tech.inputPrefix,0)!=-1) {
   if (iuseADX_B) {
      tech.indicatorName="ADX";
      tech.period=i1b_period;
      tech.movingAverage=i1b_movingAverage;
      tech.upperLevel=i1b_crossLevel;
      tech.barDelay=i1b_barDelay;
      tech.useBuffers=15;
      createTechnicalObject();
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters-> copyValuesFromOptimizationInputs -> Period:%d MA:%d CrossLevel:%.5f",tech.period,tech.movingAverage,tech.upperLevel);
         writeLog
      #endif
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RSI //i2a
   //if (StringFind("i2a_",tech.inputPrefix,0)!=-1) {
   if (iuseRSI_A) {
      tech.indicatorName="RSI";
      tech.period=i2a_period;
      tech.movingAverage=i2a_movingAverage;
      tech.appliedPrice=i2a_appliedPrice;
      tech.upperLevel=i2a_upperLevel;
      tech.lowerLevel=i2a_lowerLevel;
      tech.barDelay=i2a_barDelay;
      createTechnicalObject();
   }
   //if (StringFind("i2b_",tech.inputPrefix,0)!=-1) {
   if (iuseRSI_B) {
      tech.indicatorName="RSI";
      tech.period=i2b_period;
      tech.movingAverage=i2b_movingAverage;
      tech.appliedPrice=i2b_appliedPrice;
      tech.upperLevel=i2b_upperLevel;
      tech.lowerLevel=i2b_lowerLevel;
      tech.barDelay=i2b_barDelay;
      createTechnicalObject();
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MFI //i3a
   //if (StringFind("i3a_",tech.inputPrefix,0)!=-1) {
   if (iuseMFI_A) {
      tech.indicatorName="MFI";
      tech.period=i3a_period;
      tech.movingAverage=i3a_movingAverage;
      tech.appliedVolume=i3a_appliedVolume;
      tech.barDelay=i3a_barDelay;
      createTechnicalObject();
   }
   //if (StringFind("i3b_",tech.inputPrefix,0)!=-1) {
   if (iuseMFI_B) {
      tech.indicatorName="MFI";
      tech.period=i3b_period;
      tech.movingAverage=i3b_movingAverage;
      tech.appliedVolume=i3b_appliedVolume;
      tech.barDelay=i3b_barDelay;
      createTechnicalObject();
   }

   #endif

      // ----------------------------------------------------------------
   #ifdef _USE_SAR //i4a
   //if (StringFind("i4a_",tech.inputPrefix,0)!=-1) {
   if (iuseSAR_A) {
      tech.indicatorName="SAR";
      tech.period=i4a_period;
      tech.stepValue=i4a_stepValue;
      tech.maxValue=i4a_maxValue;
      tech.barDelay=i4a_barDelay;
      createTechnicalObject();
   }
   //if (StringFind("i4b_",tech.inputPrefix,0)!=-1) {
   if (iuseSAR_B) {
      tech.indicatorName="SAR";
      tech.period=i4b_period;
      tech.stepValue=i4b_stepValue;
      tech.maxValue=i4b_maxValue;
      tech.barDelay=i4b_barDelay;
      createTechnicalObject();
   }

   #endif

      // ----------------------------------------------------------------
   #ifdef _USE_ICH //i5a
   //if (StringFind("i5a_",tech.inputPrefix,0)!=-1) {
   if (iuseICH_A) {
      tech.indicatorName="ICH";
      tech.period=i5a_period;
      tech.tenkanSen=i5a_tenkanSen;
      tech.kijunSen=i5a_kijunSen;
      tech.spanB=i5a_spanB;
      tech.barDelay=i5a_barDelay;
      createTechnicalObject();
   }
   //if (StringFind("i5b_",tech.inputPrefix,0)!=-1) {
   if (iuseICH_B) {
      tech.indicatorName="ICH";
      tech.period=i5b_period;
      tech.tenkanSen=i5b_tenkanSen;
      tech.kijunSen=i5b_kijunSen;
      tech.spanB=i5b_spanB;
      tech.barDelay=i5b_barDelay;
      createTechnicalObject();
   }

   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_RVI //i6a

   //if (StringFind("i6a_",tech.inputPrefix,0)!=-1) {
   if (iuseRVI_A) {
      tech.indicatorName="RVI";
      tech.period=i6a_period;
      tech.movingAverage=i6a_movingAverage;
      tech.barDelay=i6a_barDelay;
      createTechnicalObject();
   }

   //if (StringFind("i6b_",tech.inputPrefix,0)!=-1) {
   if (iuseRVI_B) {
      tech.indicatorName="RVI";
      tech.period=i6b_period;
      tech.movingAverage=i6b_movingAverage;
      tech.barDelay=i6b_barDelay;
      createTechnicalObject();
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_STOC //i7a
      
      //if (StringFind("i7a_",tech.inputPrefix,0)!=-1) {
      if (iuseSTOC_A) {
         tech.indicatorName="STOC";
         tech.period=i7a_period;
         tech.dPeriod=i7a_kPeriod;
         tech.kPeriod=i7a_dPeriod;
         tech.slowMovingAverage=i7a_slowing;
         tech.movingAverageMethod=i7a_maMethod;
         tech.stocPrice=i7a_stocPrice;
         tech.barDelay=i7a_barDelay;
         createTechnicalObject();
      }
      //if (StringFind("i7b_",tech.inputPrefix,0)!=-1) {
      if (iuseSTOC_B) {
         tech.indicatorName="STOC";
         tech.period=i7b_period;
         tech.dPeriod=i7b_kPeriod;
         tech.kPeriod=i7b_dPeriod;
         tech.slowMovingAverage=i7b_slowing;
         tech.movingAverageMethod=i7b_maMethod;
         tech.stocPrice=i7b_stocPrice;
         tech.barDelay=i7b_barDelay;
         createTechnicalObject();
      }

   #endif

      // ----------------------------------------------------------------
   #ifdef _USE_OSMA //i8a
      //if (StringFind("i8a_",tech.inputPrefix,0)!=-1) {
      if (iuseOSMA_A) {
         tech.indicatorName="OSMA";
         tech.period=i8a_period;
         tech.slowMovingAverage=i8a_slowMovingAverage;
         tech.fastMovingAverage=i8a_fastMovingAverage;
         tech.signalPeriod=i8a_signalPeriod;
         tech.appliedPrice=i8a_appliedPrice;
         tech.barDelay=i8a_barDelay;
         createTechnicalObject();
      }
      //if (StringFind("i8b_",tech.inputPrefix,0)!=-1) {
      if (iuseOSMA_B) {
         tech.indicatorName="OSMA";
         tech.period=i8b_period;
         tech.slowMovingAverage=i8b_slowMovingAverage;
         tech.fastMovingAverage=i8b_fastMovingAverage;
         tech.signalPeriod=i8b_signalPeriod;
         tech.appliedPrice=i8b_appliedPrice;
         tech.barDelay=i8b_barDelay;
         createTechnicalObject();
      }

   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MACD //i9a
   //if (StringFind("i9a_",tech.inputPrefix,0)!=-1) {
   if (iuseMACD_A) {
      tech.indicatorName="MACD";
      tech.period=i9a_period;
      tech.slowMovingAverage=i9a_slowMovingAverage;
      tech.fastMovingAverage=i9a_fastMovingAverage;
      tech.signalPeriod=i9a_signalPeriod;
      tech.appliedPrice=i9a_appliedPrice;
      tech.barDelay=i9a_barDelay;
      createTechnicalObject();
   }
   //if (StringFind("i9b_",tech.inputPrefix,0)!=-1) {
   if (iuseMACD_B) {
      tech.indicatorName="MACD";
      tech.period=i9b_period;
      tech.slowMovingAverage=i9b_slowMovingAverage;
      tech.fastMovingAverage=i9b_fastMovingAverage;
      tech.signalPeriod=i9b_signalPeriod;
      tech.appliedPrice=i9b_appliedPrice;
      tech.barDelay=i9b_barDelay;
      createTechnicalObject();
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_MACDJB //i10a
   //if (StringFind("i10a_",tech.inputPrefix,0)!=-1) {
   if (iuseMACDJB_A) {
      tech.indicatorName="MACDJB";
      tech.period=i10a_period;
      tech.slowMovingAverage=i10a_slowMovingAverage;
      tech.fastMovingAverage=i10a_fastMovingAverage;
      tech.signalPeriod=i10a_signalPeriod;
      tech.barDelay=i10a_barDelay;
      createTechnicalObject();
   }
   //if (StringFind("i10b_",tech.inputPrefix,0)!=-1) {
   if (iuseMACDJB_B) {
      tech.indicatorName="MACDJB";
      tech.period=i10b_period;
      tech.slowMovingAverage=i10b_slowMovingAverage;
      tech.fastMovingAverage=i10b_fastMovingAverage;
      tech.signalPeriod=i10b_signalPeriod;
      tech.barDelay=i10b_barDelay;
      createTechnicalObject();
   }
   #endif

   // ----------------------------------------------------------------
   #ifdef _USE_ZIGZAG

   //if (StringFind("i100a_",tech.inputPrefix,0)!=-1) {
   if (iuseZZ_A) {
      tech.indicatorName="ZIGZAG";
      tech.period=i100a_ZZperiod;
      tech.ttl=i100a_ZZttl;
      tech.lowerLevel=i100a_ZZReversal;
      tech.upperLevel=i100a_ZZLevels;
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss=StringFormat("EATechnicalParameters -> copyValuesFromOptimizationInputs -> Period:%d",tech.period);
         writeLog
      #endif
      createTechnicalObject();
   }

   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalParameters::createTechnicalObject() {

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
         ss=StringFormat("EATechnicalParameters -> createTechnicalObject -> SUCCESS createTechnicalObject -> %s ",tech.indicatorName);
         writeLog
         pss
      #endif 

      // Update the DB with the single run values if in TESTER MODE
      if (!MQLInfoInteger(MQL_OPTIMIZATION) && MQLInfoInteger(MQL_TESTER)) {
         #ifdef _DEBUG_TECHNICAL_PARAMETERS
            ss= StringFormat("EATechnicalParameters -> createTechnicalObject -> (MQL_TESTER) calling setValues for:%s", tech.indicatorName);
            pss
            writeLog
         #endif 
         i.setValues();
      }
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EATechnicalParameters::getValues() {

   // Start with a blank slate on every bar we clear the nn arrays
   nnIn.Clear(); nnOut.Clear(); nnHeadings.Clear();

   //================================
   if (_systemState==_STATE_NORMAL) {
   //================================
      #ifdef _DEBUG_TECHNICAL_PARAMETERS_RUN_LOOP
         pline
         ss="EATechnicalParameters -> getValues(_STATE_NORMAL) START ";
         writeLog
         ss=StringFormat("EATechnicalParameters -> TIME:%s",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES));
         writeLog
      #endif

      double prediction[2];

      for (int i=0;i<indicators.Total();i++) {
         EATechnicalsBase *indicator=indicators.At(i);
         if (!indicator.getValues(nnIn, nnOut, TimeCurrent(), nnHeadings)) {
            #ifdef _DEBUG_TECHNICAL_PARAMETERS_RUN_LOOP
               ss=StringFormat("EATechnicalParameters -> getValues(_STATE_NORMAL) Indicator returned a EMPTY VALUE at time:%s",TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES));
               writeLog
            #endif
            return _NO_ACTION;
         }
      }

      if (nn.networkForcast(nnIn, nnOut, prediction, nnHeadings)==_OPEN_NEW_POSITION) {
         #ifdef _DEBUG_TECHNICAL_PARAMETERS_RUN_LOOP
            ss="EATechnicalParameters -> getValues(_STATE_NORMAL) Received a _OPEN_NEW_POSITION";
            writeLog
         #endif
         return _OPEN_NEW_POSITION;
      }

      #ifdef _DEBUG_TECHNICAL_PARAMETERS_RUN_LOOP
         ss="EATechnicalParameters -> getValues(_STATE_NORMAL) END";
         writeLog
      #endif

      return _NO_ACTION;
   }

   //================================
   if (_systemState==_STATE_BUILD_DATAFRAME || _systemState== _STATE_REBUILD_NETWORK) {
   //================================
      // Loop through all object and get the object to return the value as a input to the NN
      #ifdef _DEBUG_NN_DATAFRAME
         ss="EATechnicalParameters -> getValues(_STATE_BUILD_DATAFRAME OR _DEBUG_NN_DATAFRAME)";
         writeLog
      #endif

      for (int i=0;i<indicators.Total();i++) {
         EATechnicalsBase *indicator=indicators.At(i);
         if (!indicator.getValues(nnIn, nnOut, TimeCurrent(), nnHeadings)) {
            #ifdef _DEBUG_NN_DATAFRAME
               ss=StringFormat("EATechnicalParameters -> getValues Indicator returned a EMPTY VALUE at time:%s",TimeCurrent());
               writeLog
            #endif
            return _NO_ACTION;
         }
      }
      nn.buildDataFrame(nnIn,nnOut,nnHeadings);                  // Add to DF which will the be used in training

      #ifdef _DEBUG_NN_DATAFRAME
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

   return _NO_ACTION;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EATechnicalParameters::execute(EAEnum action) {


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

