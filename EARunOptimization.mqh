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


class EAPosition;

class EARunOptimization {

//=========
private:
//=========

   string   ss;

   void     copyValuesToDatabase(int row, ulong passNumber);

   struct results {
      double vp[32];          // Metrics Profit loss etc
      double vs[12];          // Strategy
      double vn[10];          // Network
      double vv[20][14];      // Technicals
   };
   results v[1];


   int   buildSQLTableRequest(string indicatorName, int idx);
   void  reloadValues(double &theArray[], string indicatorName,int idx);


//=========
protected:
//=========
   
   int         _strategyNumber;

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
   void        OnTester(const double OnTesterValue);
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

   string sql="DROP TABLE PASSES; DROP TABLE STRATEGY; DROP TABLE TECHNICALS; DROP TABLE NNETWORK;";
   if(!DatabaseExecute(_optimizeDBHandle,sql)) {
      ss=StringFormat("OnTesterInit -> Failed to drop table PASSES with code %d", GetLastError());
      pss
   } else {
      ss="OnTesterInit -> Dropping all table success ";
      pss
   }

   createSQLOptimizationTables();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::createSQLOptimizationTables(string sql) {

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

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::createSQLOptimizationTables() {

   string sql;

   string ss="createSQLOptimizationTables -> ....";
   pss
   
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE PASSES ("
      "reloadStrategy INT,"
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
      "fptl                REAL,"
      "fltl                REAL,"
      "fpts                REAL,"
      "flts                REAL,"
      "maxlong             REAL,"
      "maxshort            REAL,"
      "maxdaily            REAL,"
      "maxdailyhold        REAL,"
      "maxmg               REAL,"
      "mgmulti             REAL,"
      "longHLossamt        REAL,"
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
      "useBuffers REAL,"
      "ttl REAL,"
      "inputPrefix,"
      "normalizationMin REAL,"
      "normalizationMax REAL)";

      createSQLOptimizationTables(sql);


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
   pss
   


      string name = "";  // Public name/frame label
      ulong  pass =0;   // Number of the optimization pass at which the frame is added
      long   id   =0;   // Public id of the frame
      double val  =0.0; // Single numerical value of the frame
      //---
      FrameNext(pass,name,id,val);
      //ss=StringFormat(" ---> Name: %s pass:%u",name,DoubleToString(pass));
      //pss
      

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::copyValuesToDatabase(int row, ulong passNumber) {

   string sql;


   #ifdef _USE_ADX
      // ----------------------------------------------------------------
      if (v[0].vv[row][0]==1) { // Check the indicator number to save a string indicator name
      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage) VALUES (%u,'%s',%.5f,%.5f)",
            passNumber,"ADX",v[0].vv[row][1],v[0].vv[row][2]);
            ss=sql;
            pss
      }
   #endif

   #ifdef _USE_RSI
      // ----------------------------------------------------------------
   if (v[0].vv[row][0]==2) {  // RSI
      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,movingAverage,appliedPrice) VALUES (%u,'%s',%.5f,%.5f,%.5f)",
            passNumber,"RSI",v[0].vv[row][1],v[0].vv[row][2],v[0].vv[row][3]);
            ss=sql;
            pss
      }
   #endif


