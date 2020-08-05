//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


//#define  STATS_FRAME  1
#define _DEBUG_OPTIMIZATION

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
   
   string            ss;

   int               _dnnNumber;
   int               _dnnType;
   
   struct results {
      double v0[32];
      double v1[12];
      double v2[7];
      double v3[10];
      double v4[7];
      double v5[10];
      double v6[13];
      double v7[7];
      double v8[19];
      double v9[16];
      double v10[13];
      double v11[13];
      double v12[13];
   };
   results v[1];

   int   buildSQLTableRequest(string tableName, int idx);
   void  reloadValues(double &theArray[], string tableName,int idx);


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


      string ss="OnTesterInit -> ....";
      printf(ss);


   //--- create or open the database in the common terminal folder
   _optimizeDBHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON| DATABASE_OPEN_CREATE);
   if (_optimizeDBHandle==INVALID_HANDLE) {
      printf("OnTesterInit -> Optimization DB open failed with code %d",GetLastError());
      ExpertRemove();
   } else {

      ss="OnTesterInit -> Optimization DB open success";

   }

   // ----------------------------------------------------------------


   string sql="DROP TABLE PASSES;DROP TABLE STRATEGY;"
   "DROP TABLE ADX;DROP TABLE MFI;DROP TABLE ICH;DROP TABLE SAR;DROP TABLE STOC;DROP TABLE OSMA;DROP TABLE RSI;DROP TABLE MACD;"
   "DROP TABLE RVI;DROP TABLE MACDBULL;DROP TABLE MACDBEAR;";
   if(!DatabaseExecute(_optimizeDBHandle,sql)) {
      ss=StringFormat("OnTesterInit -> Failed to drop table PASSES with code %d", GetLastError());
      printf(ss);
   } else {
      
      ss="OnTesterInit -> Dropping all table success ";
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
   printf(ss);
   
   string sql;
   

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
      "IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table PASSES failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table PASSES success";
         printf(ss);
      #endif
   }
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
      "longHLossamt        REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table STRATEGY failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table STRATEGY success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE ADX ("
      "useADX  INT,"
      "s_ADXperiod REAL,"
      "s_ADXma REAL,"
      "m_ADXperiod REAL,"
      "m_ADXma REAL,"
      "l_ADXperiod REAL,"
      "l_ADXma REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table ADX failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table ADX success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE RSI ("
      "useRSI  INT,"
      "s_RSIperiod REAL,"
      "s_RSIma REAL,"
      "s_RSIap REAL,"
      "m_RSIperiod REAL,"
      "m_RSIma REAL,"
      "m_RSIap REAL,"
      "l_RSIperiod REAL,"
      "l_RSIma REAL,"
      "l_RSIap REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table RSI failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table RSI success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE MFI ("
      "useMFI  INT,"
      "s_MFIperiod REAL,"
      "s_MFIma REAL,"
      "m_MFIperiod REAL,"
      "m_MFIma REAL,"
      "l_MFIperiod REAL,"
      "l_MFIma REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table MFI failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table MFI success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE SAR ("
      "useSAR  INT,"
      "s_SARperiod REAL,"
      "s_SARstep REAL,"
      "s_SARmax REAL,"
      "m_SARperiod REAL,"
      "m_SARstep REAL,"
      "m_SARmax REAL,"
      "l_SARperiod REAL,"
      "l_SARstep REAL,"
      "l_SARmax REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table SAR failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table SAR success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE ICH ("
      "useICH  INT,"
      "s_ICHperiod REAL,"
      "s_tenkan_sen REAL,"
      "s_kijun_sen REAL,"
      "s_senkou_span_b REAL,"
      "m_ICHperiod REAL,"
      "m_tenkan_sen REAL,"
      "m_kijun_sen REAL,"
      "m_senkou_span_b REAL,"
      "l_ICHperiod REAL,"
      "l_tenkan_sen REAL,"
      "l_kijun_sen REAL,"
      "l_senkou_span_b REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table ICH failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table ICH success";
         printf(ss);
      #endif
   }
