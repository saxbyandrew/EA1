//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#define  _DEBUG_STRATEGY_CANDLETEST  
//#define _OPTIMIZE_DNN_PRICEACTION

#include "EAEnum.mqh"
#include "EAStrategyBase.mqh"
#include "EATimingBase.mqh"
#include "EANeuralNetwork.mqh"
#include "EAModelCandle.mqh"




//=========
class EAStrategyCandleTest : public EAStrategyBase {
//=========


//=========
private:
//=========

   double            inputs[4];      // DNN inputs
   double            outputs[];      // DNN Output

//=========
protected:
//=========

   EANeuralNetwork        *dnn; 

   EAModelCandle     shortTermCandle;
   EAModelCandle     longTermCandle;
   


   void              updateOnTick();
   EAEnum            waitOnTriggers();
   EATimingBase      t;



//=========
public:
//=========
EAStrategyCandleTest();
~EAStrategyCandleTest();

   virtual int Type() const {return _STRATEGY;};

   EAEnum runOnBar();
   EAEnum runOnTimer();

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyCandleTest::EAStrategyCandleTest() {

   #ifdef _DEBUG_STRATEGY_CANDLETEST  
      Print(__FUNCTION__);
      string ss;
   #endif 

   
   if (bool (pb.runMode&_RUN_STRATEGY_OPTIMIZATION)&&pb.optimizationLong) {
      #ifdef _DEBUG_STRATEGY_CANDLETEST  
         printf (" -> Using optimization inputs");
      #endif 
      dnn=new EANeuralNetwork(pb.runMode);
   } else {
      // Determine which DNN to load
      switch (pb.dnnType) {
         case _LONG: dnn=new EANeuralNetwork(pb.strategyNumber, pb.dnnLongNumber);
         break;
         case _SHORT: dnn=new EANeuralNetwork(pb.strategyNumber, pb.dnnShortNumber);
         break;
      }

      // Display the first and last value of the dnn weights so we can just check
      showPanel {
         // Determine which type of DNN
         if (bool (pb.dnnType&_LONG)) {
            //mp.updateInfoLabel(13,3,StringFormat("DNN strategy#:%d (Long) start:%1.2f end:%1.2f",pb.dnnLongNumber,dnn.weight[0],dnn.weight[ArraySize(dnn.weight)-1])); 
            //mp.updateInfoValue(13,4,"");
         }
         if (bool (pb.dnnType&_SHORT)) {
            //mp.updateInfoLabel(14,3,StringFormat("DNN strategy#:%d (Short) start:%1.2f end:%1.2f",pb.dnnShortNumber,dnn.weight[0],dnn.weight[ArraySize(dnn.weight)-1])); 
            //mp.updateInfoValue(14,4,""); 
         }

      }
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyCandleTest::~EAStrategyCandleTest() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyCandleTest::updateOnTick(void) {

   #ifdef _DEBUG_STRATEGY_CANDLETEST  
      Print(__FUNCTION__);
   #endif  
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategyCandleTest::waitOnTriggers() {

   #ifdef _DEBUG_STRATEGY_CANDLETEST    
      Print(__FUNCTION__);
   #endif 

      shortTermCandle.candleWeights(inputs,pb.period1);
      

      dnn.computeOutputs(inputs,outputs);

   // Prevent multiple positions begin opened
   if (triggers[_BARS_BEFORE_REENTRY]>0) {    
      triggers[_BARS_BEFORE_REENTRY]--;  
      return _NO_ACTION;
   }
   

   // Customise this section so the panel makes sence !
   
   
   showPanel {
      mp.updateInfo2Label(20,"DDN Inputs:");
      mp.updateInfo2Label(21,"DDN Outputs:");
      mp.updateInfo2Value(20,StringFormat("%1.2f %1.2f %1.2f %1.2f",inputs[0],inputs[1],inputs[2],inputs[3]));
      mp.updateInfo2Value(21,StringFormat("%1.2f %1.2f %1.2f",outputs[0],outputs[1],outputs[2]));
   }
   

   #ifdef _DEBUG_STRATEGY_CANDLETEST     
      if (bool (pb.dnnType&_LONG)) printf("Allow LONG");
      if (bool (pb.dnnType&_SHORT)) printf("Allow SHORT");
   #endif 

   // LONG         
   if (bool (pb.dnnType&_LONG)&&outputs[0]>0.6) {    
      #ifdef _DEBUG_STRATEGY_CANDLETEST                                                                 
         Print(__FUNCTION__," -> ANN returned Long trigger");
      #endif 
      
      pb.orderTypeToOpen=ORDER_TYPE_BUY;  // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION;                     // !!! Always copy this line to the last trigger  
   }   
   
   // SHORT  
   if (bool (pb.dnnType&_SHORT)&&outputs[1]>0.6) {    
      #ifdef _DEBUG_STRATEGY_CANDLETEST                                                                 
         Print(__FUNCTION__," -> ANN returned Short trigger");
      #endif 
      
      pb.orderTypeToOpen=ORDER_TYPE_SELL;   // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION;                       // !!! Always copy this line to the last trigger  

   } 
 
   // Check the flags if all conditions have been met and if a new position "could be opened"
   if (triggers[_TLAST]==_NEW_POSITION) {
      resetTriggers(_NEW_POSITION);

      switch (pb.orderTypeToOpen) {
         case ORDER_TYPE_BUY: return (_OPEN_LONG);   
         break;
         case ORDER_TYPE_SELL: return(_OPEN_SHORT);
         break;
      }
      
   }
   
   return _NO_ACTION;
}        

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategyCandleTest::runOnBar() {

   #ifdef _DEBUG_STRATEGY_CANDLETEST  
      Print(__FUNCTION__);
   #endif  
   
   EAEnum retValue=waitOnTriggers();
   // Check trading times first
   if (t.sessionTimes()) return retValue;

   return _NO_ACTION;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategyCandleTest::runOnTimer() {

   return _NO_ACTION;

}
