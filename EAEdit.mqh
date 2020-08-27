//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"



#include <Controls\Edit.mqh>




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAEdit : public CEdit {

//=========
private:
//=========

   struct EditControl {
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
      string   displayValue;
   } ec;


   void  updateValuesToDB(string sqlFieldName);
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

EAEdit(string sqlFieldName);  
~EAEdit();
};


///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEdit::EAEdit(string sqlFieldName) {

   #ifdef _DEBUG_EDIT
      printf("EAEdit --> Default Constructor");
   #endif

   // Read values for this object from the SQLDB
   setupControl(sqlFieldName);

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEdit::~EAEdit() {

}


//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
//EVENT_MAP_BEGIN(EAEdit)

//EVENT_MAP_END(CComboBox)


bool EAEdit::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CEdit::OnEvent(id,lparam,dparam,sparam);

   // Custom event handling from here
   #ifdef _DEBUG_EDIT
      printf("EAEdit -> OnEvent --> ID:%d ObjectName:%s",id,Name());
   #endif

   if (id==CHARTEVENT_OBJECT_ENDEDIT) {
      #ifdef _DEBUG_EDIT
         printf("CHARTEVENT_OBJECT_ENDEDIT '"+sparam+"'");
      #endif
      if (sparam==ec.sqlFieldName)
         updateValuesToDB(sparam);
   }


   

   return true;

}

//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void EAEdit::onChange(void) {

   // Custom event handling from here
   //#ifdef _DEBUG_EDIT
      //printf("OnEvent --> ObjectName:%s",Name());
   //#endif
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAEdit::updateValuesToDB(string sqlFieldName) {

   string sql;
   
   if (ec.dataType=="TEXT") {
      sql=StringFormat("UPDATE %s SET %s='%s' WHERE strategyNumber=%d",ec.tableGroup,ec.sqlFieldName,Text(),1234);
   }
   if (ec.dataType=="INT" || ec.dataType=="INTEGER") {
      sql=StringFormat("UPDATE %s SET %s=%d WHERE strategyNumber=%d",ec.tableGroup,ec.sqlFieldName,StringToInteger(Text()),1234);
   }
   if (ec.dataType=="REAL") {
      sql=StringFormat("UPDATE %s SET %s=%.5f WHERE strategyNumber=%d",ec.tableGroup,ec.sqlFieldName,StringToDouble(Text()),1234);
   }
   
   #ifdef _DEBUG_EDIT
      printf("EAEdit updateValuesToDB --> update request is:%s",sql);
   #endif
   if (!DatabaseExecute(_mainDBHandle,sql)) {
      Print("EAEdit updateValuesToDB -> DB request failed with code ", GetLastError());
      return;
   } else {
      #ifdef _DEBUG_EDIT
         printf("EAEdit updateValuesToDB -> updated %s SUCCESS",ec.sqlFieldName);
      #endif
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAEdit::setupControl(string sqlFieldName,string dataType) {


   int      intValue;
   double   doubleValue;
   
   string sql=StringFormat("SELECT %s FROM %s WHERE strategyNumber=1234",sqlFieldName,ec.tableGroup);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_EDIT
         Print(" -> DatabasePrepare: request failed with code ", GetLastError());
      #endif
      ExpertRemove();
   }

   DatabaseRead(request);

   if (dataType=="TEXT")  {
      DatabaseColumnText(request,0,ec.displayValue);
   }
   if (dataType=="INT"||dataType=="INTEGER")   {
      DatabaseColumnInteger(request,0,intValue);
      ec.displayValue=IntegerToString(intValue);
   }
   if (dataType=="REAL")  {
      DatabaseColumnDouble(request,0,doubleValue);
      ec.displayValue=DoubleToString(doubleValue,4);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAEdit::setupControl(string sqlFieldName) {

   string sql=StringFormat("SELECT * FROM METADATA WHERE sqlFieldName='%s'",sqlFieldName);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> DatabasePrepare: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   DatabaseRead(request);
   DatabaseColumnText(request,0,ec.sqlFieldName);      
   DatabaseColumnText(request,1,ec.description);      
   DatabaseColumnText(request,2,ec.controlType);
   DatabaseColumnText(request,3,ec.dataType);
   DatabaseColumnInteger(request,4,ec.displayColumn);
   DatabaseColumnInteger(request,5,ec.displayRow);
   DatabaseColumnInteger(request,6,ec.descriptionWidth);
   DatabaseColumnInteger(request,7,ec.controlWidth);
   DatabaseColumnText(request,8,ec.tableGroup);
   DatabaseColumnText(request,9, ec.values[0]); 
   DatabaseColumnText(request,10, ec.values[1]); 
   DatabaseColumnText(request,11,ec.values[2]); 

   #ifdef _DEBUG_EDIT
            printf("readValueFromDB --> row:%d col%d ",ec.displayRow, ec.displayColumn);
   #endif

   // Now get the actual current data value stored for this field
   setupControl(sqlFieldName,ec.dataType);

   // Set the XY positions
   ec.x1=(ec.displayColumn*ec.descriptionWidth)+((ec.displayColumn-1)*ec.controlWidth);
   ec.y1=INDENT_TOP+(CONTROL_HEIGHT*ec.displayRow);
   ec.x2=(ec.displayColumn*ec.descriptionWidth)+((ec.displayColumn-1)*ec.controlWidth)+ec.controlWidth;
   ec.y2=INDENT_TOP+(CONTROL_HEIGHT*ec.displayRow)+CONTROL_HEIGHT;

   #ifdef _DEBUG_EDIT
            printf("setupControl --> %s %d %d %d %d ",ec.sqlFieldName, ec.x1,ec.y1,ec.x2,ec.y2);
   #endif

   // Add the new control object
   if (!CEdit::Create(0,sqlFieldName,0,ec.x1,ec.y1,ec.x2,ec.y2)) {
      printf ("EAEdit --> ERROR creating edit box:%s",sqlFieldName);
      ExpertRemove();
   } 

   Text(ec.displayValue);
   Color(clrBlack);
   FontSize(10);
}