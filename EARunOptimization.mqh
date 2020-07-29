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

   printf ("===============OnTesterInit==================");

   //--- create or open the database in the common terminal folder
   _optimizeHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON| DATABASE_OPEN_CREATE);
   if (_optimizeHandle==INVALID_HANDLE) {
      printf(" -> Optimization DB open failed with code %d",GetLastError());
      ExpertRemove();
   } 

   return(INIT_SUCCEEDED);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::dropSQLOptimizationTables() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::dropSQLOptimizationTables ....";
      writeLog;
   #endif

   
/*
   
   if (DatabaseTableExists(_optimizeDB, "PASSES")) {
      string sqlTable1="DROP TABLE PASSES";
      if(!DatabaseExecute(_optimizeDB,sqlTable1)) {
         printf(" -> Failed to drop table PASSES with code %d", GetLastError());
         //ExpertRemove();
      } else {
         printf(" -> Drop table PASSES success ");
      }
   } else {
      printf(" -> PASSES does not exist will be created");
   }
   */

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::createSQLOptimizationTables() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::createSQLOptimizationTables ....";
      writeLog;
   #endif

/*

//--- create the _PASSES table
string sqlTable1 =   "CREATE TABLE PASSES ("
   "selection           INT,"
   "strategyNumber      INT,"
   "iterationNumber     INT,"
   "dnnNumber           INT,"
   "dnnType             INT,"
   "dataFrameSize       INT,"
   "lookBackBars        INT,"
   "trades              INT,"
   "winningTrades       INT,"
   "profit              REAL,"
   "grossProfit         REAL,"
   "grossLoss           REAL,"
   "sharpeRatios        REAL,"
   "profitFactor        REAL,"
   "recoveryFactor      REAL,"
   "expectedPayoff      REAL,"
   "onTester            REAL,"
   "blBalance           REAL,"
   "blProfitFactor      REAL,"
   "blExpectedPayoff    REAL,"
   "blDrawdown          REAL,"
   "blRecoverFactor     REAL,"
   "blSharpeRatio       REAL,"
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
   "s_ADXperiod REAL ,"
   "s_ADXma REAL ,"
   "m_ADXperiod REAL ,"
   "m_ADXma REAL ,"
   "l_ADXperiod REAL ,"
   "l_ADXma REAL ,"
   "s_RSIperiod REAL ,"
   "s_RSIma REAL ,"
   "s_RSIap REAL ,"
   "m_RSIperiod REAL ,"
   "m_RSIma REAL ,"
   "m_RSIap REAL ,"
   "l_RSIperiod REAL ,"
   "l_RSIma REAL ,"
   "l_RSIap REAL ,"
   "s_MFIperiod REAL ,"
   "s_MFIma REAL ,"
   "m_MFIperiod REAL ,"
   "m_MFIma REAL ,"
   "l_MFIperiod REAL ,"
   "l_MFIma REAL ,"
   "s_SARperiod REAL ,"
   "s_SARstep REAL ,"
   "s_SARmax REAL ,"
   "m_SARperiod REAL ,"
   "m_SARstep REAL ,"
   "m_SARmax REAL ,"
   "l_SARperiod REAL ,"
   "l_SARstep REAL ,"
   "l_SARmax REAL ,"
   "s_ICHperiod REAL ,"
   "s_tenkan_sen REAL ,"
   "s_kijun_sen REAL ,"
   "s_senkou_span_b REAL ,"
   "m_ICHperiod REAL ,"
   "m_tenkan_sen REAL ,"
   "m_kijun_sen REAL ,"
   "m_senkou_span_b REAL ,"
   "l_ICHperiod REAL ,"
   "l_tenkan_sen REAL ,"
   "l_kijun_sen REAL ,"
   "l_senkou_span_b REAL ,"
   "s_RVIperiod REAL ,"
   "s_RVIma REAL ,"
   "m_RVIperiod REAL ,"
   "m_RVIma REAL ,"
   "l_RVIperiod REAL ,"
   "l_RVIma REAL ,"
   "s_STOCperiod REAL ,"
   "s_kPeriod REAL ,"
   "s_dPeriod REAL ,"
   "s_slowing REAL ,"
   "s_STOCmamethod REAL ,"
   "s_STOCpa REAL ,"
   "m_STOCperiod REAL ,"
   "m_kPeriod REAL ,"
   "m_dPeriod REAL ,"
   "m_slowing REAL ,"
   "m_STOCmamethod REAL ,"
   "m_STOCpa REAL ,"
   "l_STOCperiod REAL ,"
   "l_kPeriod REAL ,"
   "l_dPeriod REAL ,"
   "l_slowing REAL ,"
   "l_STOCmamethod REAL ,"
   "l_STOCpa REAL ,"
   "s_OSMAperiod REAL ,"
   "s_OSMAfastEMA REAL ,"
   "s_OSMAslowEMA REAL ,"
   "s_OSMAsignalPeriod REAL ,"
   "s_OSMApa REAL ,"
   "m_OSMAperiod REAL ,"
   "m_OSMAfastEMA REAL ,"
   "m_OSMAslowEMA REAL ,"
   "m_OSMAsignalPeriod REAL ,"
   "m_OSMApa REAL ,"
   "l_OSMAperiod REAL ,"
   "l_OSMAfastEMA REAL ,"
   "l_OSMAslowEMA REAL ,"
   "l_OSMAsignalPeriod REAL ,"
   "l_OSMApa REAL ,"
   "s_MACDDperiod REAL ,"
   "s_MACDDfastEMA REAL ,"
   "s_MACDDslowEMA REAL ,"
   "s_MACDDsignalPeriod REAL ,"
   "m_MACDDperiod REAL ,"
   "m_MACDDfastEMA REAL ,"
   "m_MACDDslowEMA REAL ,"
   "m_MACDDsignalPeriod REAL ,"
   "l_MACDDperiod REAL ,"
   "l_MACDDfastEMA REAL ,"
   "l_MACDDslowEMA REAL ,"
   "l_MACDDsignalPeriod REAL ,"
   "s_MACDBULLperiod REAL ,"
   "s_MACDBULLfastEMA REAL ,"
   "s_MACDBULLslowEMA REAL ,"
   "s_MACDBULLsignalPeriod REAL ,"
   "m_MACDBULLperiod REAL ,"
   "m_MACDBULLfastEMA REAL ,"
   "m_MACDBULLslowEMA REAL ,"
   "m_MACDBULLsignalPeriod REAL ,"
   "l_MACDBULLperiod REAL ,"
   "l_MACDBULLfastEMA REAL ,"
   "l_MACDBULLslowEMA REAL ,"
   "l_MACDBULLsignalPeriod REAL ,"
   "s_MACDBEARperiod REAL ,"
   "s_MACDBEARfastEMA REAL ,"
   "s_MACDBEARslowEMA REAL ,"
   "s_MACDBEARsignalPeriod REAL ,"
   "m_MACDBEARperiod REAL ,"
   "m_MACDBEARfastEMA REAL ,"
   "m_MACDBEARslowEMA REAL ,"
   "m_MACDBEARsignalPeriod REAL ,"
   "l_MACDBEARperiod REAL ,"
   "l_MACDBEARfastEMA REAL ,"
   "l_MACDBEARslowEMA REAL ,"
   "l_MACDBEARsignalPeriod REAL)";


   if (!DatabaseExecute(_optimizeDB, sqlTable1)) {
      printf(" -> create table PASSES failed with code %d", GetLastError());
      //ExpertRemove();
   } else {
      printf (" -> Create table PASSES success");
   }

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

   printf ("===============OnTesterPass==================");


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

   printf ("===============OnTester==================");


   int    trades=(int)TesterStatistics(STAT_PROFIT_TRADES);

   //if (trades>0) { 
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
      //v[0].v0[10]=balance;
      //v[0].v0[11]=balance_plus_profitfactor;
      //v[0].v0[12]=balance_plus_expectedpayoff;
      //v[0].v0[13]=balance_plus_dd;
      //v[0].v0[14]=balance_plus_recoveryfactor;
      //v[0].v0[15]=balance_plus_sharpe;

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

      v[0].v2[0]=iuseADX;
      v[0].v2[1]=is_ADXperiod;
      v[0].v2[2]=is_ADXma;
      v[0].v2[3]=im_ADXperiod;
      v[0].v2[4]=im_ADXma;
      v[0].v2[5]=il_ADXperiod;
      v[0].v2[6]=il_ADXma;
      v[0].v2[7]=iuseRSI;
      v[0].v2[8]=is_RSIperiod;
      v[0].v2[9]=is_RSIma;
      v[0].v2[10]=is_RSIap;
      v[0].v2[11]=im_RSIperiod;
      v[0].v2[12]=im_RSIma;
      v[0].v2[13]=is_RSIap;
      v[0].v2[14]=il_RSIperiod;
      v[0].v2[15]=il_RSIma;
      v[0].v2[16]=il_RSIap;
      v[0].v2[17]=iuseMFI;
      v[0].v2[18]=is_MFIperiod;
      v[0].v2[19]=is_MFIma;
      v[0].v2[20]=im_MFIperiod;
      v[0].v2[21]=im_MFIma;
      v[0].v2[22]=il_MFIperiod;
      v[0].v2[23]=il_MFIma;
      v[0].v2[24]=iuseSAR;
      v[0].v2[25]=is_SARperiod;
      v[0].v2[26]=is_SARstep;
      v[0].v2[27]=is_SARmax;
      v[0].v2[28]=im_SARperiod;
      v[0].v2[29]=im_SARstep;
      v[0].v2[30]=im_SARmax;
      v[0].v2[31]=il_SARperiod;
      v[0].v2[32]=il_SARstep;
      v[0].v2[33]=il_SARmax;
      v[0].v2[34]=iuseICH;
      v[0].v2[35]=is_ICHperiod;
      v[0].v2[36]=is_tenkan_sen;
      v[0].v2[37]=is_kijun_sen;
      v[0].v2[38]=is_senkou_span_b;
      v[0].v2[39]=im_ICHperiod;
      v[0].v2[40]=im_tenkan_sen;
      v[0].v2[41]=im_kijun_sen;
      v[0].v2[42]=im_senkou_span_b;
      v[0].v2[43]=il_ICHperiod;
      v[0].v2[44]=il_tenkan_sen;
      v[0].v2[45]=il_kijun_sen;
      v[0].v2[46]=il_senkou_span_b;
      v[0].v2[47]=iuseRVI;
      v[0].v2[48]=is_RVIperiod;
      v[0].v2[49]=is_RVIma;
      v[0].v2[50]=im_RVIperiod;
      v[0].v2[51]=im_RVIma;
      v[0].v2[52]=il_RVIperiod;
      v[0].v2[53]=il_RVIma;
      v[0].v2[54]=iuseSTOC;
      v[0].v2[55]=is_STOCperiod;
      v[0].v2[56]=is_kPeriod;
      v[0].v2[57]=is_dPeriod;
      v[0].v2[58]=is_slowing;
      v[0].v2[59]=is_STOCmamethod;
      v[0].v2[60]=is_STOCpa;
      v[0].v2[61]=im_STOCperiod;
      v[0].v2[62]=im_kPeriod;
      v[0].v2[63]=im_dPeriod;
      v[0].v2[64]=im_slowing;
      v[0].v2[65]=im_STOCmamethod;
      v[0].v2[66]=im_STOCpa;
      v[0].v2[67]=il_STOCperiod;
      v[0].v2[68]=il_kPeriod;
      v[0].v2[69]=il_dPeriod;
      v[0].v2[70]=il_slowing;
      v[0].v2[71]=il_STOCmamethod;
      v[0].v2[72]=il_STOCpa;
      v[0].v2[73]=iuseOSMA;
      v[0].v2[74]=is_OSMAperiod;
      v[0].v2[75]=is_OSMAfastEMA;
      v[0].v2[76]=is_OSMAslowEMA;
      v[0].v2[77]=is_OSMAsignalPeriod;
      v[0].v2[78]=is_OSMApa;
      v[0].v2[79]=im_OSMAperiod;
      v[0].v2[80]=im_OSMAfastEMA;
      v[0].v2[81]=im_OSMAslowEMA;
      v[0].v2[82]=im_OSMAsignalPeriod;
      v[0].v2[83]=im_OSMApa;
      v[0].v2[84]=il_OSMAperiod;
      v[0].v2[85]=il_OSMAfastEMA;
      v[0].v2[86]=il_OSMAslowEMA;
      v[0].v2[87]=il_OSMAsignalPeriod;
      v[0].v2[88]=il_OSMApa;
      v[0].v2[89]=iuseMACD;
      v[0].v2[90]=is_MACDDperiod;
      v[0].v2[91]=is_MACDDfastEMA;
      v[0].v2[92]=is_MACDDslowEMA;
      v[0].v2[93]=is_MACDDsignalPeriod;
      v[0].v2[94]=im_MACDDperiod;
      v[0].v2[95]=im_MACDDfastEMA;
      v[0].v2[96]=im_MACDDslowEMA;
      v[0].v2[97]=im_MACDDsignalPeriod;
      v[0].v2[98]=il_MACDDperiod;
      v[0].v2[99]=il_MACDDfastEMA;
      v[0].v2[100]=il_MACDDslowEMA;
      v[0].v2[101]=il_MACDDsignalPeriod;
      v[0].v2[102]=is_MACDBULLperiod;
      v[0].v2[103]=is_MACDBULLfastEMA;
      v[0].v2[104]=is_MACDBULLslowEMA;
      v[0].v2[105]=is_MACDBULLsignalPeriod;
      v[0].v2[106]=im_MACDBULLperiod;
      v[0].v2[107]=im_MACDBULLfastEMA;
      v[0].v2[108]=im_MACDBULLslowEMA;
      v[0].v2[109]=im_MACDBULLsignalPeriod;
      v[0].v2[110]=il_MACDBULLperiod;
      v[0].v2[111]=il_MACDBULLfastEMA;
      v[0].v2[112]=il_MACDBULLslowEMA;
      v[0].v2[113]=il_MACDBULLsignalPeriod;
      v[0].v2[114]=is_MACDBEARperiod;
      v[0].v2[115]=is_MACDBEARfastEMA;
      v[0].v2[116]=is_MACDBEARslowEMA;
      v[0].v2[117]=is_MACDBEARsignalPeriod;
      v[0].v2[118]=im_MACDBEARperiod;
      v[0].v2[119]=im_MACDBEARfastEMA;
      v[0].v2[120]=im_MACDBEARslowEMA;
      v[0].v2[121]=im_MACDBEARsignalPeriod;
      v[0].v2[122]=il_MACDBEARperiod;
      v[0].v2[123]=il_MACDBEARfastEMA;
      v[0].v2[124]=il_MACDBEARslowEMA;
      v[0].v2[125]=il_MACDBEARsignalPeriod;
      v[0].v2[126]=iuseZZ;
      v[0].v2[127]=is_ZZperiod;
      v[0].v2[128]=im_ZZperiod;
      v[0].v2[129]=il_ZZperiod;
      v[0].v2[130]=iuseMACDBULLDIV;
      v[0].v2[131]=iuseMACDBEARDIV;

      //--- create a data frame and send it to the terminal
      if (!FrameAdd(MQLInfoString(MQL_PROGRAM_NAME)+"_stats", STATS_FRAME, v[0].v0[0], v)) {
         Print(" -> Stats Frame add error: ", GetLastError());
      } else {
         
         Print(" -> Stats Frame added, Ok");  
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

   printf ("===============OnTesterDeinit==================");


   //--- variables for reading frames
   string         name;
   ulong          iterationNumber;
   long           id;
   double         value;


   //--- move the frame pointer to the beginning
   FrameFirst();
   FrameFilter("", STATS_FRAME); // select frames with trading statistics for further work

   bool failed=false;
   //DatabaseTransactionBegin(_optimizeDB);
   while (FrameNext(iterationNumber, name, id, v[0].v0[0], v)) {
      printf(" -> ?");

   }

      /*

      //if (values[2]<500) continue;
   
      //=============
      // PASSES TABLE
      //=============

         string request1a=StringFormat("INSERT INTO TECHPASSES ("
         "selection,strategyNumber,iterationNumber,dnnNumber,dnnType,dataFrameSize,lookBackBars,"
         "trades,winningTrades,profit,grossProfit,grossLoss,"
         "sharpeRatios,profitFactor,recoveryFactor,expectedPayoff,onTester,"
         "blBalance,blProfitFactor,blExpectedPayoff,blDrawdown,blRecoverFactor,blSharpeRatio,"
         "lotSize,fptl,fltl,fpts,flts,maxlong,maxshort,maxdaily,maxdailyhold,maxmg,mgmulti,longHLossamt,"   // x12                                                                           
         "s_ADXperiod,s_ADXma,m_ADXperiod,m_ADXma,l_ADXperiod,l_ADXma,s_RSIperiod,s_RSIma,s_RSIap,m_RSIperiod,m_RSIma,m_RSIap,l_RSIperiod,l_RSIma,l_RSIap,s_MFIperiod,"
         "s_MFIma,m_MFIperiod,m_MFIma,l_MFIperiod,l_MFIma,s_SARperiod,s_SARstep,s_SARmax,m_SARperiod,m_SARstep,m_SARmax,l_SARperiod,l_SARstep,l_SARmax,s_ICHperiod,"
         "s_tenkan_sen,s_kijun_sen,s_senkou_span_b,m_ICHperiod,m_tenkan_sen,m_kijun_sen,m_senkou_span_b,l_ICHperiod,l_tenkan_sen,l_kijun_sen,l_senkou_span_b,s_RVIperiod,"
         "s_RVIma,m_RVIperiod,m_RVIma,l_RVIperiod,l_RVIma,s_STOCperiod,s_kPeriod,s_dPeriod,s_slowing,s_STOCmamethod,s_STOCpa,m_STOCperiod,m_kPeriod,m_dPeriod,m_slowing,"
         "m_STOCmamethod,m_STOCpa,l_STOCperiod,l_kPeriod,l_dPeriod,l_slowing,l_STOCmamethod,l_STOCpa,s_OSMAperiod,s_OSMAfastEMA,s_OSMAslowEMA,s_OSMAsignalPeriod,s_OSMApa,m_OSMAperiod,"
         "m_OSMAfastEMA,m_OSMAslowEMA,m_OSMAsignalPeriod,m_OSMApa,l_OSMAperiod,l_OSMAfastEMA,l_OSMAslowEMA,l_OSMAsignalPeriod,l_OSMApa,s_MACDDperiod,s_MACDDfastEMA,"
         "s_MACDDslowEMA,s_MACDDsignalPeriod,m_MACDDperiod,m_MACDDfastEMA,m_MACDDslowEMA,m_MACDDsignalPeriod,l_MACDDperiod,l_MACDDfastEMA,l_MACDDslowEMA,l_MACDDsignalPeriod,"
         "s_MACDBULLperiod,s_MACDBULLfastEMA,s_MACDBULLslowEMA,s_MACDBULLsignalPeriod,m_MACDBULLperiod,m_MACDBULLfastEMA,m_MACDBULLslowEMA,m_MACDBULLsignalPeriod,l_MACDBULLperiod,"
         "l_MACDBULLfastEMA,l_MACDBULLslowEMA,l_MACDBULLsignalPeriod,s_MACDBEARperiod,s_MACDBEARfastEMA,s_MACDBEARslowEMA,s_MACDBEARsignalPeriod,m_MACDBEARperiod,m_MACDBEARfastEMA,"
         "m_MACDBEARslowEMA,m_MACDBEARsignalPeriod,l_MACDBEARperiod,l_MACDBEARfastEMA,l_MACDBEARslowEMA,l_MACDBEARsignalPeriod"
         ") VALUES (0,%d,%d,0,0,0,0,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,%5.2f,",                             
         _strategyNumber, iterationNumber,
         values[0], values[1], values[2], values[3], values[4], values[5],
         values[6], values[7], values[8], values[9], values[10],
         values[11], values[12], values[13], values[14],
         values[15]);

         string request1b=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
         values[34],values[35],values[36],values[37],values[38],values[39],values[40],values[41],values[42],
         values[43],values[44],values[45]);
         //printf("%s",request4b);
         string request1c=StringFormat("%.5f,%.5f,%.5f,%.5f,",values[46],values[47],values[48],values[49]);
         //printf("%s",request4c);
         string request1d=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
         values[50],values[51],values[52],values[53],values[54],values[55],values[56],values[57],values[58],values[59],
         values[60],values[61],values[62],values[63],values[64],values[65],values[66],values[67],values[68],values[69]);
         //printf("%s",request4d);
         string request1e=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
         values[70],values[71],values[72],values[73],values[74],values[75],values[76],values[77],values[78],values[79],
         values[80],values[81],values[82],values[83],values[84],values[85],values[86],values[87],values[88],values[89]);
         //printf("%s",request4e);
         string request1f=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
         values[90],values[91],values[92],values[93],values[94],values[95],values[96],values[97],values[98],values[99],
         values[100],values[101],values[102],values[103],values[104],values[105],values[106],values[107],values[108],values[109]);
         //printf("%s",request4f);
         string request1g=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
         values[110],values[111],values[112],values[113],values[114],values[115],values[116],values[117],values[118],values[119],
         values[120],values[121],values[122],values[123],values[124],values[125],values[126],values[127],values[128],values[129]);
         //printf("%s",request4g);  
         string request1h=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,",
         values[130],values[131],values[132],values[133],values[134],values[135],values[136],values[137],values[138],values[139],
         values[140],values[141],values[142],values[143],values[144],values[145],values[146],values[147],values[148],values[149]);
         //printf("%s",request4h);
         string request1i=StringFormat("%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f)", 
         values[150],values[151],values[152],values[153],values[154],values[155],values[156],values[157],values[158],values[159],
         values[160],values[161],values[162]);
         //printf("%s",request4i);       


      string request1=StringFormat("%s%s%s%s%s%s%s%s%s",request1a,request1b,request1c,request1d,request1e,request1f,request1g,request1h,request1i);

      
         if (!DatabaseExecute(_optimizeDB, request1)) {
            printf(" -> Failed to insert PASSES %d with code %d", iterationNumber, GetLastError());
            failed=true;
            break;
         } else {
            #ifdef _DEBUG_OPTIMIZATION
               printf(" -> Insert into PASSES succcess:%d",iterationNumber);
            #endif
         }
      
   }
   */

}




