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
   double      main[], signal[], bullish[], bearish[];
   string      ss;

   double      getValues(int bufferNumber);


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

   
   MACDPlatinumHandle=iCustom(_Symbol,tech.period,"MACD_Platinum",tech.fastMovingAverage,tech.slowMovingAverage,tech.signalPeriod,true,true,false,false);
   if (MACDPlatinumHandle==NULL) {
   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB -> EATechnicalsJB MACD -> ERROR";
      pss
      writeLog
      ExpertRemove();
   #endif
   } 

   QQEHandle=iCustom(_Symbol,PERIOD_CURRENT,"QQE Adv",1,8,3);
   if (QQEHandle==NULL) {
   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB -> EATechnicalsJB QQE -> ERROR";
      pss
      writeLog
      ExpertRemove();
   #endif
   }

   QMPHandle=iCustom(_Symbol,tech.period,"QMP Filter",0,tech.fastMovingAverage,tech.slowMovingAverage,tech.signalPeriod,true,1,8,3,false,false);
   if (QMPHandle==NULL) {
   #ifdef _DEBUG_MACDJB_MODULE
      ss="EATechnicalsJB -> EATechnicalsJB QMP -> ERROR";
      pss
      writeLog
      ExpertRemove();
   #endif
   }

   ArraySetAsSeries(main,true);
   ArraySetAsSeries(signal,true);
   ArraySetAsSeries(bullish,true);
   ArraySetAsSeries(bearish,true);
   CopyBuffer(MACDPlatinumHandle,0,0,501,main);
   CopyBuffer(MACDPlatinumHandle,1,0,501,signal);
   CopyBuffer(MACDPlatinumHandle,2,0,501,bullish);
   CopyBuffer(MACDPlatinumHandle,3,0,501,bearish);

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


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsJB::getValues(int bufferNumber) {

   double buffer[];

   

   if (buffer[0]==EMPTY_VALUE) {
      #ifdef _DEBUG_MACDJB_MODULE
         ss=StringFormat("EATechnicalsJB -> getValues -> Buffer Number :%d EMPTY VALUE",bufferNumber);
         writeLog
      #endif
      return -1;
   }

   #ifdef _DEBUG_MACDJB_MODULE
      ss=StringFormat("EATechnicalsJB -> getValues -> Buffer Number :%d Value:%.5f",bufferNumber,buffer[0]);
      writeLog
   #endif

   return buffer[0];


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsJB::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {



   if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(main[0]);
   if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(signal[0]);

/*

      if (bool (tech.useBuffers&_BUFFER1)) {
         if (ttlCntBullish>0) {
            weightBullish=(ttlCntBullish-tech.incDecFactor)/tech.ttl;
            ttlCntBullish--;
            #ifdef _DEBUG_MACDJB_MODULE
               ss=StringFormat("EATechnicalsJB -> getValues -> Countdown -> BULLISH :%d weight:%1.2f",ttlCntBullish,weightBullish);
               writeLog
            #endif
            nnInputs.Add(weightBullish);
         } else {

            ttlCntBullish=tech.ttl;
            if (bullish[1]!=EMPTY_VALUE) {
               nnInputs.Add(1);
               #ifdef _DEBUG_MACDJB_MODULE
                  ss=StringFormat("EATechnicalsJB -> getValues -> BULLISH :%d",1);
                  writeLog
               #endif
            } else {
               nnInputs.Add(0);
               #ifdef _DEBUG_MACDJB_MODULE
                  ss=StringFormat("EATechnicalsJB -> getValues -> BULLISH EMPTY VALUE:%d",0);
                  writeLog
               #endif
            }
         }
      }

      if (bool (tech.useBuffers&_BUFFER2)) {
         if (ttlCntBearish>0) {
            weightBearish=(ttlCntBearish-tech.incDecFactor)/tech.ttl;
            ttlCntBearish--;
            #ifdef _DEBUG_MACDJB_MODULE
               ss=StringFormat("EATechnicalsJB -> getValues -> Countdown -> BEARISH :%d weight:%1.2f",ttlCntBearish,weightBullish);
               writeLog
            #endif
            nnInputs.Add(weightBearish);

         } else {

            ttlCntBearish=tech.ttl;
            if (bearish[1]!=EMPTY_VALUE) {
               nnInputs.Add(2);
               #ifdef _DEBUG_MACDJB_MODULE
                  ss=StringFormat("EATechnicalsJB -> getValues -> BEARISH :%d",2);
                  writeLog
               #endif
            } else {
               nnInputs.Add(0);
               #ifdef _DEBUG_MACDJB_MODULE
                  ss=StringFormat("EATechnicalsJB -> getValues -> BEARISH EMPTY VALUE :%d",0);
                  writeLog
               #endif
            }
         }
      }
      */
}
/*
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
*/

/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsJB::QQEFilterSlow(int ttl, double factor) {

   #ifdef _DEBUG_MACDJB_MODULE
      ss="EAModuleTechnicals ->  QQEFilterSlow";
      writeLog
      pss
   #endif 

   static double QQEBufferRSI[1];
   static int ttlCnt=0;
   double weight=1;

   ArraySetAsSeries(QQEBufferRSI,true);
   CopyBuffer(QQEHandle, 1, 0, lookBackBuffersSize, QQEBufferRSI);

   // Allow divergence time to live
   if (ttlCnt>0) {
      weight=(ttlCnt-factor)/ttl;
      ttlCnt--;
      #ifdef _DEBUG_MACDJB_MODULE
         printf("QQE slow countdown:%d weight:%1.2f",ttlCnt,weight);
      #endif
      return weight;
   } 

   if (QQEBufferRSI[1]!=EMPTY_VALUE) {
      printf("QQE slow buffer:%2.2f",QQEBufferRSI[1]);
      ttlCnt=ttl;
      return 1;
   }

   return 0;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EATechnicalsJB::QQEFilterRSIMA(int ttl, double factor) {

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
double EATechnicalsJB::QMPFilterBullish(int ttl, double factor) {

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
double EATechnicalsJB::QMPFilterBearish(int ttl, double factor) {

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
