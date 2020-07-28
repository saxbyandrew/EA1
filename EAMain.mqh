//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_MAIN_LOOP
//#define _DEBUG_MAIN_LOOP_ONTICK 

#include <Trade\AccountInfo.mqh>

#include "EAEnum.mqh"

#include "EAMartingale.mqh"
#include "EALongHedge.mqh"
//#include "EALongHedge.mqh"
#include "EALong.mqh"
#include "EAShort.mqh"
//#include "EAStrategyTester.mqh"
//#include "EAStrategyCandleTest.mqh"
#include "EAStrategy.mqh"


//=========
//class EALong;
//=========

class EAMain : public CObject {

//=========
private:
//=========
   CAccountInfo   AccountInfo;

   // Position types
   EALong         *lp;
   EAShort        *sp;
   EALongHedge    *lh;
   EALongHedge    *ho; 
   EAMartingale   *mo;

   EAStrategyBase *activeStrategy;

   //EAStrategyTester  *s1;
   EAStrategy *s2;
   //EAStrategyCandleTest *s3;

   



//=========
protected:
//=========

   struct MainBase {
      int      strategyNumber;
      int      maxLong;
      int      maxShort;
      int      maxMg;
      int      maxDaily;
      double   maxHedgeLossAmountAllowed;
   } sb;
   
   bool                 checkMaxDailyOpenQty();
   void                 infoPanel();


//=========
public:
//=========
EAMain();
~EAMain();

