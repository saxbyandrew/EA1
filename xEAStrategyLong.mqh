//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>

#include "EAEnum.mqh"
#include "EAPositionsLong.mqh"
#include "EATechnicalParameters.mqh"

class EAStrategyLong : public CObject {

//=========
private:
//=========
   string ss;

//=========
protected:
//=========
   EATechnicalParameters   *tech;
   EAPositionsLong         *pLong;

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

   #ifdef _DEBUG_LONG_STRATEGY
      ss=StringFormat("EAStrategyLong -> DEFAULT CONSTRUCTOR -> strategyNumber:%d",strategyNumber);
      writeLog
      pss
   #endif

   // Create the new Technincals object(s) which in this case is the actual strategy run based on 
   // technical triggers
   tech=new EATechnicalParameters(strategyNumber); // Using the base ref as this is the main strategy
   if (CheckPointer(tech)==POINTER_INVALID) {
      #ifdef _DEBUG_LONG_STRATEGY
         ss="EAStrategyLong -> ERROR created technical object";
         writeLog
         pss
      #endif
      ExpertRemove();
   } else {
      #ifdef _DEBUG_LONG_STRATEGY
         ss="EAStrategyLong -> SUCCESS created technical object";
         writeLog
         pss
      #endif
   }

   pLong=new EAPositionsLong(strategyNumber); 
   if (CheckPointer(pLong)==POINTER_INVALID) {
      #ifdef _DEBUG_LONG_STRATEGY
         ss="EAStrategyLong -> ERROR created LONG POSITION object";
         writeLog
         pss
      #endif
      ExpertRemove();
   } else {
      #ifdef _DEBUG_LONG_STRATEGY
      ss="EAStrategyLong -> SUCCESS created LONG POSITION object";
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
   delete pLong;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::execute(EAEnum action) {

   // entry is here from the main run loop void OnTick() 
   switch (action) {
      case _RUN_ONTICK: runOnTick(); 
      break;
      case _RUN_ONBAR:  runOnBar();  
      break;
      case _RUN_ONDAY:  runOnBar(); 
      break;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::runOnTick() {

   // Managment of positions and lists ONTICK, SL TP etc
   pLong.execute(_RUN_ONTICK);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::runOnBar() {
   #ifdef _DEBUG_LONG_STRATEGY
      ss="EAStrategyLong -> runOnBar ";
      writeLog
      pss
   #endif

   // Managment of positions and lists ONBAR, SL TP etc
   pLong.execute(_RUN_ONBAR); 

   // Run the actual strategy 
   if (tech.execute(_RUN_ONBAR)==_OPEN_NEW_POSITION) {
      pLong.execute(_OPEN_LONG);
      #ifdef _DEBUG_LONG_STRATEGY
            ss="EAStrategyLong -> runOnBar -> received _OPEN_NEW_POSITION";
            writeLog
            pss
      #endif
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyLong::runOnDay() {

   // Managment of positions and lists ONDAY, SL TP etc
   pLong.execute(_RUN_ONDAY); 

}

