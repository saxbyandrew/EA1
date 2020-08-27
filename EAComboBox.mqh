//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"



#include <Controls\ComboBox.mqh>



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAComboBox : public CComboBox {

//=========
private:
//=========

   struct ComboControl {
      string sqlFieldName;
      string description;
      string controlType;
      string dataType;
      int   displayColumn;
      int   displayRow;
      int   descriptionWidth;
      int   controlWidth;
      string tableGroup;
      string values[3];
      int x1, y1, x2, y2;
   } cb;

   void  updateValuesToDB(int saveValue);
   void  updateValuesToDB(string saveValue);
   void  updateValuesToDB();
   void  setupControl(string sqlFieldName);
   void  setupControl(string sqlFieldName,string dataType);
   

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

EAComboBox(string sqlFieldName);  
~EAComboBox();
};


///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAComboBox::EAComboBox(string sqlFieldName) {

   #ifdef _DEBUG_COMBOXBOX
      printf("EAComboBox --> Default Constructor");
   #endif


   // Read values for this object from the SQLDB
   setupControl(sqlFieldName);

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAComboBox::~EAComboBox() {

}


//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
//EVENT_MAP_BEGIN(EAComboBox)

//EVENT_MAP_END(CComboBox)


bool EAComboBox::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CComboBox::OnEvent(id,lparam,dparam,sparam);


   if (sparam==Name()) {
      #ifdef _DEBUG_COMBOXBOX
         printf("OnEvent --> ObjectName:%s",Name());
      #endif
      updateValuesToDB();
   }


   // Custom event handling from here
   #ifdef _DEBUG_COMBOXBOX
      //printf("OnEvent --> ID:%d ObjectName:%s",id,Name());
   #endif

   return true;

}

//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void EAComboBox::onChange(void) {

   // Custom event handling from here
   //#ifdef _DEBUG_COMBOXBOX
      //printf("OnEvent --> ObjectName:%s",Name());
   //#endif
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox::updateValuesToDB(string saveValue) {

   string sql=StringFormat("UPDATE %s SET %s='%s' WHERE strategyNumber=%d",cb.tableGroup,cb.sqlFieldName,saveValue,1234);
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
void EAComboBox::updateValuesToDB(int saveValue) {

   string sql=StringFormat("UPDATE %s SET %s=%d WHERE strategyNumber=%d",cb.tableGroup,cb.sqlFieldName,saveValue,1234);
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
void EAComboBox::updateValuesToDB() {

   #ifdef _DEBUG_COMBOXBOX
            printf("updateValuesToDB --> ");
   #endif

   int idx=Value();              // Selected values store index

   if (cb.dataType=="BOOL") {
      if (cb.values[idx]=="Yes") {
         updateValuesToDB(1);
         #ifdef _DEBUG_COMBOXBOX
            printf("updateValuesToDB --> Type BOOL YES value");
         #endif
      }
      if (cb.values[idx]=="No") {
         #ifdef _DEBUG_COMBOXBOX
            printf("updateValuesToDB --> Type BOOL NO value");
         #endif
         updateValuesToDB(0);
      }  

   }

   if (cb.dataType=="TEXT") {
      updateValuesToDB(cb.values[idx]);
      #ifdef _DEBUG_COMBOXBOX
         printf("updateValuesToDB --> Type STRING value:%s",cb.values[idx]);
      #endif

   }

   if (cb.dataType=="INT" || cb.dataType=="INTEGER" ) {
      updateValuesToDB(idx);
      #ifdef _DEBUG_COMBOXBOX
         printf("updateValuesToDB --> Type INT value:%d",idx);
      #endif
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox::setupControl(string sqlFieldName,string dataType) {


   int      intValue;
   double   doubleValue;
   string   textValue;
   
   string sql=StringFormat("SELECT %s FROM %s WHERE strategyNumber=1234",sqlFieldName,cb.tableGroup);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_PANEL1
         Print(" -> DatabasePrepare: request failed with code ", GetLastError());
      #endif
      ExpertRemove();
   }
   #ifdef _DEBUG_COMBOXBOX
      printf("setupControl --> %s ",sql);
   #endif

   DatabaseRead(request);

   if (dataType=="BOOL")  {
      DatabaseColumnInteger(request,0,intValue);
      Select(intValue);
      #ifdef _DEBUG_COMBOXBOX
         printf("setupControl --> %s %d read from DB and assigned to control current item value:%d",sqlFieldName,intValue,Value());
      #endif
   }
   
   if (dataType=="INT"||dataType=="INTEGER")  {
      DatabaseColumnInteger(request,0,intValue);
      Select(intValue);
   }
   
   if (dataType=="TEXT")   {
      DatabaseColumnText(request,0,textValue);
      printf("--- %s",textValue);
      SelectByText(textValue);
   }

   if (dataType=="REAL")  {
      DatabaseColumnDouble(request,0,doubleValue);
      //
   }
   

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAComboBox::setupControl(string sqlFieldName) {

   string sql=StringFormat("SELECT * FROM METADATA WHERE sqlFieldName='%s'",sqlFieldName);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> DatabasePrepare: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   #ifdef _DEBUG_COMBOXBOX
      printf("setupControl --> %s ",sql);
   #endif

   DatabaseRead(request);
   DatabaseColumnText(request,0,cb.sqlFieldName);      
   DatabaseColumnText(request,1,cb.description);      
   DatabaseColumnText(request,2,cb.controlType);
   DatabaseColumnText(request,3,cb.dataType);
   DatabaseColumnInteger(request,4,cb.displayColumn);
   DatabaseColumnInteger(request,5,cb.displayRow);
   DatabaseColumnInteger(request,6,cb.descriptionWidth);
   DatabaseColumnInteger(request,7,cb.controlWidth);
   DatabaseColumnText(request,8,cb.tableGroup);
   DatabaseColumnText(request,9, cb.values[0]); 
   DatabaseColumnText(request,10, cb.values[1]); 
   DatabaseColumnText(request,11,cb.values[2]); 

   #ifdef _DEBUG_COMBOXBOX
            printf("readValueFromDB --> v1:%s v2:%s v3:%s row:%d col%d ",cb.values[0],cb.values[1],cb.values[2],cb.displayRow, cb.displayColumn);
   #endif

   // Set the XY positions
   cb.x1=(cb.displayColumn*cb.descriptionWidth)+((cb.displayColumn-1)*cb.controlWidth);
   cb.y1=INDENT_TOP+(CONTROL_HEIGHT*cb.displayRow);
   cb.x2=(cb.displayColumn*cb.descriptionWidth)+((cb.displayColumn-1)*cb.controlWidth)+cb.controlWidth;
   cb.y2=INDENT_TOP+(CONTROL_HEIGHT*cb.displayRow)+CONTROL_HEIGHT;

   #ifdef _DEBUG_COMBOXBOX
            printf("setupControl --> %d %d %d %d ",cb.x1,cb.y1,cb.x2,cb.y2);
   #endif

   // Add the new control object
   if (!CComboBox::Create(0,sqlFieldName,0,cb.x1,cb.y1,cb.x2,cb.y2)) {
      printf ("EAComboBox --> ERROR creating combo box:%s",sqlFieldName);
      ExpertRemove();
   } 

   // Add the control values
   int i;
   for (i=0;i<ArraySize(cb.values);i++) {
      if (cb.values[i]==NULL) break;
      ItemAdd(cb.values[i]);
      #ifdef _DEBUG_COMBOXBOX
         printf("setupControl --> idx:%d Item add:%s ",i,cb.values[i]);
      #endif
   }
   ListViewItems(i);
   setupControl(sqlFieldName,cb.dataType);


}







