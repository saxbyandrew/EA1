//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_LONGHEDGE


#include "EAEnum.mqh"
#include "EAPositionBase.mqh"
//#include "EANeuralNetwork.mqh"
//#include "EAModuleCustom.mqh"
#include "EAModuleTechnicals.mqh"


// ++++++++++++++++++++++++++++++++++++++
//
// ++++++++++++++++++++++++++++++++++++++

class EALongHedge : public EAPositionBase {

//=========
private:
//=========

   void                 copyValuesFromInputs();
   double               totalLotSize;

   
   double            inputs[4];      // DNN inputs
   double            outputs[];      // DNN Output

//=========
protected:
//=========

   void              createHedge();
   void              manageHedge();
   void              checkAccountPnL();
   bool              newPosition(double lotSize);
   //EANeuralNetwork        *dnn; 
   //EAModuleCustom    *custom;
   //EAModuleTechnicals       *rsi;

//=========
public:
//=========
   EALongHedge();
   ~EALongHedge();


   virtual int Type() const {return _LONG;};

   virtual bool execute(EAEnum action);


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EALongHedge::EALongHedge() {

   //----
   #ifdef _DEBUG_LONGHEDGE 
      Print(__FUNCTION__," Default Constructor"); 
      string ss; 
   #endif
   //---- 
   
   /*
   if (usp.optimizationHedge) {
      copyValuesFromInputs();
   } else {

      // Normal non optimizing code goes here
   }
   */
   totalLotSize=0;
   ACTIVE_HEDGE=_NO;

   //---
   
   /*
   if (bool (usp.runMode&_RUN_STRATEGY_OPTIMIZATION)&&usp.optimizationHedge) {
      #ifdef _DEBUG_STRATEGY_PRICEACTION
         printf (" -> Using optimization inputs");
      #endif 
      //dnn=new EANeuralNetwork(usp.runMode);
      //usp.copyValuesFromInputs(); 
   } else {
      
      dnn=new EANeuralNetwork(usp.strategyNumber, usp.dnnLongNumber); // TESTING WITH LONG VALUES

      showPanel {
         mp.updateInfo2Label(29,StringFormat("DNN Hedge strategy#:%d start:%1.2f end:%1.2f",usp.dnnLongNumber,dnn.weight[0],dnn.weight[ArraySize(dnn.weight)-1])); 
         mp.updateInfo2Value(29,"");
      }
      
   }
   */

   //void              MACDSetParameters(ENUM_TIMEFRAMES period,int fastEMA, int slowEMA, int signalPeriod, int priceApplied);   
   //custom=new EAModuleCustom;
   //custom.MACDSetParameters(PERIOD_D1,12,26,9);
   //void              RSISetParameters(ENUM_TIMEFRAMES period,int ma_period, int priceApplied);      
   //rsi=new EAModuleTechnicals;
   //rsi.RSISetParameters(PERIOD_D1,14,PRICE_CLOSE);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EALongHedge::~EALongHedge() {

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EALongHedge::newPosition(double ls) {

   //----
   #ifdef _DEBUG_LONGHEDGE 
      Print (__FUNCTION__);
   #endif  
  //----


      // Build a new position object based on defaults
      EAPosition *p=new EAPosition();                       // Create new position object
      p.strategyNumber=usp.strategyNumber;                // copy over strategy defaults
      p.lotSize=ls;
      p.status=_HEDGE;
      p.entryPrice=getUpdatedPrice(ORDER_TYPE_SELL,_TOOPEN);
      p.orderTypeToOpen=ORDER_TYPE_SELL;                   // type is a SELL
      p.closingTypes=usp.closingTypes;
      p.fixedProfitTargetLevel=0;  
      p.fixedLossTargetLevel=0; 

      if (openPosition(p)) {
         if (longHedgePositions.Add(p)!=-1) {
            #ifdef _DEBUG_HEDGE
               Print(" -> New position opened and added to long positions list"); 
            #endif 
            //p.setTextLabel(clrRed);
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
void EALongHedge::manageHedge() {

   // manual mode 
   //----
   #ifdef _DEBUG_LONGHEDGE 
      Print (__FUNCTION__);
   #endif  
  //----

   for (int i=0;i<longHedgePositions.Total();i++) {  
      glhp;
      // Check if this position still exists in the MT5 trade system
      if (p.positionExists(p.ticket)) {
         printf("============================ POSITIONS STILL EXEISTS %d",p.ticket);

      } else {
         printf("===========================POSITION DOES NOT EXIST");
      }

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALongHedge::createHedge() {

   
   //----
   #ifdef _DEBUG_LONGHEDGE 
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
      #ifdef _DEBUG_LONGHEDGE 
         ss=StringFormat(" -> MG Ticket:%d Size:%g",np.ticket,np.lotSize);
         Print (ss);
      #endif
      //----
      longHedgePositions.Add(np);                   // add to hedge list
   }
   
   // Longs
   for (i=0;i<longPositions.Total();i++) {  
      glp;
      np=new EAPosition(p);         // Create new with copy constructor called
      //----
      #ifdef _DEBUG_LONGHEDGE 
         ss=StringFormat(" -> L Ticket:%d Size:%g",np.ticket,np.lotSize);
         Print (ss);
      #endif
      //----
      longHedgePositions.Add(np);                   // add to hedge list
   }

      
   for (i=0;i<longHedgePositions.Total();i++) {  
      glhp;
      totalLotSize=totalLotSize+p.lotSize;
      //----
      #ifdef _DEBUG_LONGHEDGE 
         ss=StringFormat(" -> H Ticket:%d Size:%g",p.ticket,p.lotSize);
         Print (ss);
      #endif
      //----
   }

   #ifdef _DEBUG_LONGHEDGE 
      ss=StringFormat(" -> Total LotSize:%g",totalLotSize);
      Print (ss);
   #endif
   newPosition(totalLotSize);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALongHedge::checkAccountPnL() {

   //----
   #ifdef _DEBUG_LONGHEDGE 
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
      PnL=PnL+p.currentPnL;

      //----
      #ifdef _DEBUG_LONGHEDGE 
         ss=StringFormat(" -> MG Ticket:%d PnL:%g",p.ticket,p.currentPnL);
         Print (ss);
      #endif
      //----
   }
   
   // Longs
   for (i=0;i<longPositions.Total();i++) {  
      glp;
      PnL=PnL+p.currentPnL;
      //----
      #ifdef _DEBUG_LONGHEDGE 
         ss=StringFormat(" -> L Ticket:%d PnL:%g",p.ticket,p.currentPnL);
         Print (ss);
      #endif
      //----
   }

   if (PnL<usp.longHLossamt) {
      #ifdef _DEBUG_LONGHEDGE 
         ss=StringFormat(" -> xxxxxxxxxxxxxxxxx Total hedge PnL:%g",PnL);
         Print (ss);
      #endif
      createHedge();
      ACTIVE_HEDGE=_YES;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EALongHedge::execute(EAEnum action) {

   
  //----
   #ifdef _DEBUG_LONGHEDGE 
      Print (__FUNCTION__);
      string ss; 
   #endif  

      // Check if we are even doing hedges
   if (bool (usp.closingTypes&_IN_LOSS_OPEN_LONG_HEDGE)==false) return false;

   
   if (ACTIVE_HEDGE==_YES) {
      #ifdef _DEBUG_LONGHEDGE
         Print(" -> In L Hedge is active ....");
      #endif   
      manageHedge();
      return true;
   }

   switch (action) {
      case _RUN_ONTICK:  checkAccountPnL();
      break;
   }

   
   
   return false;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EALongHedge::copyValuesFromInputs() {

   //usp.maxLongHedgeLossAmountAllowed=longHLossamt;
}