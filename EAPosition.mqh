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
#include "EAStructures.mqh"

class EAPositionBase;
class EATiming;


class EAPosition : public CObject {

//=========
private:
//=========

  CPositionInfo   PositionInfo;
  string          ss;

//=========
protected:
//=========

//=========
public:
//=========
EAPosition(Strategy &strategy, ENUM_ORDER_TYPE ot, EAEnum currentStatus, double ep);
EAPosition(EAPosition &cp);
~EAPosition();

  virtual int Type() const {return _NORMAL;};


  ENUM_ORDER_TYPE   orderTypeToOpen;
  int               ticket;
  double            entryPrice; 
  double            currentPnL;
  int               daysOpen;
  double            swapCosts;
  double            fixedProfitTargetLevel;     // Price Level
  double            fixedLossTargetLevel;       // Price Level
  double            fpt, flt;                   // Dollar 
  EAEnum            status;
  datetime          closingDateTime;
  int               closeAtEOD;

  Strategy          strategy;                   // Local instance copy of strategy values

    int             positionExists(int t) {return (PositionInfo.SelectByTicket(t));};
    void            calcPositionPnL();
    void            calcPositionSwapCost();

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPosition::EAPosition(Strategy &cp, ENUM_ORDER_TYPE ot, EAEnum currentStatus, double ep) {

    #ifdef _DEBUG_POSITION
        ss=StringFormat("EAPosition -> DEFAULT CONSTRUCTOR for strategyNumber:%d",cp.strategyNumber);
        writeLog
        pss
    #endif  

  // Set some defaults
  ticket=0;
  currentPnL=0;
  daysOpen=0;
  swapCosts=0;
  status=currentStatus;
  orderTypeToOpen=ot;


  // Timing Closes
  strategy.strategyNumber=cp.strategyNumber;
  strategy.lotSize=cp.lotSize;
  closeAtEOD=cp.closeAtEOD;
  strategy.brokerAdminPercent=cp.brokerAdminPercent;
  strategy.interBankPercentage=cp.interBankPercentage;
  strategy.deviationInPoints=cp.deviationInPoints;

  // Set $$ and level STL TP
  entryPrice=ep;
  strategy.inProfitClosePosition=cp.inProfitClosePosition;
  fixedProfitTargetLevel=entryPrice+cp.fpt; 
  strategy.inLossClosePosition=cp.inLossClosePosition;        
  fixedLossTargetLevel=entryPrice+cp.flt; 

  #ifdef _DEBUG_POSITION
    ss=StringFormat("EAPosition -> strategyNumber:%d entryPrice:%.2f lotSize:%.2f closeAtEOD:%d inProfitClosePosition:%d (%.2f) inLossClosePosition:%d (%.2f)",cp.strategyNumber,entryPrice,cp.lotSize,cp.closeAtEOD,cp.inProfitClosePosition,fixedProfitTargetLevel,cp.inLossClosePosition,fixedLossTargetLevel);
    writeLog
    pss
  #endif  
  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPosition::EAPosition(EAPosition &cp) {

    #ifdef _DEBUG_POSITION
        ss=StringFormat("EAPosition -> COPY CONSTRUCTOR for strategyNumber:%d",cp.strategy.strategyNumber);
        writeLog
        pss
    #endif 
  
  // POSITION

    ticket=cp.ticket;
    entryPrice=cp.entryPrice; 
    orderTypeToOpen=cp.orderTypeToOpen;
    fixedProfitTargetLevel=cp.fixedProfitTargetLevel;     // Price Level not $$ amount !
    fixedLossTargetLevel=cp.fixedLossTargetLevel;         // Price Level
    daysOpen=cp.daysOpen;
    currentPnL=cp.currentPnL;
    swapCosts=cp.swapCosts;
    status=cp.status;
    closingDateTime=cp.closingDateTime;

    strategy.strategyNumber=cp.strategy.strategyNumber;                     // Name of strategy for comment 
    strategy.lotSize=cp.strategy.lotSize; 
    strategy.deviationInPoints=cp.strategy.deviationInPoints;
    strategy.brokerAdminPercent=cp.strategy.brokerAdminPercent;
    strategy.interBankPercentage=cp.strategy.interBankPercentage;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAPosition::~EAPosition() {


}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAPosition::calcPositionSwapCost() {

  // TODO check if this calc is correct OR is we can rather get it from the actual broker!
  // there are STD lib functions for thisbut have only retured 0
  // Trade size * Close Price * (2.5% +/- LIBOR)/365
  swapCosts=daysOpen*(strategy.lotSize*iClose(_Symbol,PERIOD_D1,1)*(strategy.brokerAdminPercent+strategy.interBankPercentage))/365;
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

