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
#include "EADataFrame.mqh"
#include "EANeuralNetwork.mqh"
#include "EAInputsOutputs.mqh"
#include "EATechnicalParameters.mqh"

class EAPosition;

class EARunOptimization {

//=========
private:
//=========
   EATechnicalParameters   *tech;
   EAInputsOutputs         *io;      // NN Input Output Module
   EADataFrame             *df;      // The dataframe object
   EANeuralNetwork         *nn;      // The network 
   

   int               _dnnNumber;
   int               _dnnType;
   double            values[170];


//=========
protected:
//=========
   
   int         _optimizeDB, _mainDB, _txtHandle, _strategyNumber;

   void        dropSQLOptimizationTables();
   void        createSQLOptimizationTables();
   void        openSQLDatabase();
   //void        closeSQLDatabase();

//=========
public:
//=========
EARunOptimization();
~EARunOptimization();

   int         OnTesterInit(void);
   void        OnTesterDeinit(void);
   void        OnTester(const double OnTesterValue);
   void        OnTesterPass();
   void        closeSQLDatabase();

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EARunOptimization::EARunOptimization() {

   printf (" -> Instantiate EARunOptimization object");

   _runMode=_RUN_STRATEGY_OPTIMIZATION;

   #ifdef _WRITELOG
      string ss;
      ss=StringFormat(" -> System now set to mode:%s",EnumToString(_runMode));
      writeLog;
      ss=StringFormat("%d.txt",(1000+MathRand()%1000)+(2000+MathRand()%2000)+(3000+MathRand()%3000));
      _txtHandle=FileOpen(ss,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);  
      writeLog; 
   #endif

       // Open the database in the common terminal folder
   _mainDB=DatabaseOpen(_dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
   if (_mainDB==INVALID_HANDLE) {
      #ifdef _WRITELOG
         ss=StringFormat(" -> Failed with errorcode:%d",GetLastError());
         writeLog;
      #endif
   } 

       // Get the strategy number save it globally
   int request=DatabasePrepare(_mainDB,"SELECT strategyNumber FROM STRATEGIES WHERE isActive=1"); 
   if (DatabaseRead(request)) {
      DatabaseColumnInteger(request,0,_strategyNumber);
   } else {
      #ifdef _WRITELOG
         ss=StringFormat(" -> Failed with errorcode:%d",GetLastError());
         writeLog;
      #endif
      ExpertRemove();
   }


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

   printf ("===============OnTesterInit==================");

   #ifdef _WRITELOG
      string ss;
   #endif
   
   MqlDateTime start;
   
   start.year=2018;
   start.mon=12;
   start.day=1;
   start.min=0;
   start.hour=1;

   
   datetime sampleStartDateTime=StructToTime(start);
   #ifdef _WRITELOG
      ss=StringFormat("Starting at %s\n",TimeToString(sampleStartDateTime,TIME_DATE)); 
      writeLog;
   #endif

   // 1/ Create the tecnhincals object and in this case because we are in optimization mode the
   // tech object will read its values from the optimization inputs
   tech=new EATechnicalParameters(_mainDB,_txtHandle);
   if (CheckPointer(tech)==POINTER_INVALID) {
      Print("-> Error created technical object");
         ExpertRemove();
   } 

   // 2/ Create a input/output object passing it the new technical values
   io=new EAInputsOutputs(tech, _txtHandle);
   if (CheckPointer(io)==POINTER_INVALID) {
      Print("-> Error created input/output object");
      ExpertRemove();
   }
   // 3/ Create a data frame object, build a new data frame based on the starting date
   df=new EADataFrame(_mainDB,_txtHandle);
   if (CheckPointer(df)==POINTER_INVALID) {
      Print("-> Error created dataframe object");
      ExpertRemove();
   }
   df.buildDataFrame(PERIOD_CURRENT,sampleStartDateTime,io);

   // 4/ create a new network to train based on the dataframe
   nn=new EANeuralNetwork(_mainDB,_txtHandle);
   if (CheckPointer(nn)==POINTER_INVALID) {
      Print("-> Error created neural network object");
      ExpertRemove();
   }
   nn.trainNetwork(df);

   #ifdef _WRITELOG
      ss=StringFormat("In OnTesterInit Neural Network Inputs:%d and Outputs:%d\n",ArraySize(io.inputs),ArraySize(io.outputs)); 
      writeLog;
   #endif

      

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::openSQLDatabase() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::openSQLDatabase ....";
      writeLog;
   #endif


   //--- create or open the database in the common terminal folder
   _optimizeDB=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON| DATABASE_OPEN_CREATE);
   if (_optimizeDB==INVALID_HANDLE) {
      printf(" -> DB open failed with code %d",GetLastError());
      //ExpertRemove();
   } 


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::closeSQLDatabase() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::closeSQLDatabase ....";
      writeLog;
   #endif

   DatabaseClose(_optimizeDB);
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

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::OnTesterPass ....";
      writeLog;
   #endif


      string name ="";  // Public name/frame label
      ulong  pass =0;   // Number of the optimization pass at which the frame is added
      long   id   =0;   // Public id of the frame
      double val  =0.0; // Single numerical value of the frame
      //---
      FrameNext(pass,name,id,val,values);
      //---
      Print("Name: ",name," pass: "+IntegerToString(pass)+"; STAT_PROFIT: ",DoubleToString(values[2],2), "SHARPE: ",DoubleToString(values[5],2));

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EARunOptimization::OnTester(const double onTesterValue) {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::OnTester ....";
      writeLog;
   #endif


   int    trades=(int)TesterStatistics(STAT_PROFIT_TRADES);

   //if (trades>0) { 
      double win_trades_percent=0;
      win_trades_percent=TesterStatistics(STAT_PROFIT_TRADES)*100./trades;
      //--- fill in the array with test results
      values[0]=trades;                                       // number of trades
      values[1]=win_trades_percent;                           // percentage of profitable trades
      values[2]=TesterStatistics(STAT_PROFIT);                // net profit
      values[3]=TesterStatistics(STAT_GROSS_PROFIT);          // gross profit
      values[4]=TesterStatistics(STAT_GROSS_LOSS);            // gross loss
      values[5]=TesterStatistics(STAT_SHARPE_RATIO);          // Sharpe Ratio
      values[6]=TesterStatistics(STAT_PROFIT_FACTOR);         // profit factor
      values[7]=TesterStatistics(STAT_RECOVERY_FACTOR);       // recovery factor
      values[8]=TesterStatistics(STAT_EXPECTED_PAYOFF);       // trade mathematical expectation
      values[9]=onTesterValue;                                // custom optimization criterion

      /*
      //--- calculate built-in standard optimization criteria
      double balance=AccountInfoDouble(ACCOUNT_BALANCE);
      double balance_plus_profitfactor=0;
      if (TesterStatistics(STAT_GROSS_LOSS)!=0) {
         balance_plus_profitfactor=balance*TesterStatistics(STAT_PROFIT_FACTOR);
      }

      double balance_plus_expectedpayoff=balance*TesterStatistics(STAT_EXPECTED_PAYOFF);
      double equity_dd=TesterStatistics(STAT_EQUITYDD_PERCENT);
      double balance_plus_dd=0;
      if (equity_dd!=0) {
         balance_plus_dd=balance/equity_dd;
      }
      double balance_plus_recoveryfactor=balance*TesterStatistics(STAT_RECOVERY_FACTOR);
      double balance_plus_sharpe=balance*TesterStatistics(STAT_SHARPE_RATIO);
      values[10]=balance;                                     // Balance
      values[11]=balance_plus_profitfactor;                   // Balance+ProfitFactor
      values[12]=balance_plus_expectedpayoff;                 // Balance+ExpectedPayoff
      values[13]=balance_plus_dd;                             // Balance+EquityDrawdown
      values[14]=balance_plus_recoveryfactor;                 // Balance+RecoveryFactor
      values[15]=balance_plus_sharpe;                         // Balance+Sharpe

      values[34]=ilsize;   
      values[35]=ifptl;   
      values[36]=ifltl;
      values[37]=ifpts;  
      values[38]=iflts;  
      values[39]=imaxlong; 
      values[40]=imaxshort;     
      values[41]=imaxdaily;       
      values[42]=imaxdailyhold;  
      values[43]=imaxmg;  
      values[44]=imgmulti;  
      values[45]=ilongHLossamt; 
      values[46]=is_ADXperiod;
      values[47]=is_ADXma;
      values[48]=im_ADXperiod;
      values[49]=im_ADXma;
      values[50]=il_ADXperiod;
      values[51]=il_ADXma;
      values[52]=is_RSIperiod;
      values[53]=is_RSIma;
      values[54]=is_RSIap;
      values[55]=im_RSIperiod;
      values[56]=im_RSIma;
      values[57]=im_RSIap;
      values[58]=il_RSIperiod;
      values[59]=il_RSIma;
      values[60]=il_RSIap;
      values[61]=is_MFIperiod;
      values[62]=is_MFIma;
      values[63]=im_MFIperiod;
      values[64]=im_MFIma;
      values[65]=il_MFIperiod;
      values[66]=il_MFIma;
      values[67]=is_SARperiod;
      values[68]=is_SARstep;
      values[69]=is_SARmax;
      values[70]=im_SARperiod;
      values[71]=im_SARstep;
      values[72]=im_SARmax;
      values[73]=il_SARperiod;
      values[74]=il_SARstep;
      values[75]=il_SARmax;
      values[76]=is_ICHperiod;
      values[77]=is_tenkan_sen;
      values[78]=is_kijun_sen;
      values[79]=is_senkou_span_b;
      values[80]=im_ICHperiod;
      values[81]=im_tenkan_sen;
      values[82]=im_kijun_sen;
      values[83]=im_senkou_span_b;
      values[84]=il_ICHperiod;
      values[85]=il_tenkan_sen;
      values[86]=il_kijun_sen;
      values[87]=il_senkou_span_b;
      values[88]=is_RVIperiod;
      values[89]=is_RVIma;
      values[90]=im_RVIperiod;
      values[91]=im_RVIma;
      values[92]=il_RVIperiod;
      values[93]=il_RVIma;
      values[94]=is_STOCperiod;
      values[95]=is_kPeriod;
      values[96]=is_dPeriod;
      values[97]=is_slowing;
      values[98]=is_STOCmamethod;
      values[99]=is_STOCpa;
      values[100]=im_STOCperiod;
      values[101]=im_kPeriod;
      values[102]=im_dPeriod;
      values[103]=im_slowing;
      values[104]=im_STOCmamethod;
      values[105]=im_STOCpa;
      values[106]=il_STOCperiod;
      values[107]=il_kPeriod;
      values[108]=il_dPeriod;
      values[109]=il_slowing;
      values[110]=il_STOCmamethod;
      values[111]=il_STOCpa;
      values[112]=is_OSMAperiod;
      values[113]=is_OSMAfastEMA;
      values[114]=is_OSMAslowEMA;
      values[115]=is_OSMAsignalPeriod;
      values[116]=is_OSMApa;
      values[117]=im_OSMAperiod;
      values[118]=im_OSMAfastEMA;
      values[119]=im_OSMAslowEMA;
      values[120]=im_OSMAsignalPeriod;
      values[121]=im_OSMApa;
      values[122]=il_OSMAperiod;
      values[123]=il_OSMAfastEMA;
      values[124]=il_OSMAslowEMA;
      values[125]=il_OSMAsignalPeriod;
      values[126]=il_OSMApa;
      values[127]=is_MACDDperiod;
      values[128]=is_MACDDfastEMA;
      values[129]=is_MACDDslowEMA;
      values[130]=is_MACDDsignalPeriod;
      values[131]=im_MACDDperiod;
      values[132]=im_MACDDfastEMA;
      values[133]=im_MACDDslowEMA;
      values[134]=im_MACDDsignalPeriod;
      values[135]=il_MACDDperiod;
      values[136]=il_MACDDfastEMA;
      values[137]=il_MACDDslowEMA;
      values[138]=il_MACDDsignalPeriod;
      values[139]=is_MACDBULLperiod;
      values[140]=is_MACDBULLfastEMA;
      values[141]=is_MACDBULLslowEMA;
      values[142]=is_MACDBULLsignalPeriod;
      values[143]=im_MACDBULLperiod;
      values[144]=im_MACDBULLfastEMA;
      values[145]=im_MACDBULLslowEMA;
      values[146]=im_MACDBULLsignalPeriod;
      values[147]=il_MACDBULLperiod;
      values[148]=il_MACDBULLslowEMA;
      values[150]=il_MACDBULLsignalPeriod;
      values[151]=is_MACDBEARperiod;
      values[152]=is_MACDBEARfastEMA;
      values[153]=is_MACDBEARslowEMA;
      values[154]=is_MACDBEARsignalPeriod;
      values[155]=im_MACDBEARperiod;
      values[156]=im_MACDBEARfastEMA;
      values[157]=im_MACDBEARsignalPeriod;
      values[159]=il_MACDBEARperiod;
      values[160]=il_MACDBEARfastEMA;
      values[161]=il_MACDBEARslowEMA;
      values[162]=il_MACDBEARsignalPeriod;  
      values[163]=idataFrameSize; 
      values[164]=ilookBackBars; 
      */
      

      //--- create a data frame and send it to the terminal
      if (!FrameAdd(MQLInfoString(MQL_PROGRAM_NAME)+"_stats", STATS_FRAME, values[0], values)) {
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

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EARunOptimization::OnTesterDeinit ....";
      writeLog;
   #endif

   

   openSQLDatabase();


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
   while (FrameNext(iterationNumber, name, id, value, values)) {
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




