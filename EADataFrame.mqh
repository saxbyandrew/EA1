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
#include "EAInputsOutputs.mqh"
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
   EAInputsOutputs   *io;

//=========
public:
//=========
EADataFrame(EAInputsOutputs &inputOutputs);
~EADataFrame();

   CMatrixDouble  dataFrame;

   int      nnIn;       // Neural network inputs and outputs
   int      nnOut;
   int      barCnt;

   void     buildDataFrame();


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADataFrame::EADataFrame(EAInputsOutputs &inputOutputs) {


   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EADataFrame Object Created ....";
      writeLog;
   #endif 


   int request=DatabasePrepare(_dbHandle,"SELECT dataFrameSize FROM STRATEGIES WHERE WHERE isActive=1"); 
   if (request==INVALID_HANDLE) {
      Print(" -> DB request failed with code ", GetLastError());
      ExpertRemove();
   }
   DatabaseColumnInteger   (request,0,barCnt);
   #ifdef _WRITELOG   
      ss=StringFormat(" ->  DF size:%d ",barCnt);
      writeLog;
   #endif 

   io=inputOutputs;              // Save a local pointer 

   // Set the public properties
   nnIn=ArraySize(io.inputs);
   nnOut=ArraySize(io.outputs);

   // Initialize the new dataframe size
   setDataFrameSize(barCnt,nnIn+nnOut);


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
   #endif  

   //int csvHandle1;
   static int rowCnt=0;

   #ifdef _WRITELOG
      string ss;
   #endif

   // Insert input values
   // [row][in,in,in,in,etc]
   for (int i=0;i<ArraySize(inputs);i++) {
      dataFrame[rowCnt].Set(i,inputs[i]);
      #ifdef _WRITELOG
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][i],2);
      #endif
   }
   // tack on output values at the end of the array
   // [row][in,in,in,in,etc,out,out,out,etc]
   for (int j=0; j<ArraySize(outputs);j++) {
      dataFrame[rowCnt].Set(j+ArraySize(inputs),outputs[j]);
      #ifdef _WRITELOG
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][j+ArraySize(inputs)],2);
      #endif
   }
   
   #ifdef _WRITELOG
      static int logCnt=_LOGSIZE;
      if (logCnt>=100) {    // Only write evert 100th entry to save space but prove it works
         writeLog;
         logCnt=0;
      } else {
         ++logCnt;
      }
   #endif 

   rowCnt++;
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EADataFrame::buildDataFrame() {

   #ifdef _WRITELOG  
      string ss;
   #endif

   #ifdef _WRITELOG   // Log the start of DF history capture
      ss=StringFormat(" ->  DF collection at bar:%d ",barCnt);
      writeLog;
   #endif 
   
   io.getInputs(barCnt);
   io.getOutputs(barCnt);
   addDataFrameValues(io.inputs,io.outputs);                   // Create a new dataframe row entry
   barCnt--;


}
