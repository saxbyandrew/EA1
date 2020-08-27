//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_PANEL1
//#define _DEBUG_LABEL
#define _DEBUG_CBOX

#include <Arrays\ArrayObj.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\CheckBox.mqh>
#include <Controls\ComboBox.mqh>
//#include <ChartObjects\ChartObjectSubChart.mqh>


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// simple object to store the name/ objetc pointer as i cant seem to find
// way to get the actual pointer to the object
class EASObjects : public CObject {

private:
protected:
public:

EASObjects();
~EASObjects();

   string      sqlFieldName;  // SQL DB field name
   string      sqlDataType;   // INT or TEXT or REAL etc
   string      description;   // English name
   string      controlType;   // Combo box Text field etc
   string      displayValue;  // Old DB Values
   int         intValue;      // Old INT Value
   double      doubleValue;   // OLD double Val
   int         width;
   string      cbItem1;
   string      cbItem2;
   string      cbItem3;
   int   x1, y1, x2, y2;      // Position co-ordinates
   // Screen Object Pointers
   CLabel      *lObject;
   CEdit       *eObject;
   CCheckBox   *cObject;
   CComboBox   *cbObject;
   // Others can go here

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EASObjects::EASObjects() {
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EASObjects::~EASObjects() {
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAPanel : public CAppDialog {

//=========
private:
//=========

   int   _cellHeight, _cellWidth, _defaultLabelWidth;
   int   _marginLeft, _rightMargin, _topMargin, _bottomMargin;

   //CChartObjectSubChart subchart;                   // the sub-chart object
   CArrayObj            *screenObjects;
   CComboBox            *activeObject;
   CEdit test;


//=========
protected:
//=========

   bool              chartEventObjectClick();

   void              createScreenObjectLabel(EASObjects &so, int row);
   void              createScreenObjectCEdit(EASObjects &so, int row);
   void              createScreenObjectCComboBox(EASObjects &so, int row);
   void              createControlObject(string sqlFieldName, string dataType,int idx, int ypos);
   bool              readValueFromDB(string sqlFieldName,string dataType, EASObjects &so);
   void              createScreenObject(string sqlFieldName, string dataType, int row);
   void              updateValuesToDB(string sqlFieldName);
   void              updateValuesToDB(EASObjects &so);
   //--- handlers of the dependent controls events
   //void              onClickCEdit(string sparam);
//=========
public:
//=========
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   void              setActiveChartObject(string sparam);

      //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   

EAPanel();
~EAPanel();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPanel::EAPanel() {

   _cellHeight=26;
   _cellWidth=180;
   _defaultLabelWidth=300;
   _marginLeft=20;
   _topMargin=20;

   screenObjects=new CArrayObj;
   if (CheckPointer(screenObjects)==POINTER_INVALID) {
      printf("EAPanel --> Error creating array store for screen objects");
      ExpertRemove();
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPanel::~EAPanel() {

   delete(screenObjects);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void EAPanel::setActiveChartObject(string sparam) {


   for (int i=0;i<screenObjects.Total();i++) {
      EASObjects *so=screenObjects.At(i);

      string s=StringFormat("%sEdit",so.sqlFieldName);
      if (sparam==s) {
         if (so.controlType=="CCOMBOBOX") {
            #ifdef _DEBUG_CBOX
               printf("CCOMBOBOX --> %s found",sparam);
            #endif
            activeObject=so.cbObject;
            

         }
      }
   }
   

}

/*
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(EAPanel)
ON_EVENT(ON_CLICK,ComboBox,OnChangeList)
EVENT_MAP_END(CAppDialog)
*/



//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
bool EAPanel::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {



   if( id==ON_CHANGE) {
      printf("3 ON_CHANGE --> ID:%d, lparam:%.2f, dparam:%.2f sparam:%s",id,lparam,dparam,sparam);
   }
   
   if (id==CHARTEVENT_CLICK) {
      printf("4 CHARTEVENT_CLICK--> ID:%d, lparam:%.2f, dparam:%.2f sparam:%s",id,lparam,dparam,sparam);
      //printf("lparam:%s dparam:%s",EnumToString(lparam),EnumToString(dparam));
      

   }

   if (id==CHARTEVENT_OBJECT_ENDEDIT) {
      Print("5 CHARTEVENT_OBJECT_ENDEDIT '"+sparam+"'");
      updateValuesToDB(sparam);
      
   }
   
   if (id==CHARTEVENT_OBJECT_CLICK) {
      printf("6 CHARTEVENT_OBJECT_CLICK--> ID:%d, lparam:%.2f, dparam:%.2f sparam:%s",id,lparam,dparam,sparam);
   
   }
   
   


   return 1;

}

/*
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(EAPanel)
ON_EVENT(CHARTEVENT_OBJECT_CLICK,activeObject,chartEventObjectClick)

EVENT_MAP_END(CAppDialog)
*/
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
bool EAPanel::chartEventObjectClick() {
   printf("==================================chartEventObjectClick");
   return 1;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2) {

   int request, row=0;
   string sqlFieldName, dataType, sql;

   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)) {
      ExpertRemove();
   }

   sql=StringFormat("PRAGMA table_info(%s)",name);
   #ifdef _DEBUG_PANEL1
      printf("createPanel --> %s",sql);
   #endif

   request=DatabasePrepare(_mainDBHandle,sql); 
   while (DatabaseRead(request)) {
      DatabaseColumnText  (request,1,sqlFieldName);
      DatabaseColumnText  (request,2,dataType);
      createScreenObject (sqlFieldName,dataType,row);
      #ifdef _DEBUG_PANEL1
         printf("createPanel --> Fetching row:%d with sqlFieldName:%s datatype:%s",row,sqlFieldName,dataType);
      #endif
      row++;

   }

   return true;

}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::updateValuesToDB(EASObjects &so) {

   string saveValue;

   if (so.controlType=="CEDIT"&&(so.sqlDataType=="INT"||so.sqlDataType=="INTEGER")) {
      CEdit *eObject=so.eObject;                // Get the actual screen object
      saveValue=IntegerToString(so.eObject.Text());
   }

   if (so.controlType=="CEDIT"&&so.sqlDataType=="REAL") {
      CEdit *eObject=so.eObject;                // Get the actual screen object
      saveValue=DoubleToString(so.eObject.Text(),5);
   }

   if (so.controlType=="CCOMBOBOX"&&so.sqlDataType=="BOOL") {
      CComboBox *cbObject=so.cbObject;

      
   }


   string sql=StringFormat("UPDATE STRATEGY SET %s=%s WHERE strategyNumber=%d",so.sqlFieldName,saveValue,strategyParameters.sb.strategyNumber);
   #ifdef _DEBUG_PANEL1
      printf("updateValuesToDB --> update request is:%s",sql);
   #endif
   if (!DatabaseExecute(_mainDBHandle,sql)) {
      #ifdef _DEBUG_PANEL1
         Print("updateValuesToDB -> DB request failed with code ", GetLastError());
      #endif
      return;
   } else {
      #ifdef _DEBUG_PANEL1
         printf("updateValuesToDB -> updated %s: with value%s SUCCESS",so.sqlFieldName,so.eObject.Text());
      #endif
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::updateValuesToDB(string sqlFieldName) {

   #ifdef _DEBUG_PANEL1
            printf("updateValuesToDB --> ");
   #endif

   for (int i=0;i<screenObjects.Total();i++) {       // Find the sqlFieldName in the CArrayList
      EASObjects *so=screenObjects.At(i);
      if (so.sqlFieldName==sqlFieldName) {
         #ifdef _DEBUG_PANEL1
            printf("updateValuesToDB --> found %s at index:%d",sqlFieldName,i);
         #endif
         updateValuesToDB(so); 
      } 
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EAPanel::readValueFromDB(string sqlFieldName,string dataType, EASObjects &so) {


   string   cbItem1, cbItem2, cbItem3;
   int      retValue, intValue;
   double   doubleValue;
   
   //  EG SELECT magicNumber, description, controlType FROM STRATEGY, METADATA where STRATEGY.strategyNumber=1234 AND METADATA.fieldName='magicNumber'
   string sql=StringFormat("SELECT %s, description, controlType, width, value1, value2, value3 FROM STRATEGY, METADATA WHERE STRATEGY.strategyNumber=%d AND METADATA.fieldName='%s'",sqlFieldName,strategyParameters.sb.strategyNumber,sqlFieldName);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_PANEL1
         Print(" -> DatabasePrepare: request failed with code ", GetLastError());
      #endif
      return false;
   }

   DatabaseRead(request);
   #ifdef _DEBUG_PANEL1
      printf("readValueFromDB --> %s",sql);
   #endif

   if (dataType=="TEXT")  {
      DatabaseColumnText(request,0,so.displayValue);
   }

   if (dataType=="INT"||dataType=="INTEGER")   {
      DatabaseColumnInteger(request,0,intValue);
      so.displayValue=IntegerToString(intValue);
      so.intValue=intValue;
   }

   if (dataType=="REAL")  {
      DatabaseColumnDouble(request,0,doubleValue);
      so.displayValue=DoubleToString(doubleValue,4);
      so.doubleValue=doubleValue;
   }
   
   if (dataType=="BOOL")   {
      DatabaseColumnInteger(request,0,intValue);
      so.displayValue=IntegerToString(intValue);
      so.intValue=intValue;
   }
   

   so.sqlFieldName=sqlFieldName;
   so.sqlDataType=dataType;
   DatabaseColumnText(request,1,so.description);      // Value 2 Field Decriptive Name
   DatabaseColumnText(request,2,so.controlType);      // Value 3 Colum object input data type
   DatabaseColumnInteger(request,3,so.width);
   DatabaseColumnText(request,4,so.cbItem1); 
   DatabaseColumnText(request,5,so.cbItem2); 
   DatabaseColumnText(request,6,so.cbItem3); 
   #ifdef _DEBUG_CBOX
      if (so.cbItem1!=NULL) {
         printf("readValueFromDB -> : CBITEMS %s -> %s %s %s",so.sqlFieldName,so.cbItem1,so.cbItem2,so.cbItem3);
      }
   #endif
   
   if (so.controlType==NULL) return false;
   return true;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createScreenObjectLabel(EASObjects &so, int row) {

   CLabel *lObject=new CLabel;
   if (CheckPointer(lObject)==POINTER_INVALID) {
      printf("createScreenObject --> POINTER ERROR");
      return;
   }  

   so.x1=ClientAreaLeft()+_marginLeft;
   so.y1=ClientAreaTop()+_topMargin+(_cellHeight*row);
   so.x2=ClientAreaLeft()+_marginLeft+_defaultLabelWidth;
   so.y2=(ClientAreaTop()+_topMargin+_cellHeight)+(_cellHeight*row);
   string screenLabelName=StringFormat("L%d%s",row,so.sqlFieldName);
   #ifdef _DEBUG_LABEL
      printf("createScreenObjectLabel --> %s",screenLabelName);
   #endif

   so.lObject=lObject;
   so.lObject.Create(0,screenLabelName,0,so.x1,so.y1,so.x2,so.y2);  // Show the label

   so.lObject.Text(so.description);    
   so.lObject.Color(clrRed);
   so.lObject.FontSize(10);
   Add(so.lObject);

   #ifdef _DEBUG_LABEL
      printf("createScreenObject --> LABEL %s created",lObject.Text());
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createScreenObjectCEdit(EASObjects &so, int row) {

   CEdit *eObject=new CEdit;
   if (CheckPointer(eObject)==POINTER_INVALID) {
      printf("createScreenObject --> POINTER ERROR CEDIT");
      return;
   } else {
      #ifdef _DEBUG_PANEL1
         printf("createScreenObject --> CEDIT created SUCCESS and added to CPANEL");
      #endif
   }

   so.x1=ClientAreaLeft()+_marginLeft+_defaultLabelWidth;                               // Set the XY positions
   so.y1=ClientAreaTop()+_topMargin+(_cellHeight*row);
   so.x2=ClientAreaLeft()+_marginLeft+_defaultLabelWidth+so.width;
   so.y2=(ClientAreaTop()+_topMargin+_cellHeight)+(_cellHeight*row);

   so.eObject=eObject;                                                  // Create the object 
   so.eObject.Create(0,so.sqlFieldName,0,so.x1,so.y1,so.x2,so.y2);
   
   so.eObject.Text(so.displayValue);      // Set some object properties
   so.eObject.FontSize(10);

   Add(so.eObject);           // Add to the underlying panel

   #ifdef _DEBUG_PANEL1
      printf("createScreenObject --> CEDIT value is:%s -- %s",eObject.Text(),so.displayValue);
   #endif

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createScreenObjectCComboBox(EASObjects &so, int row) {

   #ifdef _DEBUG_CBOX
      printf("createScreenObject CCombobox --> ");
   #endif

   CComboBox *cbObject=new CComboBox;
   if (CheckPointer(cbObject)==POINTER_INVALID) {
      printf("createScreenObject --> POINTER ERROR CCOMBOBOX");
      return;
   } else {
      #ifdef _DEBUG_CBOX
         printf("createScreenObject --> CCOMBOBOX created SUCCESS");
      #endif
   }

   so.x1=ClientAreaLeft()+_marginLeft+_defaultLabelWidth;                               // Set the XY positions
   so.y1=ClientAreaTop()+_topMargin+(_cellHeight*row);
   so.x2=ClientAreaLeft()+_marginLeft+_defaultLabelWidth+so.width;
   so.y2=(ClientAreaTop()+_topMargin+_cellHeight)+(_cellHeight*row);

   so.cbObject=cbObject;
   so.cbObject.Create(0,so.sqlFieldName,0,so.x1,so.y1,so.x2,so.y2);

   if (so.cbItem1!=NULL) {
      if (so.cbObject.AddItem(so.cbItem1,0)) {
         #ifdef _DEBUG_CBOX
            printf("createScreenObject CCombobox --> Added %s SUCCESS",so.cbItem1);
         #endif
      } else {
         printf("createScreenObject --> FAILED to add item to the CComboBox control");
      }
   }
   if (so.cbItem2!=NULL) so.cbObject.AddItem(so.cbItem2,1);
   if (so.cbItem3!=NULL) so.cbObject.AddItem(so.cbItem3,2);

   // Set the control to YES/NO
   if (so.sqlDataType=="BOOL") {
      if (so.intValue==0) {
         printf("FOUND NO");
         so.cbObject.Select(0); // YES
      } else {
         printf("FOUND YES");
         so.cbObject.Select(1); //NO
      }
      
   }
   
   so.cbObject.ListViewItems(1);
   Add(so.cbObject);
   


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createScreenObject(string sqlFieldName, string dataType, int row) {


   static int cnt=0;

   // Create a ScreenOject Store intance to save all details relating to this panel type object
   // that is used to store and get information to be updated to the DB
   EASObjects *so=new EASObjects;
   if (CheckPointer(so)==POINTER_INVALID) {
      printf("createControlObject --> Error creating a new Screen Object");
      ExpertRemove();
   } else {
      #ifdef _DEBUG_PANEL1
         printf("createControlObject --> Success");
      #endif
   }

   // 1 Get the currently stored value of this field from the SQL DB 
   if (readValueFromDB(sqlFieldName, dataType, so)) {
      #ifdef _DEBUG_PANEL1
         printf("createScreenObject --> SUCCESS %s",so.description);
      #endif
   } else {
      #ifdef _DEBUG_PANEL1
         printf("createScreenObject -->  ERROR %s not found",sqlFieldName);
      #endif
      delete(so);
      return;
   }

   // 2 Create the label
   createScreenObjectLabel(so,row);
   // 3 Create the data entry/update object
   if (so.controlType=="CEDIT") createScreenObjectCEdit(so,row);
   if (so.controlType=="CCOMBOBOX") createScreenObjectCComboBox(so,row);

   screenObjects.Add(so);     // Add to the storage array
      

   // 4 Create the data entry/update object
   

   

   /*
   if (so.controlType=="CCOMBOBOX") {
      CComboBox *cbObject=new CComboBox;
      if (CheckPointer(eObject)==POINTER_INVALID) {
         printf("POINTER ERROR");
         return;
      }
      cbObject.label=so.sqlFieldName;
      cbObject.Text(so.textValue);
      cbObject.Color(clrGreen);
      cbObject.FontSize(10);
      so.cbObject=cbObject;
   }

   
   
   if (dataType=="REAL" || dataType=="INT") dt=1;

   x1=ClientAreaLeft()+_cellWidth;
   y1=ClientAreaTop()+(_cellHeight*idx);
   x2=ClientAreaLeft()+(_cellWidth*2);
   y2=(ClientAreaTop()+_cellHeight)+(_cellHeight*idx);

   // Labels on the second column
   if (ypos==2) {
      x1=ClientAreaLeft()+(_cellWidth*3);
      y1=ClientAreaTop()+(_cellHeight*idx);
      x2=ClientAreaLeft()+((_cellWidth*3)+_cellWidth);
      y2=(ClientAreaTop()+_cellHeight)+(_cellHeight*idx);

   }

   // 3 Create the RHS data object we need to know the screen object type
   // text,radio button, combo box etc
   // getXYPostion(Column#,row# x/y etc)
   getXYPostion(1,row,so.x1,so.y1,so.x2,so.y2);
   getXYPostion(0,row,so.x1,so.y1,so.x2,so.y2);

   so.sqlFieldName=sqlFieldName;
   so.dataType=dataType;

   switch (dt) {

      case 1: {
         CEdit *eObject=new CEdit;
         if (CheckPointer(eObject)==POINTER_INVALID) {
            printf("POINTER ERROR");
            return;
         }
         eObject.Text(val);
         eObject.Color(clrGreen);
         eObject.FontSize(10);
         eObject.Create(0,label,0,x1,y1,x2,y2);
         so.label=label;
         printf("111 %s",so.label);
         so.eObject=eObject;
         printf("222 %s",so.eObject.Text());
         if (screenObjects.Add(so)) {
            printf("333 ADDED OK");
         };

      }
      break;
      case 3:
         cbObject=new CComboBox;
         cbObject.Create(0,label,0,x1,y1,x2,y2);
         //screenObjects.Add(cbObject);
      break;
      case 4: {
         cObject=new CCheckBox;
         cObject.Text(label);
         cObject.Color(clrGreen);
         cObject.Width(12);
         cObject.Height(12);
         cObject.Create(0,label,0,x1,y1,x2,y2);
         //screenObjects.Add(cObject);
      }
      break;

   }
   */

}

/*
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void EAPanel::onClickCEdit(string sparam) {
   

   
}
*/




