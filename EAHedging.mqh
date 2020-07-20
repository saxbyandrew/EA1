//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_HEDGE


#include "EAEnum.mqh"
#include "EAPositionBase.mqh"
//#include "EANeuralNetwork.mqh"
#include "EAModuleCustom.mqh"
#include "EAModuleADX.mqh"
#include "EAModuleMACD.mqh"



class EAHedging : public EAPositionBase {

//=========
private:
//=========
   //double               inputs[4];      // DNN inputs
   //double               outputs[];      // DNN Output
   //void                 copyValuesFromInputs();
   double               totalLotSize;

//=========
protected:
//=========
   EAModuleADX       adx;  
   EAModuleMACD      macd;
   EAModuleCustom    custom;
   //EANeuralNetwork        *dnn; 


   //void              manageHedge();
  // void              closeOnProfit();
   //void              closeHedge();
   void              createHedge();
   void              checkAccountPnL();
   bool              newPosition(double lotSize);
   void              updatePositionLabels();
   //EAEnum            getDDNInputs(double &inputs[]); // For DNN

//=========
public:
//=========
   EAHedging();
   ~EAHedging();


   virtual int Type() const {return _HEDGE;};

   virtual bool execute(EAEnum action);


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAHedging::EAHedging() {

   //----
   #ifdef _DEBUG_HEDGE 
      Print(__FUNCTION__," Default Constructor"); 
      string ss; 
   #endif
   //---- 

   
   if (!usingStrategyValue.optimizationHedge) {
      //dnn=new EANeuralNetwork(usingStrategyValue.strategyNumber, usingStrategyValue.dnnHedgeName, usingStrategyValue.dnnHedgeNumber);
      #ifdef _DEBUG_HEDGE
         ss=StringFormat(" -> Hedge using strategy %d with weights %d",usingStrategyValue.strategyNumber, usingStrategyValue.dnnHedgeNumber);
         Print(ss);
      #endif 
   #endif    
   } else {
      #ifdef _DEBUG_HEDGE
         ss=StringFormat(" -> Hedge using optimization inputs");
         Print(ss);
      #endif 
      // Copy over the input weights to the internal array
      //dnn=new EANeuralNetwork(_STRATEGY_OPTIMIZATION);                      
   }


   totalLotSize=0;
   _ACTIVE_HEDGE=_NO;

   macd.setParameters(PERIOD_H4,12,26,9,PRICE_CLOSE);
   adx.setParameters(25,PERIOD_H4);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAHedging::~EAHedging() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAHedging::updatePositionLabels() {

   //----
   #ifdef _DEBUG_HEDGE 
      Print(__FUNCTION__); string ss; 
   #endif
   //---- 

   for (int i=0;i<hedgePositions.Total();i++) {
      ghp;
      usingPositionValue.setTextLabel(clrRed);
   }
}
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EAHedging::getDDNInputs(double &inputs[]) {

   //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__); 
      string ss;
   #endif 
   //----
   inputs[0]=macd.normalizedValue(1,20,0);
   inputs[1]=adx.normalizedValue(1,10,0);
   inputs[1]=adx.normalizedValue(1,10,1);

   if (custom.MACDPlatinum(PERIOD_CURRENT)==_BLUEDOT) {
      inputs[3]=1;
   } 
   if (custom.MACDPlatinum(PERIOD_CURRENT)==_REDDOT) {
      inputs[3]=0;
   }
   Print ("+++++++++++++++++++++++++++++++");
   ArrayPrint(inputs);
   Print ("+++++++++++++++++++++++++++++++");

   return _NO_ACTION;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAHedging::manageHedge() {

   //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__); 
      string ss;
   #endif 
   //----

   // runn methods used to get input for the DNN
   // getWeights(input)
   //if (getDDNInputs(inputs)==_NO_ACTION) return;       // TEST
      getDDNInputs(inputs);


   // Run DNN pass IN the (inputs[]) and it returns the (outputs[])
   dnn.computeOutputs(inputs,outputs);          // Run NN    
   
   #ifdef _DEBUG_HEDGE                                                               
      //ArrayPrint(inputs);
      //ArrayPrint(outputs);      
   #endif 

   if (outputs[0]>0.6) {                        // Bullish Trigger
      #ifdef _DEBUG_HEDGE                                                               
         Print(__FUNCTION__," -> ANN returned close hedge trigger");
      #endif 
      closeHedge();
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAHedging::closeHedge() {

    //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__); 
      string ss;
   #endif  

   for (int i=0;i<hedgePositions.Total();i++) {
      ghp;
      if (usingPositionValue.orderTypeToOpen==ORDER_TYPE_SELL) {
         if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
            //----
            #ifdef _DEBUG_LONG 
               Print (" -> Hedge Close"); 
            #endif
            if (hedgePositions.Delete(i)) {
               #ifdef _DEBUG_LONG 
                  Print (" -> Hedge Close object removed from CList"); 
               #endif 
               _ACTIVE_HEDGE=_NO;
               return; 
            }                     
         }
      } 
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAHedging::closeOnProfit() {

    //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__); 
      string ss;
   #endif  


   for (int i=0;i<hedgePositions.Total();i++) {
      int ticket=PositionGetTicket(i);
      double profit=PositionGetDouble(POSITION_PROFIT);
      if (profit>0) {
         //----
         #ifdef _DEBUG_HEDGE 
            ss=StringFormat(" -> T:%d in profit by:%g",ticket,profit);
            Print(ss);
         Trade.PositionClose(ticket,usingStrategyValue.deviationInPoints);
         #endif  
         //----   
      }
   }
}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAHedging::newPosition(double ls) {

   //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__);
   #endif  
  //----


      // Build a new position object based on defaults
      EAPosition *p=new EAPosition();                       // Create new position object
      p.strategyNumber=param.strategyNumber;                // copy over strategy defaults
      p.lotSize=ls;
      p.status=_HEDGE;
      p.entryPrice=getUpdatedPrice(ORDER_TYPE_SELL,_TOOPEN);
      p.orderTypeToOpen=ORDER_TYPE_SELL;                   // type is a SELL
      p.closingTypes=param.closingTypes;
      p.fixedProfitTargetLevel=0;  
      p.fixedLossTargetLevel=0; 

      if (openPosition(p)) {
         if (hedgePositions.Add(p)!=-1) {
            #ifdef _DEBUG_HEDGE
               Print(" -> New position opened and added to long positions list"); 
            #endif 
            p.setTextLabel(clrRed);
            return true;
         }            
      } else {
         #ifdef _DEBUG_HEDGE
            Print(" -> New position opened failed"); 
         #endif 
      }
   

   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAHedging::createHedge() {

   
   //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__);
      string ss;
   #endif  
  //----

   EAPosition *np;
   int i=0;

   // Martingales
   for (i=0;i<martingalePositions.Total();i++) {   
      gmp;
      np=new EAPosition(p);         // Create new with copy constructor called
      //----
      #ifdef _DEBUG_HEDGE 
         ss=StringFormat(" -> MG Ticket:%d Size:%g",np.ticket,np.lotSize);
         Print (ss);
      #endif
      //----
      hedgePositions.Add(np);                   // add to hedge list
   }
   
   // Longs
   for (i=0;i<longPositions.Total();i++) {  
      glp;
      np=new EAPosition(p);         // Create new with copy constructor called
      //----
      #ifdef _DEBUG_HEDGE 
         ss=StringFormat(" -> L Ticket:%d Size:%g",np.ticket,np.lotSize);
         Print (ss);
      #endif
      //----
      hedgePositions.Add(np);                   // add to hedge list
   }

      
   for (i=0;i<hedgePositions.Total();i++) {  
      ghp;
      totalLotSize=totalLotSize+p.lotSize;
      //----
      #ifdef _DEBUG_HEDGE 
         ss=StringFormat(" -> H Ticket:%d Size:%g",p.ticket,p.lotSize);
         Print (ss);
      #endif
      //----
   }

   #ifdef _DEBUG_HEDGE 
      ss=StringFormat(" -> Total LotSize:%g",totalLotSize);
      Print (ss);
   #endif
   newPosition(totalLotSize);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAHedging::checkAccountPnL() {

   //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__);
      string ss;
   #endif  
   //----

   int i;
   double PnL=0;

   // No Point checking if we have no open positions.
   if (martingalePositions.Total()==0&&longPositions.Total()==0) return;
   
   // Martingales
   for (i=0;i<martingalePositions.Total();i++) {   
      gmp;
      PnL=PnL+usingPositionValue.currentPnL;

      //----
      #ifdef _DEBUG_HEDGE 
         ss=StringFormat(" -> MG Ticket:%d PnL:%g",usingPositionValue.ticket,usingPositionValue.currentPnL);
         Print (ss);
      #endif
      //----
   }
   
   // Longs
   for (i=0;i<longPositions.Total();i++) {  
      glp;
      PnL=PnL+usingPositionValue.currentPnL;
      //----
      #ifdef _DEBUG_HEDGE 
         ss=StringFormat(" -> L Ticket:%d PnL:%g",usingPositionValue.ticket,usingPositionValue.currentPnL);
         Print (ss);
      #endif
      //----
   }

   if (PnL<usingStrategyValue.maxHedgeLossAmountAllowed) {
      #ifdef _DEBUG_HEDGE 
         ss=StringFormat(" -> xxxxxxxxxxxxxxxxx Total hedge PnL:%g",PnL);
         Print (ss);
      #endif
      createHedge();
      _ACTIVE_HEDGE=_YES;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAHedging::execute(EAEnum action) {

   
  //----
   #ifdef _DEBUG_HEDGE 
      Print (__FUNCTION__);
      string ss; 
   #endif  

   bool retValue=false;

    // Always update 
   updatePositionLabels();
   getDDNInputs(inputs);

   if (_ACTIVE_HEDGE==_YES) {
      #ifdef _DEBUG_HEDGE
         Print(" -> In L Hedge is active ....");
      #endif   
      manageHedge();
      return retValue;
   }

   switch (action) {
      case _RUN_ONTICK:   checkAccountPnL();
      break;
   }

   
   
   return false;
}
