//+------------------------------------------------------------------+
//|                                                         myEA.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"



//+------------------------------------------------------------------+
// GLOBALS
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   printf ("===============OnInit==================");

   

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { 

   printf ("===============OnDeinit==================");
   EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

   printf ("===============OnTick==================");

}       


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTrade() {
   



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {

   
}


//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
int OnTesterInit() {

   printf ("===============OnTesterInit==================");
   /*
   TesterInit - this event is generated during the start of optimization 
   in the strategy tester before the very first pass. 
   The TesterInit event is handled using the OnTesterInit() function. 
   During the start of optimization, an Expert Advisor with this handler is 
   automatically loaded on a separate terminal chart with the symbol and
   period specified in the tester, and receives the TesterInit event. 
   The function is used to initiate an Expert Advisor before start of
   optimization for further processing of optimization results.
   */
   return(INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit() {

   /*
   TesterDeinit - this event is generated after the end of Expert Advisor 
   optimization in the strategy tester. 
   The TesterDeinit event is handles using the OnTesterDeinit() function.
   An Expert Advisor with this handler is automatically loaded on a chart at 
   the start of optimization, and receives TesterDeinit after its completion. 
   The function is used for final processing of all optimization results.
   */

   printf ("===============OnTesterDeinit==================");


}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {

   //This function is called right before the call of OnDeinit() 
   printf ("================OnTester=================");
   
   /*
   Tester - this event is generated after completion of Expert Advisor testing 
   on history data. 
   The Tester event is handled using the OnTester() function. 
   This function can be used only when testing Expert Advisor and is intended 
   primarily for the calculation of a value that is used as a Custom max 
   criterion for genetic optimization of input parameters.
   */

   return 0;

}
//+------------------------------------------------------------------+
void OnTesterPass() {

   printf ("================OnTesterPass=================");
   
   /*
   TesterPass - this event is generated when a new data frame is received. 
   The TesterPass event is handled using the OnTesterPass() function. 
   An Expert Advisor with this handler is automatically loaded on a separate 
   terminal chart with the symbol/period specified for testing, and receives the
   TesterPass event when a frame is received during optimization.
   The function is used for dynamic handling of optimization results "on the spot" 
   without waiting for its completion. 
   Frames are added using the FrameAdd() function, which can be called after the
   end of a single pass in the OnTester() handler.
   */
   
   
   
   

}
