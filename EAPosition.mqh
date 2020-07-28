//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_POSITION

#include <Object.mqh>
#include <Trade\PositionInfo.mqh>

#include "EAEnum.mqh"


class EAPosition : public CObject {

//=========
private:
//=========

  CPositionInfo   PositionInfo;

  string          font;
  int             fontSize;

//=========
protected:
//=========

//=========
public:
//=========
EAPosition();
EAPosition(EAPosition &cp);
~EAPosition();

  virtual int Type() const {return _NORMAL;};

  // POSITION
    int               strategyNumber;            // Name of strategy for comment 
    int               ticket;
    double            entryPrice; 
    double            lotSize; 
    ENUM_ORDER_TYPE   orderTypeToOpen;
    double            fixedProfitTargetLevel;    // Price Level
    double            fixedLossTargetLevel;      // Price Level
    int               daysOpen;
    double            currentPnL;
    double            swapCosts;
    EAEnum            status;
    datetime          closingDateTime;
    EAEnum            closingTypes;
    int               deviationInPoints;
    double            brokerAdminPercent;
    double            interBankPercentage;

    int               positionExists(int ticket) {return (PositionInfo.SelectByTicket(ticket));};
    void              calcPositionPnL();
    void              calcPositionSwapCost();

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPosition::EAPosition() {

      //----
    #ifdef _DEBUG_POSITION
      Print (" ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      Print (__FUNCTION__," Default Constructor"); 
      Print (" ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    #endif  
  //----

  strategyNumber=0;            // Name of strategy for comment 
  ticket=0;
  entryPrice=0; 
  lotSize=0; 
  orderTypeToOpen=NULL;
  fixedProfitTargetLevel=0;    // Price Level
  fixedLossTargetLevel=0;      // Price Level
  daysOpen=0;
  currentPnL=0;
  swapCosts=0;
  status=_NOTSET;
  closingDateTime=NULL;
  closingTypes=NULL;
  deviationInPoints=0;
  brokerAdminPercent=0;
  interBankPercentage=0;


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPosition::EAPosition(EAPosition &cp) {

    //----
    #ifdef _DEBUG_POSITION
      Print (" ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      Print (__FUNCTION__," Copy Constructor"); 
      Print (" ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    #endif  
  //----
  

  // POSITION
    strategyNumber=cp.strategyNumber;                     // Name of strategy for comment 
    ticket=cp.ticket;
    entryPrice=cp.entryPrice; 
    lotSize=cp.lotSize; 
    orderTypeToOpen=cp.orderTypeToOpen;
    fixedProfitTargetLevel=cp.fixedProfitTargetLevel;     // Price Level not $$ amount !
    fixedLossTargetLevel=cp.fixedLossTargetLevel;         // Price Level
    daysOpen=cp.daysOpen;
    currentPnL=cp.currentPnL;
    swapCosts=cp.swapCosts;
    status=cp.status;
    closingDateTime=cp.closingDateTime;
    closingTypes=cp.closingTypes;
    deviationInPoints=cp.deviationInPoints;
    brokerAdminPercent=cp.brokerAdminPercent;
    interBankPercentage=cp.interBankPercentage;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPosition::~EAPosition() {

   //----
    #ifdef _DEBUG_POSITION
      Print (" ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      Print (__FUNCTION__," Destructor"); 
      Print (" ->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    #endif  
  //----

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPosition::calcPositionSwapCost() {

  // TODO check if this calc is correct OR is we can rather get it from the actual broker!
  // there are STD lib functions for thisbut have only retured 0
  // Trade size * Close Price * (2.5% +/- LIBOR)/365
  swapCosts=daysOpen*(lotSize*iClose(_Symbol,PERIOD_D1,1)*(brokerAdminPercent+interBankPercentage))/365;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPosition::calcPositionPnL() {

  PositionInfo.SelectByTicket(ticket);
  currentPnL=PositionInfo.Profit();

}

/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPosition::updateTextLabel(color clr) {

  #ifdef _DEBUG_POSITION 
    Print(__FUNCTION__); 
  #endif 

  if (ObjectFind(0,objName)==-1) {
    if (!ObjectCreate(0,objName, OBJ_TEXT, 0, TimeCurrent(), entryPrice)) {
      Print (" -> Failed to create new text object",GetLastError());
    } else {
      Print (" -> Created text object OK");
    }

        ObjectSetString(0,objName,OBJPROP_FONT,font);
        ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,fontSize);
        ObjectSetDouble(0,objName,OBJPROP_ANGLE,0);
        ObjectSetInteger(0,objName, OBJPROP_COLOR, clr);
        ObjectSetString(0,objName,OBJPROP_TEXT,setTextLabel());
  } else {
        ObjectSetString(0,objName,OBJPROP_FONT,font);
        ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,fontSize);
        ObjectSetDouble(0,objName,OBJPROP_ANGLE,0);
        ObjectSetInteger(0,objName, OBJPROP_COLOR, clr);
        ObjectSetString(0,objName,OBJPROP_TEXT,setTextLabel());
  }

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPosition::setTextLabel(color clr) {

  #ifdef _DEBUG_POSITION 
    Print(__FUNCTION__); 
  #endif 
  string s1, s2, sResult;

  double  priceLevel=ObjectGetDouble(0,profitLineObject,OBJPROP_PRICE,0);

    textObjName=DoubleToString(entryPrice);

    if (ObjectFind(0,textObjName)==-1) {
        if (!ObjectCreate(0,textObjName, OBJ_TEXT, 0, TimeCurrent(), priceLevel)) {
            Print (" -> Failed to create new text object",GetLastError());
            ExpertRemove(); 
        } else {
            Print (" -> Created text object OK");
            ObjectSetString(0,textObjName,OBJPROP_FONT,font);
            ObjectSetInteger(0,textObjName,OBJPROP_FONTSIZE,fontSize);
            ObjectSetDouble(0,textObjName,OBJPROP_ANGLE,0);
            ObjectSetInteger(0,textObjName, OBJPROP_COLOR, clr);
        }
    } 



    // Establish possible position links
    if (this.Next()!=NULL) {
      EAPosition *np=this.Next();
      s2=StringFormat("<< next ticket:%d",np.ticket);
    } else {
      s2="<< no next ticket";
    }
    if (this.Prev()!=NULL) {
      EAPosition *pp=this.Prev();
      s2=StringFormat("<< prev ticket:%d",pp.ticket);
    } else {
      s2=StringFormat("<< has no prev ticket",this.ticket);
    }

  switch (status) {
    case _LONG: s1="L";
    break;
    case _SHORT: s1="S";
    break;
    case _MARTINGALE: s1="M";
    break;
    case _HEDGE: s1="H";
    break;
  }

  PositionInfo.SelectByTicket(ticket);
  double pnl=MathRound(PositionInfo.Profit());
  double tp=MathRound(fixedProfitTargetLevel);
  double tl=MathRound(fixedLossTargetLevel);
  if (s1=="L") {
    sResult=StringFormat(" --> %s T:%u PnL:%g TP:%g TL:%g %s",s1,ticket,pnl,tp,tl,s2);
  }

  if (s1=="S") {
    sResult=StringFormat(" --> %s T:%u PnL:%g TP:%g TL:%g %s",s1,ticket,pnl,tl,tp,s2);
  }

  ObjectSetString(0,textObjName,OBJPROP_TEXT,sResult);

}
*/

