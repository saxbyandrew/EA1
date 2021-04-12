//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"
#include "EAStructures.mqh"
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayString.mqh>

class EANeuralNetwork;

//=========
class EATechnicalsBase : public CObject {
//=========

//=========
private:
//=========

   string ss;
   string VToString(double v);
   string VToString(int v);
   string VToString(string v);
   void csvInformation(); 
   

//=========
protected:
//=========

   Technicals tech;     // See EAStructures.mqh
   void     updateValuesToDatabase(string sql);
   int      countBuffersUsed();

//=========
public:
//=========
   EATechnicalsBase();
   ~EATechnicalsBase();

   void     copyValues(Technicals &tt);

   
   virtual void setValues() {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {};
   virtual void getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, int barNumber) {};
   //virtual bool getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime) {return false;};
   virtual bool getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs, datetime barDateTime, CArrayString &nnHeadings) {return false;};
   virtual EAEnum execute(EAEnum action) {return _NO_ACTION;}; 

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsBase::EATechnicalsBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsBase::~EATechnicalsBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifdef _DEBUG_NN_FORCAST_WRITE_CSV

//+------------------------------------------------------------------+
string EATechnicalsBase::VToString(int v) {
   return IntegerToString(v)+",";
}
//+------------------------------------------------------------------+
string EATechnicalsBase::VToString(double v) {
   return DoubleToString(v)+",";
}
//+------------------------------------------------------------------+
string EATechnicalsBase::VToString(string v) {
   return v+",";
}
//+------------------------------------------------------------------+
void EATechnicalsBase::csvInformation() {

   if (!_csvHandle) {
      _csvHandle=FileOpen("indicators.csv",FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
      if (_csvHandle==INVALID_HANDLE) {
         ss="EATechnicalsBase -> csvInformation error failed to open file";
         writeLog
         return;
      }
      // Write the heading
      FileWrite(_csvHandle,"strategyNumber,indicatorName,instanceNumber,period,enumTimeFrames,movingAverage,slowMovingAverage,fastMovingAverage,movingAverageMethod,enumMAMethod,"
         "appliedPrice,enumAppliedPrice,stepValue,maxValue,signalPeriod,tenkanSen,kijunSen,spanB,kPeriod,dPeriod,"
         "stocPrice,enumStoPrice,appliedVolume,enumAppliedVolume,useBuffers,ttl,incDecFactor,inputPrefix,lowerLevel,upperLevel,barDelay,versionNumber");
      FileFlush(_csvHandle);
   }

      
      ss=VToString(tech.strategyNumber);
      ss=ss+VToString(tech.indicatorName);
      ss=ss+VToString(tech.instanceNumber);
      ss=ss+VToString((int)tech.period);
      ss=ss+VToString(tech.enumTimeFrames);
      ss=ss+VToString(tech.movingAverage);
      ss=ss+VToString(tech.slowMovingAverage);
      ss=ss+VToString(tech.fastMovingAverage);
      ss=ss+VToString((int)tech.movingAverageMethod);
      ss=ss+VToString(tech.enumMAMethod);
      ss=ss+VToString((int)tech.appliedPrice);
      ss=ss+VToString(tech.enumAppliedPrice);
      ss=ss+VToString(tech.stepValue);
      ss=ss+VToString(tech.maxValue);
      ss=ss+VToString(tech.signalPeriod);
      ss=ss+VToString(tech.tenkanSen);
      ss=ss+VToString(tech.kijunSen);
      ss=ss+VToString(tech.spanB);
      ss=ss+VToString(tech.kPeriod);
      ss=ss+VToString(tech.dPeriod);
      ss=ss+VToString((int)tech.stocPrice);
      ss=ss+VToString(tech.enumStoPrice); 
      ss=ss+VToString((int)tech.appliedVolume); 
      ss=ss+VToString(tech.enumAppliedVolume);    
      ss=ss+VToString(tech.useBuffers);
      ss=ss+VToString(tech.ttl);
      ss=ss+VToString(tech.incDecFactor);
      ss=ss+VToString(tech.inputPrefix);
      ss=ss+VToString(tech.lowerLevel);
      ss=ss+VToString(tech.upperLevel);
      ss=ss+VToString(tech.versionNumber);

      // Convert any special charaters
      for (int i=0;i<StringLen(ss);i++) {
         ushort c=StringGetCharacter(ss,i);
         if (c<13) {
            StringSetCharacter(ss,i,32);
         } 
      }

      FileWrite(_csvHandle,ss);
      FileFlush(_csvHandle);
      //FileClose(_csvHandle);

}
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsBase::copyValues(Technicals &t) {
      
   tech.strategyNumber=t.strategyNumber;
   tech.indicatorName=t.indicatorName;
   tech.instanceNumber=t.instanceNumber;
   tech.period=t.period;
   tech.enumTimeFrames=t.enumTimeFrames;
   tech.movingAverage=t.movingAverage;
   tech.slowMovingAverage=t.slowMovingAverage;
   tech.fastMovingAverage=t.fastMovingAverage;
   tech.movingAverageMethod=t.movingAverageMethod;
   tech.enumMAMethod=t.enumMAMethod;
   tech.appliedPrice=t.appliedPrice;
   tech.enumAppliedPrice=t.enumAppliedPrice;
   tech.stepValue=t.stepValue;
   tech.maxValue=t.maxValue;
   tech.signalPeriod=t.signalPeriod;
   tech.tenkanSen=t.tenkanSen;
   tech.kijunSen=t.kijunSen;
   tech.spanB=t.spanB;
   tech.kPeriod=t.kPeriod;
   tech.dPeriod=t.dPeriod;
   tech.stocPrice=t.stocPrice;
   tech.enumStoPrice=t.enumStoPrice;
   tech.appliedVolume=t.appliedVolume;
   tech.enumAppliedVolume=t.enumAppliedVolume;
   tech.useBuffers=t.useBuffers;
   tech.ttl=t.ttl;
   tech.inputPrefix=t.inputPrefix;
   tech.lowerLevel=t.lowerLevel;
   tech.upperLevel=t.upperLevel;
   tech.barDelay=t.barDelay;
   tech.versionNumber=t.versionNumber;

   #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
      ss="EATechnicalsBase -> copyValues -> writing CSV values";
      writeLog
      csvInformation();
   #endif

   #ifdef _DEBUG_OSMA_MODULE 
      ss=StringFormat("EATechnicalsBase -> copyValues -> fastMovingAverage:%d slowMovingAverage:%d signalPeriod appliedPrice:%d",t.fastMovingAverage,t.slowMovingAverage,t.signalPeriod,t.appliedPrice);
      writeLog
   #endif
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsBase::updateValuesToDatabase(string sql) {

   int request=DatabaseExecute(_mainDBHandle, sql);
   if (!request) {
      ss=StringFormat("EATechnicalsBase -> updateValuesToDatabase -> Failed to insert with code %d", GetLastError());
      writeLog
      ss=sql;
      writeLog

   } else {
      #ifdef _DEBUG_TECHNICAL_PARAMETERS
         ss="EATechnicalsBase -> updateValuesToDatabase -> UPDATE INTO TECHNICALS success";
         writeLog
         ss="   ----> "+sql;
         writeLog
      #endif
      DatabaseFinalize(request);
   }  

}



