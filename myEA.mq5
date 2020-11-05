//+------------------------------------------------------------------+
//|                                                         myEA.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"

#define  STATS_FRAME  1
#define _RUN_LONG_STRATEGY
//#define _RUN_SHORT_STRATEGY
//#define _RUN_LONG_HEDGE_STRATEGY
//#define _RUN_MARTINGALE_STRATEGY
//#define _RUN_PANEL

// DEBUG OPTIONS
#define _DEBUG_WRITE_CSV
//#define _DEBUG_MYEA
//#define _DEBUG_PANEL
//#define _DEBUG_COMBOXBOX
//#define _DEBUG_EDIT
//#define _DEBUG_CPANEL   // Blank panel NOT infoPanel !
//#define _DEBUG_TAB_CONTROL
//#define _DEBUG_PARAMETERS
//#define _DEBUG_MAIN_LOOP
//#define _DEBUG_TIME
#define _DEBUG_TECHNICAL_PARAMETERS
#define _DEBUG_NN_INPUTS_OUTPUTS
#define _DEBUG_NN
//#define _DEBUG_NN_LOADSAVE
//#define _DEBUG_NN_FORCAST
//#define _DEBUG_NN_TRAINING
//#define _DEBUG_STRATEGY
//#define _DEBUG_STRATEGY_TRIGGERS
//#define _DEBUG_DATAFRAME
//#define _DEBUG_BASE
//#define _DEBUG_LONG 
//#define _DEBUG_LABEL



#define _DEBUG_OPTIMIZATION

#include <Object.mqh>
#include <Arrays\List.mqh>
#include <Arrays\ArrayObj.mqh>

// =================
//Shortcuts / macros
// =================
#define gmp  EAPosition *p=martingalePositions.GetNodeAtIndex(i)
#define glp  EAPosition *p=longPositions.GetNodeAtIndex(i)
#define gsp  EAPosition *p=shortPositions.GetNodeAtIndex(i)
#define glhp EAPosition *p=longHedgePositions.GetNodeAtIndex(i)

#define writeLog FileWrite(_txtHandle,ss); FileFlush(_txtHandle);
//#define writeLog if (MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {FileWrite(_txtHandle,ss); FileFlush(_txtHandle);}
#define pss printf(ss);
#define pline ss="----------------------------------------------------------------"; pss writeLog


#include "EAEnum.mqh"
#include "EARunOptimization.mqh"

#ifdef _RUN_LONG_STRATEGY
    #include "EAStrategyLong.mqh"
#endif

#ifdef _RUN_PANEL
    #include "EAPanel.mqh"
    #include "EATabControlMenu.mqh"
    #define ip infoPanel
    #define showPanel if (!MQLInfoInteger(MQL_OPTIMIZATION)) 
#endif


//+------------------------------------------------------------------+
// GLOBALS
//+------------------------------------------------------------------+
double _x[100];
bool                    ENABLE_EVENTS, LOAD_HISTORY;
unsigned                ACTIVE_HEDGE;
unsigned                TRADING_CIRCUIT_BREAKER;
CList                   longPositions, shortPositions, martingalePositions, longHedgePositions;
CArrayObj               indicators, strategies;

#ifdef _RUN_LONG_STRATEGY
    EAStrategyLong          *strategyLong;
#endif


#ifdef _RUN_PANEL
    EAPanel                 *infoPanel; 
    EATabControlMenu        *tabControlMenu;
#endif

EAEnum                  _runMode;
datetime                _historyStart;
int                     _mainDBHandle, _txtHandle, _optimizeDBHandle;
string                  _mainDBName="strategies.sqlite";
string                  _optimizeDBName="optimization.sqlite";


