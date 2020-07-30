//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


//#define  STATS_FRAME  1

#include "EAEnum.mqh"
//#include "EADataFrame.mqh"
//#include "EANeuralNetwork.mqh"
//#include "EAInputsOutputs.mqh"
//#include "EATechnicalParameters.mqh"

class EAPosition;

class EARunOptimization {

//=========
private:
//=========
   //EATechnicalParameters   *tech;
   //EAInputsOutputs         *io;      // NN Input Output Module
   //EADataFrame             *df;      // The dataframe object
   //EANeuralNetwork         *nn;      // The network 
   

   int               _dnnNumber;
   int               _dnnType;
   
   struct results {
      double v0[20];
      double v1[50];
      double v2[150];
   };
   
   results  v[1];


//=========
protected:
//=========
   
   int         _strategyNumber;

   void        dropSQLOptimizationTables();
   void        createSQLOptimizationTables();


//=========
public:
//=========
EARunOptimization();
~EARunOptimization();

   int         OnTesterInit(void);
   void        OnTesterDeinit(void);
   void        OnTester(const double OnTesterValue);
   void        OnTesterPass();

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EARunOptimization::EARunOptimization() {



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EARunOptimization::~EARunOptimization() {

}

//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
int EARunOptimization::OnTesterInit(void) {

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

   string ss="OnTesterInit -> ....";
   writeLog;
   printf(ss);

   //--- create or open the database in the common terminal folder
   _optimizeDBHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON| DATABASE_OPEN_CREATE);
   if (_optimizeDBHandle==INVALID_HANDLE) {
      printf("OnTesterInit -> Optimization DB open failed with code %d",GetLastError());
      ExpertRemove();
   } else {
      ss="OnTesterInit -> Optimization DB open success";
      writeLog
   }

   if (DatabaseTableExists(_optimizeDBHandle, "PASSES")) {
      string sql="DROP TABLE PASSES";
      if(!DatabaseExecute(_optimizeDBHandle,sql)) {
         ss=StringFormat("OnTesterInit -> Failed to drop table PASSES with code %d", GetLastError());
         writeLog;
         printf(ss);
      } else {
         ss="OnTesterInit -> Drop table PASSES success ";
         writeLog;
         printf(ss);
      }
   } else {
      ss="OnTesterInit -> PASSES does not exist will be created";
      writeLog;
      printf(ss);
   }

   createSQLOptimizationTables();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::createSQLOptimizationTables() {

   string ss="createSQLOptimizationTables -> ....";
   writeLog;
   printf(ss);
   

//--- create the _PASSES table
string sqlTable1 =   "CREATE TABLE PASSES ("
   "trades              INT,"
   "winningTrades       INT,"
   "profit              REAL,"
   "grossProfit         REAL,"
   "grossLoss           REAL,"
   "sharpeRatios        REAL,"
   "profitFactor        REAL,"
   "recoveryFactor      REAL,"
   "expectedPayoff      REAL,"
   "onTester            REAL)";


   if (!DatabaseExecute(_optimizeDBHandle, sqlTable1)) {
      ss=StringFormat("createSQLOptimizationTables -> create table PASSES failed with code %d", GetLastError());
      writeLog
      printf(ss);
      ExpertRemove();
   } else {
      ss="createSQLOptimizationTables -> Create table PASSES success";
      writeLog
      printf(ss);
   }



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::OnTesterPass() {

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
   string ss="OnTesterPass ->  ....";
   writeLog;
   printf(ss);


      string name ="";  // Public name/frame label
      ulong  pass =0;   // Number of the optimization pass at which the frame is added
      long   id   =0;   // Public id of the frame
      double val  =0.0; // Single numerical value of the frame
      //---
      FrameNext(pass,name,id,val,v);
      //---
      //Print("Name: ",name," pass: "+IntegerToString(pass)+"; STAT_PROFIT: ",DoubleToString(v[1].v0[2],2), "SHARPE: ",DoubleToString(v[1].v0[5],2));

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::OnTester(const double onTesterValue) {

   /*
      Tester - this event is generated after completion of Expert Advisor testing 
      on history data. 
      The Tester event is handled using the OnTester() function. 
      This function can be used only when testing Expert Advisor and is intended 
      primarily for the calculation of a value that is used as a Custom max 
      criterion for genetic optimization of input parameters.
   */

   string ss="OnTester ->  ....";
   writeLog;
   printf(ss);

   int   trades=(int)TesterStatistics(STAT_PROFIT_TRADES);

   if (trades>0) { 
      double win_trades_percent=0;
      win_trades_percent=TesterStatistics(STAT_PROFIT_TRADES)*100./trades;
      //--- fill in the array with test results
      v[0].v0[0]=trades; 
      v[0].v0[1]=win_trades_percent;
      v[0].v0[2]=TesterStatistics(STAT_PROFIT);
      v[0].v0[3]=TesterStatistics(STAT_GROSS_PROFIT);
      v[0].v0[4]=TesterStatistics(STAT_GROSS_LOSS);
      v[0].v0[5]=TesterStatistics(STAT_SHARPE_RATIO);
      v[0].v0[6]=TesterStatistics(STAT_PROFIT_FACTOR);
      v[0].v0[7]=TesterStatistics(STAT_RECOVERY_FACTOR);
      v[0].v0[8]=TesterStatistics(STAT_EXPECTED_PAYOFF);
      v[0].v0[9]=onTesterValue;

      v[0].v1[0]=ilsize;
      v[0].v1[1]=ifptl;
      v[0].v1[2]=ifltl;
      v[0].v1[3]=ifpts;
      v[0].v1[4]=iflts;
      v[0].v1[5]=imaxlong;
      v[0].v1[6]=imaxshort;
      v[0].v1[7]=imaxdaily;
      v[0].v1[8]=imaxdailyhold;   
      v[0].v1[9]=ilongHLossamt;
      v[0].v1[10]=imaxmg;
      v[0].v1[11]=imgmulti;

      //--- create a data frame and send it to the terminal
      if (!FrameAdd(MQLInfoString(MQL_PROGRAM_NAME)+"_stats", STATS_FRAME, v[0].v0[0], v)) {
         ss=StringFormat(" -> Stats Frame add error: ", GetLastError());
         printf(ss);
      } else {
         ss=StringFormat(" -> Stats Frame added:%.2f",v[0].v0[0]);  
         printf(ss);
      }

   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::OnTesterDeinit() {

   /*
      TesterDeinit - this event is generated after the end of Expert Advisor 
      optimization in the strategy tester. 
      The TesterDeinit event is handles using the OnTesterDeinit() function.
      An Expert Advisor with this handler is automatically loaded on a chart at 
      the start of optimization, and receives TesterDeinit after its completion. 
      The function is used for final processing of all optimization results.
   */

   string ss="OnTesterDeinit ->  ....";
   printf(ss);


   //--- variables for reading frames
   string         name;
   ulong          iterationNumber;
   long           id;
   double         value;

   //--- move the frame pointer to the beginning
   FrameFirst();
   FrameFilter("", STATS_FRAME); // select frames with trading statistics for further work

   ss="Loop start->  ....";
   printf(ss);

   while (FrameNext(iterationNumber, name, id, v[0].v0[0], v)) {

      ss="In Loop ->  ....";
      printf(ss);

      //if (v[0].v0[2]<100) continue;
   
      //=============
      // PASSES TABLE
      //=============
         string sql=StringFormat("INSERT INTO PASSES ("
         "trades,winningTrades,profit,grossProfit,grossLoss,sharpeRatios,profitFactor,recoveryFactor,expectedPayoff,onTester "
         ") VALUES (%d,%d,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f)",
         v[0].v0[0], v[0].v0[1], v[0].v0[2], v[0].v0[3], v[0].v0[4], v[0].v0[5],
         v[0].v0[6], v[0].v0[7], v[0].v0[8], v[0].v0[9]);

   printf(sql);
      
         if (!DatabaseExecute(_optimizeDBHandle, sql)) {
            ss=StringFormat("OnTesterDeinit -> Failed to insert PASSES with code %d", GetLastError());
            writeLog
            printf(ss);
            break;
         } else {
            ss=" -> Insert into PASSES succcess";
            writeLog
            printf(ss);

         }  
   }
   

}