   void runOnTick();
   void runOnBar();
   void runOnDay();
   void runOnTimer();

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAMain::EAMain() {

   #ifdef _DEBUG_MAIN_LOOP 
      Print(__FUNCTION__," -> Object instantiated"); 
   #endif 

   // Create the position object types allowed
   //if (sb.maxLong>0) {
      lp=new EALong();
      if (CheckPointer(lp)==POINTER_INVALID) ExpertRemove();
   //}

   //if (sb.maxShort>0) {
      sp=new EAShort;
      if (CheckPointer(sp)==POINTER_INVALID) ExpertRemove();
  // }

   lh=new EALongHedge;
   if (CheckPointer(lh)==POINTER_INVALID) ExpertRemove();

   //if (sb.maxMg>0) {
      mo=new EAMartingale;
      if (CheckPointer(mo)==POINTER_INVALID) ExpertRemove();
   //}


/*
   s1=new EAStrategyTester;
   if (CheckPointer(s1)==POINTER_INVALID) { 
      ExpertRemove();
   } else {
      #ifdef _DEBUG_MAIN_LOOP 
         Print(" -> s1 Object instantiated"); 
      #endif  
   }
   activeStrategy=s1;
*/


   s2=new EAStrategy();
   if (CheckPointer(s2)==POINTER_INVALID) { 
      ExpertRemove();
   } else {
      #ifdef _DEBUG_MAIN_LOOP 
         Print(" -> s2 Object instantiated"); 
      #endif  
   }
   
   // Set the active strategy here
   activeStrategy=s2;


/*
   s3=new EAStrategyCandleTest();
   if (CheckPointer(s3)==POINTER_INVALID) { 
      ExpertRemove();
   } else {
      #ifdef _DEBUG_MAIN_LOOP 
         Print(" -> s3 Object instantiated"); 
      #endif  
   }
   // Set the active strategy here
   activeStrategy=s3;
*/

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAMain::~EAMain() {

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAMain::checkMaxDailyOpenQty() {

   #ifdef _DEBUG_MAIN_LOOP Print(__FUNCTION__); string ss; #endif 

   MqlDateTime start, end;   
   int sNumber, cnt=0;
   string s;

   //showPanel infoPanel.updateInfo1Label(9, "Max Positions/Day");  
   if (usp.maxDaily==-1) {
      #ifdef _DEBUG_MAIN_LOOP 
         Print(" -> No max number of daily positions specfied");
         #endif    
      //showPanel infoPanel.updateInfo1Value(9,"No Maximum");
      return true;           // No max daily qty
   }

   TimeToStruct(TimeCurrent(),start);
   TimeToStruct(TimeCurrent(),end);
   // Modify the times
   start.hour=0; start.min=0; end.hour=23; end.min=59;

   #ifdef _DEBUG_MAIN_LOOP 
      Print(" -> Max number of daily positions specfied:",usp.maxDaily);
   #endif  
   //showPanel infoPanel.updateInfo1Value(9,IntegerToString(usp.maxDaily));
   // Get todays order history    
   if (HistorySelect(StructToTime(start), StructToTime(end))) {   
      for (int i=0;i<HistoryDealsTotal();i++) {         
         sNumber=(int)HistoryDealGetString(HistoryDealGetTicket(i),DEAL_COMMENT);
         if (usp.strategyNumber==sNumber) ++cnt;
         #ifdef _DEBUG_MAIN_LOOP
            PrintFormat(" -> Number today %d %d %d",HistoryDealsTotal(),sNumber, HistoryDealGetTicket(i));
         #endif
         if (cnt>=usp.maxDaily) {
            s=StringFormat("%d Max Reached",cnt);
            //showPanel infoPanel.updateInfo1Value(9,s);
            return false;  
         }  else {
            s=StringFormat("%d/%d",cnt,usp.maxDaily);
            //showPanel usp.updateInfo1Value(9,s);
         }                 
      }
   }

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMain::runOnBar() {


   #ifdef _DEBUG_MAIN_LOOP Print(__FUNCTION__); string ss; #endif 

   #ifdef _DEBUG_MAIN_LOOP
      Print (" -> Back from strategy execution ONBAR with trade action:");
      if (TRADING_CIRCUIT_BREAKER&IS_LOCKED) Print ("Trading prevented lock is ON");
      if (TRADING_CIRCUIT_BREAKER&IS_UNLOCKED) Print ("Trading allowed lock is OFF");
   #endif


   // Check if the strategy database has been updated and if so reloaded
   //pb.checkSQLDatabase();

   // Main price action strategy 
   if (activeStrategy.runOnBar()==_OPEN_LONG) {
      if (checkMaxDailyOpenQty()&&bool (TRADING_CIRCUIT_BREAKER&IS_UNLOCKED)) {
         TRADING_CIRCUIT_BREAKER=IS_LOCKED;
         if (lp.execute(_OPEN_LONG)) {
            #ifdef _DEBUG_MAIN_LOOP
               Print(" -> New long opened");
            #endif  
         } else {
            #ifdef _DEBUG_MAIN_LOOP
               Print(" -> New long could not be opened");
            #endif                
         }
         TRADING_CIRCUIT_BREAKER=IS_UNLOCKED;               // Enable trading subsystem 
      }
   }


   if (activeStrategy.runOnBar()==_OPEN_SHORT) {
      if (checkMaxDailyOpenQty()&&bool (TRADING_CIRCUIT_BREAKER&IS_UNLOCKED)) {  
         if (sp.execute(_OPEN_SHORT)) {
            #ifdef _DEBUG_MAIN_LOOP_ONBAR
               Print(" -> New short opened");
            #endif  
         } else {
            #ifdef _DEBUG_MAIN_LOOP_ONBAR
               Print(" -> New short could not be opened");
            #endif                
         }
         TRADING_CIRCUIT_BREAKER=IS_UNLOCKED;               // Enable trading subsystem 
      }
   }

   lp.execute(_RUN_ONBAR);
   sp.execute(_RUN_ONBAR);
   mo.execute(_RUN_ONBAR);
   lh.execute(_RUN_ONBAR); 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMain::runOnTick() {

   #ifdef _DEBUG_MAIN_LOOP_ONTICK 
      Print(__FUNCTION__);  
   #endif 

   // Manage positions OnTick
   lp.execute(_RUN_ONTICK);
   sp.execute(_RUN_ONTICK);
   mo.execute(_RUN_ONTICK);
   lh.execute(_RUN_ONTICK); 


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMain::runOnDay() {

   #ifdef _DEBUG_MAIN_LOOP_ONTICK 
      Print(__FUNCTION__);  
   #endif 

   lp.execute(_RUN_ONDAY);
   sp.execute(_RUN_ONDAY);
   mo.execute(_RUN_ONDAY);
   lh.execute(_RUN_ONDAY);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMain::runOnTimer() {

   activeStrategy.runOnTimer();
   
}