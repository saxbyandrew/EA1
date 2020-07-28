//+------------------------------------------------------------------+
//|                                                     MQPanels.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_PANEL

#include <Controls\Dialog.mqh>
#include <Controls\Panel.mqh>
#include <Controls\Label.mqh>
#include <Controls\Button.mqh>
#include <Trade\AccountInfo.mqh>





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EAPanel : public CAppDialog {

//=========
private:
//=========
   CAccountInfo   AccountInfo;

   int   _x1, _y1, _x2, _y2;     // absolute window sise
   int   gridX, gridY;           // Absolute starting xy in LHS
   int   gridXSize, gridYSize;   // Size of the XY cell  
   int   _positionListYOffset;
   int   _totalPositionListSize;

   void  createPositionLabel(EAPosition &p, int idx);
   void  clearPositionLabel();


   struct Pinfo {
      CWndObj           *labelObject;  // Text Information
      CWndObj           *valueObject;  // Changing value information
      string            label;
      int               status;
      datetime          event;








      Pinfo() : labelObject(NULL), valueObject(NULL), label(NULL), status(_NOTSET), event(NULL) {};  
   };

//=========
protected:
//=========


   void              showInfo1();
   void              showInfo2();
   Pinfo             info1[35];         // Labels and Values
   Pinfo             info2[35];

   void              createObject(int index, int type, color clr);  

   CButton           *refreshButton;   // Button to reload strategy from SQL DB
   CPanel            *panel;
   CLabel            *label;

   void CreateButtonClosePositions(void);

//=========
public:
//=========
   void              createPanel(string name,int subWindow,int x1,int y1,int x2, int y2);
   void              showPanelDetails();
   void              mainInfoPanel();
   void              positionInfoUpdate();
   void              accountInfoUpdate();
   
   void              updateInfo1Label(int index, string val) {info1[index].labelObject.Text(val);};  
   void              updateInfo1Value(int index, string val) {info1[index].valueObject.Text(val);};  
   void              updateInfo2Label(int index, string val) {info2[index].labelObject.Text(val);};  
   void              updateInfo2Value(int index, string val) {info2[index].valueObject.Text(val);};
   
   void              setInfo1LabelColor(int index, color clr) {info1[index].labelObject.Color(clr);};
   void              setInfo1ValueColor(int index, color clr) {info1[index].valueObject.Color(clr);};
   void              setInfo2LabelColor(int index, color clr) {info2[index].labelObject.Color(clr);};
   void              setInfo2ValueColor(int index, color clr) {info2[index].valueObject.Color(clr);};

   
   //int               objs[4];

EAPanel();
~EAPanel();


};

//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
//EVENT_MAP_BEGIN(MQPanels)

//EVENT_MAP_END(CAppDialog)


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::createPanel(string name,int subWindow,int x1,int y1,int x2,int y2) {


   if(!CAppDialog::Create(0,name,subWindow,x1,y1,x2,y2)) {
      ExpertRemove();
   }

   showInfo1();
   showInfo2();


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
   setInfo2LabelColor(18,clrRed);
   setInfo2ValueColor(18,clrRed);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPanel::EAPanel() {


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPanel::~EAPanel() {
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::mainInfoPanel() {

   

   #ifdef _DEBUG_MAIN_LOOP Print(__FUNCTION__); string ss; #endif 

   updateInfo1Label(0, "Strategy Number");  
   updateInfo1Value(0,IntegerToString(usp.strategyNumber));

   updateInfo1Label(1, "Trading Time");  
   

   if (usp.sessionTradingTime==_ANYTIME) {
      updateInfo1Value(1,"Any Time");
   }

   if (usp.sessionTradingTime==_FIXED_TIME) {
      updateInfo1Value(1,"Fixed Times");

      updateInfo1Label(2, "Trading Start");  
      updateInfo1Value(2,usp.tradingStart);
      updateInfo1Label(3, "Trading End");  
      updateInfo1Value(3,usp.tradingEnd);
   }

   if (usp.sessionTradingTime==_SESSION_TIME) {
      updateInfo1Value(1,"Session Times");
      updateInfo1Label(2, "Trading Start");  
      updateInfo1Value(2,usp.tradingStart);
      updateInfo1Label(3, "Trading End");  
      updateInfo1Value(3,usp.tradingEnd);

      if (usp.marketOpenDelay!=0) {
         updateInfo1Label(4, "Market Open Delay");  
         updateInfo1Value(4,IntegerToString(usp.marketOpenDelay));
      } else {
         updateInfo1Label(4, "Market Open Delay");  
         updateInfo1Value(4, "No Delay");
      }

      if (usp.marketCloseDelay!=0) {
         updateInfo1Label(5, "Market Close Delay");  
         updateInfo1Value(5,IntegerToString(usp.marketCloseDelay));
      } else {
         updateInfo1Label(5, "Market Close Delay");  
         updateInfo1Value(5, "No Delay");
      }
   }


   updateInfo1Label(6, "Weekend Trading");
   if (usp.allowWeekendTrading) {
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
         updateInfo2Value(7,StringFormat("$%5.2f",usp.maxLongHedgeLoss));
         updateInfo2Label(8, "Hedge Number"); 
         updateInfo2Value(8,StringFormat("%d",usp.dnnHedgeNumber));
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
         updateInfo2Value(11,IntegerToString(usp.multiMg));
         updateInfo2Label(12, "Martingale Number"); 
         updateInfo2Value(12,StringFormat("%d",usp.dnnMartingaleNumber));

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
      Print (__FUNCTION__); 
      string ss;
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
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::showInfo1() {

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

         info1[i].labelObject=lObject;
         info1[i].valueObject=vObject;
         Add(info1[i].labelObject);
         Add(info1[i].valueObject);

         info1[i].label=labels[i];

         // XY Placement Name
         labelName=StringFormat("L%d",i);
         x1=ClientAreaLeft();
         y1=ClientAreaTop()+(cellHeight*i);
         x2=ClientAreaLeft()+cellWidth;
         y2=(ClientAreaTop()+cellHeight)+(cellHeight*i);

         info1[i].labelObject.Create(0,labelName,0,x1,y1,x2,y2);

         // XY Placement Values
         labelName=StringFormat("V%d",i);
         x1=ClientAreaLeft()+cellWidth;
         y1=ClientAreaTop()+(cellHeight*i);
         x2=ClientAreaLeft()+(cellWidth*2);
         y2=(ClientAreaTop()+cellHeight)+(cellHeight*i);

         info1[i].valueObject.Create(0,labelName,0,x1,y1,x2,y2);
      }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPanel::showInfo2() {

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

         info2[i].labelObject=lObject;
         info2[i].valueObject=vObject;
         Add(info2[i].labelObject);
         Add(info2[i].valueObject);

         info2[i].label=labels[i];

         // XY Placement Name
         labelName=StringFormat("P%d",i);
         x1=ClientAreaLeft()+(cellWidth*2);
         y1=ClientAreaTop()+(cellHeight*i);
         x2=ClientAreaLeft()+(cellWidth*3);
         y2=(ClientAreaTop()+cellHeight)+(cellHeight*i);

         info2[i].labelObject.Create(0,labelName,0,x1,y1,x2,y2);

         // XY Placement Values
         labelName=StringFormat("A%d",i);
         x1=ClientAreaLeft()+(cellWidth*3);
         y1=ClientAreaTop()+(cellHeight*i);
         x2=ClientAreaLeft()+(cellWidth*4);
         y2=(ClientAreaTop()+cellHeight)+(cellHeight*i);

         info2[i].valueObject.Create(0,labelName,0,x1,y1,x2,y2);
      }

    // change colors


}

