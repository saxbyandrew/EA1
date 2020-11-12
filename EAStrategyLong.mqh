//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EAEnum.mqh"
#include "EAPositionLong.mqh"
#include "EATechnicalParameters.mqh"

//=========
class EAStrategyLong : public EAPositionLong {
//=========


//=========
private:
//=========
   string ss;


//=========
protected:
//=========
   EATechnicalParameters   *tech;

   void runOnTick();
   void runOnBar();
   void runOnDay();

//=========
public:
//=========
EAStrategyLong(int strategyNumber);
~EAStrategyLong();

   virtual void   execute(EAEnum action);


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyLong::EAStrategyLong(int strategyNumber) {

   #ifdef _DEBUG_LONG
      ss=StringFormat("EAStrategyLong -> default constructor .... %d",strategyNumber);
      writeLog
      pss
   #endif

   // Create the new Technincals object(s)
   tech=new EATechnicalParameters(strategyNumber); // Using the base ref as this is the main strategy
   if (CheckPointer(tech)==POINTER_INVALID) {
      ss="EAStrategyLong -> ERROR created technical object";
         #ifdef _DEBUG_LONG
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      ss="EAStrategyLong -> SUCCESS created technical object";
      #ifdef _DEBUG_LONG
         writeLog
         pss
      #endif
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyLong::~EAStrategyLong() {

   delete tech;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::runOnTick() {
      #ifdef _DEBUG_LONG
      ss="runOnTick -> EAStrategyLong....";
      writeLog
      pss
   #endif

   // Managment of positions and lists on tick, SL TP etc
   EAPositionLong::execute(_RUN_ONTICK);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::runOnBar() {
   
   #ifdef _DEBUG_LONG
      ss="EAStrategyLong -> runOnBar ....";
      writeLog
      pss
   #endif

   if (tech.execute(_RUN_ONBAR)==_OPEN_NEW_POSITION) {
      #ifdef _DEBUG_LONG
         ss="EAStrategyLong -> runOnBar -> received _OPEN_NEW_POSITION";
         writeLog
         pss
      #endif
      EAPositionLong::execute(_OPEN_LONG);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::runOnDay() {
      #ifdef _DEBUG_LONG
      ss="runOnDay -> EAStrategyLong....";
      writeLog
      pss
   #endif

   // Managment of positions and lists on day, SL TP etc
   EAPositionLong::execute(_RUN_ONDAY); 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::execute(EAEnum action) {

   // entry is here from the main run loop void OnTick() 

   #ifdef _DEBUG_LONG
      if (action!=(int) _RUN_ONTICK) {
         ss=StringFormat("EAStrategyLong -> execute %d",action);
         writeLog
         pss
      }
   #endif

   switch (action) {
      //case _RUN_ONTICK: runOnTick(); 
      //break;
      case _RUN_ONBAR:  runOnBar();  
      break;
      case _RUN_ONDAY:  runOnBar(); 
      break;
   }

}