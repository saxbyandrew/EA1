//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "EAEnum.mqh"


//=========
class EATechnicalsBase : public CObject {
//=========

//=========
private:
//=========


//=========
protected:
//=========

//=========
public:
//=========
   EATechnicalsBase();
   ~EATechnicalsBase();

   int   lookback;
   int   buffer;
   ENUM_TIMEFRAMES period;
   int   ma;




};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsBase::EATechnicalsBase() {

}
EATechnicalsBase::~EATechnicalsBase() {

}