//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_COMBOXBOX

#include <Controls\ComboBox.mqh>

#define INDENT_LEFT                         (20)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (10)      // indent from top (with allowance for border width)
#define CONTROL_HEIGHT                      (30)      // size by Y coordinate


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAComboBox1 : public CComboBox {

//=========
private:
//=========

   struct ComboBox {
      string sqlFieldName;
      string description;
      string controlType;
      string dataType;
      int   displayColumn;
      int   displayRow;
      int   width;
      string values[3];
      int x1, y1, x2, y2;
   } cb;

   void  updateValuesToDB(int saveValue);
   void  updateValuesToDB(string saveValue);
   void  updateValuesToDB();
   void  setupControl(string sqlFieldName);
   

//=========
protected:
//=========



//=========
public:
//=========


   //virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- handlers of the dependent controls events
   void       onChange();

EAComboBox1(string sqlFieldName);  
~EAComboBox1();
};


///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAComboBox1::EAComboBox1(string sqlFieldName) {

   #ifdef _DEBUG_COMBOXBOX
      printf("EAComboBox1 --> Default Constructor");
   #endif

   // Read values for this object from the SQLDB
   setupControl(sqlFieldName);

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAComboBox1::~EAComboBox1() {

}


//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
//EVENT_MAP_BEGIN(EAComboBox1)

//EVENT_MAP_END(CComboBox)


bool EAComboBox1::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   //CComboBox::OnEvent(id,lparam,dparam,sparam);

   // Custom event handling from here
   #ifdef _DEBUG_COMBOXBOX
      printf("OnEvent --> ID:%d ObjectName:%s",id,Name());
   #endif


   return true;

}

//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void EAComboBox1::onChange(void) {

   // Custom event handling from here
   #ifdef _DEBUG_COMBOXBOX
      printf("OnEvent --> ObjectName:%s",Name());
   #endif
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox1::updateValuesToDB(string saveValue) {
   //String update goes here
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox1::updateValuesToDB(int saveValue) {

   string sql=StringFormat("UPDATE STRATEGY SET %s=%d WHERE strategyNumber=%d",cb.sqlFieldName,saveValue,1234);
   #ifdef _DEBUG_COMBOXBOX
      printf("updateValuesToDB --> update request is:%s",sql);
   #endif
   if (!DatabaseExecute(_mainDBHandle,sql)) {
      Print("updateValuesToDB -> DB request failed with code ", GetLastError());
      return;
   } else {
      #ifdef _DEBUG_COMBOXBOX
         printf("updateValuesToDB -> updated %s SUCCESS",cb.sqlFieldName);
      #endif
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox1::updateValuesToDB() {

   #ifdef _DEBUG_COMBOXBOX
            printf("updateValuesToDB --> ");
   #endif

   int idx=Value();              // Selected values store index

   if (cb.dataType=="BOOL") {
      if (cb.values[idx]=="YES") updateValuesToDB(1);
      if (cb.values[idx]=="NO")  updateValuesToDB(0);
   }

   if (cb.dataType=="TEXT") {

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox1::setupControl(string sqlFieldName) {

   string sql=StringFormat("SELECT * FROM METADATA WHERE sqlFieldName='%s'",sqlFieldName);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> DatabasePrepare: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   DatabaseRead(request);
   DatabaseColumnText(request,0,cb.sqlFieldName);      
   DatabaseColumnText(request,1,cb.description);      
   DatabaseColumnText(request,2,cb.controlType);
   DatabaseColumnText(request,3,cb.dataType);
   DatabaseColumnInteger(request,4,cb.displayColumn);
   DatabaseColumnInteger(request,5,cb.displayRow);
   DatabaseColumnInteger(request,6,cb.width);
   DatabaseColumnText(request,7, cb.values[0]); 
   DatabaseColumnText(request,8, cb.values[1]); 
   DatabaseColumnText(request,9,cb.values[2]); 

   #ifdef _DEBUG_COMBOXBOX
            printf("readValueFromDB --> %s %s %s ",cb.values[0],cb.values[1],cb.values[2]);
   #endif

   // Set the XY positions
   cb.x1=INDENT_LEFT+(cb.displayColumn*cb.width);
   cb.y1=INDENT_TOP+(CONTROL_HEIGHT*cb.displayRow);
   cb.x2=INDENT_LEFT+(cb.displayColumn*cb.width)+cb.width;
   cb.y2=INDENT_TOP+(CONTROL_HEIGHT*cb.displayRow)+CONTROL_HEIGHT;

   #ifdef _DEBUG_COMBOXBOX
            printf("setupControl --> %d %d %d %d ",cb.x1,cb.y1,cb.x2,cb.y2);
   #endif

   // Add the new control object
   if (!CComboBox::Create(0,sqlFieldName,0,cb.x1,cb.y1,cb.x2,cb.y2)) {
      printf ("EAComboBox1 --> ERROR creating combo box:%s",sqlFieldName);
      ExpertRemove();
   } 

   

   // Add the control values
   for (int i=0;i<ArraySize(cb.values);i++) {
      if (cb.values[i]==NULL) break;
      ItemAdd(cb.values[i]);
      #ifdef _DEBUG_COMBOXBOX
         printf("setupControl --> idx:%d Item add:%s ",i,cb.values[i]);
      #endif
   }

}
