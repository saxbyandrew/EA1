//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_LABEL

#include <Controls\Button.mqh>

#define INDENT_LEFT                         (20)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (10)      // indent from top (with allowance for border width)
#define CONTROL_HEIGHT                      (30)      // size by Y coordinate


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EACButton : public CButton {

//=========
private:
//=========

   
   

//=========
protected:
//=========

void  setupControl(string sqlFieldName);

//=========
public:
//=========


//virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);


EACButton(string sqlFieldName);  
~EACButton();
};


///+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EACButton::EACButton(string sqlFieldName) {

   #ifdef _DEBUG_LABEL
      printf("EACButton --> Default Constructor");
   #endif

   // Read values for this object from the SQLDB
   setupControl(sqlFieldName);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EACButton::~EACButton() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EACButton::setupControl(string sqlFieldName) {

   string description;
   int displayColumn,displayRow,descriptionWidth, controlWidth;
   int x1,x2,y1,y2;

   string sql=StringFormat("SELECT description, displayColumn, displayRow, descriptionWidth, controlWidth FROM METADATA WHERE sqlFieldName='%s'",sqlFieldName);
   int request=DatabasePrepare(_mainDBHandle,sql); 
   if (request==INVALID_HANDLE) {
      printf(" -> DatabasePrepare: request failed with code %d", GetLastError());
      printf("%s",sql);
      ExpertRemove();
   }

   DatabaseRead(request);     
   DatabaseColumnText(request,0,description);  
   DatabaseColumnInteger(request,1,displayColumn);
   DatabaseColumnInteger(request,2,displayRow);
   DatabaseColumnInteger(request,3,descriptionWidth);    
   DatabaseColumnInteger(request,4,controlWidth);    
   
   #ifdef _DEBUG_LABEL
            printf("setupControl --> label:%s",description);
   #endif

   displayColumn=displayColumn-1;            // Always 1 less than the data area 
   x1=INDENT_LEFT+(displayColumn*descriptionWidth)+(displayColumn*controlWidth);
   y1=INDENT_TOP+(CONTROL_HEIGHT*displayRow);
   x2=INDENT_LEFT+(displayColumn*descriptionWidth)+descriptionWidth+(displayColumn*controlWidth)+(INDENT_LEFT*displayColumn);
   y2=INDENT_TOP+(CONTROL_HEIGHT*displayRow)+CONTROL_HEIGHT;

   #ifdef _DEBUG_LABEL
            printf("setupControl --> %d %d %d %d ",x1,y1,x2,y2);
   #endif

   // Add the new control object
   if (!CButton::Create(0,"_B"+sqlFieldName,0,x1,y1,x2,y2)) {
      printf ("EACButton --> ERROR creating button:%s",sqlFieldName);
      ExpertRemove();
   } 

   Text(description);
   Color(clrGreen);
   FontSize(10);

   

}