EARunOptimization       optimization;
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

    string ss;



    // If the system is in optimization mode once the initializtion is complete
    // we need to create, populate a dataframe and the train the network before optimization continues
    // and positions are open/closed
    if (MQLInfoInteger(MQL_OPTIMIZATION)) {   
        _runMode=_RUN_OPTIMIZATION; 
    }
  
 /*
    _historyStart=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_SERVER_FIRSTDATE); 

    Print("Total number of bars for the symbol-period at this moment = ", 
    SeriesInfoInteger(Symbol(),Period(),SERIES_BARS_COUNT)); 
    
    Print("The first date for the symbol-period at this moment = ", 
        (datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_FIRSTDATE)); 
    
    Print("The first date in the history for the symbol-period on the server = ", 
        (datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_SERVER_FIRSTDATE)); 
    
    Print("Symbol data are synchronized = ", 
        (bool)SeriesInfoInteger(Symbol(),Period(),SERIES_SYNCHRONIZED)); 
*/
    MqlDateTime t;
    TimeToStruct(TimeCurrent(),t);
    string fn=StringFormat("%d%d%d%d%d%d%d%d.log",t.year,t.mon,t.day,t.hour,t.min,t.sec);
    _txtHandle=FileOpen(fn,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_TXT);  

    EventSetTimer(60);

    // Open the database in the common terminal folder
    _mainDBHandle=DatabaseOpen(_mainDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
    if (_mainDBHandle==INVALID_HANDLE) {
        #ifdef _DEBUG_MYEA
            ss=StringFormat("OnInit ->  Failed to open Main DB with errorcode:%d",GetLastError());
            writeLog
            pss
        #endif
        ExpertRemove();
    } else {
        #ifdef _DEBUG_MYEA
            ss="OnInit -> Open Main DB success";
            writeLog
            pss
        #endif
    }


    #ifdef _RUN_PANEL
    showPanel {
        ip=new EAPanel;                                                                          
        if (CheckPointer(ip)==POINTER_INVALID) {
            #ifdef _DEBUG_PANEL
                ss="OnInit -> Error instantiating info panel";
                pss
            #endif  
            ExpertRemove();
        } else {
            ip.Create(0,"Panel",0,10,10,700,900);
            #ifdef _DEBUG_PANEL
                ss="OnInit -> Success instantiating info panel";
                pss
            #endif  
        } 
        if (!ip.Run()) {
            #ifdef _DEBUG_PANEL
                ss="OnInit -> Error running info panel";
                pss
            #endif  
            ExpertRemove();
        }
    }
    #endif

    #ifdef _RUN_LONG_STRATEGY
        strategyLong=new EAStrategyLong;                                                                            
        if (CheckPointer(strategyLong)==POINTER_INVALID) {
            #ifdef _DEBUG_LONG
                ss="OnInit  -> Error instantiating LONG EA strategy";
                writeLog
                pss
            #endif 
            ExpertRemove();
        
        } else {
            #ifdef _DEBUG_LONG
                ss="OnInit  -> Success instantiating LONG EA strategy";
                writeLog
                pss
            #endif 
            strategies.Add(strategyLong);
            #ifdef _DEBUG_LONG
                ss=StringFormat("OnInit  -> Number of loaded strategies:%d",strategies.Total());
                writeLog
                pss
            #endif 
        }
    #endif


    TRADING_CIRCUIT_BREAKER=IS_UNLOCKED;          // Initially allow trading operations across all object
    ACTIVE_HEDGE=_NO;
    ENABLE_EVENTS=true;

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { 

    #ifdef _RUN_LONG_STRATEGY
        delete(strategyLong);
    #endif

    //delete(strategyParameters);
    #ifdef _RUN_PANEL
        showPanel {infoPanel.Destroy(reason);}
    #endif
    EventKillTimer();
    
}

/*
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void eaStrategyLoad() {


    strategyParameters=new EAStrategyParameters;
    if (CheckPointer(strategyParameters)==POINTER_INVALID) {
        #ifdef _DEBUG_MYEA
            ss="OnInit -> Error instantiating strategy parameters";
            writeLog;
            pss
        #endif 
        ExpertRemove();
    } else {
        #ifdef _DEBUG_MYEA
            ss="OnInit -> Success instantiating strategy parameters";
            writeLog;
            pss
        #endif 
    }

    usp.runMode=_RUN_STRATEGY_REBUILD_NN;

    expertAdvisor=new EAMain;                                  // Instantiate the EA                                           
    if (CheckPointer(expertAdvisor)==POINTER_INVALID) {
        #ifdef _DEBUG_MYEA
            ss="OnInit  -> Error instantiating main EA";
            writeLog
            pss
        #endif 
        ExpertRemove();
        
    } else {
        #ifdef _DEBUG_MYEA
            ss="OnInit  -> Success instantiating main EA";
            writeLog
            pss
        #endif 
    }
    

}
*/
/*
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void eaStrategyUpdate() {

    delete expertAdvisor;
    delete strategyParameters;

    eaStrategyLoad();
    

}
*/
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

    EAEnum  action;
    string  ss;
    static  datetime lastBar, lastDay;

   //=========
   // ON TICK!
   //=========
    action=_RUN_ONTICK;

    #ifdef _RUN_PANEL
        showPanel ip.positionInfoUpdate();
    #endif

   //=========
   // ON BAR ! 
   //========= 
    if(lastBar!=iTime(NULL,PERIOD_CURRENT,0)) {
        lastBar=iTime(NULL,PERIOD_CURRENT,0);

        action=_RUN_ONBAR;

        //=========
        // ON RELOAD
        //=========
        //if (usp.runMode==_RUN_STRATEGY_UPDATE) {
            //eaStrategyUpdate();
        //}
        #ifdef _RUN_PANEL   
            showPanel ip.accountInfoUpdate();  
        #endif
    }

   //========
   //ON DAY !
   //======== 
    if(lastDay!=iTime(NULL,PERIOD_D1,0)) {
        lastDay=iTime(NULL,PERIOD_D1,0);
        #ifdef _DEBUG_MYEA
            Print(__FUNCTION__," -> In OnTick fire OnDay");
        #endif 
        action=_RUN_ONDAY;
                        
    } 

    // Loop through all strategies and send a action
    for (int i=0;i<strategies.Total();i++) {
        EAPositionBase *p=strategies.At(i);
        p.execute(action);
        #ifdef _DEBUG_MYEA
            ss=StringFormat(" -> In OnTick sending action:%d",action);
            writeLog
            pss
        #endif 
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
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type

{
    

    if (MQLInfoInteger(MQL_OPTIMIZATION)) return;

    if (!ENABLE_EVENTS) return;

    if(id==CHARTEVENT_KEYDOWN) {
        //printf("Key Pressed");
    }
    
    #ifdef _RUN_PANEL
        ip.ChartEvent(id,lparam,dparam,sparam);
    #endif
    

}
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
int OnTesterInit() {


    string ss=StringFormat("OnTesterInit --> %s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1000)));
    writeLog

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

    double val=TesterStatistics(STAT_PROFIT);

    if (val>=istrategyGrossProfit) {
        optimization.OnTester(val);
    }

    /*
    if (val)

    double ret=0;  
    double balance_dd=TesterStatistics(STAT_BALANCE_DDREL_PERCENT);
    //--- create a custom optimization criterion as the ratio of a net profit to a relative balance drawdown
    if(balance_dd!=0)
        ret=TesterStatistics(STAT_PROFIT)/balance_dd;
        optimization.OnTester(ret);
    */
    return(1);

    
}
/*
//+------------------------------------------------------------------+
void OnTesterPass() {

        double val=TesterStatistics(STAT_SHARPE_RATIO);
    string ss=StringFormat("================OnTester================= STAT_SHARPE_RATIO: %s",DoubleToString(val));
    pss

    optimization.OnTesterPass();


}
*/
