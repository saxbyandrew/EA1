//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_STRATEGY_BASE

#include <Object.mqh>

#include "EAEnum.mqh"



class EAStrategyBase : public CObject{

//=========
private:
//=========
  void                 triggerVerticalLine(color clr, datetime t);
  int                  fileHandle;
  void                 openCSVFile(string fn);
  void                 readCSVFile();
  void                 writeCSVFile(string data);
  void                 closeCSVFile();
  void                 flushCSVFile();


//=========
protected:
//=========

  EAEnum    triggers[10];


//=========

  EAEnum    resetTriggers();
  void      resetTriggers(EAEnum action);  


//=========
public:
//=========
  EAStrategyBase();
  ~EAStrategyBase();

  virtual int Type() const {return _STRATEGY_BASE;};

  virtual EAEnum runOnBar() {return false;};
  virtual EAEnum runOnTimer() {return false;};

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyBase::EAStrategyBase() {


  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyBase::~EAStrategyBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void EAStrategyBase::openCSVFile(string fn) {

  fileHandle=FileOpen(fn,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,",");  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyBase::readCSVFile() {


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyBase::writeCSVFile(string data) {

  FileWrite(fileHandle,data);
  FileFlush(fileHandle);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyBase::closeCSVFile() {

  FileClose(fileHandle);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyBase::flushCSVFile() {

  FileFlush(fileHandle);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyBase::triggerVerticalLine(color clr, datetime t) {

    #ifdef _DEBUG_MACD_MODULE
        Print(__FUNCTION__);
    #endif  

    static   int cnt=0;
    string   objName;

    // Clear up the chart    
    if (cnt>=10) {
        cnt=0; 
        ObjectsDeleteAll(0,"VL",-1,-1);
    } else {
        ++cnt;
    }  

    if (ObjectFind(0,objName) == -1) {  
        StringConcatenate(objName,"VL",cnt);
        if (ObjectCreate(0,objName, OBJ_VLINE, 0, t, 0)) {
            ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
            ObjectSetInteger(0,objName,OBJPROP_STYLE,STYLE_DASH);
        } 
    } 
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyBase::resetTriggers(EAEnum action) {

  #ifdef _DEBUG_EABASE 
    Print(__FUNCTION__); 
  #endif  

  static int barCnt=0;

   // Determine which type of reset we are looking to check
   if (action==_DO_CHECKS) action=usp.triggerReset; // 

  switch (action) {
      case _NEW_POSITION: 
        #ifdef _DEBUG_STRATEGY_BASE
          Print(" -> Reset Triggers initiated by new position open trigger");
        #endif 
        resetTriggers();
      break;
      case _RUN_ONDAY: 
        #ifdef _DEBUG_STRATEGY_BASE
          Print(" -> Reset Triggers _DAILY");
        #endif
        // TODO SOME ACTION IS NEEDED
      break;
      case _RUN_ONBAR:
        if (barCnt>=usp.triggerResetCounter) {
          barCnt=0;
          #ifdef _DEBUG_STRATEGY_BASE
            Print(" -> Reset Triggers _BARS");
          #endif
          resetTriggers();
        } else {
          barCnt++;
        }        
      }
}  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategyBase::resetTriggers() {

  #ifdef _DEBUG_STRATEGY_BASE 
    Print(__FUNCTION__); 
  #endif  

  // Clear the trigger array for the next loop
  ArrayFill(triggers,0,ArraySize(triggers),_NOTSET);   
  // Reset the count down for a reentry 
  triggers[_BARS_BEFORE_REENTRY]=usp.entryBars; 

  #ifdef _DEBUG_STRATEGY_LOOP 
    ArrayPrint(triggers); 
  #endif  
  return _NO_ACTION;
}
