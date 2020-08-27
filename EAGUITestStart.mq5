//+------------------------------------------------------------------+
//|                                                        EAGUI.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EAGUIPanelTest.mqh"


int               _mainDBHandle;
string            _mainDBName="strategies.sqlite";
EAGUIPanelTest    testPanel;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

   string ss;

    // Open the database in the common terminal folder
    _mainDBHandle=DatabaseOpen(_mainDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
    if (_mainDBHandle==INVALID_HANDLE) {
        ss=StringFormat("OnInit ->  Failed to open Main DB with errorcode:%d",GetLastError());
        pss
        ExpertRemove();
    } else {
        ss="OnInit -> Open Main DB success";
        pss
    }

    if(!testPanel.Create(0,"Test Panel",0,10,50,1800,900)) {
      printf("error -1");
      return(-1); 
    }
      
      
    if(!testPanel.Run()) {
      printf("error -2");
      return(-2);
    }
      

    return(INIT_SUCCEEDED);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//--- destroy application dialog
  testPanel.Destroy(reason);
  //--- display the CHARTEVENT_CUSTOM constant value
  Print("CHARTEVENT_CUSTOM=",CHARTEVENT_CUSTOM);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
//---

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type

{
  if(id==CHARTEVENT_CLICK)
      Print("Mouse click coordinates on a chart: x = ",lparam,"  y = ",dparam);

  testPanel.ChartEvent(id,lparam,dparam,sparam);

}