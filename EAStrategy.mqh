//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#define  _DEBUG_STRATGEY_LIVE


#include "EAEnum.mqh"
#include "EATimingBase.mqh"
#include "EAStrategyBase.mqh"
#include "EANeuralNetwork.mqh"
#include "EAInputsOutputs.mqh"
#include "EADataFrame.mqh"
#include "EANeuralNetwork.mqh"
#include "EAInputsOutputs.mqh"
#include "EATechnicalParameters.mqh"


//=========
class EAStrategy : public EAStrategyBase {
//=========


//=========
private:
//=========

   // Single object instances 
   EATimingBase      t;       // Timing Module
   //EANeuralNetwork   nn;      // The network 
   //EAInputsOutputs   io;      // NN Input Output Module

   EATechnicalParameters   *tech;
   EAInputsOutputs         *io;      // NN Input Output Module
   EADataFrame             *df;      // The dataframe object
   EANeuralNetwork         *nn;      // The network 


//=========
protected:
//=========

   void              updateOnTick();
   EAEnum            waitOnTriggers();



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

   #ifdef _DEBUG_STRATGEY_LIVE
      Print(__FUNCTION__);
   #endif
   

   // 1/ Create the new Technincals object
   tech=new EATechnicalParameters();
   if (CheckPointer(tech)==POINTER_INVALID) {
      Print("-> Error created technical object");
      ExpertRemove();
   } 

   // 2/ Create a input/output object passing it the new technical values
   io=new EAInputsOutputs(tech);
   if (CheckPointer(io)==POINTER_INVALID) {
      Print("-> Error created input/output object");
      ExpertRemove();
   }

   // 3/ create a new network to train based on the dataframe if needed
   nn=new EANeuralNetwork(usp.dnnBaseStrategyNumber,io);
   if (CheckPointer(nn)==POINTER_INVALID) {
      Print("-> Error created neural network object");
      ExpertRemove();
   }

   // 4/ Create a data frame object if we are in optimization mode
   if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {
      df=new EADataFrame(io);
      if (CheckPointer(df)==POINTER_INVALID) {
         Print("-> Error created dataframe object");
         ExpertRemove();
      }
   }
   

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategy::~EAStrategy() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategy::waitOnTriggers() {

   double trigger;

   #ifdef _DEBUG_STRATGEY_LIVE  
      Print(__FUNCTION__);
   #endif 

   // Pass in the live values into the trained model
   // Get the updated inputs from the input/output model and 
   // pass these to the NN to forecast a output
   //io.getInputs(1);                              // Inputs for the current bar
   nn.networkForcast(io.inputs,io.outputs);        // ask the NN to forcast a output(s)
   
   /*
   showPanel {
      
         //mp.updateInfo2Label(20,"DDN Inputs:");
         //mp.updateInfo2Label(21,"DDN Outputs:");
         //mp.updateInfo2Value(20,StringFormat("%1.2f %1.2f %1.2f %1.2f",io.inputs[0],io.inputs[1],inputs[2],inputs[3]));
         //mp.updateInfo2Value(21,StringFormat("%1.2f %1.2f",outputs[0],outputs[1]));

         //mp.updateInfo2Label(22,StringFormat("SADXM:%2.2f SADX+:%2.2f SRSI:%2.2f",inputs[0],inputs[1],inputs[2]));
         //mp.updateInfo2Label(23,StringFormat("MADXM:%2.2f MADX+:%2.2f MRSI:%2.2f",inputs[3],inputs[4],inputs[5]));
         //mp.updateInfo2Label(24,StringFormat("LADXM:%2.2f LADX+:%2.2f LRSI:%2.2f",inputs[6],inputs[7],inputs[8]));
         //mp.updateInfo2Label(25,StringFormat("SSAR:%2.2f MSAR:%2.2f LSAR:%2.2f",inputs[0],inputs[1],inputs[2]));
      }

/*
   #ifdef _DEBUG_STRATGEY_LIVE  
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
      #ifdef _DEBUG_STRATGEY_LIVE                                                               
         Print(__FUNCTION__," -> Network returned Long trigger");
      #endif 
   
      usp.orderTypeToOpen=ORDER_TYPE_BUY;  // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION;                     // !!! Always copy this line to the last trigger  
   }   
   
   // SHORT  
   if (usp.maxShort>0 && io.outputs[1]>0.6) {    
      #ifdef _DEBUG_STRATGEY_LIVE                                                               
         Print(__FUNCTION__," -> Network returned Short trigger");
      #endif 
      
      usp.orderTypeToOpen=ORDER_TYPE_SELL;   // Cast the specific values before opening a position !!!
      triggers[_TLAST]=_NEW_POSITION;                       // !!! Always copy this line to the last trigger  

   } 

   // Check the flags if all conditions have been met and if a new position "could be opened"
   if (triggers[_TLAST]==_NEW_POSITION) {
      resetTriggers(_NEW_POSITION);

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

   #ifdef _DEBUG_STRATGEY_LIVE
      Print(__FUNCTION__);
   #endif  
   
   EAEnum retValue;


   // Check if we are building a DataFrame either in strategy testing mode or specified via the DB
   if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {
      if (df.barCnt>0) { 
         #ifdef _DEBUG_STRATGEY_LIVE
            printf(" -> buildDataFrame:%d",df.barCnt);
         #endif 
         df.buildDataFrame(io); // Get the next bars info and store it
         return _NO_ACTION;
      }
      // Once DF is completed we train the network
      if (df.barCnt==0&&nn.isTrained==false) { 
         #ifdef _DEBUG_STRATGEY_LIVE
            printf(" -> trainNetwork");
         #endif 
         nn.trainNetwork(df);
      }
   }
   retValue=waitOnTriggers();

   // Check trading times first
   if (t.sessionTimes()) return retValue;

   return _NO_ACTION;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAStrategy::runOnTimer() {

   return _NO_ACTION;

}
