//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EAEnum.mqh"
#include "EATimingBase.mqh"
#include "EAStrategyBase.mqh"
#include "EANeuralNetwork.mqh"
#include "EAInputsOutputs.mqh"
#include "EANeuralNetwork.mqh"
#include "EAInputsOutputs.mqh"
#include "EATechnicalParameters.mqh"

//=========
class EAStrategy : public EAStrategyBase {
//=========


//=========
private:
//=========

   string                  ss;
   EATimingBase            *t;          // Timing Module
   EATechnicalParameters   *tech;
   EAInputsOutputs         *io;        // NN Input Output Module
   EANeuralNetwork         *nn;        // The network 

//=========
protected:
//=========

   void     updateOnTick();
   EAEnum   waitOnTriggers();

//=========
public:
//=========
EAStrategy();
~EAStrategy();

   virtual int Type() const {return _STRATEGY;};
   EAEnum runOnBar();
   EAEnum runOnTimer();

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategy::EAStrategy() {

   #ifdef _DEBUG_STRATEGY
      Print(__FUNCTION__);
   #endif
   
   MqlTick last_tick;

   SymbolInfoTick(Symbol(),last_tick); // Also STD lib is RefreshRates()

   // 0/ Create the timing object
   t=new EATimingBase();
   if (CheckPointer(t)==POINTER_INVALID) {
      ss="EAStrategy -> ERROR created timing object";
         #ifdef _DEBUG_STRATEGY
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      ss="EAStrategy -> SUCCESS created timing object";
      #ifdef _DEBUG_STRATEGY
         writeLog
         pss
      #endif
   }

   // 1/ Create the new Technincals object
   tech=new EATechnicalParameters(usp.baseReference); // Using the base ref as this is the main strategy
   if (CheckPointer(tech)==POINTER_INVALID) {
      ss="EAStrategy -> ERROR created technical object";
         #ifdef _DEBUG_STRATEGY
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      ss="EAStrategy -> SUCCESS created technical object";
      #ifdef _DEBUG_STRATEGY
         writeLog
         pss
      #endif
   }

   // 2/ Create a input/output object passing it the new technical values
   io=new EAInputsOutputs(tech);
   if (CheckPointer(io)==POINTER_INVALID) {
      ss="EAStrategy -> ERROR created input/output object";
         #ifdef _DEBUG_STRATEGY
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      ss="EAStrategy -> SUCCESS created input/output object";
      #ifdef _DEBUG_STRATEGY
         writeLog
         pss
      #endif
   }

   // 3/ create a new network to train based on the dataframe if needed
   nn=new EANeuralNetwork(usp.baseReference,io); // base refer here in the main NN number
   if (CheckPointer(nn)==POINTER_INVALID) {
      ss="EAStrategy -> ERROR created neural network object";
         #ifdef _DEBUG_STRATEGY
            writeLog
         #endif
      pss
      ExpertRemove();
   } else {
      #ifdef _DEBUG_STRATEGY  
         ss=StringFormat("EAStrategy -> Using base strategy number:%d",usp.baseReference);
         writeLog
         pss
      #endif 
   }

   showPanel {
      //ip.mainInfoPanel();
   }
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategy::~EAStrategy() {

   delete t;
   delete io;
   delete tech;
   delete nn;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategy::waitOnTriggers() {

   string s;
   double trigger;

   //#ifdef _DEBUG_STRATEGY_TRIGGERS  
      //Print(__FUNCTION__);
   //#endif 

   // Pass in the live values into the trained model
   // Get the updated inputs from the input/output model and 
   // pass these to the NN to forecast a output
   #ifdef _DEBUG_STRATEGY_TRIGGERS
      if (MQLInfoInteger(MQL_OPTIMIZATION)) {
         ss=" -> networkForcast called in optimization mode";
         writeLog
      }
   #endif

   // Inputs for the current bar Outputs are returned
   nn.networkForcast(io.inputs,io.outputs);        // ask the NN to forcast a output(s)
   #ifdef _DEBUG_STRATEGY_TRIGGERS
      ss="Inputs: ";
      for (int i=0;i<ArraySize(io.inputs);i++) {
         ss=ss+DoubleToString(io.inputs[i]);
      }
      writeLog
      ss="Outputs: ";
      for (int i=0;i<ArraySize(io.outputs);i++) {
         ss=ss+DoubleToString(io.outputs[i]);
      }
      writeLog
   #endif



      //ip.updateInfo2Value(20,StringFormat("%1.2f %1.2f %1.2f %1.2f",io.inputs[0],io.inputs[1],inputs[2],inputs[3]));
      //ip.updateInfo2Value(21,StringFormat("%1.2f %1.2f",outputs[0],outputs[1]));
   
/*
         //mp.updateInfo2Label(22,StringFormat("SADXM:%2.2f SADX+:%2.2f SRSI:%2.2f",inputs[0],inputs[1],inputs[2]));
         //mp.updateInfo2Label(23,StringFormat("MADXM:%2.2f MADX+:%2.2f MRSI:%2.2f",inputs[3],inputs[4],inputs[5]));
         //mp.updateInfo2Label(24,StringFormat("LADXM:%2.2f LADX+:%2.2f LRSI:%2.2f",inputs[6],inputs[7],inputs[8]));
         //mp.updateInfo2Label(25,StringFormat("SSAR:%2.2f MSAR:%2.2f LSAR:%2.2f",inputs[0],inputs[1],inputs[2]));
      }

/*
   #ifdef _DEBUG_STRATEGY  
      printf("Network retured:");
      ArrayPrint(inputs);
      ArrayPrint(outputs);
   #endif 

   EAEnum x = shortTerm.ZIGZAGValue(1);
   if (x==_UP) {
      printf("GOT a UP");
   }
   if (x==_DOWN) {
      printf("GOT a DOWN");
   }
*/
/*
   if (longTerm.ZIGZAGValue()==_UP) {
      printf("LONG TERM UP");
   }
   if (mediumTerm.ZIGZAGValue()==_UP) {
      printf("MEDUIM TERM UP");
   }

   if (longTerm.ZIGZAGValue()==_DOWN) {
      printf("LONG TERM DOWN");
   }
   if (mediumTerm.ZIGZAGValue()==_DOWN) {
      printf("MEDIUM TERM UP");
   }
   */


   // Allow LONG/SHORTS if strategy values have been set       
   if (usp.maxLong>0 && io.outputs[0]>0.6) {    
      #ifdef _DEBUG_STRATEGY_TRIGGERS                                                               
         ss="waitOnTriggers -> Network returned Long trigger";
         writeLog
         pss
      #endif 
   
      usp.orderTypeToOpen=ORDER_TYPE_BUY;  // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION;                     // !!! Always copy this line to the last trigger  
   }   
   
   // SHORT  
   if (usp.maxShort>0 && io.outputs[1]>0.6) {   
      #ifdef _DEBUG_STRATEGY_TRIGGERS                                                               
         ss="waitOnTriggers -> Network returned Short trigger";
         writeLog
         pss
      #endif 
      
      usp.orderTypeToOpen=ORDER_TYPE_SELL;   // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION;                       // !!! Always copy this line to the last trigger  

   } 

   // Check the flags if all conditions have been met and if a new position "could be opened"
   if (triggers[_TLAST]==_NEW_POSITION) {
      resetTriggers(_NEW_POSITION);

      #ifdef _DEBUG_STRATEGY_TRIGGERS                                                               
         ss="waitOnTriggers -> trigger new position open";
         writeLog
         pss
      #endif 

      switch (usp.orderTypeToOpen) {
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
EAEnum EAStrategy::runOnBar() {

   #ifdef _DEBUG_STRATEGY
      Print(__FUNCTION__);
   #endif  
   
   EAEnum retValue;
   static int delay=0;

   /*
   // This has been placed here instread of in the nn module because if placed there teh values returned are EMPTY VALUES
   if (nn.rebuild_DataFrame) {
      io.getInputs(1);
      if (io.inputs[0]>0) {
         printf("111111111111111111111111");
         nn.buildDataFrame(io);
         return _NO_ACTION;
      } else {
         printf("00000000000000000000");
      }
   }
   */

   // Check trading times first
   //if (t.sessionTimes()) return retValue;


   if (usp.runMode==_RUN_STRATEGY_REBUILD_NN) {
      #ifdef _DEBUG_STRATEGY
         ss=StringFormat(" -> Building new DF first time %d",delay);
         printf(ss);
      #endif
      io.getInputs(1);   
      io.getOutputs(1); 
      if (delay>10) {
         nn.buildDataFrame(io);
      }
      delay++;
      return _NO_ACTION;      // return with no action till the DF is completed
   }
   
   if (MQLInfoInteger(MQL_OPTIMIZATION) && nn.isTrained==false) {
      #ifdef _DEBUG_STRATEGY
         ss=" -> Building DF";
         writeLog
      #endif
      nn.buildDataFrame(io);  // Get the next bars info and store it
      return _NO_ACTION;      // return with no action till the DF is completed
   } else {
      #ifdef _DEBUG_STRATEGY
         ss=" -> NN Training completed in optimization mode";
         writeLog
      #endif

   }

   retValue=waitOnTriggers();

   return retValue;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategy::runOnTimer() {

   return _NO_ACTION;
}
