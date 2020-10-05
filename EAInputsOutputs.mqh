//+------------------------------------------------------------------+
//|                                              MQStrategyTest1.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"



#include "EAEnum.mqh"


//=========
class EAInputsOutputs  {
//=========


//=========
private:
//=========

   string      ss;

//=========
protected:
//=========


//=========
public:
//=========
EAInputsOutputs(int basestrategyType);
~EAInputsOutputs();

   virtual int Type() const {return _STRATEGY;};

   double            inputs[];       
   double            outputs[];      

   void  getInputs();
   void  getOutputs();


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAInputsOutputs::EAInputsOutputs(int basestrategyType ) {


   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss="EAInputsOutputs ->  Object Created ....";
      writeLog
      pss
   #endif 


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAInputsOutputs::~EAInputsOutputs() {

   // Clean up
   for (int i=0;i<indicators.Total();i++) {
      delete(indicators.At(i));
   }

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::getInputs() {


   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss=("getInputs -> ");
      writeLog
      pss
   #endif 

   // Loop through all object and get the object to return the value as a input to the NN
   for (int i=0;i<indicators.Total();i++) {
      EATechnicalsBase *t=indicators.At(i);
      t.getValues();
      #ifdef _DEBUG_NN_INPUTS_OUTPUTS
         for (int l=0;l<ArraySize(t.iOutputs);l++) {
            ss=ss+' '+t.iOutputs[l];
         }
         writeLog
         pss
      #endif
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAInputsOutputs::getOutputs() {
   /*

   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss=StringFormat("getOutputs ->for bar number:%d",currentBar);
      writeLog
      pss
   #endif  

   double  o[2];
   int     j=0;

   // Output are the strategyType we will try and train the model to
   
   //outputs[0]=mediumTerm.SARValue(tech.adx.m_SARperiod);
   //outputs[1]=longTerm.SARValue(tech.adx.l_SARperiod);

   EAEnum x = shortTerm.ZIGZAGValue(currentBar);

   if (x==_UP) {
      o[j++]=1;
      o[j++]=0;
   }
   if (x==_DOWN) {
      o[j++]=0;
      o[j++]=1;
   }

   ArrayCopy(outputs,o,0,0,j);
   
   #ifdef _DEBUG_NN_INPUTS_OUTPUTS
      ss="getOutputs -> ";
      for (int i=0;i<ArraySize(outputs);i++) {
         ss=ss+"  "+DoubleToString(outputs[i]);
      }
      writeLog
      pss
   #endif
   */

}

