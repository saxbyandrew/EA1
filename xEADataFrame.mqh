//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EAEnum.mqh"
#include <Math\Alglib\alglib.mqh>

class EAInputsOutputs;
class EATechnicalParameters;
class EANeuralNetwork;

class EADataFrame  {

//=========
private:
//=========


//=========
protected:
//=========

   void     setDataFrameSize(int x, int y) {dataFrame.Resize(x,y); };
   void     addDataFrameValues(double &inputs[], double &outputs[]);

//=========
public:
//=========
EADataFrame(EAInputsOutputs &io, EANeuralNetwork &nn);
~EADataFrame();

   CMatrixDouble  dataFrame;
   int      barCnt;
   void     buildDataFrame(EAInputsOutputs &io);
   void     buildDataFrame(EAInputsOutputs &io, EANeuralNetwork &nn, datetime fromDate);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADataFrame::EADataFrame(EAInputsOutputs &io, EANeuralNetwork &nn) {

   #ifdef _DEBUG_DATAFRAME
      string ss;
      ss="EADataFrame -> Object Created ....";
      writeLog
      pss
   #endif 

   // OPTIMIZATION MODE
   // Check which mode we are executing in
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {         
      dataFrame.Resize(n.dfSize,ArraySize(io.inputs)+ArraySize(io.outputs));                         
      return;
   } 



}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADataFrame::~EADataFrame() {


}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EADataFrame::addDataFrameValues(double &inputs[], double& outputs[]) {

   #ifdef _DEBUG_DATAFRAME
      string ss;
      ss="addDataFrameValues -> inputs ->";
      for (int i=0;i<ArraySize(inputs);i++) {
         ss=ss+":"+DoubleToString(inputs[i]);
      }
      writeLog
      pss

      ss="addDataFrameValues -> outputs ->";
      for (int i=0;i<ArraySize(outputs);i++) {
         ss=ss+":"+DoubleToString(outputs[i]);
      }
      writeLog
      pss
   #endif  

   //int csvHandle1;
   static int rowCnt=0;

   // Insert input values
   // [row][in,in,in,in,etc]
   #ifdef _DEBUG_DATAFRAME
      ss="addDataFrameValues -> creating dataFrame row:"+rowCnt+" ";
   #endif
   for (int i=0;i<ArraySize(inputs);i++) {
      dataFrame[rowCnt].Set(i,inputs[i]);
      #ifdef _DEBUG_DATAFRAME
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][i],2);
      #endif
   }
   // tack on output values at the end of the array
   // [row][in,in,in,in,etc,out,out,out,etc]
   for (int j=0; j<ArraySize(outputs);j++) {
      dataFrame[rowCnt].Set(j+ArraySize(inputs),outputs[j]);
      #ifdef _DEBUG_DATAFRAME
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][j+ArraySize(inputs)],2);
      #endif
   }
   
   #ifdef _DEBUG_DATAFRAME
      writeLog
      pss
   #endif 

   rowCnt++;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EADataFrame::buildDataFrame(EAInputsOutputs &io) {

   #ifdef _DEBUG_DATAFRAME  
      string ss;
      ss="buildDataFrame -> ....";
      writeLog
      pss
   #endif
   
   io.getInputs(1);
   io.getOutputs(1);
   addDataFrameValues(io.inputs,io.outputs);                   // Create a new dataframe row entry
   barCnt--;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EADataFrame::buildDataFrame(EAInputsOutputs &io, datetime fromDate) {

   #ifdef _DEBUG_DATAFRAME  
      string ss;
      ss=StringFormat("buildDataFrame from date -> ....%s",TimeToString(fromDate,TIME_DATE));
      writeLog
      pss
   #endif

   // Get the bar number of the start date as set by the optimization run 
   // then iterate to the end as set by dfSize
   barCnt=startbarsetby optimization time
   if (barCnt>0) { 
      io.getInputs(barCnt);
      io.getOutputs(barCnt);
      addDataFrameValues(io.inputs,io.outputs);                   // Create a new dataframe row entry
      barCnt--;
         
   }

   // The DF is built now train it and save it as a disk file
   nn.trainNetwork(df);

   

}
