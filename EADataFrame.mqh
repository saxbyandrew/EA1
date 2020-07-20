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
EADataFrame();
~EADataFrame();

   CMatrixDouble  dataFrame;

   int      nnIn;       // Neural network inputs and outputs
   int      nnOut;

   void     buildDataFrame(ENUM_TIMEFRAMES period, datetime startTime, EAInputsOutputs &io);


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EADataFrame::EADataFrame() {

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EADataFrame Object Created ....";
      writeLog;
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
void EADataFrame::buildDataFrame(ENUM_TIMEFRAMES period, datetime startTime, EAInputsOutputs &io) {

   #ifdef _DEBUG_STRATGEY_LIVE  
      Print(__FUNCTION__);  
   #endif 

   #ifdef _WRITELOG  
      string ss;
   #endif

   // TODO fix
   //int  barNumber=iBarShift(_Symbol,period,startTime,true);          // Starting bar for DF creation
   int barNumber=500;

   // Set the public properties
   nnIn=ArraySize(io.inputs);
   nnOut=ArraySize(io.outputs);

   // Initialize the new dataframe size
   setDataFrameSize(barNumber,nnIn+nnOut);

   #ifdef _WRITELOG   // Log the start of DF history capture
      ss=StringFormat(" -> Starting DF collection at bar:%d time:%s",barNumber,TimeToString(startTime,TIME_DATE));
      writeLog;
   #endif 
   
   while (barNumber>0) {

      io.getInputs(barNumber);
      io.getOutputs(barNumber);
      addDataFrameValues(io.inputs,io.outputs);                   // Create a new dataframe row entry
      barNumber--;
   }


   #ifdef _WRITELOG   // Log the start of DF history capture
      ss=StringFormat(" -> End DF collection at bar:%d time:%s",barNumber,TimeToString(startTime,TIME_DATE));
      writeLog;
   #endif 

/*
   // Ending Checks
   if (frameCnt>=usingStrategyValue.dataFrameSize) {   
      #ifdef _WRITELOG  
         ss=StringFormat(" -> Ending dataframe collection last bar was:%s:%s and frame count is:%d",
            TimeToString(iTime(_Symbol,PERIOD_CURRENT,barCnt),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,barCnt),TIME_MINUTES),frameCnt);
         writeLog;
      #endif
      dnn.trainNetwork();                                               // Train network
      return;
   } else {

      // Interate over and get all historical values if needed
      while (barCnt>2) {   

         #ifdef _WRITELOG   // Log the start of DF history capture
            if (frameCnt==0) {
               ss=StringFormat(" -> Starting DF collection in history at bar:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,barCnt),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,barCnt),TIME_MINUTES));
               writeLog;
            }
         #endif  

         setInputs(barCnt);
         setOutputs(barCnt);
         dnn.addDataFrameValues(inputs,outputs,true);                   // Create a new dataframe row entry
         ++frameCnt;
         --barCnt;
         #ifdef _DEBUG_STRATGEY_LIVE  
            printf(" --> Adding History bar:%d frame:%d",barCnt,frameCnt);
         #endif 
      }

      // Now continue to capture current values for the dataframe in real time until we reach dataFrameSize
      setInputs(1);
      setOutputs(1);
      dnn.addDataFrameValues(inputs,outputs,true);    // Create a new dataframe row entry
      ++frameCnt;
      #ifdef _DEBUG_STRATGEY_LIVE  
         printf(" --> Adding current bar:%d frame:%d",barCnt,frameCnt);
      #endif 

   }
*/

}
