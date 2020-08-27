//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_PANEL

#include <Controls\Label.mqh>

#define INDENT_LEFT                         (20)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (10)      // indent from top (with allowance for border width)
#define CONTROL_HEIGHT                      (30)      // size by Y coordinate


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EACPanel : public CPanel {

//=========
private:
//=========

   

//=========
protected:
//=========

void  setupControl();

//=========
public:
//=========


//virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);


EACPanel();  
~EACPanel();
};


///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EACPanel::EACPanel() {

   #ifdef _DEBUG_PANEL
      printf("EACPanel --> Default Constructor");
   #endif

   // Read values for this object from the SQLDB
   setupControl();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EACPanel::~EACPanel() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EACPanel::setupControl() {

   int x1,x2,y1,y2;

   x1=10;
   y1=10;
   x2=100;
   y2=50;

   #ifdef _DEBUG_PANEL
            printf("setupControl --> %d %d %d %d ",x1,y1,x2,y2);
   #endif

   // Add the new control object
   if (!CPanel::Create(0,"_P",0,x1,y1,x2,y2)) {
      printf ("EACPanel --> ERROR creating label box");
      ExpertRemove();
   } 
   
   //ColorBackground(clrRed);
   Text("hello");
   Color(clrAqua);



}
