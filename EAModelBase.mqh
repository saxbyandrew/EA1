//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

//#define _DEBUG_MODELBASE

#include "EAEnum.mqh"

//=========
class EAModelBase {
//=========

//=========
private:
//=========

//=========
protected:
//=========


   void                 triggerVerticalLine(int win,color clr, ENUM_LINE_STYLE style);  


//=========
public:
//=========
EAModelBase();
~EAModelBase();


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAModelBase::EAModelBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAModelBase::~EAModelBase() {

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAModelBase::triggerVerticalLine(int win,color clr, ENUM_LINE_STYLE style) {

   static   int cnt=0;
   string   objName;
   
   // Clear up the chart    
   if (cnt>=10) {
      cnt=0; 
      ObjectsDeleteAll(0,"VL",-1,-1);
   } else {
      ++cnt;
   }  
           
   if (ObjectFind(0,objName) == -1) {  
      StringConcatenate(objName,"VL",cnt);
      if (ObjectCreate(0,objName, OBJ_VLINE, win, iTime(_Symbol,PERIOD_CURRENT,0), 0)) {
         ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
         ObjectSetInteger(0,objName,OBJPROP_STYLE,style);     
      } 
   } 
}  


