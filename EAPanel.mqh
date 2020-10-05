//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define INDENT_LEFT                         (20)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (100)      // indent from top (with allowance for border width)
#define CONTROL_HEIGHT                      (30)      // size by Y coordinate
#define COLUMN_WIDTH                        (150)


#include <Controls\Dialog.mqh>
#include <Trade\AccountInfo.mqh>

#include "EATabControl.mqh"
#include "EAComboBox.mqh"
#include "EAEdit.mqh"
#include "EALabel.mqh"
#include "EACPanel.mqh"
#include "EACButton.mqh"
#include "EAScreenObject.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAPanel : public CAppDialog  {

//=========
private:
//=========

   string ss;
   CAccountInfo   AccountInfo;

/*
   struct Pinfo {
      CWndObj           *labelObject;  // Text Information
      CWndObj           *valueObject;  // Changing value information
      string            label;
      int               status;
      datetime          event;
      Pinfo() : labelObject(NULL), valueObject(NULL), label(NULL), status(_NOTSET), event(NULL) {};  
   };
   */

   void              createInfoLabels(string tableGroup);
   //Pinfo             tabPage1[35];           // Labels and controls on Tab Page 1
   //Pinfo             info1[35];         // Labels and Values
   //Pinfo             info2[35];

   int               _positionListYOffset;
   int               _totalPositionListSize;
   void              createPositionLabel(EAPosition &p, int idx);
   void              clearPositionLabel();



protected:

   CArrayObj            *screenObjects;
   EATabControl         *tabControl[10];
   EAEdit               *edit[50];
   EAComboBox           *comboBox[50];
   EACPanel             *panels[10];
   EACButton            *buttons[10];

   void                 hideControls(string screenName);
   void                 showControls(string screenName);
   //void                 showHideControls(string screenName);
   void                 createTabControls(string tableGroup);
   void                 createComboControls(string tableGroup);
   void                 createEditControls(string tableGroup);
   void                 createButtonControls();

//=========
public:
//=========

   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              updateInfoLabel(int row, int col, string val);


   void              showPanelDetails();
   void              mainInfoPanel();
   void              positionInfoUpdate();
   void              accountInfoUpdate();
   
EAPanel();
~EAPanel();
};


