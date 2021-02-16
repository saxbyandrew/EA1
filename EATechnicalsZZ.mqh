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
   int   handle;

   double   buffer0[];
   double   buffer1[];
   double   buffer2[];
   double   buffer3[];

//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsZZ(Technicals &t);
   ~EATechnicalsZZ();

   bool  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime, CArrayString &nnHeadings); 
   void  setValues();   

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsZZ::EATechnicalsZZ(Technicals &t) {

   int bars;

   EATechnicalsBase::copyValues(t);

   if (handle==NULL) 
      handle=iCustom(_Symbol,tech.period,"deltazigzag",0,0,500,0.5,1);

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

   EATechnicalsBase::updateValuesToDatabase(sql);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  EATechnicalsZZ::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {  

   int   barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME

   #ifdef _DEBUG_ZIGZAG
      ss=StringFormat("EATechnicalsZZ  -> using getValues(1) %s barNumber:%d Time:%s",tech.inputPrefix, barNumber,TimeToString(barDateTime,TIME_DATE|TIME_MINUTES)); 
      writeLog
      pss
      ss=StringFormat("EATechnicalsZZ -> barscalculated:%d ",BarsCalculated(handle));
      pss
      writeLog

   #endif

      static int    direction;
      static int    ttlCnt=0;

      // Descriptive heading for CSV file
      #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
         nnHeadings.Add("ZZ Direction,Prediction");
      #endif


      if (CopyBuffer(handle,0,barDateTime,1,buffer0)==-1 ||
         CopyBuffer(handle,1,barDateTime,1,buffer1)==-1 ||
         CopyBuffer(handle,2,barDateTime,1,buffer2)==-1 ||
         CopyBuffer(handle,3,barDateTime,1,buffer3)==-1) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(1) -> copybuffer error";
            pss
            writeLog
         #endif
         return false;
      }

      if (buffer0[0]==EMPTY_VALUE || buffer1[0]==EMPTY_VALUE || buffer2[0]==EMPTY_VALUE || buffer3[0]==EMPTY_VALUE) {
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
            ss=StringFormat("EATechnicalsZZ -> getValues(2) countdown:%d of %d",ttlCnt,tech.ttl);
            pss
            writeLog
         #endif
         nnOutputs.Add(direction);

         return true;
      } 

      if (buffer0[0]>0) {
         ttlCnt=tech.ttl;
         direction= (int) _DOWN;
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(3) -> buffer0 -> DOWN";
            pss
            writeLog
         #endif
      }

      if (buffer1[0]>0) {
         ttlCnt=tech.ttl;
         direction= (int) _UP;
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(4) -> buffer1 -> UP";
            pss
            writeLog
         #endif
      }

      if (direction==_DOWN) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(5) -> DOWN";
            pss
            writeLog
         #endif
      }

      if (direction==_UP) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(6) -> UP";
            pss
            writeLog
         #endif
      }

      if (buffer2[0]>0) {

         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(7) -> buffer2 -> > 0";
            pss
            writeLog
         #endif
      }

      if (buffer3[0]>0) {
         #ifdef _DEBUG_ZIGZAG
            ss="EATechnicalsZZ -> getValues(8) -> buffer3 -> > 0";
            pss
            writeLog
         #endif
      }

      nnOutputs.Add(direction);

      return true;

}

