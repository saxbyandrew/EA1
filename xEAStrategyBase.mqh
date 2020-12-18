//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_STRATEGY_BASE

#include <Object.mqh>

#include "EAEnum.mqh"



class EAStrategyBase : public CObject{

//=========
private:
//=========

//=========
protected:
//=========

//=========
public:
//=========
  EAStrategyBase();
  ~EAStrategyBase();

  virtual void   execute(EAEnum action) {};

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyBase::EAStrategyBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyBase::~EAStrategyBase() {

}
