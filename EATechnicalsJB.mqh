//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"

#include <Indicators\Oscilators.mqh>

//=========
class EATechnicalsJB : public EATechnicalsBase {
//=========

//=========
private:

   int         MACDPlatinumHandle, QQEHandle, QMPHandle;
   string      ss;
   CiMACD      macd;  


//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsJB(Technicals &tech);
   ~EATechnicalsJB();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsJB::EATechnicalsJB(Technicals &tech) {

   /*
   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB -> .... Default Constructor";
      pss
      writeLog
   #endif
   */

   // Set the local instance struct variables
   EATechnicalsBase::copyValues(tech);

   if (MACDPlatinumHandle==NULL) {
      MACDPlatinumHandle=iCustom(_Symbol,period,"MACD_Platinum",tech.fastMovingAverage,tech.slowMovingAverage,tech.signalPeriod,true,true,false,false);

      #ifdef _DEBUG_MACDJB_MODULE
            ss="EATechnicalsJB -> EATechnicalsJB MACD -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 

   if (QQEHandle==NULL) {
      QQEHandle=iCustom(_Symbol,PERIOD_CURRENT,"QQE Adv",1,8,3);

      #ifdef _DEBUG_MACDJB_MODULE
         ss="EATechnicalsJB -> EATechnicalsJB QQE -> ERROR";
         pss
         writeLog
         ExpertRemove();
      #endif
   }

   if (QMPHandle==NULL) {
      QMPHandle=iCustom(_Symbol,period,"QMP Filter",0,tech.fastMovingAverage,tech.slowMovingAverage,tech.signalPeriod,true,1,8,3,false,false);

      #ifdef _DEBUG_MACDJB_MODULE
         ss="EATechnicalsJB -> EATechnicalsJB QMP -> ERROR";
         pss
         writeLog
         ExpertRemove();
      #endif
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsJB::~EATechnicalsJB() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsJB::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   /*
   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB -> getValues -> Entry 2....";
      pss
      writeLog
   #endif 
   */

   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   main[1], signal[1];

   // Refresh the indicator and get all the buffers
   macd.Refresh(-1);

   if (macd.GetData(barDateTime,1,0,main)>0 && macd.GetData(barDateTime,1,0,signal)>0) {
      #ifdef _DEBUG_MACDJB_MODULE
         ss=StringFormat("EATechnicalsJB -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsJB -> getValues -> SIGNAL:%.5f",signal[0]);        
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(signal[0]);
      //if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_MACDJB_MODULE
         ss="EATechnicalsJB -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsJB::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   /*
   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB -> getValues -> Entry 1....";
      pss
      writeLog
   #endif 
   */

   double main[1], signal[1];

   // Refresh the indicator and get all the buffers
   macd.Refresh(-1);

   if (macd.GetData(1,1,0,main)>0 && macd.GetData(1,1,0,signal)>0) {
      #ifdef _DEBUG_MACDJB_MODULE
         ss=StringFormat("EATechnicalsJB -> getValues -> MAIN:%.2f",main[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsJB -> getValues -> SIGNAL:%.5f",signal[0]);        
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(signal[0]);
      //if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(??);

   } else {
      #ifdef _DEBUG_MACDJB_MODULE
         ss="EATechnicalsJB -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);

   }



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsJB::MACDPlatinumBullish(int ttl, double factor) {

   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB ->  MACDPlatinumBearish";
      writeLog
      pss
   #endif

   static double MACDBuffer[];
   static int ttlCnt=0;
   double weight=1;
   

   ArraySetAsSeries(MACDBuffer,true);
   CopyBuffer(MACDPlatinumHandle,2,0,1,MACDBuffer);

   // Allow  time to live
   if (ttlCnt>0) {
      weight=(ttlCnt-factor)/tech.ttl;
      ttlCnt--;
      #ifdef _DEBUG_MACDPLAT_BULLISH
         printf("_DEBUG_MACDPLAT_BULLISH countdown:%d weight:%1.2f",ttlCnt,weight);
      #endif
      return weight;
   } 

   if (MACDBuffer[1]!=EMPTY_VALUE) {
      ttlCnt=tech.ttl;
      return 1;
   }

   return 0;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsJB::MACDPlatinumBearish(int ttl, double factor) {

   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB ->  MACDPlatinumBearish";
      writeLog
      pss
   #endif

   static double MACDBuffer[];
   static int ttlCnt=0;
   double weight=1;

   
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
double EAModuleTechnicals::QQEFilterSlow(int ttl, double factor) {

   #ifdef _DEBUG_MACDJB_MODULE
      ss="EAModuleTechnicals ->  QQEFilterSlow";
      writeLog
      pss
   #endif 

   static double QQEBuffer[];
   static int ttlCnt=0;
   double weight=1;

   ArraySetAsSeries(QQEBuffer,true);
   CopyBuffer(QQEHandle, 1, 0, lookBackBuffersSize, QQEBuffer);

   // Allow divergence time to live
   if (ttlCnt>0) {
      weight=(ttlCnt-factor)/ttl;
      ttlCnt--;
      #ifdef _DEBUG_MACDJB_MODULE
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

   #ifdef _DEBUG_MACDJB_MODULE
      ss="EAModuleTechnicals ->  QQEFilterRSIMA";
      writeLog
      pss
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
      #ifdef _DEBUG_MACDJB_MODULE
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

// Does not work with optimization 

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
