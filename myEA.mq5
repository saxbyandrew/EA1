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
//#define usingStrategyValue param
//#define usingPositionValue p

//#define gmp  EAPosition *p=martingalePositions.GetNodeAtIndex(i)
//#define glp  EAPosition *p=longPositions.GetNodeAtIndex(i)
////#define gsp  EAPosition *p=shortPositions.GetNodeAtIndex(i)
//#define glhp EAPosition *p=longHedgePositions.GetNodeAtIndex(i)
//#define showPanel if (bool (usingStrategyValue.runMode&_RUN_SHOW_PANEL)) 
#define commentLine FileWrite(_txtHandle,"--------------------------------------------------")
#define writeLog FileWrite(_txtHandle,ss); FileFlush(_txtHandle)


#include "EAEnum.mqh"
//#include "EAStrategyParameters.mqh"
#include "EARunOptimization.mqh"
//#include "EAMain.mqh"
//#include "EAPanel.mqh"


//+------------------------------------------------------------------+
// GLOBALS
//+------------------------------------------------------------------+

unsigned                ACTIVE_HEDGE;
unsigned                TRADING_CIRCUIT_BREAKER;
//CList                   longPositions, shortPositions, martingalePositions, longHedgePositions;

//EAStrategyParameters    *param;
//EAMain                  *ea; 
//EAPanel                 *mp; 
EAEnum                  _runMode;
int                     _dbHandle, _optimizeDB, _txtHandle, _strategyNumber;
string                  _dbName="strategies.sqlite";
string                  _optimizeDBName="optimization.sqlite";

//EAStrategyParameters    param;
EARunOptimization       optimization;
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

    Print(__FUNCTION__);

    EventSetTimer(60);

    // Open the database in the common terminal folder
    _dbHandle=DatabaseOpen(_dbName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
    if (_dbHandle==INVALID_HANDLE) {
        printf(" -> DB open failed to open:%d",GetLastError());
         ExpertRemove();
    } 

    // Get the strategy number save it globally
    int request=DatabasePrepare(_dbHandle,"SELECT strategyNumber FROM STRATEGIES WHERE isActive=1"); 
    if (DatabaseRead(request)) {
        DatabaseColumnInteger(request,0,_strategyNumber);
    } else {
        printf(" -> Failed with errorcode:%d",GetLastError());
        ExpertRemove();
    }

    _runMode=_RUN_NORMAL; // Set the initial mode to normal for now
    
    #ifdef _WRITELOG
        string ss;
        ss=StringFormat(" -> System initially set to mode:%s",EnumToString(_runMode));
        writeLog;
        _txtHandle=FileOpen("eaLog.txt",FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);  
        commentLine;
        writeLog;
   #endif

   
   

/*
    param=new EAStrategyParameters;
    if (CheckPointer(param)==POINTER_INVALID) {
        #ifdef _DEBUG_MYEA
            Print(" -> Error instantiating strategy parameters");
        #endif 
        ExpertRemove();
    } 
*/

/*
    showPanel {
        mp=new EAPanel;                                                                          
        if (CheckPointer(mp)==POINTER_INVALID) {
            #ifdef _DEBUG_MYEA
                Print(" -> Error instantiating info panel");
            #endif  
        } else {
            mp.createPanel("fff",0,10,10,800,650);
            mp.showPanelDetails();
        } 
    }


    

    ea=new EAMain;                                  // Instantiate the EA                                           
    if (CheckPointer(ea)==POINTER_INVALID) {
        #ifdef _DEBUG_MYEA
            Print(" -> Error instantiating main EA");
        #endif 
        
    }
    
    
    TRADING_CIRCUIT_BREAKER=IS_UNLOCKED;          // Initially allow trading operations across all object
    ACTIVE_HEDGE=_NO;
*/
    
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

    /*
    static datetime lastBar, lastDay;

   //=========
   // ON TICK!
   //=========
    ea.runOnTick();

   //=========
   // ON BAR ! 
   //========= 
    if(lastBar!=iTime(NULL,PERIOD_CURRENT,0)) {
        lastBar=iTime(NULL,PERIOD_CURRENT,0);
        #ifdef _DEBUG_MYEA
            Print(__FUNCTION__," _-> In OnTick fire OnBar");
        #endif 
        ea.runOnBar();   
    }

   //========
   //ON DAY !
   //======== 
    if(lastDay!=iTime(NULL,PERIOD_D1,0)) {
        lastDay=iTime(NULL,PERIOD_D1,0);
        #ifdef _DEBUG_MYEA
            Print(__FUNCTION__," -> In OnTick fire OnDay");
        #endif 
        ea.runOnDay();                       
    } 

    */
    
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

    printf ("===============OnTesterInit==================");
    return(optimization.OnTesterInit());

}
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit() {

    printf ("===============OnTesterDeinit==================");
    optimization.OnTesterDeinit(); 
    printf ("===============OnTesterDeinit==================");
    optimization.closeSQLDatabase();

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
