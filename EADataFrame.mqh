//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"

#define _DEBUG_DATAFRAME

#include "EAEnum.mqh"
#include <Math\Alglib\alglib.mqh>


class EAInputsOutputs;
class EATechnicalParameters;

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
EADataFrame(EAInputsOutputs &io);
~EADataFrame();

   CMatrixDouble  dataFrame;

   int      barCnt;

   void     buildDataFrame(EAInputsOutputs &io);


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADataFrame::EADataFrame(EAInputsOutputs &io) {


   #ifdef _DEBUG_DATAFRAME
      string ss;
      printf(" -> EADataFrame Object Created ....");
   #endif 
   int numInput, numOutput;
   barCnt=usp.dataFrameSize; // Number of bars to grab and insert into the DF

   // Set the public properties
   numInput=ArraySize(io.inputs);
   numOutput=ArraySize(io.outputs);

   // Initialize the new dataframe size
   dataFrame.Resize(barCnt,numInput+numOutput);

   #ifdef _DEBUG_DATAFRAME
      ss=StringFormat(" -> DataFrame size is %d",dataFrame.Size());
      printf(ss);
   #endif  


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
      Print(__FUNCTION__);
      string ss;
      ArrayPrint(inputs);
      ArrayPrint(outputs);
   #endif  

   //int csvHandle1;
   static int rowCnt=0;

   // Insert input values
   // [row][in,in,in,in,etc]
   for (int i=0;i<ArraySize(inputs);i++) {
      dataFrame[rowCnt].Set(i,inputs[i]);
      #ifdef _DEBUG_DATAFRAME
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][i],2);
         printf(ss);
      #endif
   }
   // tack on output values at the end of the array
   // [row][in,in,in,in,etc,out,out,out,etc]
   for (int j=0; j<ArraySize(outputs);j++) {
      dataFrame[rowCnt].Set(j+ArraySize(inputs),outputs[j]);
      #ifdef _DEBUG_DATAFRAME
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][j+ArraySize(inputs)],2);
         printf(ss);
      #endif
   }
   
   /*
   #ifdef _DEBUG_DATAFRAME
      static int logCnt=_LOGSIZE;
      if (logCnt>=100) {    // Only write evert 100th entry to save space but prove it works
         printf(ss);
         logCnt=0;
      } else {
         ++logCnt;
      }
   #endif 
   */

   rowCnt++;
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EADataFrame::buildDataFrame(EAInputsOutputs &io) {

   #ifdef _DEBUG_DATAFRAME  
      string ss;
   #endif

   #ifdef _DEBUG_DATAFRAME   // Log the start of DF history capture
      ss=StringFormat(" ->  DF collection at bar:%d ",barCnt);
      printf(ss);
   #endif 
   
   io.getInputs(1);
   io.getOutputs(1);
   addDataFrameValues(io.inputs,io.outputs);                   // Create a new dataframe row entry
   barCnt--;


}
