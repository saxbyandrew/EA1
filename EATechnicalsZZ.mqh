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

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsZZ::EATechnicalsZZ(Technicals &t) {

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
      ZIGZAGHandle=iCustom(_Symbol,t.period,"deltazigzag",0,0,500,0.5,1);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsZZ::~EATechnicalsZZ() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsZZ::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   /*
   #ifdef _DEBUG_ZIGZAG
      ss="EATechnicalsZZ -> getValues 2 -> ....";
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

      CopyBuffer(ZIGZAGHandle,0,barDateTime,1,ZIGZAGBuffer0);
      CopyBuffer(ZIGZAGHandle,1,barDateTime,1,ZIGZAGBuffer1);

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
