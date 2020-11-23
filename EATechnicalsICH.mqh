//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EATechnicalsBase.mqh"

#include <Indicators\Trend.mqh>

//=========
class EATechnicalsICH : public EATechnicalsBase {
//=========

//=========
private:

   string         ss;
   CiIchimoku     ich;  

//=========
protected:
//=========


//=========
public:
//=========
   EATechnicalsICH(Technicals &t);
   ~EATechnicalsICH();

   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs);    
   void  getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime);                    


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsICH::EATechnicalsICH(Technicals &t) {

   EATechnicalsBase::copyValues(t);

   if (!ich.Create(_Symbol,t.period,t.tenkanSen,t.kijunSen,t.spanB)) {
      #ifdef _DEBUG_ICH_MODULE
            ss="ICHSetParameters -> ERROR";
            pss
            writeLog
            ExpertRemove();
      #endif
   } 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATechnicalsICH::~EATechnicalsICH() {

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsICH::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs,datetime barDateTime) {

   int      barNumber=iBarShift(_Symbol,tech.period,barDateTime,false); // Adjust the bar number based on PERIOD and TIME
   double   tenkanSen[1], kijunSen[1], senkouSpanA[1], senkouSpanB[1], chinkouSpan[1];

   // Refresh the indicator and get all the buffers
   ich.Refresh(-1);
   // The ChinkouSpan is simply the current bid shifted backwards by the Kijun period (default 26).

   if (ich.GetData(barDateTime,1,0,tenkanSen)>0  && ich.GetData(barDateTime,1,1,kijunSen)>0 && 
      ich.GetData(barDateTime,1,1,senkouSpanA)>0 && ich.GetData(barDateTime,1,1,senkouSpanB)>0 &&
      ich.GetData(barNumber+tech.kijunSen,1,1,chinkouSpan)>0) {
      #ifdef _DEBUG_ICH_MODULE
         ss=StringFormat("EATechnicalsICH  -> getValues -> _RUN_OPTIMIZATION tenkanSen:%.2f",tenkanSen[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues ->  _RUN_OPTIMIZATION kijunSen:%.2f",kijunSen[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> _RUN_OPTIMIZATION senkouSpanA:%.2f",senkouSpanA[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> _RUN_OPTIMIZATION senkouSpanB:%.2f",senkouSpanB[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> _RUN_OPTIMIZATION barnumber:%d chinkouSpan:%.2f ",barNumber,chinkouSpan[0]);    
         writeLog
         pss

      #endif

      /*
      https://www.alglib.net/dataanalysis/neuralnetworks.php#header0
      Data preprocessing is normalization of training data - inputs and output are normalized to have unit mean/deviation. 
      Preprocessing is essential for fast convergence of the training algorithm - it may even fail to converge on badly scaled data. 
      ALGLIB package automatically analyzes data set and chooses corresponding scaling for inputs and outputs. 
      Input data are automatically scaled prior to feeding network, and network outputs are automatically unscaled after processing. 
      Preprocessing is done transparently to user, you don't have to worry about it - just feed data to training algorithm!
      */

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(tenkanSen[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(kijunSen[0]);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(senkouSpanA[0]);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(senkouSpanB[0]);
      if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(chinkouSpan[0]);


   } else {
      #ifdef _DEBUG_ICH_MODULE
         ss="EATechnicalsICH   -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(0);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATechnicalsICH::getValues(CArrayDouble &nnInputs, CArrayDouble &nnOutputs) {


   double   tenkanSen[1], kijunSen[1], senkouSpanA[1], senkouSpanB[1], chinkouSpan[1];

   // Refresh the indicator and get all the buffers
   ich.Refresh(-1);

   // The ChinkouSpan is simply the current bid shifted backwards by the Kijun period (default 26).

      if (ich.GetData(1,1,0,tenkanSen)>0  && ich.GetData(1,1,1,kijunSen)>0 && 
         ich.GetData(1,1,2,senkouSpanA)>0 && ich.GetData(1,1,3,senkouSpanB)>0 &&
         ich.GetData(tech.kijunSen,1,4,chinkouSpan)>0) {
      #ifdef _DEBUG_ICH_MODULE
         ss=StringFormat("EATechnicalsICH  -> getValues -> tenkanSen:%.2f",tenkanSen[0]);        
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> kijunSen:%.2f",kijunSen[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> senkouSpanA:%.2f",senkouSpanA[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> senkouSpanB:%.2f",senkouSpanB[0]);    
         writeLog
         pss
         ss=StringFormat("EATechnicalsICH  -> getValues -> chinkouSpan:%.2f",chinkouSpan[0]);    
         writeLog
         pss
      #endif

      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(tenkanSen[0]);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(kijunSen[0]);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(senkouSpanA[0]);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(senkouSpanB[0]);
      if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(chinkouSpan[0]);


   } else {
      #ifdef _DEBUG_ICH_MODULE
         ss="EATechnicalsICH -> getValues -> ERROR will return zeros"; 
         writeLog
         pss
      #endif
      if (bool (tech.useBuffers&_BUFFER1)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER2)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER3)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER4)) nnInputs.Add(0);
      if (bool (tech.useBuffers&_BUFFER5)) nnInputs.Add(0);
   }
}