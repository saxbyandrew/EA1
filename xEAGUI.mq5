//+------------------------------------------------------------------+
//|                                                        EAGUI.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "xEAPanel.mqh"




int _mainDBHandle;
string                  _mainDBName="strategies.sqlite";

EAPanel                 *infoPanel1, infoPanel2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

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
//---
  infoPanel1=new EAPanel;  
//--- set the flag of receiving chart object creation events

        
  infoPanel1.Create(0,"STRATEGY",0,80,80,800,1000);
  infoPanel1.Run();
  
  return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   infoPanel1.Destroy(0);

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
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

 string comment="Last event: ";

//--- select event on chart
   switch(id)
     {
      //--- 1
      case CHARTEVENT_KEYDOWN:
        {
         comment+="1) keystroke";
         break;
        }
      //--- 2
      case CHARTEVENT_MOUSE_MOVE:
        {
         comment+="2) mouse";
         break;
        }
      //--- 3
      case CHARTEVENT_OBJECT_CREATE:
        {
         comment+="3) create graphical object";
         break;
        }
      //--- 4
      case CHARTEVENT_OBJECT_CHANGE:
        {
         comment+="4) change object properties via properties dialog";
         break;
        }
      //--- 5
      case CHARTEVENT_OBJECT_DELETE:
        {
         comment+="5) delete graphical object";
         break;
        }
      //--- 6
      case CHARTEVENT_CLICK:
        {
         comment+="6) mouse click on chart";
         break;
        }
      //--- 7
      case CHARTEVENT_OBJECT_CLICK:
        {
         comment+="7) mouse click on graphical object";
         break;
        }
      //--- 8
      case CHARTEVENT_OBJECT_DRAG:
        {
         comment+="8) move graphical object with mouse";
         break;
        }
      //--- 9
      case CHARTEVENT_OBJECT_ENDEDIT:
        {
         comment+="9) finish editing text";
         break;
        }
      //--- 10
      case CHARTEVENT_CHART_CHANGE:
        {
         comment+="10) modify chart";
         break;
        }
     }
//---
   Comment(comment);
    
    infoPanel1.ChartEvent(id,lparam,dparam,sparam);
    //printf("ID:%d, lparam:%.2f, dparam:%.2f sparam:%.2f",id,lparam,dparam,sparam);
    
  }