// ----------------------------------------------------------------
   sql =   "CREATE TABLE RVI ("
      "useRVI  INT,"
      "s_RVIperiod REAL,"
      "s_RVIma REAL,"
      "m_RVIperiod REAL,"
      "m_RVIma REAL,"
      "l_RVIperiod REAL,"
      "l_RVIma REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table RVI failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table RVI success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE STOC ("
      "useSTOC  INT,"
      "s_STOCperiod REAL,"
      "s_kPeriod REAL,"
      "s_dPeriod REAL,"
      "s_slowing REAL,"
      "s_STOCmamethod REAL,"
      "s_STOCpa REAL,"

      "m_STOCperiod REAL,"
      "m_kPeriod REAL,"
      "m_dPeriod REAL,"
      "m_slowing REAL,"
      "m_STOCmamethod REAL,"
      "m_STOCpa REAL,"

      "l_STOCperiod REAL,"
      "l_kPeriod REAL,"
      "l_dPeriod REAL,"
      "l_slowing REAL,"
      "l_STOCmamethod REAL,"
      "l_STOCpa REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table STOC failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table STOC success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE OSMA ("
      "useOSMA  INT,"
      "s_OSMAperiod REAL,"
      "s_OSMAfastEMA REAL,"
      "s_OSMAslowEMA REAL,"
      "s_OSMAsignalPeriod REAL,"
      "s_OSMApa REAL,"
      "m_OSMAperiod REAL,"
      "m_OSMAfastEMA REAL,"
      "m_OSMAslowEMA REAL,"
      "m_OSMAsignalPeriod REAL,"
      "m_OSMApa REAL,"
      "l_OSMAperiod REAL,"
      "l_OSMAfastEMA REAL,"
      "l_OSMAslowEMA REAL,"
      "l_OSMAsignalPeriod REAL,"
      "l_OSMApa REAL, IDX INT)";

   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table OSMA failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table OSMA success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE MACD ("
      "useMACD  INT,"
      "s_MACDDperiod REAL,"
      "s_MACDDfastEMA REAL,"
      "s_MACDDslowEMA REAL,"
      "s_MACDDsignalPeriod REAL,"
      "m_MACDDperiod REAL,"
      "m_MACDDfastEMA REAL,"
      "m_MACDDslowEMA REAL,"
      "m_MACDDsignalPeriod REAL,"
      "l_MACDDperiod REAL,"
      "l_MACDDfastEMA REAL,"
      "l_MACDDslowEMA REAL,"
      "l_MACDDsignalPeriod REAL, IDX INT)";
      
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table MACD failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table MACD success";
         printf(ss);
      #endif
   }

   sql =   "CREATE TABLE MACDBULL ("
      "useMACDBULL INT,"
      "s_MACDBULLperiod REAL,"
      "s_MACDBULLfastEMA REAL,"
      "s_MACDBULLslowEMA REAL,"
      "s_MACDBULLsignalPeriod REAL,"
      "m_MACDBULLperiod REAL,"
      "m_MACDBULLfastEMA REAL,"
      "m_MACDBULLslowEMA REAL,"
      "m_MACDBULLsignalPeriod REAL,"
      "l_MACDBULLperiod REAL,"
      "l_MACDBULLfastEMA REAL,"
      "l_MACDBULLslowEMA REAL,"
      "l_MACDBULLsignalPeriod REAL, IDX INT)";
         
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table MACDBULL failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table MACDBULL success";
         printf(ss);
      #endif
   }
   // ----------------------------------------------------------------
   sql =   "CREATE TABLE MACDBEAR ("
      "useMACDBEAR  INT,"
      "s_MACDBEARperiod REAL,"
      "s_MACDBEARfastEMA REAL,"
      "s_MACDBEARslowEMA REAL,"
      "s_MACDBEARsignalPeriod REAL,"
      "m_MACDBEARperiod REAL,"
      "m_MACDBEARfastEMA REAL,"
      "m_MACDBEARslowEMA REAL,"
      "m_MACDBEARsignalPeriod REAL,"
      "l_MACDBEARperiod REAL,"
      "l_MACDBEARfastEMA REAL,"
      "l_MACDBEARslowEMA REAL,"
      "l_MACDBEARsignalPeriod REAL, IDX INT)";
         
   if (!DatabaseExecute(_optimizeDBHandle, sql)) {
      ss=StringFormat("createSQLOptimizationTables -> create table MACDBEAR failed with code %d", GetLastError());
      printf(ss);
      ExpertRemove();
   } else {
      #ifdef _DEBUG_OPTIMIZATION
         ss="createSQLOptimizationTables -> Create table MACDBEAR success";
         printf(ss);
      #endif
   }

   // ----------------------------------------------------------------

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



      string name = "";  // Public name/frame label
      ulong  pass =0;   // Number of the optimization pass at which the frame is added
      long   id   =0;   // Public id of the frame
      double val  =0.0; // Single numerical value of the frame
      //---
      FrameNext(pass,name,id,val);
      Print("Name: ",name," pass: "+IntegerToString(pass)+" VAL:",val); //DoubleToString(v[1].v0[2],2), "SHARPE: ",DoubleToString(v[1].v0[5],2));

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

   #ifdef _DEBUG_OPTIMIZATION
      string ss="OnTester ->  ....";
      writeLog;
      printf(ss);
   #endif

   if (onTesterValue>0) { 
  // ----------------------------------------------------------------
      v[0].v0[0]=0;
      v[0].v0[1]=TesterStatistics(STAT_WITHDRAWAL);
      v[0].v0[2]=TesterStatistics(STAT_PROFIT);
      v[0].v0[3]=TesterStatistics(STAT_GROSS_PROFIT);
      v[0].v0[4]=TesterStatistics(STAT_GROSS_LOSS);
      v[0].v0[5]=TesterStatistics(STAT_MAX_PROFITTRADE);
      v[0].v0[6]=TesterStatistics(STAT_MAX_LOSSTRADE);
      v[0].v0[7]=TesterStatistics(STAT_CONPROFITMAX);
      v[0].v0[8]=TesterStatistics(STAT_CONPROFITMAX_TRADES);
      v[0].v0[9]=TesterStatistics(STAT_MAX_CONWINS);
      v[0].v0[10]=TesterStatistics(STAT_MAX_CONPROFIT_TRADES);
      v[0].v0[11]=TesterStatistics(STAT_BALANCEMIN);
      v[0].v0[12]=TesterStatistics(STAT_BALANCE_DD);
      v[0].v0[13]=TesterStatistics(STAT_EQUITYDD_PERCENT);
      v[0].v0[14]=TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
      v[0].v0[15]=TesterStatistics(STAT_EQUITY_DD_RELATIVE);
      v[0].v0[16]=TesterStatistics(STAT_EXPECTED_PAYOFF);
      v[0].v0[17]=TesterStatistics(STAT_RECOVERY_FACTOR);
      v[0].v0[18]=TesterStatistics(STAT_SHARPE_RATIO);
      v[0].v0[19]=TesterStatistics(STAT_MIN_MARGINLEVEL);
      v[0].v0[20]=TesterStatistics(STAT_CUSTOM_ONTESTER);
      v[0].v0[21]=TesterStatistics(STAT_DEALS);
      v[0].v0[22]=TesterStatistics(STAT_TRADES);
      v[0].v0[23]=TesterStatistics(STAT_PROFIT_TRADES);
      v[0].v0[24]=TesterStatistics(STAT_LOSS_TRADES);
      v[0].v0[25]=TesterStatistics(STAT_SHORT_TRADES);
      v[0].v0[26]=TesterStatistics(STAT_LONG_TRADES);
      v[0].v0[27]=TesterStatistics(STAT_PROFIT_SHORTTRADES);
      v[0].v0[28]=TesterStatistics(STAT_PROFIT_LONGTRADES);
      v[0].v0[29]=TesterStatistics(STAT_PROFITTRADES_AVGCON);
      v[0].v0[30]=TesterStatistics(STAT_LOSSTRADES_AVGCON);
      v[0].v0[31]=onTesterValue;
  // ----------------------------------------------------------------
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
      // ----------------------------------------------------------------
      v[0].v2[0]=iuseADX;
      v[0].v2[1]=is_ADXperiod;
      v[0].v2[2]=is_ADXma;
      v[0].v2[3]=im_ADXperiod;
      v[0].v2[4]=im_ADXma;
      v[0].v2[5]=il_ADXperiod;
      v[0].v2[6]=il_ADXma;
      // ----------------------------------------------------------------
      v[0].v3[0]=iuseRSI;
      v[0].v3[1]=is_RSIperiod;
      v[0].v3[2]=is_RSIma;
      v[0].v3[3]=is_RSIap;
      v[0].v3[4]=im_RSIperiod;
      v[0].v3[5]=im_RSIma;
      v[0].v3[6]=is_RSIap;
      v[0].v3[7]=il_RSIperiod;
      v[0].v3[8]=il_RSIma;
      v[0].v3[9]=il_RSIap;
      //----------------------------------------------------------------
      v[0].v4[0]=iuseMFI;
      v[0].v4[1]=is_MFIperiod;
      v[0].v4[2]=is_MFIma;
      v[0].v4[3]=im_MFIperiod;
      v[0].v4[4]=im_MFIma;
      v[0].v4[5]=il_MFIperiod;
      v[0].v4[6]=il_MFIma;
      //----------------------------------------------------------------
      v[0].v5[0]=iuseSAR;
      v[0].v5[1]=is_SARperiod;
      v[0].v5[2]=is_SARstep;
      v[0].v5[3]=is_SARmax;
      v[0].v5[4]=im_SARperiod;
      v[0].v5[5]=im_SARstep;
      v[0].v5[6]=im_SARmax;
      v[0].v5[7]=il_SARperiod;
      v[0].v5[8]=il_SARstep;
      v[0].v5[9]=il_SARmax;
      //----------------------------------------------------------------
      v[0].v6[0]=iuseICH;
      v[0].v6[1]=is_ICHperiod;
      v[0].v6[2]=is_tenkan_sen;
      v[0].v6[3]=is_kijun_sen;
      v[0].v6[4]=is_senkou_span_b;
      v[0].v6[5]=im_ICHperiod;
      v[0].v6[6]=im_tenkan_sen;
      v[0].v6[7]=im_kijun_sen;
      v[0].v6[8]=im_senkou_span_b;
      v[0].v6[9]=il_ICHperiod;
      v[0].v6[10]=il_tenkan_sen;
      v[0].v6[11]=il_kijun_sen;
      v[0].v6[12]=il_senkou_span_b;
      //----------------------------------------------------------------
      v[0].v7[0]=iuseRVI;
      v[0].v7[1]=is_RVIperiod;
      v[0].v7[2]=is_RVIma;
      v[0].v7[3]=im_RVIperiod;
      v[0].v7[4]=im_RVIma;
      v[0].v7[5]=il_RVIperiod;
      v[0].v7[6]=il_RVIma;
      //----------------------------------------------------------------
      v[0].v8[0]=iuseSTOC;

      v[0].v8[1]=is_STOCperiod;
      v[0].v8[2]=is_kPeriod;
      v[0].v8[3]=is_dPeriod;
      v[0].v8[4]=is_slowing;
      v[0].v8[5]=is_STOCmamethod;
      v[0].v8[6]=is_STOCpa;

      v[0].v8[7]=im_STOCperiod;
      v[0].v8[8]=im_kPeriod;
      v[0].v8[9]=im_dPeriod;
      v[0].v8[10]=im_slowing;
      v[0].v8[11]=im_STOCmamethod;
      v[0].v8[12]=im_STOCpa;

      v[0].v8[13]=il_STOCperiod;
      v[0].v8[14]=il_kPeriod;
      v[0].v8[15]=il_dPeriod;
      v[0].v8[16]=il_slowing;
      v[0].v8[17]=il_STOCmamethod;
      v[0].v8[18]=il_STOCpa;
      //----------------------------------------------------------------
      v[0].v9[0]=iuseOSMA;
      v[0].v9[1]=is_OSMAperiod;
      v[0].v9[2]=is_OSMAfastEMA;
      v[0].v9[3]=is_OSMAslowEMA;
      v[0].v9[4]=is_OSMAsignalPeriod;
      v[0].v9[5]=is_OSMApa;
      v[0].v9[6]=im_OSMAperiod;
      v[0].v9[7]=im_OSMAfastEMA;
      v[0].v9[8]=im_OSMAslowEMA;
      v[0].v9[9]=im_OSMAsignalPeriod;
      v[0].v9[10]=im_OSMApa;
      v[0].v9[11]=il_OSMAperiod;
      v[0].v9[12]=il_OSMAfastEMA;
      v[0].v9[13]=il_OSMAslowEMA;
      v[0].v9[14]=il_OSMAsignalPeriod;
      v[0].v9[15]=il_OSMApa;
      //----------------------------------------------------------------  
      v[0].v10[0]=iuseMACD;
      v[0].v10[1]=is_MACDDperiod;
      v[0].v10[2]=is_MACDDfastEMA;
      v[0].v10[3]=is_MACDDslowEMA;
      v[0].v10[4]=is_MACDDsignalPeriod;

      v[0].v10[5]=im_MACDDperiod;
      v[0].v10[6]=im_MACDDfastEMA;
      v[0].v10[7]=im_MACDDslowEMA;
      v[0].v10[8]=im_MACDDsignalPeriod;

      v[0].v10[9]=il_MACDDperiod;
      v[0].v10[10]=il_MACDDfastEMA;
      v[0].v10[11]=il_MACDDslowEMA;
      v[0].v10[12]=il_MACDDsignalPeriod;
      //----------------------------------------------------------------
      v[0].v11[0]=iuseMACDBULL;
      v[0].v11[1]=is_MACDBULLperiod;
      v[0].v11[2]=is_MACDBULLfastEMA;
      v[0].v11[3]=is_MACDBULLslowEMA;
      v[0].v11[4]=is_MACDBULLsignalPeriod;

      v[0].v11[5]=im_MACDBULLperiod;
      v[0].v11[6]=im_MACDBULLfastEMA;
      v[0].v11[7]=im_MACDBULLslowEMA;
      v[0].v11[8]=im_MACDBULLsignalPeriod;

      v[0].v11[9]=il_MACDBULLperiod;
      v[0].v11[10]=il_MACDBULLfastEMA;
      v[0].v11[11]=il_MACDBULLslowEMA;
      v[0].v11[12]=il_MACDBULLsignalPeriod;
      //----------------------------------------------------------------
      v[0].v12[0]=iuseMACDBEAR;
      v[0].v12[1]=is_MACDBEARperiod;
      v[0].v12[2]=is_MACDBEARfastEMA;
      v[0].v12[3]=is_MACDBEARslowEMA;
      v[0].v12[4]=is_MACDBEARsignalPeriod;

      v[0].v12[5]=im_MACDBEARperiod;
      v[0].v12[6]=im_MACDBEARfastEMA;
      v[0].v12[7]=im_MACDBEARslowEMA;
      v[0].v12[8]=im_MACDBEARsignalPeriod;

      v[0].v12[9]=il_MACDBEARperiod;
      v[0].v12[10]=il_MACDBEARfastEMA;
      v[0].v12[11]=il_MACDBEARslowEMA;
      v[0].v12[12]=il_MACDBEARsignalPeriod;


      //--- create a data frame and send it to the terminal
      if (!FrameAdd(MQLInfoString(MQL_PROGRAM_NAME)+"_stats", STATS_FRAME,v[0].v0[0], v)) {
         ss=StringFormat(" -> Stats Frame add error: ", GetLastError());
         printf(ss);
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=StringFormat(" -> Stats Frame added:%.2f",v[0].v0[0]);  
            printf(ss);
         #endif
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
   string         name, sql;
   ulong          idx;
   long           id;
   double         value;

   //--- move the frame pointer to the beginning
   FrameFirst();
   FrameFilter("", STATS_FRAME); // select frames with trading statistics for further work

   ss="Loop start->  ....";
   printf(ss);

   while (FrameNext(idx, name, id,v[0].v0[0], v)) {

      ss="In Loop ->  ....";
      printf(ss);

      //if (v[0].v0[2]<100) continue;
      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO PASSES ("
      "reloadStrategy, statWITHDRAWAL, statPROFIT, statGROSSPROFIT, statGROSSLOSS, statMAXPROFITTRADE, statMAXLOSSTRADE, statCONPROFITMAX, statCONPROFITMAXTRADES,"
      "statMAXCONWINS, statMAXCONPROFITTRADES, statBALANCEMIN, statBALANCEDD, statEQUITYDDPERCENT, statEQUITYDDRELPERCENT, statEQUITYDDRELATIVE,"
      "statEXPECTEDPAYOFF, statRECOVERYFACTOR, statSHARPERATIO, statMINMARGINLEVEL, statCUSTOMONTESTER, statDEALS,"
      "statTRADES, statPROFITTRADES, statLOSSTRADES, statSHORTTRADES, statLONGTRADES, statPROFITSHORTTRADES, statPROFITLONGTRADES, statPROFITTRADESAVGCON, statLOSSTRADESAVGCON,"
      "onTester, IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v0[0],v[0].v0[1],v[0].v0[2],v[0].v0[3],v[0].v0[4],v[0].v0[5],
      v[0].v0[6],v[0].v0[7],v[0].v0[8],v[0].v0[9],v[0].v0[10],v[0].v0[11],
      v[0].v0[12],v[0].v0[13],v[0].v0[14],v[0].v0[15],v[0].v0[16],v[0].v0[17],
      v[0].v0[18],v[0].v0[19],v[0].v0[20],v[0].v0[21],v[0].v0[22],v[0].v0[23],
      v[0].v0[24],v[0].v0[25],v[0].v0[26],v[0].v0[27],v[0].v0[28],v[0].v0[29],
      v[0].v0[30],v[0].v0[31],
      idx);
   
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert PASSES with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into PASSES succcess";
            printf(ss);
         #endif
      }  

      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO STRATEGY ("
      "lotSize,fptl,fltl,fpts,flts,maxlong,maxshort,maxdaily,maxdailyhold,maxmg,mgmulti,longHLossamt,IDX "
      ") VALUES (%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v1[0],v[0].v1[1],v[0].v1[2],v[0].v1[3],v[0].v1[4],v[0].v1[5],v[0].v1[6],v[0].v1[7],v[0].v1[8],v[0].v1[9],v[0].v1[10],v[0].v1[11],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert STRATEGY with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into STRATEGY succcess";
            printf(ss);
         #endif
      }  

      // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO ADX ("
      "useADX,s_ADXperiod,s_ADXma,m_ADXperiod,m_ADXma,l_ADXperiod,l_ADXma,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v2[0],v[0].v2[1],v[0].v2[2],v[0].v2[3],v[0].v2[4],v[0].v2[5],v[0].v2[6],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert ADX with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into ADX succcess";
            printf(ss);
         #endif
      }  
   


   // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO RSI ("
      "useRSI,"
      "s_RSIperiod, s_RSIma, s_RSIap,"
      "m_RSIperiod, m_RSIma, m_RSIap,"
      "l_RSIperiod, l_RSIma, l_RSIap,"
      "IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v3[0],v[0].v3[1],v[0].v3[2],v[0].v3[3],v[0].v3[4],v[0].v3[5],v[0].v3[6],v[0].v3[7],v[0].v3[8],v[0].v3[9],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert RSI with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into RSI succcess";
            printf(ss);
         #endif
      }  



  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO MFI ("
      "useMFI,s_MFIperiod,s_MFIma,m_MFIperiod,m_MFIma,l_MFIperiod,l_MFIma,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v4[0],v[0].v4[1],v[0].v4[2],v[0].v4[3],v[0].v4[4],v[0].v4[5],v[0].v4[6],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert MFI with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into MFI succcess";
            printf(ss);
         #endif
      }  



  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO SAR ("
      "useSAR,"
      "s_SARperiod, s_SARstep, s_SARmax,"
      "m_SARperiod, m_SARstep, m_SARmax,"
      "l_SARperiod, l_SARstep, l_SARmax,"
      "IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v5[0],v[0].v5[1],v[0].v5[2],v[0].v5[3],v[0].v5[4],v[0].v5[5],v[0].v5[6],v[0].v5[7],v[0].v5[8],v[0].v5[9],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert SAR with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into SAR succcess";
            printf(ss);
         #endif
      }  



  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO ICH ("
      "useICH,"
      "s_ICHperiod, s_tenkan_sen, s_kijun_sen, s_senkou_span_b,"
      "m_ICHperiod, m_tenkan_sen, m_kijun_sen, m_senkou_span_b,"
      "l_ICHperiod, l_tenkan_sen, l_kijun_sen, l_senkou_span_b,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v6[0],v[0].v6[1],v[0].v6[2],v[0].v6[3],v[0].v6[4],v[0].v6[5],v[0].v6[6],v[0].v6[7],v[0].v6[8],v[0].v6[9],v[0].v6[10],v[0].v6[11],v[0].v6[12],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert ICH with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into ICH succcess";
            printf(ss);
         #endif
      }  



  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO RVI ("
      "useRVI,s_RVIperiod,s_RVIma,m_RVIperiod,m_RVIma,l_RVIperiod,l_RVIma,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v7[0],v[0].v7[1],v[0].v7[2],v[0].v7[3],v[0].v7[4],v[0].v7[5],v[0].v7[6],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert RVI with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into RVI succcess";
            printf(ss);
         #endif
      }  



  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO STOC ("
      "useSTOC, "
      "s_STOCperiod, s_kPeriod, s_dPeriod, s_slowing, s_STOCmamethod, s_STOCpa,"
      "m_STOCperiod, m_kPeriod, m_dPeriod, m_slowing, m_STOCmamethod ,m_STOCpa,"
      "l_STOCperiod, l_kPeriod, l_dPeriod, l_slowing, l_STOCmamethod, l_STOCpa,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v8[0],v[0].v8[1],v[0].v8[2],v[0].v8[3],v[0].v8[4],v[0].v8[5],v[0].v8[6],v[0].v8[7],v[0].v8[8],v[0].v8[9],
      v[0].v8[10],v[0].v8[11],v[0].v8[12],v[0].v8[13],v[0].v8[14],v[0].v8[15],v[0].v8[16],v[0].v8[17],v[0].v8[18],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert STOC with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into STOC succcess";
            printf(ss);
         #endif
      }  



  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO OSMA ("
      "useOSMA,s_OSMAperiod,s_OSMAfastEMA,s_OSMAslowEMA,s_OSMAsignalPeriod,s_OSMApa,"
      "m_OSMAperiod,m_OSMAfastEMA,m_OSMAslowEMA,m_OSMAsignalPeriod,m_OSMApa,"
      "l_OSMAperiod,l_OSMAfastEMA,l_OSMAslowEMA,l_OSMAsignalPeriod,l_OSMApa,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v9[0],v[0].v9[1],v[0].v9[2],v[0].v9[3],v[0].v9[4],v[0].v9[5],v[0].v9[6],v[0].v9[7],v[0].v9[8],v[0].v9[9],
      v[0].v9[10],v[0].v9[11],v[0].v9[12],v[0].v9[13],v[0].v9[14],v[0].v9[15],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert OSMA with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into OSMA succcess";
            printf(ss);
         #endif
      }  

  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO MACD ("
      "useMACD,"
      "s_MACDDperiod, s_MACDDfastEMA, s_MACDDslowEMA, s_MACDDsignalPeriod,"
      "m_MACDDperiod, m_MACDDfastEMA, m_MACDDslowEMA, m_MACDDsignalPeriod,"
      "l_MACDDperiod, l_MACDDfastEMA, l_MACDDslowEMA, l_MACDDsignalPeriod,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v10[0],v[0].v10[1],v[0].v10[2],v[0].v10[3],v[0].v10[4],v[0].v10[5],v[0].v10[6],v[0].v10[7],v[0].v10[8],v[0].v10[9],v[0].v10[10],v[0].v10[11],v[0].v10[12],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert MACD with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into MACD succcess";
            printf(ss);
         #endif
      }

  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO MACDBULL ("
      "useMACDBULL,"
      "s_MACDBULLperiod, s_MACDBULLfastEMA, s_MACDBULLslowEMA, s_MACDBULLsignalPeriod,"
      "m_MACDBULLperiod, m_MACDBULLfastEMA, m_MACDBULLslowEMA, m_MACDBULLsignalPeriod,"
      "l_MACDBULLperiod, l_MACDBULLfastEMA, l_MACDBULLslowEMA, l_MACDBULLsignalPeriod,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v11[0],v[0].v11[1],v[0].v11[2],v[0].v11[3],v[0].v11[4],v[0].v11[5],v[0].v11[6],v[0].v11[7],v[0].v11[8],v[0].v11[9],v[0].v11[10],v[0].v11[11],v[0].v11[12],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert MACDBULL with code %d", GetLastError());
         printf(ss);
         break;
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into MACDBULL succcess";
            printf(ss);
         #endif
      }  
  


  // ----------------------------------------------------------------
      sql=StringFormat("INSERT INTO MACDBEAR ("        
      "useMACDBEAR,"
      "s_MACDBEARperiod, s_MACDBEARfastEMA, s_MACDBEARslowEMA, s_MACDBEARsignalPeriod,"
      "m_MACDBEARperiod, m_MACDBEARfastEMA, m_MACDBEARslowEMA, m_MACDBEARsignalPeriod,"
      "l_MACDBEARperiod, l_MACDBEARfastEMA, l_MACDBEARslowEMA, l_MACDBEARsignalPeriod,IDX"
      ") VALUES (%d,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%d)",
      v[0].v12[0],v[0].v12[1],v[0].v12[2],v[0].v12[3],v[0].v12[4],v[0].v12[5],v[0].v12[6],v[0].v12[7],v[0].v12[8],v[0].v12[9],v[0].v12[10],v[0].v12[11],v[0].v12[12],idx);
      
      if (!DatabaseExecute(_optimizeDBHandle, sql)) {
         ss=StringFormat("OnTesterDeinit -> Failed to insert MACDBEAR with code %d", GetLastError());
         printf(ss);
      } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss=" -> Insert into PASSES succcess";
            printf(ss);
         #endif
      }  
      
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::reloadStrategy() {

   EATechnicalParameters *t;
   int idx;

   //--- open the database in the common terminal folder
   _optimizeDBHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READONLY | DATABASE_OPEN_COMMON);
   if (_optimizeDBHandle==INVALID_HANDLE) {
      printf("reloadStrategy -> Optimization DB open failed with code %d",GetLastError());
      ExpertRemove();
   } else {
      ss="reloadStrategy -> Optimization DB open success for strategy update";
      printf(ss);
   }

   string sql="SELECT IDX FROM PASSES WHERE reloadStrategy=1";
   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("updateSelected ->  DB query failed with code %d",GetLastError());
         writeLog
         printf(ss);
      #endif    
   }
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("updateSelected -> DB read failed with code %d",GetLastError());
         writeLog
         printf(ss);
      #endif   
   } else {
         DatabaseColumnInteger(request,0,idx);
         #ifdef _DEBUG_OPTIMIZATION
            ss=StringFormat("updateSelected -> optimal value found at index:%d",idx);
            printf(ss);
         #endif
   }


   reloadValues(v[0].v1,"STRATEGY",idx);
   if (reloadValues(v[0].v2,"ADX",idx)) {
      t.insertUpdateTable(tableName,&v[0].v2,);

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

   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EARunOptimization::buildSQLTableRequest(string tableName, int idx) {
   string sql=StringFormat("SELECT * FROM %s WHERE IDX=%d",tableName,idx);

   #ifdef _DEBUG_OPTIMIZATION
      ss="buildSQLTableRequest -> ....";
      printf(ss);
      printf(sql);
   #endif

   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("buildSQLRequest ->  Table:%s index:%d failed with code %d",tableName,idx,GetLastError());
         printf(ss);
         ExpertRemove();
      #endif    
   }

   return request;
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::reloadValues(double &theArray[], string tableName,int idx) {

   int isUsing;
   int request;

   request=buildSQLTableRequest(tableName,idx);
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_OPTIMIZATION
         ss=StringFormat("reloadValues -> Table:%s index:%d, failed with code %d",tableName,idx,GetLastError());
         printf(ss);
         ExpertRemove();
      #endif   
   } else {

      #ifdef _DEBUG_OPTIMIZATION
         ss="reloadValues -> success ....";
         printf(ss);
   }

      // Get the first filed and check if we are evening using this indicator
      DatabaseColumnInteger(request,0,isUsing);
      if (isUsing==0) {
            #ifdef _DEBUG_OPTIMIZATION
               ss=StringFormat("reloadValues -> indicator type:%s was not selected active",tableName);
               printf(ss);
            #endif
         return; // Not being used
      } else {
         // Now get the rest of the values;
         theArray[0]=1;
         for (int i=1;i<ArraySize(theArray);i++) {
            DatabaseColumnDouble(request,i,theArray[i]);
            #ifdef _DEBUG_OPTIMIZATION
               ss=StringFormat("%s -> index:%d value:%1.2f",tableName,i,theArray[i]);
               printf(ss);
            #endif
         }
      }


   

}

