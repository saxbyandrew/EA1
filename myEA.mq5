//+------------------------------------------------------------------+
//|                                                         myEA.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"

#define  STATS_FRAME  1
//#define _DEBUG_MYEA
//#define  _DEBUG_NN_INPUTS_OUTPUTS
//#define _DEBUG_DNN
//#define  _DEBUG_STRATGEY
//#define  _DEBUG_STRATGEY_TRIGGERS
//#define _DEBUG_DATAFRAME
//#define _DEBUG_LONG 
//#define _DEBUG_STRATEGY_TIME




#include <Object.mqh>
#include <Arrays\List.mqh>


//Shortcuts / macros
//#define pb param

#define usp  strategyParameters.sb    
#define gmp  EAPosition *p=martingalePositions.GetNodeAtIndex(i)
#define glp  EAPosition *p=longPositions.GetNodeAtIndex(i)
#define gsp  EAPosition *p=shortPositions.GetNodeAtIndex(i)
#define glhp EAPosition *p=longHedgePositions.GetNodeAtIndex(i)
#define showPanel if (!MQLInfoInteger(MQL_OPTIMIZATION)) 
#define writeLog if (MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {FileWrite(_txtHandle,ss); FileFlush(_txtHandle);}



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
int                     _mainDBHandle, _txtHandle, _optimizeDBHandle;
string                  _mainDBName="strategies.sqlite";
string                  _optimizeDBName="optimization.sqlite";


EARunOptimization       optimization;
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

    #ifdef _DEBUG_MYEA
        string ss;
    #endif

    MqlDateTime t;
    TimeToStruct(TimeCurrent(),t);
    string fn=StringFormat("%d%d%d%d%d%d%d%d.log",t.year,t.mon,t.day,t.hour,t.min,t.sec);
    _txtHandle=FileOpen(fn,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);  
    
    EventSetTimer(60);

    // Open the database in the common terminal folder
    _mainDBHandle=DatabaseOpen(_mainDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
    if (_mainDBHandle==INVALID_HANDLE) {
        #ifdef _DEBUG_MYEA
            ss=StringFormat("OnInit ->  Failed to open Main DB with errorcode:%d",GetLastError());
            writeLog
            printf(ss);
        #endif
        ExpertRemove();
    } else {
        #ifdef _DEBUG_MYEA
            ss="OnInit -> Open Main DB success";
            writeLog
            printf(ss);
        #endif
    }

    strategyParameters=new EAStrategyParameters;
    if (CheckPointer(strategyParameters)==POINTER_INVALID) {
        #ifdef _DEBUG_MYEA
            ss="OnInit -> Error instantiating strategy parameters";
            writeLog;
            printf(ss);
        #endif 
        ExpertRemove();
    } else {
        #ifdef _DEBUG_MYEA
            ss="OnInit -> Success instantiating strategy parameters";
            writeLog;
            printf(ss);
        #endif 
    }


    showPanel {
        infoPanel=new EAPanel;                                                                          
        if (CheckPointer(infoPanel)==POINTER_INVALID) {
            #ifdef _DEBUG_MYEA
                ss="OnInit -> Error instantiating info panel";
                printf(ss);
            #endif  
            ExpertRemove();
        } else {
            infoPanel.createPanel("Panel",0,10,10,800,650);
            #ifdef _DEBUG_MYEA
                ss="OnInit -> Success instantiating info panel";
                printf(ss);
            #endif  
        } 
    }

    expertAdvisor=new EAMain;                                  // Instantiate the EA                                           
    if (CheckPointer(expertAdvisor)==POINTER_INVALID) {
        #ifdef _DEBUG_MYEA
            ss="OnInit  -> Error instantiating main EA";
            writeLog
            printf(ss);
        #endif 
        ExpertRemove();
        
    } else {
        #ifdef _DEBUG_MYEA
            ss="OnInit  -> Success instantiating main EA";
            writeLog
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
        optimization.OnTester(ret);
    return(ret);

    
}
//+------------------------------------------------------------------+
void OnTesterPass() {

    optimization.OnTesterPass();

}
