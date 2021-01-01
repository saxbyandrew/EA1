//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"


//=========
class EATechnicalsZZ : public EATechnicalsBase {
//=========

//=========
private:
   string   ss;
   int   ZIGZAGHandle;

//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsZZ(Technicals &t);
   ~EATechnicalsZZ();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);   
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime); 
   void  setValues();   

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsZZ::EATechnicalsZZ(Technicals &t) {

   int bars;
   /*
   #ifdef _DEBUG_ZIGZAG
      ss="EATechnicalsZZ -> .... default constructor";
      pss
      writeLog
   #endif
   */

   // Set the local instance struct variables
   EATechnicalsBase::copyValues(t);

   if (ZIGZAGHandle==NULL) 
      ZIGZAGHandle=iCustom(_Symbol,tech.period,"deltazigzag",0,0,500,0.5,1);

   bars=Bars(_Symbol,tech.period);

   #ifdef _DEBUG_ZIGZAG
      ss=StringFormat("EATechnicalsZZ -> bars in terminal history:%d for period:%s",bars,EnumToString(tech.period));
      pss
      writeLog
   #endif

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsZZ::~EATechnicalsZZ() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsZZ::setValues() {

   string sql;

   tech.versionNumber++;

   sql=StringFormat("UPDATE TECHNICALS SET period=%d, ENUM_TIMEFRAMES='%s', versionNumber=%d "
      "WHERE strategyNumber=%d AND inputPrefix='%s'",
      tech.period, EnumToString(tech.period), tech.versionNumber, tech.strategyNumber,tech.inputPrefix);

   #ifdef _DEBUG_BASE
      ss="EATechnicalsZZ -> UPDATE INTO TECHNICALS";
      pss
      writeLog
      ss=sql;
      pss
      writeLog
   #endif

   EATechnicalsBase::updateValuesToDatabase(sql);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsZZ::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   int   barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME

   #ifdef _DEBUG_ZIGZAG
      ss=StringFormat("EATechnicalsZZ  -> using getValues(1) %s barNumber:%d Time:%s",tech.inputPrefix, barNumber,TimeToString(barDateTime,TIME_DATE|TIME_MINUTES)); 
      writeLog
      pss
      ss=StringFormat("EATechnicalsZZ -> barscalculated:%d ",BarsCalculated(ZIGZAGHandle));
      pss
      writeLog

   #endif

      static double ZIGZAGBuffer0[];
      static double ZIGZAGBuffer1[];
      static double ZIGZAGBuffer2[];
      static double ZIGZAGBuffer3[];
      static int    direction;
      static int    ttlCnt=0;

      ArraySetAsSeries(ZIGZAGBuffer0,true);
      ArraySetAsSeries(ZIGZAGBuffer1,true);
      ArraySetAsSeries(ZIGZAGBuffer2,true);
      ArraySetAsSeries(ZIGZAGBuffer3,true);

      CopyBuffer(ZIGZAGHandle,0,barDateTime,1,ZIGZAGBuffer0);
      CopyBuffer(ZIGZAGHandle,1,barDateTime,1,ZIGZAGBuffer1);
      CopyBuffer(ZIGZAGHandle,2,barDateTime,1,ZIGZAGBuffer2);
      CopyBuffer(ZIGZAGHandle,3,barDateTime,1,ZIGZAGBuffer3);

      if (ZIGZAGBuffer0[0]==EMPTY_VALUE || ZIGZAGBuffer1[0]==EMPTY_VALUE || ZIGZAGBuffer2[0]==EMPTY_VALUE || ZIGZAGBuffer3[0]==EMPTY_VALUE) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> EMPTY_VALUE";
            pss
            writeLog
         #endif

      }

      // Allow indicator time to live
      if (ttlCnt>0) {
         ttlCnt--;
         #ifdef _DEBUG_ZIGZAG
            ss=StringFormat("EATechnicalsZZ -> getValues countdown:%d ",ttlCnt);
            pss
            writeLog
         #endif
         nnOutputs.Add(direction);
         return;
      } 

      if (ZIGZAGBuffer0[0]>0) {
         ttlCnt=tech.ttl;
         direction= (int) _DOWN;
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> ZIGZAGBuffer0 -> DOWN";
            pss
            writeLog
         #endif
      }

      if (ZIGZAGBuffer1[0]>0) {
         ttlCnt=tech.ttl;
         direction= (int) _UP;
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> ZIGZAGBuffer1 -> UP";
            pss
            writeLog
         #endif
      }

      if (direction==_DOWN) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> DOWN";
            pss
            writeLog
         #endif
      }

      if (direction==_UP) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> UP";
            pss
            writeLog
         #endif
      }

      if (ZIGZAGBuffer2[0]>0) {

         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> ZIGZAGBuffer2 -> > 0";
            pss
            writeLog
         #endif
      }

      if (ZIGZAGBuffer3[0]>0) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> ZIGZAGBuffer3 -> > 0";
            pss
            writeLog
         #endif
      }

      nnOutputs.Add(direction);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsZZ::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {

   /*
   #ifdef _DEBUG_ZIGZAG
      ss="EATechnicalsZZ -> getValues 1 -> ....";
      pss
      writeLog
   #endif 
   */

      static double ZIGZAGBuffer0[];
      static double ZIGZAGBuffer1[];
      static int direction;
      static int ttlCnt=0;

      ArraySetAsSeries(ZIGZAGBuffer0,true);
      ArraySetAsSeries(ZIGZAGBuffer1,true);

      CopyBuffer(ZIGZAGHandle,0,0,1,ZIGZAGBuffer0);
      CopyBuffer(ZIGZAGHandle,1,0,1,ZIGZAGBuffer1);

      // Allow indicator time to live
      if (ttlCnt>0) {
         ttlCnt--;
         #ifdef _DEBUG_ZIGZAG
            ss=StringFormat("EATechnicalsZZ -> getValues ->countdown:%d ",ttlCnt);
            pss
            writeLog
         #endif
         nnOutputs.Add(direction);
         return;
      } 

      if (ZIGZAGBuffer0[0]>0) {
         ttlCnt=tech.ttl;
         direction= (int) _DOWN;
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> DOWN";
            pss
            writeLog
         #endif
      }

      if (ZIGZAGBuffer1[0]>0) {
         ttlCnt=tech.ttl;
         direction= (int) _UP;
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> UP";
            pss
            writeLog
         #endif
      }

      if (direction==_DOWN) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> DOWN";
            pss
            writeLog
         #endif
      }

      if (direction==_UP) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues -> UP";
            pss
            writeLog
         #endif
      }

      nnOutputs.Add(direction);

}
