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

   void              createInfo1Controls(string tableGroup);
   void              createInfo2Controls(string tableGroup);
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

   void              updateInfo(int row, int col, string val);
   void              updateInfo1Label(int row, string val) {updateInfo(row,1,val);};
   void              updateInfo2Label(int row, string val) {updateInfo(row,2,val);};
   void              updateInfo1Value(int row, string val) {updateInfo(row,3,val);};
   void              updateInfo2Value(int row, string val) {updateInfo(row,4,val);};

   //void              updateInfo1Label(int index, string val) {info1[index].labelObject.Text(val);};  
   //void              updateInfo1Value(int index, string val) {info1[index].valueObject.Text(val);};  
   //void              updateInfo2Label(int index, string val) {info2[index].labelObject.Text(val);};  
   //void              updateInfo2Value(int index, string val) {info2[index].valueObject.Text(val);};
   
   //void              setInfo1LabelColor(int index, color clr) {info1[index].labelObject.Color(clr);};
   //void              setInfo1ValueColor(int index, color clr) {info1[index].valueObject.Color(clr);};
   //void              setInfo2LabelColor(int index, color clr) {info2[index].labelObject.Color(clr);};
   //void              setInfo2ValueColor(int index, color clr) {info2[index].valueObject.Color(clr);};

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
void EAPanel::updateInfo(int row, int col, string val) {

   // Co1 1 and 3 = label object
   // Col 2 and 4 = value object
   string filter;

   if (col==1||col==3) filter="GROUP1";
   if (col==2||col==4) filter="GROUP2";

   for (int i=0;i<screenObjects.Total();i++) {
      EAScreenObject *s=screenObjects.At(i);
      if (s.rowNumber=row && s.screenName==filter) {
         // did this to cast the object type
         CLabel *l=s.labelObject;
         l.Text(val); 
         s.labelObject=l;
         return;
      }
      if (s.rowNumber=row && s.screenName==filter) {
                  // did this to cast the object type
         CLabel *l=s.valueObject;
         l.Text(val); 
         s.valueObject=l;
         return;
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
void EAPanel::createInfo1Controls(string tableGroup) {

      string labelName;
      int   cellHeight=18;
      int   cellWidth=200;
      int   x1, y1, x2, y2;

      CLabel *lObject, *vObject;
      string labels[35]={"-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"};
      string values[35]={"-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"};

      for (int i=0;i<ArraySize(labels);i++) {

         lObject=new CLabel;     
         lObject.Text(labels[i]);    
         lObject.Color(clrBlack);
         lObject.FontSize(8);

         vObject=new CLabel;
         vObject.Text(values[i]);
         vObject.Color(clrGreen);
         vObject.FontSize(8);

         // XY Placement Name
         labelName=StringFormat("L1%d",i);
         x1=ClientAreaLeft();
         y1=INDENT_TOP+(cellHeight*i);
         x2=ClientAreaLeft()+cellWidth;
         y2=INDENT_TOP+cellHeight+(cellHeight*i);

         lObject.Create(0,labelName,0,x1,y1,x2,y2);

         // XY Placement Values
         labelName=StringFormat("_V1%d",i);
         x1=ClientAreaLeft()+cellWidth;
         y1=INDENT_TOP+(cellHeight*i);
         x2=ClientAreaLeft()+(cellWidth*2);
         y2=INDENT_TOP+cellHeight+(cellHeight*i);

         vObject.Create(0,labelName,0,x1,y1,x2,y2);

         // Save this label/ control pair
         EAScreenObject *s=new EAScreenObject;
         if (CheckPointer(s)==POINTER_INVALID) {
            printf(" -> createComboControls ERROR creating EAScreenInfo object");
            return;
         } else {
            s.rowNumber=i;
            s.sqlFieldName="GROUP1";
            s.screenName=tableGroup;
            s.labelObject=lObject;
            s.valueObject=vObject;
            s.isVisible=false;
            screenObjects.Add(s);  
            s.labelObject.Hide();
            s.valueObject.Hide();
         }
      }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createInfo2Controls(string tableGroup) {

      string labelName;
      int   cellHeight=18;
      int   cellWidth=160;
      int   x1, y1, x2, y2;

      CLabel *lObject, *vObject;
      string labels[35]={"-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"};
      string values[35]={"-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-","-"};

      for (int i=0;i<ArraySize(labels);i++) {

         lObject=new CLabel;     
         lObject.Text(labels[i]);    
         lObject.Color(clrBlack);
         lObject.FontSize(8);

         vObject=new CLabel;
         vObject.Text(values[i]);
         vObject.Color(clrGreen);
         vObject.FontSize(8);

         // XY Placement Name
         labelName=StringFormat("_L2%d",i);
         x1=ClientAreaLeft()+(cellWidth*2);
         y1=INDENT_TOP+(cellHeight*i);
         x2=ClientAreaLeft()+(cellWidth*3);
         y2=INDENT_TOP+cellHeight+(cellHeight*i);

         lObject.Create(0,labelName,0,x1,y1,x2,y2);

         // XY Placement Values
         labelName=StringFormat("_V2%d",i);
         x1=ClientAreaLeft()+(cellWidth*3);
         y1=INDENT_TOP+(cellHeight*i);
         x2=ClientAreaLeft()+(cellWidth*4);
         y2=INDENT_TOP+cellHeight+(cellHeight*i);

         vObject.Create(0,labelName,0,x1,y1,x2,y2);

         // Save this label/ control pair
         EAScreenObject *s=new EAScreenObject;
         if (CheckPointer(s)==POINTER_INVALID) {
            printf(" -> createComboControls ERROR creating EAScreenInfo object");
            return;
         } else {
            s.rowNumber=i;
            s.sqlFieldName="GROUP2";
            s.screenName=tableGroup;
            s.labelObject=lObject;
            s.valueObject=vObject;
            s.isVisible=false;
            screenObjects.Add(s);  
            s.labelObject.Hide();
            s.valueObject.Hide();
         }
      }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::showPanelDetails() {

   _positionListYOffset=12;
   _totalPositionListSize=9;


   mainInfoPanel();

   // change color once
   updateInfo2Value(18,"");
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

   updateInfo1Label(0, "Strategy Number");  
   updateInfo1Value(0,IntegerToString(usp.strategyNumber));

   updateInfo1Label(1, "Trading Time");  
   

   if (ustp.sessionTradingTime=="Any Time") {
      updateInfo1Value(1,"Any Time");
   }

   if (ustp.sessionTradingTime=="Fixed Time") {
      updateInfo1Value(1,"Fixed Time");

      updateInfo1Label(2, "Trading Start");  
      updateInfo1Value(2,ustp.tradingStart);
      updateInfo1Label(3, "Trading End");  
      updateInfo1Value(3,ustp.tradingEnd);
   }

   if (ustp.sessionTradingTime=="Session Time") {
      updateInfo1Value(1,"Session Time");
      updateInfo1Label(2, "Trading Start");  
      updateInfo1Value(2,ustp.tradingStart);
      updateInfo1Label(3, "Trading End");  
      updateInfo1Value(3,ustp.tradingEnd);

      if (ustp.marketOpenDelay!=0) {
         updateInfo1Label(4, "Market Open Delay");  
         updateInfo1Value(4,IntegerToString(ustp.marketOpenDelay));
      } else {
         updateInfo1Label(4, "Market Open Delay");  
         updateInfo1Value(4, "No Delay");
      }

      if (ustp.marketCloseDelay!=0) {
         updateInfo1Label(5, "Market Close Delay");  
         updateInfo1Value(5,IntegerToString(ustp.marketCloseDelay));
      } else {
         updateInfo1Label(5, "Market Close Delay");  
         updateInfo1Value(5, "No Delay");
      }
   }


   updateInfo1Label(6, "Weekend Trading");
   if (ustp.allowWeekendTrading) {
         updateInfo1Value(6,"Yes");
   } else {
         updateInfo1Value(6,"No");
   }

   updateInfo1Label(7, "EOD Close");  
   if (bool (usp.closingTypes&_CLOSE_AT_EOD)) {
         updateInfo1Value(7,"Yes");
   } else {
         updateInfo1Value(7,"No");
   }

   updateInfo1Label(8, "Overnight holding");  
   if (usp.maxDailyHold>0) {
         updateInfo1Value(8,"Yes");
   } else {
         updateInfo1Value(8,"No");
   }


   // MOVED TO  EAMain::checkMaxDailyOpenQty
   //updateInfo1Label(9, "Max Positions/Day");  
   //if (usp.maxTotalDailyPositions==-1) {
      //updateInfo1Value(9,"No Maximum");
   //} else {
      //updateInfo1Value(9,StringToInteger(usp.maxTotalDailyPositions));
   //}

   updateInfo1Label(10, "Max day to hold"); 
   if (usp.maxDailyHold>0) {
      updateInfo1Value(10,IntegerToString(usp.maxDailyHold));
   } else {
      updateInfo1Value(10,"Infinite");
   }
   

   // Info 2

   updateInfo2Label(0, "Close in Profit");  
   if (bool (usp.closingTypes&_IN_PROFIT_CLOSE_POSITION)) {
         updateInfo2Value(0,"Yes");
         updateInfo2Label(2, "Profit Long");  
         updateInfo2Value(2,StringFormat("$%5.2f",usp.fptl));
         updateInfo2Label(4, "Profit Short");  
         updateInfo2Value(4,StringFormat("$%5.2f",usp.fpts));

   } else {
         updateInfo2Value(0,"No");
   }

   updateInfo2Label(1, "Close in Loss");  
   if (bool (usp.closingTypes&_IN_LOSS_CLOSE_POSITION)) {
         updateInfo2Value(1,"Yes");
         updateInfo2Label(3, "Loss Long");  
         updateInfo2Value(3,StringFormat("$%5.2f",usp.fltl));
         updateInfo2Label(5, "Loss Short");  
         updateInfo2Value(5,StringFormat("$%5.2f",usp.flts));
   } else {
         updateInfo2Value(1,"No");
   }



   updateInfo2Label(6, "Long Hedge");  
   if (usp.inLossOpenLongHedge) {
         updateInfo2Value(6,"Yes");
         updateInfo2Label(7, "Hedge Loss Amt");  
         updateInfo2Value(7,StringFormat("$%5.2f",usp.longHLossamt));
         updateInfo2Label(8, "Hedge Number"); 
         //pdateInfo2Value(8,StringFormat("%d",usp.dnnHedgeNumber));
   } else {
         updateInfo2Value(6,"No");
         updateInfo2Label(7, "-");  
         updateInfo2Value(7,"-");
         updateInfo2Label(8,"-");
         updateInfo2Value(8, "-"); 
   }

   updateInfo2Label(9, "Open Martingale");  
   if (usp.inLossOpenMartingale) {
         updateInfo2Value(9,"Yes");
         updateInfo2Label(10, "Martingale Positions");  
         updateInfo2Value(10,IntegerToString(usp.maxMg));
         updateInfo2Label(11, "Martingale multiplier");  
         updateInfo2Value(11,IntegerToString(usp.mgMultiplier));
         updateInfo2Label(12, "Martingale Number"); 
         //updateInfo2Value(12,StringFormat("%d",usp.dnnMartingaleNumber));

   } else {
         updateInfo2Value(9,"No");
         updateInfo2Label(10, "-");  
         updateInfo2Value(10,"-");
         updateInfo2Label(11, "-");  
         updateInfo2Value(11,"-");
         updateInfo2Label(12, "-");  
         updateInfo2Value(12,"-");
   }



   updateInfo2Label(15, "Lot Size"); 
   updateInfo2Value(15,DoubleToString(usp.lotSize));

   if (usp.maxLong>0) {
      updateInfo2Label(16, "Max allowed Long"); 
      updateInfo2Value(16,IntegerToString(usp.maxLong));
   } else {
      updateInfo2Label(16, "No Long position allowed"); 
      updateInfo2Value(16,"-");
   }
   
   if (usp.maxShort>0) {
   updateInfo2Label(17, "Max allowed Short"); 
   updateInfo2Value(17,IntegerToString(usp.maxShort));
   } else {
   updateInfo2Label(17, "No Short positions allowed"); 
   updateInfo2Value(17,"-");
   }



   updateInfo2Label(19, "---- Triggers ----"); 
   updateInfo2Value(19, "------------------");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::accountInfoUpdate() {

      string posInfo=StringFormat("Long:%d Short:%d Martingale:%d Hedge:%d",longPositions.Total(),shortPositions.Total(),martingalePositions.Total(),longHedgePositions.Total());
      updateInfo1Label(22,posInfo);  
      updateInfo1Value(22,"");

      updateInfo1Label(23,StringFormat("Total Swap Costs: $%3.2f",usp.swapCosts));
      updateInfo1Value(23,"");


      string accInfo=StringFormat("Bal:$%3.2f Profit:$%3.2f Margin:$%3.2f",AccountInfo.Balance(),AccountInfo.Profit(),AccountInfo.Margin());
      updateInfo2Label(18,accInfo);  
      updateInfo2Value(18,"");

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::clearPositionLabel() {

   for (int i=_positionListYOffset;i<_positionListYOffset+_totalPositionListSize;i++) {
      updateInfo1Label(i,"*");
      updateInfo1Value(i,"*");
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
      updateInfo1Label(idx,s);
   } else {
      updateInfo1Value(idx,s);
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
   
   createTabControls("TAB");
   createComboControls("STRATEGY");
   createEditControls("STRATEGY");
   createComboControls("TIMING");
   createEditControls("TIMING");
   createInfo1Controls("GROUP1");
   createInfo2Controls("GROUP2");

   EAScreenObject *s;
   for (int i=0;i<screenObjects.Total();i++) {
   
      s=screenObjects.At(i);
      printf("->%s",s.sqlFieldName);
   }
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
