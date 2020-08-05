//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_MAIN_LOOP

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

   string ss;


//=========
protected:
//=========

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
      ss="EAMain -> Object instantiated"; 
      writeLog
      printf(ss);
   #endif 

   // Create the position object types allowed
   //if (sb.maxLong>0) {
      lp=new EALong();
      if (CheckPointer(lp)==POINTER_INVALID) {
         #ifdef _DEBUG_MAIN_LOOP
            ss="EAMain -> ERROR creating object EALong";
            writeLog
            printf(ss);
            ExpertRemove();
         #endif
      } else {
         #ifdef _DEBUG_MAIN_LOOP
            ss="EAMain -> SUCCESS creating object EALong";
            writeLog
            printf(ss);
         #endif
      }
   //}

   //if (sb.maxShort>0) {
      sp=new EAShort;
      if (CheckPointer(sp)==POINTER_INVALID) {
         #ifdef _DEBUG_MAIN_LOOP
            ss="EAMain -> ERROR creating object EAShort";
            writeLog
            printf(ss);
            ExpertRemove();
         #endif
         ExpertRemove();
      } else {
                  #ifdef _DEBUG_MAIN_LOOP
            ss="EAMain -> SUCCESS creating object EAShort";
            writeLog
            printf(ss);
         #endif

      }
  // }

   lh=new EALongHedge;
   if (CheckPointer(lh)==POINTER_INVALID) {
      #ifdef _DEBUG_MAIN_LOOP
         ss="EAMain -> ERROR creating object EALongHedge";
         writeLog
         printf(ss);
         ExpertRemove();
      #endif
      ExpertRemove();
   } else {
      #ifdef _DEBUG_MAIN_LOOP
         ss="EAMain -> SUCCESS creating object EALongHedge";
         writeLog
         printf(ss);
      #endif

   }

   //if (sb.maxMg>0) {
      mo=new EAMartingale;
      if (CheckPointer(mo)==POINTER_INVALID) {
         #ifdef _DEBUG_MAIN_LOOP
            ss="EAMain -> ERROR creating object EAMartingale";
            writeLog
            printf(ss);
            ExpertRemove();
         #endif
         ExpertRemove();
      } else {
         #ifdef _DEBUG_MAIN_LOOP
            ss="EAMain -> SUCCESS creating object EAMartingale";
            writeLog
            printf(ss);
         #endif

      }
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

   delete lp;
   delete sp;
   delete lh;
   delete ho;
   delete mo;
   delete activeStrategy;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAMain::checkMaxDailyOpenQty() {

   #ifdef _DEBUG_MAIN_LOOP 
      ss="checkMaxDailyOpenQty -> ...."; 
      writeLog
      printf(ss);
   #endif 

   MqlDateTime start, end;   
   int sNumber, cnt=0;
   string s;

   //showPanel infoPanel.updateInfo1Label(9, "Max Positions/Day");  
   if (usp.maxDaily<=0) {
      #ifdef _DEBUG_MAIN_LOOP 
         ss="checkMaxDailyOpenQty -> No max number of daily positions specfied";
         writeLog
         printf(ss);
      #endif    
      //showPanel infoPanel.updateInfo1Value(9,"No Maximum");
      return true;           // No max daily qty
   }

   TimeToStruct(TimeCurrent(),start);
   TimeToStruct(TimeCurrent(),end);
   // Modify the times
   start.hour=0; start.min=0; end.hour=23; end.min=59;

   #ifdef _DEBUG_MAIN_LOOP 
      ss=StringFormat("checkMaxDailyOpenQty -> Max number of daily positions specfied:",usp.maxDaily);
               writeLog
         printf(ss);
   #endif  
   //showPanel infoPanel.updateInfo1Value(9,IntegerToString(usp.maxDaily));
   // Get todays order history    
   if (HistorySelect(StructToTime(start), StructToTime(end))) {   
      for (int i=0;i<HistoryDealsTotal();i++) {         
         sNumber=(int)HistoryDealGetString(HistoryDealGetTicket(i),DEAL_COMMENT);
         if (usp.strategyNumber==sNumber) ++cnt;
         #ifdef _DEBUG_MAIN_LOOP
            ss=StringFormat("checkMaxDailyOpenQty -> Number today %d %d %d",HistoryDealsTotal(),sNumber, HistoryDealGetTicket(i));
            writeLog
            printf(ss);
         #endif
         if (cnt>=usp.maxDaily) {
            #ifdef _DEBUG_MAIN_LOOP
               ss=StringFormat("checkMaxDailyOpenQty => %d Max Reached",cnt);
               writeLog
               printf(ss);
            #endif
            //showPanel infoPanel.updateInfo1Value(9,s);
            return false;  
         }  else {
            #ifdef _DEBUG_MAIN_LOOP
               ss=StringFormat("checkMaxDailyOpenQty -> %d/%d",cnt,usp.maxDaily);
               writeLog
               printf(ss);
            #endif
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


   #ifdef _DEBUG_MAIN_LOOP 
      ss="runOnBar -> ...."; 
      writeLog
      printf(ss);
   #endif 

   #ifdef _DEBUG_MAIN_LOOP
      ss="runOnBar -> Back from strategy execution ONBAR with trade action:";
         writeLog
         printf(ss);
      if (TRADING_CIRCUIT_BREAKER&IS_LOCKED) {
         ss="Trading prevented lock is ON";
         writeLog
         printf(ss);
      }
      if (TRADING_CIRCUIT_BREAKER&IS_UNLOCKED) {
         ss="Trading allowed lock is OFF";
         writeLog
         printf(ss);
      }
   #endif


   // Check if the strategy database has been updated and if so reloaded
   //pb.checkSQLDatabase();

   // Main price action strategy 
   if (activeStrategy.runOnBar()==_OPEN_LONG) {
      if (checkMaxDailyOpenQty()&&bool (TRADING_CIRCUIT_BREAKER&IS_UNLOCKED)) {
         TRADING_CIRCUIT_BREAKER=IS_LOCKED;
         if (lp.execute(_OPEN_LONG)) {
            #ifdef _DEBUG_MAIN_LOOP
               ss="runOnBar -> New long opened";
               writeLog
               printf(ss);
            #endif  
         } else {
            #ifdef _DEBUG_MAIN_LOOP
               ss="runOnBar -> New long could not be opened";
               writeLog
               printf(ss);
            #endif                
         }
         TRADING_CIRCUIT_BREAKER=IS_UNLOCKED;               // Enable trading subsystem 
      }
   }


   if (activeStrategy.runOnBar()==_OPEN_SHORT) {
      if (checkMaxDailyOpenQty()&&bool (TRADING_CIRCUIT_BREAKER&IS_UNLOCKED)) {  
         if (sp.execute(_OPEN_SHORT)) {
            #ifdef _DEBUG_MAIN_LOOP_ONBAR
               ss="runOnBar -> New short opened";
               writeLog
               printf(ss);
            #endif  
         } else {
            #ifdef _DEBUG_MAIN_LOOP_ONBAR
               ss="runOnBar -> New short could not be opened";
               writeLog
               printf(ss);
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

   #ifdef _DEBUG_MAIN_LOOP      
      ss="runOnDay -> ...."; 
      writeLog
      printf(ss);
   #endif 

   // Check if a reload of the strategy is in order based on a new optimization run
   if (!MQLInfoInteger(MQL_OPTIMIZATION)) {
      #ifdef _DEBUG_MAIN_LOOP 
         ss="runOnDay -> ********** reloadStrategy ********** ";
         printf(ss);
      #endif
      optimization.reloadStrategy();
   }


   lp.execute(_RUN_ONDAY);
   sp.execute(_RUN_ONDAY);
   mo.execute(_RUN_ONDAY);
   lh.execute(_RUN_ONDAY);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMain::runOnTimer() {

   #ifdef _DEBUG_MAIN_LOOP 
      string ss;
      ss="runOnTimer -> ...."; 
      writeLog
      printf(ss);
   #endif

   activeStrategy.runOnTimer();
   
}