   #ifdef _USE_MACD
      // ----------------------------------------------------------------
   if (v[0].vv[row][0]==9) {  // MACD
      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO TECHNICALS (passNumber,indicatorName,"
         "period,slowMovingAverage,fastMovingAverage,signalPeriod,appliedPrice) VALUES (%u,'%s',%.5f,%.5f,%.5f,%.5f,%.5f)",
            passNumber,"MACD",v[0].vv[row][1],v[0].vv[row][2],v[0].vv[row][3],v[0].vv[row][4],v[0].vv[row][5]);
            ss=sql;
            pss
      }
   #endif

      
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("OnTesterDeinit -> Failed to insert with code %d", GetLastError());
      pss
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss=" -> INSERT INTO TECHNICALS succcess";
         pss
      #endif
   }  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::OnTester(const double val) {


   /*
      Tester - this event is generated after completion of Expert Advisor testing 
      on history data. 
      The Tester event is handled using the OnTester() function. 
      This function can be used only when testing Expert Advisor and is intended 
      primarily for the calculation of a value that is used as a Custom max 
      criterion for genetic optimization of input parameters.
   */

   int row=0, col=0; // Counters for technical array

   #ifdef _DEBUG_OPTIMIZATION
      string ss="OnTester ->  ....";
      pss
   #endif

   //if (onTesterValue>0) { 
      

  // ----------------------------------------------------------------
      v[0].vp[0]=0;  // Reserved to save the number of technical indicators used in the strategy/pass
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
      v[0].vp[31]=val;
   // ----------------------------------------------------------------
      v[0].vs[0]=ilsize;
      v[0].vs[1]=ifptl;
      v[0].vs[2]=ifltl;
      v[0].vs[3]=ifpts;
      v[0].vs[4]=iflts;
      v[0].vs[5]=imaxlong;
      v[0].vs[6]=imaxshort;
      v[0].vs[7]=imaxdaily;
      v[0].vs[8]=imaxdailyhold;   
      v[0].vs[9]=ilongHLossamt;
      v[0].vs[10]=imaxmg;
      v[0].vs[11]=imgmulti;

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
      

      #ifdef _USE_ADX
      // ----------------------------------------------------------------
      // v[0].vv[0][0,1,2]
         // Save the value
      v[0].vv[row][col++]=i1a_indicatorNumber;
      v[0].vv[row][col++]=i1a_period;
      v[0].vv[row][col++]=i1a_movingAverage;
      row++; col=0;

      // v[0].vv[1].[0,1,2]
      v[0].vv[row][col++]=i1b_indicatorNumber;
      v[0].vv[row][col++]=i1b_period;
      v[0].vv[row][col++]=i1b_movingAverage;
      row++; col=0;
      #endif

      #ifdef _USE_RSI
      // ----------------------------------------------------------------
      v[0].vv[row][col++]=i2a_indicatorNumber;
      v[0].vv[row][col++]=i2a_period;
      v[0].vv[row][col++]=i2a_movingAverage;
      v[0].vv[row][col++]=i2a_appliedPrice;
      row++; col=0;

      v[0].vv[row][col++]=i2b_indicatorNumber;
      v[0].vv[row][col++]=i2b_period;
      v[0].vv[row][col++]=i2b_movingAverage;
      v[0].vv[row][col++]=i2b_appliedPrice;
      row++; col=0;
      #endif

      #ifdef _USE_MACD
      // ----------------------------------------------------------------
      v[0].vv[row][col++]=i9a_indicatorNumber;
      v[0].vv[row][col++]=i9a_period;
      v[0].vv[row][col++]=i9a_slowMovingAverage;
      v[0].vv[row][col++]=i9a_fastMovingAverage;
      v[0].vv[row][col++]=i9a_signalPeriod;
      v[0].vv[row][col++]=i9a_appliedPrice;
      row++; col=0;

      v[0].vv[row][col++]=i9b_indicatorNumber;
      v[0].vv[row][col++]=i9b_period;
      v[0].vv[row][col++]=i9b_slowMovingAverage;
      v[0].vv[row][col++]=i9b_fastMovingAverage;
      v[0].vv[row][col++]=i9b_signalPeriod;
      v[0].vv[row][col++]=i9b_appliedPrice;
      row++; col=0;
      #endif
      
/*
      #ifdef _USE_MFI
      // ----------------------------------------------------------------
      addValue(i3a_indicatorNumber);
      addValue(i3a_period);
      addValue(i3a_movingAverage);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i3b_indicatorNumber);
      addValue(i3b_period);
      addValue(i3b_movingAverage);
      addValue(EMPTY_VALUE); // Bump row count
      #endif
      // ----------------------------------------------------------------

      #ifdef _USE_SAR
      addValue(i4a_indicatorNumber);
      addValue(i4a_stepValue);
      addValue(i4a_maxValue);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i4b_indicatorNumber);
      addValue(i4b_stepValue);
      addValue(i4b_maxValue);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_ICH
      // ----------------------------------------------------------------
      addValue(i5a_indicatorNumber);
      addValue(i5a_tenkanSen);
      addValue(i5a_kijunSen);
      addValue(i5a_spanB);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i5b_indicatorNumber);
      addValue(i5b_tenkanSen);
      addValue(i5b_kijunSen);
      addValue(i5b_spanB);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_RVI
      // ----------------------------------------------------------------
      addValue(i6a_indicatorNumber);
      addValue(i6a_period);
      addValue(i6a_movingAverage);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i6b_indicatorNumber);
      addValue(i6b_period);
      addValue(i6b_movingAverage);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_STOC
      // ----------------------------------------------------------------
      addValue(i7a_indicatorNumber);
      addValue(i7a_period);
      addValue(i7a_kPeriod);
      addValue(i7a_dPeriod);
      addValue(i7a_movingAverageMethod);
      addValue(i7a_STOCpa);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i7b_indicatorNumber);
      addValue(i7b_period);
      addValue(i7b_kPeriod);
      addValue(i7b_dPeriod);
      addValue(i7b_movingAverageMethod);
      addValue(i7b_STOCpa);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_OSMA
      // ----------------------------------------------------------------
      addValue(i8a_indicatorNumber);
      addValue(i8a_period);
      addValue(i8a_slowMovingAverage);
      addValue(i8a_fastMovingAverage);
      addValue(i8a_signalPeriod);
      addValue(i8a_appliedPrice);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i8b_indicatorNumber);
      addValue(i8b_period);
      addValue(i8b_slowMovingAverage);
      addValue(i8b_fastMovingAverage);
      addValue(i8b_signalPeriod);
      addValue(i8b_appliedPrice);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_MACD
      // ----------------------------------------------------------------
      addValue(i9a_indicatorNumber);
      addValue(i9a_period);
      addValue(i9a_slowMovingAverage);
      addValue(i9a_fastMovingAverage);
      addValue(i9a_signalPeriod);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i9b_indicatorNumber);
      addValue(i9b_period);
      addValue(i9b_slowMovingAverage);
      addValue(i9b_fastMovingAverage);
      addValue(i9b_signalPeriod);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_MACDBULL
      // ----------------------------------------------------------------
      addValue(i10a_indicatorNumber);
      addValue(i10a_period);
      addValue(i10a_slowMovingAverage);
      addValue(i10a_fastMovingAverage);
      addValue(i10a_signalPeriod);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i10b_indicatorNumber);
      addValue(i10b_period);
      addValue(i10b_slowMovingAverage);
      addValue(i10b_fastMovingAverage);
      addValue(i10b_signalPeriod);
      addValue(EMPTY_VALUE); // Bump row count
      #endif

      #ifdef _USE_MACDBEAR
      // ----------------------------------------------------------------
      addValue(i11a_indicatorNumber);
      addValue(i11a_period);
      addValue(i11a_slowMovingAverage);
      addValue(i11a_fastMovingAverage);
      addValue(i11a_signalPeriod);
      addValue(EMPTY_VALUE); // Bump row count

      addValue(i11b_indicatorNumber);
      addValue(i11b_period);
      addValue(i11b_slowMovingAverage);
      addValue(i11b_fastMovingAverage);
      addValue(i11b_signalPeriod);
      addValue(EMPTY_VALUE); // Bump row count
      #endif
*/

      v[0].vp[0]=row; // Save the number of indicators we have for this strategy, so it can be inserted to the DB

      //--- create a data frame and send it to the terminal
      if (!FrameAdd(MQLInfoString(MQL_PROGRAM_NAME)+"_stats", STATS_FRAME,v[0].vp[0], v)) {
         ss=StringFormat(" -> Stats Frame add error: ", GetLastError());
         pss
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=StringFormat(" -> Stats Frame added:%.2f",v[0].vp[0]);  
            writeLog
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

   string ss="OnTesterDeinit ->  ....";
   pss

   //--- variables for reading frames
   string         name, sql, sql1, sql2;
   ulong          passNumber;
   long           id;
   double         value;
   int            row;

   //--- move the frame pointer to the beginning
   if (FrameFirst()) {
      Print("FrameFirst SUCCESS");
   } else {
      Print("FrameFirst ERROR");
   };
   FrameFilter("", STATS_FRAME); // select frames with trading statistics for further work

   while (FrameNext(passNumber, name, id,v[0].vp[0], v)) {

      ss=StringFormat("In FrameNext Loop -> %u %s <%.5f> ....",passNumber,name,v[0].vp[1]);
      pss


      //if (v[0].vp[2]<100) continue;
      // ----------------------------------------------------------------
      sql1="INSERT INTO PASSES ("
      "reloadStrategy, statWITHDRAWAL, statPROFIT, statGROSSPROFIT, statGROSSLOSS, statMAXPROFITTRADE, statMAXLOSSTRADE, statCONPROFITMAX, statCONPROFITMAXTRADES,"
      "statMAXCONWINS, statMAXCONPROFITTRADES, statBALANCEMIN, statBALANCEDD, statEQUITYDDPERCENT, statEQUITYDDRELPERCENT, statEQUITYDDRELATIVE,"
      "statEXPECTEDPAYOFF, statRECOVERYFACTOR, statSHARPERATIO, statMINMARGINLEVEL, statCUSTOMONTESTER, statDEALS,"
      "statTRADES, statPROFITTRADES, statLOSSTRADES, statSHORTTRADES, statLONGTRADES, statPROFITSHORTTRADES, statPROFITLONGTRADES, statPROFITTRADESAVGCON, statLOSSTRADESAVGCON,"
      "onTester, passNumber"
      ")";
      sql2=StringFormat(" VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%u)",
      v[0].vp[0],v[0].vp[1],v[0].vp[2],v[0].vp[3],v[0].vp[4],v[0].vp[5],
      v[0].vp[6],v[0].vp[7],v[0].vp[8],v[0].vp[9],v[0].vp[10],v[0].vp[11],
      v[0].vp[12],v[0].vp[13],v[0].vp[14],v[0].vp[15],v[0].vp[16],v[0].vp[17],
      v[0].vp[18],v[0].vp[19],v[0].vp[20],v[0].vp[21],v[0].vp[22],v[0].vp[23],
      v[0].vp[24],v[0].vp[25],v[0].vp[26],v[0].vp[27],v[0].vp[28],v[0].vp[29],
      v[0].vp[30],v[0].vp[31],
      passNumber);

      sql=sql1+sql2;
   
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert PASSES with code %d", GetLastError());
         pss
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into PASSES succcess";
            pss
         #endif
      }  


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

            // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO NNETWORK ("
      "networkType,dfSize,triggerThreshold,trainWeightsThreshold,nnLayer1,nnLayer2,restarts,decay,wStep,maxITS,passNumber "
      ") VALUES (%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%u)",
      v[0].vn[0],v[0].vn[1],v[0].vn[2],v[0].vn[3],v[0].vn[4],v[0].vn[5],v[0].vn[6],v[0].vn[7],v[0].vn[8],v[0].vn[9],passNumber);
      
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert NNETWORK with code %d", GetLastError());
         pss
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into STRATEGY succcess";
            pss
         #endif
      } 

      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO STRATEGY ("
      "lotSize,fptl,fltl,fpts,flts,maxlong,maxshort,maxdaily,maxdailyhold,maxmg,mgmulti,longHLossamt,passNumber "
      ") VALUES (%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%u)",
      v[0].vs[0],v[0].vs[1],v[0].vs[2],v[0].vs[3],v[0].vs[4],v[0].vs[5],v[0].vs[6],v[0].vs[7],v[0].vs[8],v[0].vs[9],v[0].vs[10],v[0].vs[11],passNumber);
      
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert STRATEGY with code %d", GetLastError());
         pss
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into STRATEGY succcess";
            pss
         #endif
      }  


      // ----------------------------------------------------------------
      for (int row=0;row<v[0].vp[0];row++) copyValuesToDatabase(row,passNumber);

   
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::reloadStrategy() {
/*
   EATechnicalParameters *t;
   int idx;

   //--- open the database in the common terminal folder
   _optimizeDBHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READONLY | DATABASE_OPEN_COMMON);
   if (_optimizeDBHandle==INVALID_HANDLE) {
      printf("reloadStrategy -> Optimization DB open failed with code %d",GetLastError());
      ExpertRemove();
   } else {
      ss="reloadStrategy -> Optimization DB open success for strategy update";
      pss
   }

   string sql="SELECT IDX FROM PASSES WHERE reloadStrategy=1";
   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("updateSelected ->  DB query failed with code %d",GetLastError());
         writeLog
         pss
      #endif    
   }
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("updateSelected -> DB read failed with code %d",GetLastError());
         writeLog
         pss
      #endif   
   } else {
         DatabaseColumnInteger(request,0,idx);
         #ifdef _DEBUG_OPTIMIZATION
            ss=StringFormat("updateSelected -> optimal value found at index:%d",idx);
            pss
         #endif
   }


   reloadValues(v[0].v1,"STRATEGY",idx);
   if (reloadValues(v[0].v2,"ADX",idx)) {
      t.insertUpdateTable(indicatorName,&v[0].v2,);
   };
   reloadValues(v[0].v3,"RSI",idx);
   reloadValues(v[0].v4,"MFI",idx);
   reloadValues(v[0].v5,"SAR",idx);
   reloadValues(v[0].v6,"ICH",idx);
   reloadValues(v[0].v7,"RVI",idx);
   reloadValues(v[0].v8,"STOC",idx);
   reloadValues(v[0].v9,"OSMA",idx);
   reloadValues(v[0].v10,"MACD",idx);
   reloadValues(v[0].v11,"MACDBULL",idx);
   reloadValues(v[0].v12,"MACDBEAR",idx);
*/
   
}
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

