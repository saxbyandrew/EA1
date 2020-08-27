//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define TABCONTROL_HEIGHT                   (60)

#include <Controls\Label.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EATabControl : public CPanel {

//=========
private:
//=========

struct TabControl {
      string sqlFieldName;
      string description;
      string controlType;
      string dataType;
      int   displayColumn;
      int   displayRow;
      int   descriptionWidth;
      int   controlWidth;
      string tableGroup;
      int x1, y1, x2, y2;
      string tabColor;
   } tc;


//=========
protected:
//=========

void  setupControl(string sqlFieldName);

//=========
public:
//=========

//virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
//virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);


EATabControl(string sqlFieldName);  
~EATabControl();
};

///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATabControl::EATabControl(string sqlFieldName) {

   #ifdef _DEBUG_TAB_CONTROL
      printf("EATabControl --> Default Constructor");
   #endif

   // Read values for this object from the SQLDB
   setupControl(sqlFieldName);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATabControl::~EATabControl() {

}
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
//EVENT_MAP_BEGIN(EAEdit)

//EVENT_MAP_END(CComboBox)


bool EATabControl::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CPanel::OnEvent(id,lparam,dparam,sparam);

   // Custom event handling from here
   #ifdef _DEBUG_TAB_CONTROL
      printf("EATabControl -> OnEvent --> ID:%d ObjectName:%s sparam:%s",id,Name(),sparam);
   #endif

   if (sparam==Name()) {
      printf("Object Name:%s and sparam:%s MATCH",Name(),sparam);
      return true;
   }

   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATabControl::setupControl(string sqlFieldName) {


   string sql=StringFormat("SELECT * FROM METADATA WHERE sqlFieldName='%s'",sqlFieldName);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> DatabasePrepare: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   #ifdef _DEBUG_TAB_CONTROL
      printf("setupControl --> %s ",sql);
   #endif

   DatabaseRead(request);
   DatabaseColumnText(request,0,tc.sqlFieldName);      
   DatabaseColumnText(request,1,tc.description);      
   DatabaseColumnText(request,2,tc.controlType);
   DatabaseColumnText(request,3,tc.dataType);
   DatabaseColumnInteger(request,4,tc.displayColumn);
   DatabaseColumnInteger(request,5,tc.displayRow);
   DatabaseColumnInteger(request,6,tc.descriptionWidth);
   DatabaseColumnInteger(request,7,tc.controlWidth);
   DatabaseColumnText(request,8,tc.tableGroup);
   DatabaseColumnText(request,9,tc.tabColor);


   // Set the XY positions
   tc.x1=(tc.displayColumn*tc.descriptionWidth);
   tc.y1=0;
   tc.x2=(tc.displayColumn*tc.descriptionWidth)+tc.descriptionWidth;
   tc.y2=TABCONTROL_HEIGHT;

   #ifdef _DEBUG_TAB_CONTROL
            printf("setupControl --> %d %d %d %d ",tc.x1,tc.y1,tc.x2,tc.y2);
   #endif

   // Add the new control object
   if (!CPanel::Create(0,sqlFieldName,0,tc.x1,tc.y1,tc.x2,tc.y2)) {
      printf ("EATabControl --> ERROR creating tabControl:%s",sqlFieldName);
      ExpertRemove();
   } 

   ColorBackground(tc.tabColor);

}