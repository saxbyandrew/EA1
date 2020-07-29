//+------------------------------------------------------------------+
//|                                                         myEA.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"

#define  STATS_FRAME  1
#define _WRITELOG
#define _LOGSIZE 1
//#define _DEBUG_MYEA


#include <Object.mqh>
#include <Arrays\List.mqh>


//Shortcuts / macros
//#define pb param

#define usp  strategyParameters.sb    
#define gmp  EAPosition *p=martingalePositions.GetNodeAtIndex(i)
#define glp  EAPosition *p=longPositions.GetNodeAtIndex(i)
#define gsp  EAPosition *p=shortPositions.GetNodeAtIndex(i)
#define glhp EAPosition *p=longHedgePositions.GetNodeAtIndex(i)
#define showPanel if (!MQLInfoInteger(MQL_TESTER)) 
#define commentLine FileWrite(_txtHandle,"--------------------------------------------------")
#define writeLog FileWrite(_txtHandle,ss); FileFlush(_txtHandle)



#include "EAEnum.mqh"
#include "EAStrategyParameters.mqh"
#include "EARunOptimization.mqh"
#include "EAMain.mqh"
#include "EAPanel.mqh"


//+------------------------------------------------------------------+
// GLOBALS
//+------------------------------------------------------------------+

unsigned                ACTIVE_HEDGE;
unsigned                TRADING_CIRCUIT_BREAKER;
CList                   longPositions, shortPositions, martingalePositions, longHedgePositions;

EAMain                  *expertAdvisor; 
EAPanel                 *infoPanel; 
EAStrategyParameters    *strategyParameters; 
EAEnum                  _runMode;
int                     _dbHandle, _txtHandle, _optimizeHandle;
string                  _dbName="strategies.sqlite";
string                  _optimizeDBName="optimization.sqlite";


EARunOptimization       optimization;
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

    #ifdef _WRITELOG
        string ss;
    #endif

    EventSetTimer(60);

    if (!MQLInfoInteger(MQL_OPTIMIZATION)) {
        _txtHandle=FileOpen("eaLog.txt",FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);  
    }

    // Open the database in the common terminal folder
    _dbHandle=DatabaseOpen(_dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
    if (_dbHandle==INVALID_HANDLE) {
        #ifdef _WRITELOG
            ss=StringFormat("1 ->  Failed to open Main DB with errorcode:%d",GetLastError());
            writeLog;
            printf(ss);
        #endif
        ExpertRemove();
    } else {
        #ifdef _WRITELOG
            ss="1 -> Open Main DB success";
            writeLog;
            printf(ss);
        #endif
    }

    strategyParameters=new EAStrategyParameters;
    if (CheckPointer(strategyParameters)==POINTER_INVALID) {
        #ifdef _WRITELOG
            ss="2 -> Error instantiating strategy parameters";
            writeLog;
            printf(ss);
        #endif 
        ExpertRemove();
    } else {
        #ifdef _WRITELOG
            ss="2 -> Success instantiating strategy parameters";
            writeLog;
            printf(ss);
        #endif 
    }


    showPanel {
        infoPanel=new EAPanel;                                                                          
        if (CheckPointer(infoPanel)==POINTER_INVALID) {
            #ifdef _WRITELOG
                ss="3 -> Error instantiating info panel";
                writeLog;
                printf(ss);
            #endif  
            ExpertRemove();
        } else {
            infoPanel.createPanel("Panel",0,10,10,800,650);
            #ifdef _WRITELOG
                ss="3 -> Success instantiating info panel";
                writeLog;
                printf(ss);
            #endif  
        } 
    }

    expertAdvisor=new EAMain;                                  // Instantiate the EA                                           
    if (CheckPointer(expertAdvisor)==POINTER_INVALID) {
        #ifdef _WRITELOG
            ss="4  -> Error instantiating main EA";
            writeLog;
            printf(ss);
        #endif 
        ExpertRemove();
        
    } else {
        #ifdef _WRITELOG
            ss="4  -> Success instantiating main EA";
            writeLog;
            printf(ss);
        #endif 
    }
    
    
    TRADING_CIRCUIT_BREAKER=IS_UNLOCKED;          // Initially allow trading operations across all object
    ACTIVE_HEDGE=_NO;

    
    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { 

    EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

    static datetime lastBar, lastDay;

   //=========
   // ON TICK!
   //=========
    expertAdvisor.runOnTick();
    showPanel infoPanel.positionInfoUpdate();

   //=========
   // ON BAR ! 
   //========= 
    if(lastBar!=iTime(NULL,PERIOD_CURRENT,0)) {
        lastBar=iTime(NULL,PERIOD_CURRENT,0);
        #ifdef _DEBUG_MYEA
            Print(__FUNCTION__," _-> In OnTick fire OnBar");
        #endif 
        expertAdvisor.runOnBar(); 
        showPanel infoPanel.accountInfoUpdate();  
    }

   //========
   //ON DAY !
   //======== 
    if(lastDay!=iTime(NULL,PERIOD_D1,0)) {
        lastDay=iTime(NULL,PERIOD_D1,0);
        #ifdef _DEBUG_MYEA
            Print(__FUNCTION__," -> In OnTick fire OnDay");
        #endif 
        expertAdvisor.runOnDay();                       
    } 
    
}       

//+------------------------------------------------------------------+
//| https://www.mql5.com/en/docs/event_handlers/ontradetransaction    
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, 
    const MqlTradeRequest &request, const MqlTradeResult &result) {

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

    //ea.runOnTimer();
}


//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
int OnTesterInit() {

    return(optimization.OnTesterInit());

}
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit() {

    optimization.OnTesterDeinit(); 

}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {


    printf ("================OnTester=================");

    double ret=0;  
    double balance_dd=TesterStatistics(STAT_BALANCE_DDREL_PERCENT);
    //--- create a custom optimization criterion as the ratio of a net profit to a relative balance drawdown
    if(balance_dd!=0)
        ret=TesterStatistics(STAT_PROFIT)/balance_dd;
        //optimization.OnTester(ret);
    return(ret);

    
}
//+------------------------------------------------------------------+
void OnTesterPass() {

    optimization.OnTesterPass();

}
