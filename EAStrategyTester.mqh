//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_STRATGY_TESTER

#include "EAEnum.mqh"
#include "EAStrategyBase.mqh"
#include "EATimingBase.mqh"
//#include "EADNNOptimizationInputs.mqh"  // this not needed in this tester startegy just needed for compiler


class EAStrategyTester : public EAStrategyBase {

//=========
private:
//=========

protected:
//=========
   EATimingBase   t;
   void           updateOnTick();
   EAEnum         waitOnTriggers();

//=========
public:
//=========
   EAStrategyTester();
   ~EAStrategyTester();

   virtual int Type() const {return _STRATEGY;};


   EAEnum runOnBar();

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyTester::EAStrategyTester() {

   #ifdef _DEBUG_STRATGY_TESTER
      Print (__FUNCTION__," - > Init of Strategy");
   #endif  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyTester::~EAStrategyTester() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyTester::updateOnTick(void) {

   #ifdef _DEBUG_STRATGY_TESTER
      Print(__FUNCTION__);
   #endif  
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategyTester::waitOnTriggers() {

   // This is just a simple tester routine to basically test the other 
   // systems

   static int cntLong=0;
   static int cntShort=0;
   #ifdef _DEBUG_STRATGY_TESTER
      Print(__FUNCTION__);
   #endif  
   

   // Prevent multiple positions begin opened
   if (triggers[_BARS_BEFORE_REENTRY]>0) {    
      triggers[_BARS_BEFORE_REENTRY]--;  
      return _NO_ACTION;
   }

   
      usp.orderTypeToOpen=ORDER_TYPE_BUY;   // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION; 
      
      

      //usp.orderTypeToOpen=ORDER_TYPE_SELL;   // Cast the specific values before opening a position !!!
      //triggers[_TLAST]=_NEW_POSITION; 



   // Check the flags if all conditions have been met and if a new position "could be opened"
   if (triggers[_TLAST]==_NEW_POSITION) {
   #ifdef _DEBUG_STRATGY_TESTER
      Print(" -> Trigger send order open");
   #endif 
      resetTriggers(_NEW_POSITION);

      switch (usp.orderTypeToOpen) {
         case ORDER_TYPE_BUY: {
               #ifdef _DEBUG_STRATGY_TESTER
                  Print(" -> Request order type buy");
               #endif 
               return (_OPEN_LONG);
            }
            
         break;
         case ORDER_TYPE_SELL: {
               #ifdef _DEBUG_STRATGY_TESTER
                  Print(" -> Request order type sell");
               #endif 
            return(_OPEN_SHORT);
         }
         break;
      }
         
   }
   
   return _NO_ACTION;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategyTester::runOnBar() {

   #ifdef _DEBUG_STRATGY_TESTER  Print (__FUNCTION__," RUN ON BAR"); #endif 
   
   EAEnum retValue=waitOnTriggers();
   // Check trading times first
   if (t.sessionTimes()) return retValue;

   return _NO_ACTION;
}