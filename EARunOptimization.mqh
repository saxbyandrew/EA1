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
#include "EAOptimizationInputs.mqh"
#include "EAOptimizationIndicator.mqh"


class EAPosition;

class EARunOptimization {

//=========
private:
//=========

   CArrayObj   allIndicators;

   string   ss;

   struct results {
      double vp[32];          // Metrics Profit loss etc
      double vs[12];          // Strategy
      double vn[10];          // Network
      double vv[20][14];      // Technicals
   };
   results v[1];
   

   //int   buildSQLTableRequest(string indicatorName, int idx);
   //void  reloadValues(double &theArray[], string indicatorName,int idx);


//=========
protected:
//=========
   

   void        dropSQLOptimizationTables();
   void        createSQLOptimizationTables();
   void        createSQLOptimizationTables(string sql);


//=========
public:
//=========
EARunOptimization();
~EARunOptimization();

   int         OnTesterInit(void);
   void        OnTesterDeinit(void);
   void        OnTester();
   void        OnTesterPass();

   // Called inn a non optimization mode only !
   void        reloadStrategy();

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

/*
   //--- create or open the database in the common terminal folder
   _optimizeDBHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON| DATABASE_OPEN_CREATE);
   if (_optimizeDBHandle==INVALID_HANDLE) {
      ss=StringFormat("OnTesterInit -> Optimization DB open failed with code %d",GetLastError());
      pss
      ExpertRemove();
   } else {
      ss="OnTesterInit -> Optimization DB open success";
      pss
   }

   // ----------------------------------------------------------------
   string sql="DROP TABLE OPTIMIZATION; DROP TABLE PASSES; DROP TABLE STRATEGY; DROP TABLE TECHNICALS; DROP TABLE NNETWORK;";
   if(!DatabaseExecute(_optimizeDBHandle,sql)) {
      ss=StringFormat("OnTesterInit -> Failed to drop all tables with code %d", GetLastError());
      pss
   } else {
      ss="OnTesterInit -> Dropping all table success ";
      pss
   }

   createSQLOptimizationTables();

   // This strategy will use these indicators 
   // make sure that this lines up in a 1to1 with other sections in the code
   // 1 EAOptimizationInputs.mqh
   // 2 EARunOptimization::OnTester
   // 3 EATechnicalParameters::copyValuesFromOptimizationInputs()
   #ifdef _USE_ADX 
      allIndicators.Add(new EAOptimizationIndicator("i1a_","ADX",10)); //i1a
      allIndicators.Add(new EAOptimizationIndicator("i1b_","ADX",11));
   #endif
   #ifdef _USE_RSI 
      allIndicators.Add(new EAOptimizationIndicator("i2a_","RSI",20));  //i2a
      allIndicators.Add(new EAOptimizationIndicator("i2b_","RSI",21));
   #endif
   #ifdef _USE_MFI 
      allIndicators.Add(new EAOptimizationIndicator("i3a_","MFI",30)); //13a
      allIndicators.Add(new EAOptimizationIndicator("i3b_","MFI",31));
   #endif
   #ifdef _USE_SAR 
      allIndicators.Add(new EAOptimizationIndicator("i4a_","SAR",40));  //14a
      allIndicators.Add(new EAOptimizationIndicator("i4b_","SAR",41));
   #endif
   #ifdef _USE_ICH   
      allIndicators.Add(new EAOptimizationIndicator("i5a_","ICH",50));  //i5a
      allIndicators.Add(new EAOptimizationIndicator("i5b_","ICH",51));
   #endif
   #ifdef _USE_RVI  
      allIndicators.Add(new EAOptimizationIndicator("i6a_","RVI",60));  //i6a
      allIndicators.Add(new EAOptimizationIndicator("i6b_","RVI",61));
   #endif
   #ifdef _USE_STOC  
      allIndicators.Add(new EAOptimizationIndicator("i7a_","STOC",70));  //i7a
      allIndicators.Add(new EAOptimizationIndicator("i7b_","STOC",71));
   #endif
   #ifdef _USE_OSMA
      allIndicators.Add(new EAOptimizationIndicator("i8a_","OSMA",80));  //i8a
      allIndicators.Add(new EAOptimizationIndicator("i8b_","OSMA",81));
   #endif
   #ifdef _USE_MACD 
      allIndicators.Add(new EAOptimizationIndicator("i9a_","MACD",90)); //i9a
      allIndicators.Add(new EAOptimizationIndicator("i9b_","MACD",91));
   #endif
   #ifdef _USE_MACDJB 
      allIndicators.Add(new EAOptimizationIndicator("i10a_","MACDJB",100)); //i10a
      allIndicators.Add(new EAOptimizationIndicator("i10b_","MACDJB",101));
   #endif
*/

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::createSQLOptimizationTables(string sql) {

/*
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table failed with code %d", GetLastError());
      ss=sql;
      pss
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table success";
         pss
      #endif
   }
*/
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::createSQLOptimizationTables() {

/*
   string sql;

   ss="createSQLOptimizationTables -> ....";
   pss

   // ----------------------------------------------------------------
   sql =   "CREATE TABLE OPTIMIZATION ("
      "strategyNumber REAL,"
      "passNumber REAL,"
      "reload REAL)";

      createSQLOptimizationTables(sql);
   
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE PASSES ("
      "statWITHDRAWAL REAL,"
      "statPROFIT REAL,"
      "statGROSSPROFIT REAL,"
      "statGROSSLOSS REAL,"
      "statMAXPROFITTRADE REAL,"
      "statMAXLOSSTRADE REAL,"
      "statCONPROFITMAX REAL,"
      "statCONPROFITMAXTRADES REAL,"
      "statMAXCONWINS REAL,"
      "statMAXCONPROFITTRADES REAL,"
      "statBALANCEMIN REAL,"
      "statBALANCEDD REAL,"
      "statEQUITYDDPERCENT REAL,"
      "statEQUITYDDRELPERCENT REAL,"
      "statEQUITYDDRELATIVE REAL,"
      "statEXPECTEDPAYOFF REAL,"
      "statRECOVERYFACTOR REAL,"
      "statSHARPERATIO REAL,"
      "statMINMARGINLEVEL REAL,"
      "statCUSTOMONTESTER REAL,"
      "statDEALS REAL,"
      "statTRADES REAL,"
      "statPROFITTRADES REAL,"
      "statLOSSTRADES REAL,"
      "statSHORTTRADES REAL,"
      "statLONGTRADES REAL,"
      "statPROFITSHORTTRADES REAL,"
      "statPROFITLONGTRADES REAL,"
      "statPROFITTRADESAVGCON REAL,"
      "statLOSSTRADESAVGCON REAL,"
      "onTester REAL,"
      "passNumber REAL)";
      

      createSQLOptimizationTables(sql);


    // ----------------------------------------------------------------
   sql =   "CREATE TABLE STRATEGY ("
      "lotSize             REAL," 
      "fpt                 REAL,"
      "flt                 REAL,"
      "maxPositions        REAL,"
      "maxdaily            REAL,"
      "maxdailyhold        REAL,"
      "maxmg               REAL,"
      "mgmulti             REAL,"
      "hedgeLossAmount     REAL,"
      "passNumber REAL)";

      createSQLOptimizationTables(sql);

   // ----------------------------------------------------------------
   sql =   "CREATE TABLE NNETWORK ("
      "networkType            REAL,"
      "dfSize                 REAL," 
      "triggerThreshold       REAL,"
      "trainWeightsThreshold  REAL,"
      "nnLayer1               REAL,"
      "nnLayer2               REAL,"
      "restarts               REAL,"
      "decay                  REAL,"
      "wStep                  REAL,"
      "maxITS                 REAL,"
      "passNumber REAL)";

      createSQLOptimizationTables(sql);

   // ----------------------------------------------------------------
   sql = "CREATE TABLE TECHNICALS ("
      "passNumber	REAL,"
      "indicatorName	TEXT,"
      "period	REAL,"
      "movingAverage	REAL,"
      "slowMovingAverage	REAL,"
      "fastMovingAverage	REAL,"
      "movingAverageMethod	REAL,"
      "appliedPrice	REAL,"
      "stepValue	REAL,"
      "maxValue	REAL,"
      "signalPeriod	REAL,"
      "tenkanSen	REAL,"
      "kijunSen	REAL,"
      "spanB	REAL,"
      "kPeriod	REAL,"
      "dPeriod	REAL,"
      "stocPrice REAL,"
      "appliedVolume REAL,"
      "useBuffers REAL,"
      "ttl REAL,"
      "incDecFactor REAL,"
      "inputPrefix,"
      "upperLevel REAL,"
      "lowerLevel REAL)";

      createSQLOptimizationTables(sql);
*/

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
   ss="EARunOptimization -> OnTesterPass ->  ....";
   pss
   

      string name = "";  // Public name/frame label
      ulong  pass =0;   // Number of the optimization pass at which the frame is added
      long   id   =0;   // Public id of the frame
      double val  =0.0; // Single numerical value of the frame
      //---
      //FrameNext(pass,name,id,val);
      //ss=StringFormat(" ---> Name: %s pass:%u",name,DoubleToString(pass));
      //pss
      

}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::OnTester() {

   return;

   /*
      Tester - this event is generated after completion of Expert Advisor testing 
      on history data. 
      The Tester event is handled using the OnTester() function. 
      This function can be used only when testing Expert Advisor and is intended 
      primarily for the calculation of a value that is used as a Custom max 
      criterion for genetic optimization of input parameters.
   */

   int row=0, col=0;                      // Counters for technical array

   #ifdef _DEBUG_OPTIMIZATION
      ss="EARunOptimization -> OnTester -> ";
      pss
   #endif
   
   if (TesterStatistics(STAT_PROFIT)<istrategyGrossProfit) return;
      

  // ----------------------------------------------------------------
      v[0].vp[0]=0;  
      v[0].vp[1]=TesterStatistics(STAT_WITHDRAWAL);
      v[0].vp[2]=TesterStatistics(STAT_PROFIT);
      v[0].vp[3]=TesterStatistics(STAT_GROSS_PROFIT);
      v[0].vp[4]=TesterStatistics(STAT_GROSS_LOSS);
      v[0].vp[5]=TesterStatistics(STAT_MAX_PROFITTRADE);
      v[0].vp[6]=TesterStatistics(STAT_MAX_LOSSTRADE);
      v[0].vp[7]=TesterStatistics(STAT_CONPROFITMAX);
      v[0].vp[8]=TesterStatistics(STAT_CONPROFITMAX_TRADES);
      v[0].vp[9]=TesterStatistics(STAT_MAX_CONWINS);
      v[0].vp[10]=TesterStatistics(STAT_MAX_CONPROFIT_TRADES);
      v[0].vp[11]=TesterStatistics(STAT_BALANCEMIN);
      v[0].vp[12]=TesterStatistics(STAT_BALANCE_DD);
      v[0].vp[13]=TesterStatistics(STAT_EQUITYDD_PERCENT);
      v[0].vp[14]=TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
      v[0].vp[15]=TesterStatistics(STAT_EQUITY_DD_RELATIVE);
      v[0].vp[16]=TesterStatistics(STAT_EXPECTED_PAYOFF);
      v[0].vp[17]=TesterStatistics(STAT_RECOVERY_FACTOR);
      v[0].vp[18]=TesterStatistics(STAT_SHARPE_RATIO);
      v[0].vp[19]=TesterStatistics(STAT_MIN_MARGINLEVEL);
      v[0].vp[20]=TesterStatistics(STAT_CUSTOM_ONTESTER);
      v[0].vp[21]=TesterStatistics(STAT_DEALS);
      v[0].vp[22]=TesterStatistics(STAT_TRADES);
      v[0].vp[23]=TesterStatistics(STAT_PROFIT_TRADES);
      v[0].vp[24]=TesterStatistics(STAT_LOSS_TRADES);
      v[0].vp[25]=TesterStatistics(STAT_SHORT_TRADES);
      v[0].vp[26]=TesterStatistics(STAT_LONG_TRADES);
      v[0].vp[27]=TesterStatistics(STAT_PROFIT_SHORTTRADES);
      v[0].vp[28]=TesterStatistics(STAT_PROFIT_LONGTRADES);
      v[0].vp[29]=TesterStatistics(STAT_PROFITTRADES_AVGCON);
      v[0].vp[30]=TesterStatistics(STAT_LOSSTRADES_AVGCON);
      v[0].vp[31]=0;
   // ----------------------------------------------------------------
      v[0].vs[0]=ilsize;
      v[0].vs[1]=ifpt;
      v[0].vs[2]=iflt;
      v[0].vs[3]=imaxPositions;
      v[0].vs[4]=imaxdaily;
      v[0].vs[5]=imaxdailyhold;   
      v[0].vs[6]=imaxmg;
      v[0].vs[7]=imgmulti;
      v[0].vs[8]=ihedgeLossAmount;

   // ----------------------------------------------------------------
      v[0].vn[0]=inetworkType;
      v[0].vn[1]=idataFrameSize;
      v[0].vn[2]=itriggerThreshold;
      v[0].vn[3]=itrainWeightsThreshold;
      v[0].vn[4]=innLayer1;
      v[0].vn[5]=innLayer2;
      v[0].vn[6]=irestarts;
      v[0].vn[7]=idecay;
      v[0].vn[8]=iwStep;
      v[0].vn[9]=imaxITS;
      

      // ----------------------------------------------------------------
      #ifdef _USE_ADX   //i1a // Checked
      // ----------------------------------------------------------------
      // v[0].vv[0][0,1,2]
      // i1a_
      v[0].vv[row][col++]=10;
      v[0].vv[row][col++]=i1a_period;
      v[0].vv[row][col++]=i1a_movingAverage;
      v[0].vv[row][col++]=i1a_crossLevel;

      row++; col=0;
      // i1b_
      v[0].vv[row][col++]=11;
      v[0].vv[row][col++]=i1b_period;
      v[0].vv[row][col++]=i1b_movingAverage;
      v[0].vv[row][col++]=i1b_crossLevel;

      row++; col=0;
      #endif

      //----------------------------------------------------------------
      #ifdef _USE_RSI   //i2a // Checked
      // ----------------------------------------------------------------
      // i1a_
      v[0].vv[row][col++]=20;
      v[0].vv[row][col++]=i2a_period;
      v[0].vv[row][col++]=i2a_movingAverage;
      v[0].vv[row][col++]=i2a_appliedPrice;
      v[0].vv[row][col++]=i2a_upperLevel;
      v[0].vv[row][col++]=i2a_lowerLevel;
      row++; col=0;
      // i2b
      v[0].vv[row][col++]=21;
      v[0].vv[row][col++]=i2b_period;
      v[0].vv[row][col++]=i2b_movingAverage;
      v[0].vv[row][col++]=i2b_appliedPrice;
      v[0].vv[row][col++]=i2a_upperLevel;
      v[0].vv[row][col++]=i2a_lowerLevel;
      row++; col=0;
      #endif

      //----------------------------------------------------------------
      #ifdef _USE_MFI   //i3a // Checked
      // ----------------------------------------------------------------
      // i4a_
      v[0].vv[row][col++]=30;
      v[0].vv[row][col++]=i3a_period;
      v[0].vv[row][col++]=i3a_movingAverage;
      v[0].vv[row][col++]=i3a_appliedVolume;
      row++; col=0;
      // i4b
      v[0].vv[row][col++]=31;
      v[0].vv[row][col++]=i3b_period;
      v[0].vv[row][col++]=i3b_movingAverage;
      v[0].vv[row][col++]=i3b_appliedVolume;
      row++; col=0;
      #endif
      //----------------------------------------------------------------
      #ifdef _USE_SAR   //i4a // Checked
      // ----------------------------------------------------------------
      // i4a_
      v[0].vv[row][col++]=40;
      v[0].vv[row][col++]=i4a_period;
      v[0].vv[row][col++]=i4a_stepValue;
      v[0].vv[row][col++]=i4a_maxValue;
      row++; col=0;
      // i4b
      v[0].vv[row][col++]=41;
      v[0].vv[row][col++]=i4b_period;
      v[0].vv[row][col++]=i4b_stepValue;
      v[0].vv[row][col++]=i4b_maxValue;
      row++; col=0;
      #endif

      //----------------------------------------------------------------
      #ifdef _USE_ICH   //i5a // Checked
      // ----------------------------------------------------------------
      // i5a_
      v[0].vv[row][col++]=50;
      v[0].vv[row][col++]=i5a_period;
      v[0].vv[row][col++]=i5a_tenkanSen;
      v[0].vv[row][col++]=i5a_kijunSen;
      v[0].vv[row][col++]=i5a_spanB;
      row++; col=0;
      // i5b
      v[0].vv[row][col++]=51;
      v[0].vv[row][col++]=i5b_period;
      v[0].vv[row][col++]=i5b_tenkanSen;
      v[0].vv[row][col++]=i5b_kijunSen;
      v[0].vv[row][col++]=i5b_spanB;
      row++; col=0;
      #endif


      // ----------------------------------------------------------------
      #ifdef _USE_RVI   //i6a // Checked
      // ----------------------------------------------------------------
      // i6a_
      v[0].vv[row][col++]=60;
      v[0].vv[row][col++]=i6a_period;
      v[0].vv[row][col++]=i6a_movingAverage;
      row++; col=0;
      // i6b
      v[0].vv[row][col++]=61;
      v[0].vv[row][col++]=i6b_period;
      v[0].vv[row][col++]=i6b_movingAverage;
      row++; col=0;
      #endif

      // ----------------------------------------------------------------
      #ifdef _USE_STOC  //i7a
      // ----------------------------------------------------------------
      // i7a_
      v[0].vv[row][col++]=90;
      v[0].vv[row][col++]=i7a_period;
      v[0].vv[row][col++]=i7a_kPeriod;
      v[0].vv[row][col++]=i7a_dPeriod;
      v[0].vv[row][col++]=i7a_slowing;
      v[0].vv[row][col++]=i7a_maMethod;
      v[0].vv[row][col++]=i7a_stocPrice;

      row++; col=0;
      // i7b_
      v[0].vv[row][col++]=90;
      v[0].vv[row][col++]=i7b_period;
      v[0].vv[row][col++]=i7b_kPeriod;
      v[0].vv[row][col++]=i7b_dPeriod;
      v[0].vv[row][col++]=i7b_slowing;
      v[0].vv[row][col++]=i7b_maMethod;
      v[0].vv[row][col++]=i7b_stocPrice;
      row++; col=0;
      #endif

      // ----------------------------------------------------------------
      #ifdef _USE_OSMA //i8a // Checked
      // ----------------------------------------------------------------
      v[0].vv[row][col++]=80;
      v[0].vv[row][col++]=i8a_period;
      v[0].vv[row][col++]=i8a_slowMovingAverage;
      v[0].vv[row][col++]=i8a_fastMovingAverage;
      v[0].vv[row][col++]=i8a_signalPeriod;
      v[0].vv[row][col++]=i8a_appliedPrice;
      row++; col=0;
      // i8b_
      v[0].vv[row][col++]=81;
      v[0].vv[row][col++]=i8b_period;
      v[0].vv[row][col++]=i8b_slowMovingAverage;
      v[0].vv[row][col++]=i8b_fastMovingAverage;
      v[0].vv[row][col++]=i8b_signalPeriod;
      v[0].vv[row][col++]=i8b_appliedPrice;
      row++; col=0;

      #endif
      // ----------------------------------------------------------------
      #ifdef _USE_MACD  //i9a // Checked
      // ----------------------------------------------------------------
      // i9a_
      v[0].vv[row][col++]=90;
      v[0].vv[row][col++]=i9a_period;
      v[0].vv[row][col++]=i9a_slowMovingAverage;
      v[0].vv[row][col++]=i9a_fastMovingAverage;
      v[0].vv[row][col++]=i9a_signalPeriod;
      v[0].vv[row][col++]=i9a_appliedPrice;
      row++; col=0;
      // i9b_
      v[0].vv[row][col++]=91;
      v[0].vv[row][col++]=i9b_period;
      v[0].vv[row][col++]=i9b_slowMovingAverage;
      v[0].vv[row][col++]=i9b_fastMovingAverage;
      v[0].vv[row][col++]=i9b_signalPeriod;
      v[0].vv[row][col++]=i9b_appliedPrice;
      row++; col=0;
      #endif

      // ----------------------------------------------------------------
      #ifdef _USE_MACDJB  //i10a 
      // ----------------------------------------------------------------
      // i10a_
      v[0].vv[row][col++]=100;
      v[0].vv[row][col++]=i10a_period;
      v[0].vv[row][col++]=i10a_slowMovingAverage;
      v[0].vv[row][col++]=i10a_fastMovingAverage;
      v[0].vv[row][col++]=i10a_signalPeriod;
      row++; col=0;
      // i10b_
      v[0].vv[row][col++]=101;
      v[0].vv[row][col++]=i10b_period;
      v[0].vv[row][col++]=i10b_slowMovingAverage;
      v[0].vv[row][col++]=i10b_fastMovingAverage;
      v[0].vv[row][col++]=i10b_signalPeriod;
      row++; col=0;
      #endif
      
      //--- create a data frame and send it to the terminal
      if (!FrameAdd(MQLInfoString(MQL_PROGRAM_NAME)+"_stats", STATS_FRAME,v[0].vp[0], v)) {
         ss=StringFormat(" -> Stats Frame add error: ", GetLastError());
         pss
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=StringFormat(" -> Stats Frame added:%.2f",v[0].vp[0]);  
            pss
         #endif
      }


   //}
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

/*

   ss="OnTesterDeinit ->  ....";
   pss

   //--- variables for reading frames
   string         name, sql, sql1, sql2;
   ulong          passNumber;
   long           id;


   //--- move the frame pointer to the beginning
   if (FrameFirst()) {
      Print("FrameFirst SUCCESS");
   } else {
      Print("FrameFirst ERROR");
   };
   FrameFilter("", STATS_FRAME); // select frames with trading statistics for further work

   while (FrameNext(passNumber, name, id,v[0].vp[0], v)) {



    //ss=StringFormat("In FrameNext Loop -> %u %s <%.5f> ....",passNumber,name,v[0].vp[1]);
      //pss
      
      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO OPTIMIZATION (strategyNumber,passNumber,reload) VALUES (%d,%d,%d)",_strategyNumber,passNumber,0);
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=sql;
         pss
         ss=StringFormat("OnTesterDeinit -> Failed to insert OPTIMIZATION with code %d", GetLastError());
         pss
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss="EARunOptimization -> OnTesterDeinit -> Insert into OPTIMIZATION succcess";
            pss
         #endif
      }
      


      //if (v[0].vp[2]<100) continue;
      // ----------------------------------------------------------------
      sql1="INSERT INTO PASSES ("
         "statWITHDRAWAL, statPROFIT, statGROSSPROFIT, statGROSSLOSS, statMAXPROFITTRADE, statMAXLOSSTRADE, statCONPROFITMAX, statCONPROFITMAXTRADES,"
         "statMAXCONWINS, statMAXCONPROFITTRADES, statBALANCEMIN, statBALANCEDD, statEQUITYDDPERCENT, statEQUITYDDRELPERCENT, statEQUITYDDRELATIVE,"
         "statEXPECTEDPAYOFF, statRECOVERYFACTOR, statSHARPERATIO, statMINMARGINLEVEL, statCUSTOMONTESTER, statDEALS,"
         "statTRADES, statPROFITTRADES, statLOSSTRADES, statSHORTTRADES, statLONGTRADES, statPROFITSHORTTRADES, statPROFITLONGTRADES, statPROFITTRADESAVGCON, statLOSSTRADESAVGCON,"
         "onTester, passNumber"
         ")";
         sql2=StringFormat(" VALUES ("
         "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"                                                                               //9
         "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"                                                                          //20
         "%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,"                                                                          //30
         "%.5f,%.5f,%d"                                                                                                                //31
         ")",
         v[0].vp[1],v[0].vp[2],v[0].vp[3],v[0].vp[4],v[0].vp[5],v[0].vp[6],v[0].vp[7],v[0].vp[8],v[0].vp[9],                           //9
         v[0].vp[10],v[0].vp[11],v[0].vp[12],v[0].vp[13],v[0].vp[14],v[0].vp[15],v[0].vp[16],v[0].vp[17],v[0].vp[18],v[0].vp[19],      //20
         v[0].vp[20],v[0].vp[21],v[0].vp[22],v[0].vp[23],v[0].vp[24],v[0].vp[25],v[0].vp[26],v[0].vp[27],v[0].vp[28],v[0].vp[29],      //30
         v[0].vp[30],v[0].vp[31], passNumber                                                                                           //31
         );

         sql=sql1+sql2;
   
         if (!DatabaseExecute(_optimizeDBHandle, sql)) {
            ss=StringFormat("EARunOptimization -> OnTesterDeinit -> Failed to insert PASSES with code %d", GetLastError());
            pss
            break;
         } else {
            #ifdef _DEBUG_OPTIMIZATION
               ss="EARunOptimization -> OnTesterDeinit -> Insert into PASSES succcess";
               pss
            #endif
         }  

      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO NNETWORK ("
         "networkType,dfSize,triggerThreshold,trainWeightsThreshold,nnLayer1,nnLayer2,restarts,decay,wStep,maxITS,passNumber "
         ") VALUES (%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%u)",
         v[0].vn[0],v[0].vn[1],v[0].vn[2],v[0].vn[3],v[0].vn[4],v[0].vn[5],v[0].vn[6],v[0].vn[7],v[0].vn[8],v[0].vn[9],passNumber);
      
         if (!DatabaseExecute(_optimizeDBHandle, sql)) {
            ss=StringFormat("EARunOptimization -> OnTesterDeinit -> Failed to insert NNETWORK with code %d", GetLastError());
            pss
            break;
         } else {
            #ifdef _DEBUG_OPTIMIZATION
               ss="EARunOptimization -> OnTesterDeinit -> Insert into NNETWORK succcess";
               pss
            #endif
         } 

      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO STRATEGY ("
         "lotSize,fpt,flt,maxPositions,maxdaily,maxdailyhold,maxmg,mgmulti,hedgeLossAmount,passNumber "
         ") VALUES (%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%u)",
         v[0].vs[0],v[0].vs[1],v[0].vs[2],v[0].vs[3],v[0].vs[4],v[0].vs[5],v[0].vs[6],v[0].vs[7],v[0].vs[8],passNumber);
      
         if (!DatabaseExecute(_optimizeDBHandle, sql)) {
            ss=StringFormat("EARunOptimization -> OnTesterDeinit -> Failed to insert STRATEGY with code %d", GetLastError());
            pss
            break;
         } else {
            #ifdef _DEBUG_OPTIMIZATION
               ss="EARunOptimization -> OnTesterDeinit -> Insert into STRATEGY succcess";
               pss
            #endif
         }  

      // ----------------------------------------------------------------
      // Iterate through all indicators that are part of this strategy passing in the optimization values
      // which will then be updated in the optimzation DB
      for (int row=0;row<allIndicators.Total();row++)  {
         EAOptimizationIndicator *oi;
         double dst[14];
         oi=allIndicators.At(row);

         for (int col=0;col<14;col++) {
            //ss=StringFormat(" ----> row:%d col:%d",row,col);
            //pss
            dst[col]=v[0].vv[row][col];
         }
         oi.addOptimizationValues(dst,passNumber);
         #ifdef _DEBUG_OPTIMIZATION
            //ss=StringFormat(" -> %.5f %.5f %.5f",dst[0],dst[1],dst[2]);
            //pss
         #endif
      }
      
   }
   */
}

/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EARunOptimization::buildSQLTableRequest(string indicatorName, int idx) {
   string sql=StringFormat("SELECT * FROM %s WHERE IDX=%d",indicatorName,idx);

   #ifdef _DEBUG_OPTIMIZATION
      ss="buildSQLTableRequest -> ....";
      pss
      writeLog
      ss=sql;
      writeLog
   #endif

   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("buildSQLRequest ->  Table:%s index:%d failed with code %d",indicatorName,idx,GetLastError());
         pss
         ExpertRemove();
      #endif    
   }

   return request;
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::reloadValues(double &theArray[], string indicatorName,int idx) {

   int isUsing;
   int request;

   request=buildSQLTableRequest(indicatorName,idx);
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("reloadValues -> Table:%s index:%d, failed with code %d",indicatorName,idx,GetLastError());
         pss
         writeLog
         ExpertRemove();
      #endif   
   } else {

      #ifdef _DEBUG_OPTIMIZATION
         ss="reloadValues -> success ....";
         pss
         writeLog
      #endif
   }

      // Get the first filed and check if we are evening using this indicator
      DatabaseColumnInteger(request,0,isUsing);
      if (isUsing==0) {
            #ifdef _DEBUG_OPTIMIZATION
               ss=StringFormat("reloadValues -> indicator type:%s was not selected active",indicatorName);
               pss
               writeLog
            #endif
         return; // Not being used
      } else {
         // Now get the rest of the values;
         theArray[0]=1;
         for (int i=1;i<ArraySize(theArray);i++) {
            DatabaseColumnDouble(request,i,theArray[i]);
            #ifdef _DEBUG_OPTIMIZATION
               ss=StringFormat("%s -> index:%d value:%1.2f",indicatorName,i,theArray[i]);
               pss
               writeLog
            #endif
         }
      }


   

}
*/

