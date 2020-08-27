//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Controls\Dialog.mqh>

#include "EATabControl.mqh"



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EATabControlMenu : public CAppDialog  {

//=========
private:
//=========

protected:

   EATabControl         *tabControl[10];
   EALabel              *tabControlLabels[10];

   void                 createTabControls(string tableGroup);

//=========
public:
//=========

   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);


EATabControlMenu();
~EATabControlMenu();
};

///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATabControlMenu::EATabControlMenu() {

   #ifdef _DEBUG_TAB_CONTROL
      printf("EATabControlMenu --> Default Constructor");
   #endif

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATabControlMenu::~EATabControlMenu() {

}
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
bool EATabControlMenu::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CAppDialog::OnEvent(id,lparam,dparam,sparam);


   #ifdef _DEBUG_PANEL
      //printf("OnEvent --> last object clicked%s id:%d",sparam,id);
   #endif

   for (int i=0;i<ArraySize(tabControl);i++) {
      if (tabControl[i]!=NULL) {

         if (tabControl[i].OnEvent(id,lparam,dparam,sparam)&&sparam=="tab1") {
            printf("TAB1 %s pressed",sparam);
            //showInfo1Controls();
         }
         if (tabControl[i].OnEvent(id,lparam,dparam,sparam)&&sparam=="tab2") {
            printf("TAB2 %s pressed",sparam);
            //showInfo2Controls();
         }
         if (tabControl[i].OnEvent(id,lparam,dparam,sparam)&&sparam=="tab3") {
            printf("TAB3 %s pressed",sparam);
            //showEditControls();
         }
         if (tabControl[i].OnEvent(id,lparam,dparam,sparam)&&sparam=="tab4") {
            printf("TAB4 %s pressed",sparam);
            //showInfo1Controls();
         }

      }

   }

   return true;

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EATabControlMenu::createTabControls(string tableGroup) {

   #ifdef _DEBUG_PANEL
      printf("EATabControlMenu createTabControls -->");
   #endif

   static int i=0;
   string sqlFieldName;

   string sql=StringFormat("SELECT sqlFieldName FROM METADATA WHERE controlType='TAB' AND tableGroup='%s' ORDER BY displayColumn",tableGroup);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> createTabControls: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   #ifdef _DEBUG_PANEL
      printf("EATabControlMenu --> %s",sql);
   #endif

   while (DatabaseRead(request)) {
      DatabaseColumnText(request,0,sqlFieldName);  
      //printf("CreateComboBoxes --> %s",sqlFieldName);
      
      tabControl[i]=new EATabControl(sqlFieldName);
      if (CheckPointer(tabControl[i])==POINTER_INVALID) {
         printf("ERROR creating createTabControls");
      } else {
         //combox1.Create(0,"combox1",0,combox1.x1,combox1.y1,combox1.x2,combox1.y2);
         //printf("SUCCESS creating Label adding to CAppDialog");
         Add(tabControl[i]);
         printf("SUCCESS creating tabControl adding to CAppDialog %d",tabControl[i].ZOrder());
      }

      tabControlLabels[i]=new EALabel(sqlFieldName);
      if (CheckPointer(tabControlLabels[i])==POINTER_INVALID) {
         printf("ERROR creating tabControlLabels");
      } else {
         //combox1.Create(0,"combox1",0,combox1.x1,combox1.y1,combox1.x2,combox1.y2);
         printf("SUCCESS creating tabControlLabels adding to CAppDialog %d",tabControlLabels[i].ZOrder());
         Add(tabControlLabels[i]);
         printf("SUCCESS creating tabControlLabels adding to CAppDialog %d",tabControlLabels[i].ZOrder());
      }

      i++;

   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool EATabControlMenu::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2) {

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
   
   #ifdef _DEBUG_PANEL
      printf("EATabControlMenu Create -->");
   #endif

   createTabControls("TAB");


   return(true);
}