//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
bool EAPanel::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {

   // Call the base class event handler
   CAppDialog::OnEvent(id,lparam,dparam,sparam);


   #ifdef _DEBUG_PANEL
      //printf("OnEvent --> last object clicked%s id:%d",sparam,id);
   #endif

   if (StringFind(sparam,"tab",0)!=-1) {
      for (int i=0;i<ArraySize(tabControl);i++) {
         if (tabControl[i]!=NULL) {
            if (tabControl[i].OnEvent(id,lparam,dparam,sparam)&&sparam=="tab1") {
               printf("TAB1 %s pressed",sparam);
               hideControls("GROUP1");
               hideControls("GROUP2");
               showControls("STRATEGY");
               showControls("TIMING");
               }
            if (tabControl[i].OnEvent(id,lparam,dparam,sparam)&&sparam=="tab2") {
               printf("TAB2 %s pressed",sparam);
               hideControls("STRATEGY");
               hideControls("TIMING");
               showControls("GROUP1");
               showControls("GROUP2");

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

/*
   for (int i=0;i<ArraySize(comboBox);i++) {
      if (comboBox[i]!=NULL) comboBox[i].OnEvent(id,lparam,dparam,sparam);
      #ifdef _DEBUG_PANEL
         printf("OnEvent --> comboboxes %d sparam:%s",i,sparam);
      #endif
   }

   if (id==CHARTEVENT_OBJECT_ENDEDIT) {
      for (int i=0;i<ArraySize(edit);i++) {
         if (edit[i]!=NULL) edit[i].OnEvent(id,lparam,dparam,sparam);
         #ifdef _DEBUG_PANEL
            printf("OnEvent --> edit %d sparam:%s",i,sparam);
         #endif
      }
   }
*/
   return true;

}
//EVENT_MAP_BEGIN(EAPanel)
//ON_EVENT(ON_CHANGE,combobox1,combobox1.onChange)
//ON_EVENT(ON_CHANGE,combobox2,combobox2.onChange)
//EVENT_MAP_END(EAPanel)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPanel::EAPanel() {

   #ifdef _DEBUG_PANEL
      printf("EAPanel -->  default constructor");
   #endif

   screenObjects=new CArrayObj;
   if (CheckPointer(screenObjects)==POINTER_INVALID) {
         ss="EAPanel -> Error creating CArray";
         pss
      ExpertRemove();
   } else {
      #ifdef EAPanel
         ss="EAPanel -> Success screenObjects CArray";
         pss
      #endif 
   }


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPanel::~EAPanel() {

}

//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAPanel::updateInfoLabel(int row, int col, string val) {

   #ifdef _DEBUG_PANEL
      printf("EAPanel::updateInfo %s for row:%d and col:%d",val,row,col);
   #endif

   for (int i=0;i<screenObjects.Total();i++) {
      EAScreenObject *s=screenObjects.At(i);
      //printf("Found %d %d",s.rowNumber,s.columnNumber);
      if (row==s.rowNumber && col==s.columnNumber) {
         s.infolabelObject.Text(val);
         return;
      }
   }
}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAPanel::createButtonControls() {

   #ifdef _DEBUG_PANEL
      printf("EAPanel createButtonControls -->");
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

/*
//+------------------------------------------------------------------+
//|                                                          |
//+------------------------------------------------------------------+
void EAPanel::showHideControls(string screenName) {

   static bool sFlag=true;

   #ifdef _DEBUG_PANEL
      printf("showHideControls ---> pressed for%s",screenName);
   #endif

   for (int i=0;i<screenObjects.Total();i++) {
      EAScreenObject *s=screenObjects.At(i);
      if (s.screenName==screenName) {
         if (s.isVisible) {
            s.labelObject.Hide();
            s.valueObject.Hide();
            s.valueObject.Disable();
            s.isVisible=false;
         } else {
            s.labelObject.Show();
            s.valueObject.Show();
            s.valueObject.Enable();
            s.isVisible=true;
         }
      }
   }

}
*/
//+------------------------------------------------------------------+
//|                                                          |
//+------------------------------------------------------------------+
void EAPanel::showControls(string screenName) {

return;

   static bool sFlag=true;

   #ifdef _DEBUG_PANEL
      printf("showControls ---> pressed for%s",screenName);
   #endif

   for (int i=0;i<screenObjects.Total();i++) {
      EAScreenObject *s=screenObjects.At(i);
      if (s.screenName==screenName) {
         s.labelObject.Show();
         s.valueObject.Show();
         s.valueObject.Enable();
         s.isVisible=true;
      }
   }
}
//+------------------------------------------------------------------+
//|                                                          |
//+------------------------------------------------------------------+
void EAPanel::hideControls(string screenName) {

   static bool sFlag=true;

   #ifdef _DEBUG_PANEL
      printf("hideControls ---> pressed for%s",screenName);
   #endif

   for (int i=0;i<screenObjects.Total();i++) {
      EAScreenObject *s=screenObjects.At(i);
      if (s.screenName==screenName) {
         s.labelObject.Hide();
         s.valueObject.Hide();
         s.valueObject.Disable();
         s.isVisible=false;
      }
   }
}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAPanel::createEditControls(string tableGroup) {

   #ifdef _DEBUG_PANEL
      printf("EAPanel createEditControls -->");
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
      printf("EAPanel --> %s",sql);
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

      // Save this label/ control pair
      EAScreenObject *s=new EAScreenObject;
      if (CheckPointer(s)==POINTER_INVALID) {
         printf(" -> creatEditControls ERROR creating EAScreenInfo object");
         return;
      } else {
         s.sqlFieldName=sqlFieldName;
         s.screenName=tableGroup;
         s.labelObject=l;
         s.valueObject=edit[i];
         s.isVisible=false;
         screenObjects.Add(s);  
         s.labelObject.Hide();
         s.valueObject.Hide();
         s.valueObject.Disable();
      }
      i++; 

   }

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createInfoLabels(string tableGroup) {

      string labelName;
      int   x1, y1, x2, y2;

      CLabel *lObject, *vObject;

      for (int row=0;row<25;row++) {

 
         for (int col=0;col<4;col++) {
            lObject=new CLabel;  
            //ss=StringFormat("%d:%d",row,col);   
            lObject.Text("");    
            lObject.Color(clrBlack);
            lObject.FontSize(8);

            // XY Placement Name
            labelName=StringFormat("L1%d%d",row,col);
            // Set the XY positions
            x1=(col*COLUMN_WIDTH);
            y1=INDENT_TOP+(CONTROL_HEIGHT*row);
            x2=(col*COLUMN_WIDTH)+COLUMN_WIDTH;
            y2=INDENT_TOP+(CONTROL_HEIGHT*row)+CONTROL_HEIGHT;

            lObject.Create(0,labelName,0,x1,y1,x2,y2);
            Add(lObject); 

            // Save this label/ control pair
            EAScreenObject *s=new EAScreenObject;
            if (CheckPointer(s)==POINTER_INVALID) {
               printf(" -> createComboControls ERROR creating EAScreenInfo object");
               return;
            }                         // Add to CApDialog

            s.rowNumber=row;
            s.columnNumber=col;
            s.sqlFieldName="INFO";
            s.screenName=tableGroup;
            s.infolabelObject=lObject;
            screenObjects.Add(s);

            #ifdef _DEBUG_PANEL
               printf("createInfoLabels ---> %s row:%d col:%d -- %d %d %d %d",s.infolabelObject.Text(),s.rowNumber,s.columnNumber,x1,y1,x2,y2);
            #endif
         }
      }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::showPanelDetails() {


return;

   _positionListYOffset=12;
   _totalPositionListSize=9;


   //mainInfoPanel();

   // change color once
   //(18,1,"");
   //setInfo2LabelColor(18,clrRed);
   //setInfo2ValueColor(18,clrRed);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::mainInfoPanel() {


   #ifdef _DEBUG_PANEL 
      Print(__FUNCTION__); 
      string ss; 
   #endif 

   //printf("1111111");
   updateInfoLabel(0,0, "Strategy Number"); 


   updateInfoLabel(0,1,IntegerToString(usp.strategyNumber));

   updateInfoLabel(5,0, "Trading Time");  
   

   if (ustp.sessionTradingTime=="Any Time") {
      updateInfoLabel(5,1,"Any Time");
   }

   if (ustp.sessionTradingTime=="Fixed Time") {
      updateInfoLabel(5,1,"Fixed Time");

      updateInfoLabel(6,0,"Trading Start");  
      updateInfoLabel(6,1,ustp.tradingStart);
      updateInfoLabel(7,0,"Trading End");  
      updateInfoLabel(7,1,ustp.tradingEnd);
   }

   if (ustp.sessionTradingTime=="Session Time") {
      updateInfoLabel(5,1,"Session Time");
      updateInfoLabel(6,0,"Trading Start");  
      updateInfoLabel(6,1,ustp.tradingStart);
      updateInfoLabel(7,0,"Trading End");  
      updateInfoLabel(7,1,ustp.tradingEnd);

      if (ustp.marketOpenDelay!=0) {
         updateInfoLabel(8,0,"Market Open Delay");  
         updateInfoLabel(8,1,IntegerToString(ustp.marketOpenDelay));
      } else {
         updateInfoLabel(8,0,"Market Open Delay");  
         updateInfoLabel(8,1,"No Delay");
      }

      if (ustp.marketCloseDelay!=0) {
         updateInfoLabel(9,0, "Market Close Delay");  
         updateInfoLabel(9,1,IntegerToString(ustp.marketCloseDelay));
      } else {
         updateInfoLabel(9,0, "Market Close Delay");  
         updateInfoLabel(9,1, "No Delay");
      }
   }


   updateInfoLabel(10,0,"Weekend Trading");
   if (ustp.allowWeekendTrading) {
         updateInfoLabel(10,1,"Yes");
   } else {
         updateInfoLabel(10,1,"No");
   }

   updateInfoLabel(11,0,"EOD Close");  
   if (bool (usp.closingTypes&_CLOSE_AT_EOD)) {
         updateInfoLabel(11,1,"Yes");
   } else {
         updateInfoLabel(11,1,"No");
   }

   updateInfoLabel(12,0, "Overnight holding");  
   if (usp.maxDailyHold>0) {
         updateInfoLabel(12,1,"Yes");
   } else {
         updateInfoLabel(12,1,"No");
   }


   // MOVED TO  EAMain::checkMaxDailyOpenQty
   //updateInfoLabel(9, "Max Positions/Day");  
   //if (usp.maxTotalDailyPositions==-1) {
      //updateInfoLabel(9,"No Maximum");
   //} else {
      //updateInfoLabel(9,StringToInteger(usp.maxTotalDailyPositions));
   //}

   updateInfoLabel(13,0, "Max day to hold"); 
   if (usp.maxDailyHold>0) {
      updateInfoLabel(13,1,IntegerToString(usp.maxDailyHold));
   } else {
      updateInfoLabel(13,1,"Infinite");
   }
   

   // Info 2

   updateInfoLabel(3,2, "Close in Profit");  
   if (bool (usp.closingTypes&_IN_PROFIT_CLOSE_POSITION)) {
         updateInfoLabel(3,3,"Yes");
         updateInfoLabel(4,2, "Profit Long");  
         updateInfoLabel(4,3,StringFormat("$%5.2f",usp.fptl));
         updateInfoLabel(5,2, "Profit Short");  
         updateInfoLabel(5,3,StringFormat("$%5.2f",usp.fpts));

   } else {
         updateInfoLabel(3,2,"No");
   }

   updateInfoLabel(6,2, "Close in Loss");  
   if (bool (usp.closingTypes&_IN_LOSS_CLOSE_POSITION)) {
         updateInfoLabel(6,3,"Yes");
         updateInfoLabel(7,2, "Loss Long");  
         updateInfoLabel(7,3,StringFormat("$%5.2f",usp.fltl));
         updateInfoLabel(8,2, "Loss Short");  
         updateInfoLabel(8,3,StringFormat("$%5.2f",usp.flts));
   } else {
         updateInfoLabel(6,3,"No");
         updateInfoLabel(7,2,"-");  
         updateInfoLabel(7,3,"-");
         updateInfoLabel(8,2,"-");  
         updateInfoLabel(8,3,"-");
   }


   updateInfoLabel(9,2, "Long Hedge");  
   if (usp.inLossOpenLongHedge) {
         updateInfoLabel(9,3,"Yes");
         updateInfoLabel(10,2,"Hedge Loss Amt");  
         updateInfoLabel(10,3,StringFormat("$%5.2f",usp.longHLossamt));
         //updateInfoLabel(20,2,"Hedge Number"); 
         //pdateInfo2Value(8,StringFormat("%d",usp.dnnHedgeNumber));
   } else {
         updateInfoLabel(9,2,"No");
         updateInfoLabel(10,2,"-");  
         updateInfoLabel(10,3,"-");

   }

   updateInfoLabel(11,2,"Open Martingale");  
   if (usp.inLossOpenMartingale) {
         updateInfoLabel(11,3,"Yes");
         updateInfoLabel(12,2,"Martingale Positions");  
         updateInfoLabel(12,3,IntegerToString(usp.maxMg));
         updateInfoLabel(13,2,"Martingale multiplier");  
         updateInfoLabel(13,3,IntegerToString(usp.mgMultiplier));

   } else {
         updateInfoLabel(11,3,"No");
         updateInfoLabel(12,2,"-");  
         updateInfoLabel(12,3,"-");
         updateInfoLabel(24,2,"-");  
         updateInfoLabel(13,3,"-");
         updateInfoLabel(13,2, "-");  
   }




   updateInfoLabel(0,2, "Lot Size"); 
   updateInfoLabel(0,3,DoubleToString(usp.lotSize));

   if (usp.maxLong>0) {
      updateInfoLabel(1,2,"Max allowed Long"); 
      updateInfoLabel(1,3,IntegerToString(usp.maxLong));
   } else {
      updateInfoLabel(1,2,"No Long position allowed"); 
      updateInfoLabel(1,3,"-");
   }
   
   if (usp.maxShort>0) {
   updateInfoLabel(2,2,"Max allowed Short"); 
   updateInfoLabel(2,3,IntegerToString(usp.maxShort));
   } else {
   updateInfoLabel(2,2,"No Short positions allowed"); 
   updateInfoLabel(2,3,"-");
   }


return;
   updateInfoLabel(19,2,"---- Triggers ----"); 
   updateInfoLabel(19,3,"------------------");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::accountInfoUpdate() {


      string posInfo=StringFormat("Long:%d Short:%d Martingale:%d Hedge:%d",longPositions.Total(),shortPositions.Total(),martingalePositions.Total(),longHedgePositions.Total());
      updateInfoLabel(14,0,posInfo);  
      updateInfoLabel(14,1,"");

      updateInfoLabel(15,0,StringFormat("Total Swap Costs: $%3.2f",usp.swapCosts));
      updateInfoLabel(15,1,"");


      string accInfo=StringFormat("Bal:$%3.2f Profit:$%3.2f Margin:$%3.2f",AccountInfo.Balance(),AccountInfo.Profit(),AccountInfo.Margin());
      updateInfoLabel(16,0,accInfo);  
      updateInfoLabel(16,1,"");

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::clearPositionLabel() {

   for (int i=_positionListYOffset;i<_positionListYOffset+_totalPositionListSize;i++) {
      updateInfoLabel(i,1,"*");
      updateInfoLabel(i,3,"*");
   } 
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createPositionLabel(EAPosition &p, int idx) {

   string s, s1;

   switch (p.status) {
      case _LONG:       s1="L";
      break;
      case _SHORT:      s1="S";
      break;
      case _MARTINGALE: s1="M";
      break;
      case _HEDGE:      s1="H";
      break;
   }

   s=StringFormat("%s %d    $%3.2f    %2d $%3.2f",s1,p.ticket,p.currentPnL ,p.daysOpen, p.swapCosts);
   if (idx>_totalPositionListSize) {
      updateInfoLabel(idx,1,s);
   } else {
      updateInfoLabel(idx,1,s);
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::positionInfoUpdate() {

   int idx=_positionListYOffset;   //LHS Panel Y starting pos
      //----
   #ifdef _DEBUG_PANEL 
      //Print (__FUNCTION__); 
      //string ss;
   #endif  
  //----

   clearPositionLabel();


   for (int i=0;i<longPositions.Total();i++) {
      glp;
      createPositionLabel(p,idx);
      idx++;
   }

   for (int i=0;i<shortPositions.Total();i++) {
      gsp;
      createPositionLabel(p,idx);
      idx++;
   }

   for (int i=0;i<martingalePositions.Total();i++) {
      gmp;
      createPositionLabel(p,idx);
      idx++;
   }

   for (int i=0;i<longHedgePositions.Total();i++) {
      glhp;
      createPositionLabel(p,idx);
      idx++;
   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAPanel::createComboControls(string tableGroup) {

   #ifdef _DEBUG_PANEL
      printf("EAPanel createComboControls -->");
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
      printf("EAPanel --> %s",sql);
   #endif

   while (DatabaseRead(request)) {
      DatabaseColumnText(request,0,sqlFieldName);  
      //printf("CreateComboBoxes --> %s",sqlFieldName);


      EALabel *l=new EALabel(sqlFieldName);
      if (CheckPointer(l)==POINTER_INVALID) {
         printf("ERROR creating combox");
      } else {
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

      // Save this label/ control pair
      EAScreenObject *s=new EAScreenObject;
      if (CheckPointer(s)==POINTER_INVALID) {
         printf(" -> createComboControls ERROR creating EAScreenInfo object");
         return;
      } else {
         s.sqlFieldName=sqlFieldName;
         s.screenName=tableGroup;
         s.labelObject=l;
         s.valueObject=comboBox[i];
         s.isVisible=false;
         screenObjects.Add(s);  
         s.labelObject.Hide();
         s.valueObject.Hide();
         s.valueObject.Disable();
      }
      i++;

   }

}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
void EAPanel::createTabControls(string tableGroup) {

   #ifdef _DEBUG_PANEL
      printf("EAPanel createTabControls -->");
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
      printf("EAPanel --> %s",sql);
   #endif

   while (DatabaseRead(request)) {
      DatabaseColumnText(request,0,sqlFieldName);  
 
      tabControl[i]=new EATabControl(sqlFieldName);
      if (CheckPointer(tabControl[i])==POINTER_INVALID) {
         printf("ERROR creating createTabControls");
      } else {

         Add(tabControl[i]);
      }

      i++;
   }
}
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool EAPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2) {

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
   
   #ifdef _DEBUG_PANEL
      printf("EAPanel Create -->");
   #endif

   ENABLE_EVENTS=false;

   //createButtonControls();
   
   //createTabControls("TAB");
   //createComboControls("STRATEGY");
   //createEditControls("STRATEGY");
   
   //createComboControls("TIMING");
   //createEditControls("TIMING");
   createInfoLabels("INFO");
   mainInfoPanel();

   //showControls("GROUP1");
   //showControls("GROUP2");


   #ifdef _DEBUG_PANEL
      EAScreenObject *s;
      for (int i=0;i<screenObjects.Total();i++) {
   
         s=screenObjects.At(i);
         printf("->%s",s.sqlFieldName);
      }
   #endif
   //createComboControls("ADX");
   
   //createComboControls("RSI");
   //createComboControls("ICH");
   
   //createComboControls("STOC");
   //createComboControls("RVI");
   //createComboControls("MFI");

   
   //createComboControls("OSMA");
   //createComboControls("SAR");
   
   //createComboControls("MACD");
   //createComboControls("MACDBULL");
   //createComboControls("MACDBEAR");
   
   ENABLE_EVENTS=true;

   return(true);
}
