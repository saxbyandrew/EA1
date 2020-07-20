//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_MARTINGALE

#include "EAEnum.mqh"
#include "EAPositionBase.mqh"



class EAMartingale : public EAPositionBase {

//=========
private:
//=========
   //void        copyValuesFromInputs();
   double      nextTargetLevel;
   bool        triggerNewMartingale();

//=========
protected:
//=========

   void     updateOnInterval(EAEnum interval);
   bool     newPosition(EAPosition *pp);
   void     closeOnStealthProfit();
   void     closeOnStealthLoss();
   void     managePositions();
//=========
public:
//=========

   EAMartingale();
   ~EAMartingale();
   virtual int Type() const {return _MARTINGALE;};

   virtual bool    execute(EAEnum action);  

 //

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAMartingale::EAMartingale() {


   if (usingStrategyValue.optimizationMartingale) {
      #ifdef _DEBUG_HEDGE
         ss=StringFormat(" -> Using optimization inputs");
         Print(ss);
      #endif 
      
      //dnn=new EANeuralNetwork(_STRATEGY_OPTIMIZATION);
      //copyValuesFromInputs();    
   } else {
      
      //dnn=new EANeuralNetwork(usingStrategyValue.strategyNumber, usingStrategyValue.dnnMartingaleName, usingStrategyValue.dnnMartingaleNumber);
      //#ifdef _DEBUG_HEDGE
         //ss=StringFormat(" -> Using strategy %d with weights %d",usingStrategyValue.dnnMartingaleName, usingStrategyValue.dnnMartingaleNumber);
         //Print(ss);
      //#endif 
   }

   //fileHandle=openCSVFile("mgSwapCosts");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAMartingale::~EAMartingale() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMartingale::updateOnInterval(EAEnum interval) {

//----
   #ifdef _DEBUG_MARTINGALE 
   Print (__FUNCTION__); 
   #endif  
  //----

   
      if (interval==_RUN_ONBAR||interval==_RUN_ONTICK) {
         for (int i=0;i<martingalePositions.Total();i++) {
            gmp;
            usingPositionValue.calcPositionPnL();
            #ifdef _DEBUG_MARTINGALE
               printf("M,%d,%g",p.ticket,p.currentPnL);
               #endif 
         }
      }


      if (interval==_RUN_ONDAY) {
         for (int i=0;i<martingalePositions.Total();i++) {
            gmp;
            usingPositionValue.daysOpen++; 
            usingPositionValue.calcPositionSwapCost();
            #ifdef _DEBUG_MARTINGALE
               printf("M,%d,%d,%g",p.ticket,,p.daysOpen,p.swapCosts);
            #endif 
         }
      }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMartingale::closeOnStealthProfit() {

    //----
   #ifdef _DEBUG_MARTINGALE 
      Print (__FUNCTION__); 
      string ss;
   #endif  
  //----
   MqlTick last_tick;
   SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
   bool inProfit;

    //----
   #ifdef _DEBUG_MARTINGALE 
      ss=StringFormat(" -> Number of martingales:%d",martingalePositions.Total());
      Print(ss);
   #endif  
  //----

   for (int i=0;i<martingalePositions.Total();i++) {
      gmp; 
      usingPositionValue.calcPositionPnL();

      if (last_tick.bid>p.fixedProfitTargetLevel)  {inProfit=true;};
      if (last_tick.bid<p.fixedProfitTargetLevel)  {inProfit=false;}; 

      if (bool (p.closingTypes&_IN_PROFIT_CLOSE_POSITION)) {  
         if (inProfit) {
            if (Trade.PositionClose(p.ticket,p.deviationInPoints)) {
               #ifdef _DEBUG_MARTINGALE 
                  Print (" -> Martingale Close in profit"); 
               #endif
               usingStrategyValue.closeSQLPosition(p);
               if (martingalePositions.Delete(i)) {
                  #ifdef _DEBUG_MARTINGALE 
                     Print (" -> Martingale Close in profit object removed from CList");  
                  #endif 
                  
                  return;                      
               }
            }  
         }
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAMartingale::closeOnStealthLoss() {


   //----
   #ifdef _DEBUG_MARTINGALE 
      Print (__FUNCTION__); 
   string ss;
   #endif  
   //----
   MqlTick last_tick;
   SymbolInfoTick(Symbol(),last_tick);                               // Get the lastest tick information
   bool inLoss;

   for (int i=0;i<martingalePositions.Total();i++) {
      gmp; 

      if (last_tick.bid<p.fixedLossTargetLevel)    {inLoss=true;};
      if (last_tick.bid>p.fixedLossTargetLevel)    {inLoss=false;};

      // Check for LONG position in loss copied over
      if (inLoss&&usingPositionValue.status==_LONG) {                // found a new LONg loosing Long
         #ifdef _DEBUG_MARTINGALE 
            ss=StringFormat(" -> LONG Object with Ref:%u",p);
            Print(ss);
         #endif
         newPosition(p);                                             // Create a new MG
         return;                                                     // ignore others till the next tick
      }

      // Check for loosing MG position as well
      if (inLoss&&usingPositionValue.status==_MARTINGALE) {

         if (p.Next()==NULL) { 
            string s=StringFormat("-> possible MG for ticket:%d",usingPositionValue.ticket);
            newPosition(p);                         // Try open MG on a losing MG
         }
         #ifdef _DEBUG_MARTINGALE 
            ss=StringFormat(" -> MG Object with Ref:%u",p);
            Print(ss);
         #endif
      }

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAMartingale::newPosition(EAPosition *pp) {

   #ifdef _DEBUG_MARTINGALE 
      Print(__FUNCTION__); string ss; string sss; 
   #endif 

   int cnt=0;

      // Count MG totals only, exclude and LONGS moved over
      for (int i=0;i<martingalePositions.Total();i++) {
         gmp; 
         if (usingPositionValue.status==_MARTINGALE) ++cnt;
      }
      // ----
      #ifdef _DEBUG_MARTINGALE
         Print (" -> Quantity checked mpg count:",cnt);
      #endif 
      // ----
      if (cnt>param.maxMartingalePositions) return false;

   //----
      #ifdef _DEBUG_MARTINGALE
      for (int i=0;i<martingalePositions.Total();i++) {
         gmp;
         switch (p.status) {
            case _LONG: sss="LONG";
            break;
            case _MARTINGALE: sss="MG";
            break;
         }
         ss=StringFormat("T:%d %s",p.ticket,sss);
         Print(sss);
      }
      #endif
   //----

      if (martingalePositions.Total()>param.maxMartingalePositions) return false;

         // Build a new position object based on defaults
         EAPosition *p=new EAPosition();
         p.strategyNumber=param.strategyNumber;
         p.entryPrice=getUpdatedPrice(ORDER_TYPE_BUY,_TOOPEN);
         p.orderTypeToOpen=ORDER_TYPE_BUY;                             
         p.closingTypes=param.closingTypes;
         p.status=_MARTINGALE;

         // update this new MG based on the entry positions values
         p.lotSize=pp.lotSize*usingStrategyValue.martingaleMultiplier;           // New lot Size
         p.fixedProfitTargetLevel=p.entryPrice+(usingStrategyValue.fixedProfitTargetLong*usingStrategyValue.martingaleMultiplier);
         p.fixedLossTargetLevel=p.entryPrice+(usingStrategyValue.fixedLossTargetShort*usingStrategyValue.martingaleMultiplier);
         pp.status=_MARTINGALE;                                                  // Re status the position that causes this 


         if (openPosition(p)) {
            if (martingalePositions.Add(p)!=-1) {
               #ifdef _DEBUG_MARTINGALE
                     Print(" -> New martingale position opened and added to CList"); 
               #endif 

               return true;
            }            
         } else {
            #ifdef _DEBUG_MARTINGALE
               Print(" -> New martingale position opened failed"); 
            #endif 
         }
   
   return false;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAMartingale::execute(EAEnum action) {

    //----
   #ifdef _DEBUG_MARTINGALE 
      Print (__FUNCTION__);
      string ss; 
   #endif  

   // Check if we are even doing martingales
   if (bool (usingStrategyValue.closingTypes&_IN_LOSS_OPEN_MARTINGALE)==false) return false;


   if (ACTIVE_HEDGE==_YES) {
      #ifdef _DEBUG_MARTINGALE
         Print(" -> In MG Hedge is active ....");
      #endif   
      return false;
   }

   switch (action) {
      case _RUN_ONTICK:    closeOnStealthProfit();
                           closeOnStealthLoss();
                           updateOnInterval(_RUN_ONTICK);
      break;
      case _RUN_ONBAR:    updateOnInterval(_RUN_ONBAR);
                           
      break;
      case _RUN_ONDAY:    updateOnInterval(_RUN_ONDAY);
      break;

   }
   
   return true;

}
