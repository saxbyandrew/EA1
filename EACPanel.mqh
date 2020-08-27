//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Controls\Label.mqh>



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
virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
//virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);


EACPanel();  
~EACPanel();
};


///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EACPanel::EACPanel() {

   #ifdef _DEBUG_CPANEL
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
//| Event Handling                                                   |
//+------------------------------------------------------------------+
//EVENT_MAP_BEGIN(EAEdit)

//EVENT_MAP_END(CComboBox)


bool EACPanel::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CPanel::OnEvent(id,lparam,dparam,sparam);

   // Custom event handling from here
   #ifdef _DEBUG_CPANEL
      printf("EACPanel -> OnEvent --> ID:%d ObjectName:%s",id,Name());
   #endif

   return true;

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

   #ifdef _DEBUG_CPANEL
      printf("setupControl --> %d %d %d %d ",x1,y1,x2,y2);
   #endif

   // Add the new control object
   if (!CPanel::Create(0,"_P",0,x1,y1,x2,y2)) {
      printf ("EACPanel --> ERROR creating label box");
      ExpertRemove();
   } 
   
   ColorBackground(clrRed);


}
