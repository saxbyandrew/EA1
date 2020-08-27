//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_PANEL
#include <Controls\Dialog.mqh>


#include "EAComboBox.mqh"
#include "EAEdit.mqh"
#include "EALabel.mqh"
#include "EACPanel.mqh"
#include "EACButton.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAGUIPanelTest : public CAppDialog {

//=========
private:
//=========

   bool eventsEnabled;
   


protected:

   EAEdit               *edit[50];
   EAComboBox           *comboBox[50];
   EACPanel             *panels[10];
   EACButton            *buttons[10];

   void                 createComboControls(string tableGroup);
   void                 createEditControls(string tableGroup);
   void                 createPanelControls();
   void                 createButtonControls();

//=========
public:
//=========

   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

EAGUIPanelTest();
~EAGUIPanelTest();
};


//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
bool EAGUIPanelTest::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CAppDialog::OnEvent(id,lparam,dparam,sparam);

   if(!eventsEnabled) {
      printf("events disabled");
      return false;
   }

   //printf("OnEvent --> last object clicked%s id:%d",sparam,id);
   for (int i=0;i<ArraySize(comboBox);i++) {
      if (comboBox[i]!=NULL) comboBox[i].OnEvent(id,lparam,dparam,sparam);
      //printf("OnEvent --> comboboxes %d",i);
   }

   if (id==CHARTEVENT_OBJECT_ENDEDIT) {
      for (int i=0;i<ArraySize(edit);i++) {
         if (edit[i]!=NULL) edit[i].OnEvent(id,lparam,dparam,sparam);
         //printf("OnEvent --> comboboxes %d",i);
      }
   }

   return true;

}
//EVENT_MAP_BEGIN(EAGUIPanelTest)
//ON_EVENT(ON_CHANGE,combobox1,combobox1.onChange)
//ON_EVENT(ON_CHANGE,combobox2,combobox2.onChange)
//EVENT_MAP_END(EAGUIPanelTest)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAGUIPanelTest::EAGUIPanelTest() {

   //printf("EAGUIPanelTest -->  default constructor");

   eventsEnabled=false;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAGUIPanelTest::~EAGUIPanelTest() {

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAGUIPanelTest::createPanelControls() {

   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest createPanelControls -->");
   #endif

   panels[0]=new EACPanel();
   if (CheckPointer(panels[0])==POINTER_INVALID) {
      printf("ERROR creating createPanelControls");
   } else {
      Add(panels[0]);
      printf("SUCESS creating createPanelControls");
   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAGUIPanelTest::createButtonControls() {

   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest createButtonControls -->");
   #endif

   static int i=0;
   string sqlFieldName;

   string sql="SELECT sqlFieldName FROM METADATA WHERE controlType='CBUTTON'";
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> createButtonControls: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   #ifdef _DEBUG_PANEL
      printf("createButtonControls --> %s",sql);
   #endif

   while (DatabaseRead(request)) {
      DatabaseColumnText(request,0,sqlFieldName);  
      //printf("CreateComboBoxes --> %s",sqlFieldName);

      buttons[i]=new EACButton(sqlFieldName);
      if (CheckPointer(buttons[i])==POINTER_INVALID) {
         printf("ERROR creating edit");
      } else {
         Add(buttons[i]);
      }
      i++;
   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAGUIPanelTest::createEditControls(string tableGroup) {

   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest createEditControls -->");
   #endif

   static int i=0;
   string sqlFieldName;

   string sql=StringFormat("SELECT sqlFieldName FROM METADATA WHERE controlType='CEDIT' AND tableGroup='%s'",tableGroup);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> createEditControls: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest --> %s",sql);
   #endif

   while (DatabaseRead(request)) {
      DatabaseColumnText(request,0,sqlFieldName);  
      //printf("CreateComboBoxes --> %s",sqlFieldName);


      EALabel *l=new EALabel(sqlFieldName);
      if (CheckPointer(l)==POINTER_INVALID) {
         printf("ERROR creating edit");
      } else {
         //combox1.Create(0,"combox1",0,combox1.x1,combox1.y1,combox1.x2,combox1.y2);
         //printf("SUCCESS creating Label adding to CAppDialog");
         Add(l);
      }

      edit[i]=new EAEdit(sqlFieldName);
      if (CheckPointer(edit[i])==POINTER_INVALID) {
         printf("ERROR creating edit");
      } else {
         //combox1.Create(0,"combox1",0,combox1.x1,combox1.y1,combox1.x2,combox1.y2);
         //printf("SUCCESS creating combox1 adding to CAppDialog");
         Add(edit[i]);
      }
      i++;

   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAGUIPanelTest::createComboControls(string tableGroup) {

   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest createComboControls -->");
   #endif

   static int i=0;
   string sqlFieldName;

   string sql=StringFormat("SELECT sqlFieldName FROM METADATA WHERE controlType='CCOMBOBOX' AND tableGroup='%s'",tableGroup);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> CreateComboBoxes: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest --> %s",sql);
   #endif

   while (DatabaseRead(request)) {
      DatabaseColumnText(request,0,sqlFieldName);  
      //printf("CreateComboBoxes --> %s",sqlFieldName);


      EALabel *l=new EALabel(sqlFieldName);
      if (CheckPointer(l)==POINTER_INVALID) {
         printf("ERROR creating combox");
      } else {
         //combox1.Create(0,"combox1",0,combox1.x1,combox1.y1,combox1.x2,combox1.y2);
         //printf("SUCCESS creating Label adding to CAppDialog");
         Add(l);
      }

      comboBox[i]=new EAComboBox(sqlFieldName);
      if (CheckPointer(comboBox[i])==POINTER_INVALID) {
         printf("ERROR creating combox");
      } else {
         //combox1.Create(0,"combox1",0,combox1.x1,combox1.y1,combox1.x2,combox1.y2);
         //printf("SUCCESS creating combox1 adding to CAppDialog");
         Add(comboBox[i]);
      }
      i++;

   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool EAGUIPanelTest::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2) {

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
   
   #ifdef _DEBUG_PANEL
      printf("EAGUIPanelTest Create -->");
   #endif

   createButtonControls();
   //createPanelControls();
   
   createComboControls("STRATEGY");
   createEditControls("STRATEGY");
   createComboControls("TIMING");
   createEditControls("TIMING");
   createComboControls("ADX");
   
   createComboControls("RSI");
   createComboControls("ICH");
   
   createComboControls("STOC");
   createComboControls("RVI");
   createComboControls("MFI");

   
   createComboControls("OSMA");
   createComboControls("SAR");
   
   createComboControls("MACD");
   createComboControls("MACDBULL");
   createComboControls("MACDBEAR");
   
   
   
   eventsEnabled=true;
   

   return(true);
}
