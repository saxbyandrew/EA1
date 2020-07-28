//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


//#define _DEBUG_DNN
//#define _DEBUG_DATAFRAME

#include "EAEnum.mqh"
#include "EAModelBase.mqh"
#include <Math\Alglib\alglib.mqh>
#include <Arrays\ArrayDouble.mqh>

class EADataFrame;

class EANeuralNetwork  {

//=========
private:
//=========

   struct neuralNetwork {
      EAEnum nnType;
      int nnIn;
      int nnLayer1;
      int nnLayer2;
      int nnOut;
   } n;

   void     networkProperties();
   void     createNewNetwork();
   bool     saveNetwork();
   bool     loadNetwork();
   void     networkForcast(double &inputs[], double &outputs[]);

   int      _txtHandle, _mainDB;
   

//=========
protected:
//=========
      CAlglib  no;
      CMultilayerPerceptronShell ps;
      void copyValuesFromDatabase();

//=========
public:
//=========
EANeuralNetwork();
~EANeuralNetwork();


   bool           isTrained;
   CArrayDouble   *nnArray;
   void           trainNetwork(EADataFrame &df);


   //void     addTargetValues();


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::EANeuralNetwork() {


   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=" -> EANeuralNetwork Object Created ....";
      writeLog;
   #endif


   if (MQLInfoInteger(MQL_TESTER)) { 
      copyValuesFromDatabase();
      // we use the L1 L2 and NNTYPE from the DB but the NN is created later in the training  function
      // and the IN / OUT is based on the IO objects number of inputs and outputs
   } else { 
      copyValuesFromDatabase();
      createNewNetwork();
      loadNetwork();
      #ifdef _WRITELOG
         ss=" -> Load NN from DB values";
         writeLog;
      #endif

   }

   isTrained=false;

   nnArray=new CArrayDouble;

   #ifdef _WRITELOG
      ss=StringFormat(" -> EANeuralNetwork Run Mode is:%d",_runMode);
      writeLog;
   #endif


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::~EANeuralNetwork() {


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::copyValuesFromDatabase() {

   #ifdef _WRITELOG
      string ss;
   #endif


   int request=DatabasePrepare(_dbHandle,"SELECT dnnType,dnnIn,dnnLayer1,dnnLayer2,dnnOut FROM STRATEGIES WHERE isActive=1");
   if (request==INVALID_HANDLE) {
      #ifdef _WRITELOG
         ss=StringFormat(" -> Error in database SELECT, %d",GetLastError());
         writeLog;
      #endif
   }
   if (!DatabaseRead(request)) {
      Print(" -> DB read request failed with code:", GetLastError()); 
      ExpertRemove();
   } else {
      DatabaseColumnInteger   (request,2,n.nnType);
      DatabaseColumnInteger   (request,3,n.nnIn);
      DatabaseColumnInteger   (request,4,n.nnLayer1);
      DatabaseColumnInteger   (request,5,n.nnLayer2);
      DatabaseColumnInteger   (request,6,n.nnOut);
   }

   #ifdef _WRITELOG
      ss=StringFormat(" -> EANeuralNetwork::copyValuesFromDatabase Read NN:%s from DB with I:%d L1:%d L2:%d O:%d",EnumToString(n.nnType),n.nnIn,n.nnLayer1,n.nnLayer2,n.nnOut);
      writeLog;
   #endif
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkProperties()  {

   #ifdef _DEBUG_DNN
      Print(__FUNCTION__);
   #endif

   int nInputs= 0, nOutputs= 0, nWeights= 0;
   no.MLPProperties(ps, nInputs, nOutputs, nWeights);

   /*
   showPanel {
      string s1=StringFormat("I:%d L1:%d L2:%d O:%d W:%d",nInputs,pb.dnnLayer1,pb.dnnLayer2,nOutputs,nWeights);
      mp.updateInfo2Label(20,s1);
   }
   */

   #ifdef _WRITELOG
      string ss= StringFormat(" -> Inputs:%d Layer 1:%d Layer 2:%d Outputs:%d Weights:%d ",nInputs,n.nnLayer1,n.nnLayer2,nOutputs,nWeights);
      writeLog;
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::createNewNetwork()  {

   // TODO error checks

   switch (n.nnType) {
      case _NN_2: no.MLPCreateC2(n.nnIn,n.nnLayer1,n.nnLayer2,n.nnOut,ps);
      break;
      case _NN_C2:no.MLPCreate2(n.nnIn,n.nnLayer1,n.nnLayer2,n.nnOut,ps);
      break;
      case _NN_R2:no.MLPCreateR2(n.nnIn,n.nnLayer1,n.nnLayer2,n.nnOut,0,1,ps);
      break;
   }
   networkProperties();
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::saveNetwork() {

   #ifdef _DEBUG_DNN
      Print(__FUNCTION__);
   #endif

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=StringFormat(" -> Saving network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      writeLog;
   #endif 

   bool savedNetwork= false;
   int k= 0, i= 0, j= 0, numLayers= 0, network[], nLayer1= 1, functionType= 0, binFileHandle;
   double threshold= 0, weights= 0, media= 0, sigma= 0;
   string fileName;
   double nn[];

   //fileName=IntegerToString(pb.strategyNumber);
   //= fileName+".dnn";
   //FileDelete(fileName, FILE_COMMON);
   ResetLastError();
   //binFileHandle= FileOpen(fileName, FILE_WRITE|FILE_BIN|FILE_COMMON);
   //savedNetwork= binFileHandle!=INVALID_HANDLE;

   //#ifdef _WRITELOG
      //FileWrite(_txtHandle,StringFormat(" -> Network file name:%s",fileName));
      //commentLine;
   //#endif

   //if(savedNetwork) {
      numLayers= no.MLPGetLayersCount(ps);
      nnArray.Add(numLayers);                                                                // **                                                              
      //savedNetwork= savedNetwork && FileWriteDouble(binFileHandle, numLayers)>0;
      ArrayResize(network, numLayers);
      //for(k= 0; savedNetwork && k<numLayers; k++) {
      for(k= 0; k<numLayers; k++) {
         network[k]= no.MLPGetLayerSize(ps, k);
         nnArray.Add(network[k]);                                                           // **
         //savedNetwork= savedNetwork && FileWriteDouble(binFileHandle, network[k])>0;
      }
      //for(k= 0; savedNetwork && k<numLayers; k++) {
      for(k= 0; k<numLayers; k++) {
         //for(i= 0; savedNetwork && i<network[k]; i++) {
         for(i= 0; i<network[k]; i++) {
            if(k==0) {
               no.MLPGetInputScaling(ps, i, media, sigma);
               nnArray.Add(media);                                                          // **
               nnArray.Add(sigma); 
               //FileWriteDouble(binFileHandle, media);
               //FileWriteDouble(binFileHandle, sigma);
            } else if (k==numLayers-1) {
               no.MLPGetOutputScaling(ps, i, media, sigma);
               nnArray.Add(media);                                                          // **
               nnArray.Add(sigma);                                                          // **
               //FileWriteDouble(binFileHandle, media);
               //FileWriteDouble(binFileHandle, sigma);
            }
            no.MLPGetNeuronInfo(ps, k, i, functionType, threshold);
            nnArray.Add(functionType);                                                      // **
            nnArray.Add(threshold);                                                         // **
            //FileWriteDouble(binFileHandle, functionType);
            //FileWriteDouble(binFileHandle, threshold);
            //for(j= 0; savedNetwork && k<(numLayers-1) && j<network[k+1]; j++) {
            for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
               weights= no.MLPGetWeight(ps, k, i, k+1, j);
               nnArray.Add(weights);                                                        // **
               //savedNetwork= savedNetwork && FileWriteDouble(binFileHandle, weights)>0;
            }
         }      
      }
      //FileClose(binFileHandle);
   //}
   //if(!savedNetwork) Print(__FUNCTION__,GetLastError());
   //return(savedNetwork);
   #ifdef _WRITELOG
      ss=StringFormat(" -> Saved network with:%d elements",nnArray.Total());
      writeLog;
   #endif 
   return true;
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::loadNetwork() {

   #ifdef _DEBUG_DNN
      Print(__FUNCTION__);
   #endif

   #ifdef _WRITELOG
      string ss;
      commentLine;
      ss=StringFormat(" -> Loading network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      writeLog;
   #endif  

   //bool networkLoaded= false;
   int k= 0, i= 0, j= 0, idx=0;
   int numLayers= 0, network[], functionType= 0, binFileHandle;
   double threshold= 0, weights= 0, media= 0, sigma= 0;
   //string fileName;

   //fileName=IntegerToString(pb.strategyNumber);
   //fileName= fileName+".dnn";
   //binFileHandle= FileOpen(fileName, FILE_READ|FILE_BIN|FILE_COMMON);
   //networkLoaded= binFileHandle!=INVALID_HANDLE;
   //#ifdef _WRITELOG
      //FileWrite(_txtHandle,StringFormat(" -> Network file name:%s",fileName));
      //commentLine;
   //#endif

   //if(networkLoaded) {
      numLayers=nnArray.At(idx++);
      //numLayers= (int)FileReadDouble(binFileHandle);
      ArrayResize(network, numLayers);
      //for(k= 0; k<numLayers; k++) network[k]= (int)FileReadDouble(binFileHandle); 
      for(k= 0; k<numLayers; k++) network[k]= (int)nnArray.At(idx++); 
      createNewNetwork();
      //no.MLPCreateC2(pb.dnnIn,pb.dnnLayer1,pb.dnnLayer2,pb.dnnOut,ps);
      //no.MLPCreate2(pb.dnnIn,pb.dnnLayer1,pb.dnnLayer2,pb.dnnOut,ps);
      //no.MLPCreateR2(pb.dnnIn,pb.dnnLayer1,pb.dnnLayer2,pb.dnnOut,0,1,ps);
      //networkProperties();

         for(k= 0; k<numLayers; k++) {
            for(i= 0; i<network[k]; i++) {
               if(k==0) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  //media= FileReadDouble(binFileHandle);
                  //sigma= FileReadDouble(binFileHandle);
                  no.MLPSetInputScaling(ps, i, media, sigma);
               }
               else if(k==numLayers-1) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  //media= FileReadDouble(binFileHandle);
                  //sigma= FileReadDouble(binFileHandle);
                  no.MLPSetOutputScaling(ps, i, media, sigma);
               }
               functionType= (int)nnArray.At(idx++);
               threshold= nnArray.At(idx++);
               //functionType= (int)FileReadDouble(binFileHandle);
               //threshold= FileReadDouble(binFileHandle);
               no.MLPSetNeuronInfo(ps, k, i, functionType, threshold);
               for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
                  weights= nnArray.At(idx++);
                  //weights= FileReadDouble(binFileHandle);
                  #ifdef _WRITELOG
                     printf("-> Loading weight:%2.5f",weights);
                  #endif 
                  no.MLPSetWeight(ps, k, i, k+1, j, weights);
               }
            }      
         }
      
   //}
   //FileClose(binFileHandle);
   //return(networkLoaded);
   return true;
   }

/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::addTargetValues(double& outputs[]) {
   // This will be based on strategy and also called dependant variables
   // get the various which will be applied to the OUTPUT these values
   // will are teh targets which we have to train to.
     // tack on output values at the end of the array
   // [row][in,in,in,in,etc,out,out,out,etc]
   for (int j=0; j<pb.dnnOut;j++) {
      dataFrame[rowCnt].Set(j+pb.dnnIn,outputs[j]);
      #ifdef _DEBUG_DATAFRAME
         ss=ss+" "+DoubleToString(dataFrame[rowCnt][j+pb.dnnIn],2);
      #endif
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::clearDataFrameValues() {

   for (int i=0;i<dataFrame.Size();i++) {
      for (int j=0;j<pb.dnnIn+pb.dnnOut;j++) {
         dataFrame[i].Set(j,0);
      }
   }

}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkForcast(double &inputs[], double &outputs[]) {

   #ifdef _DEBUG_DNN
      Print(__FUNCTION__);
      printf("Before network forcast:");
      ArrayPrint(inputs);
      ArrayPrint(outputs);
   #endif

   #ifdef _WRITELOG
      string ss, s1;
      commentLine;
      ss=StringFormat(" -> Forecast at:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      writeLog;
   #endif  

   no.MLPProcess(ps, inputs, outputs);    // Ask the network for a prediction

   #ifdef _WRITELOG
      s1=""; ss="In:";
      for (int i=0;i<ArraySize(inputs);i++) {
         s1=StringFormat("%0.5f",inputs[i]);
         ss=ss+":"+s1;
      }
      ss=ss+" Out:";
      for (int j=0;j<ArraySize(outputs);j++) {
         s1=StringFormat("%0.5f",outputs[j]);
         ss=ss+":"+s1;
      }
      writeLog;
   #endif

   /*
   showPanel {
      //mp.updateInfo2Label(21,"DDN Inputs:");
      for (int i=0;i<pb.dnnIn;i++) {
         ss=ss+" "+StringFormat("%0.2f",inputs[i]);
      }
      mp.updateInfo2Label(21,ss);
      ss="";
      //mp.updateInfo2Label(22,"DDN Outputs:");
      for (int j=0;j<pb.dnnOut;j++) {
         ss=ss+" "+StringFormat("%0.2f",outputs[j]);
      }
      mp.updateInfo2Label(22,ss);
   }
   */


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::trainNetwork(EADataFrame &df) {

   #ifdef _DEBUG_DNN
      Print(__FUNCTION__);
   #endif  

   #ifdef _WRITELOG
      datetime ts=TimeCurrent();
      string ss=StringFormat(" -> Started training network at:%s %s %s",TimeToString(ts,TIME_DATE),TimeToString(ts,TIME_MINUTES),TimeToString(ts,TIME_SECONDS));
      writeLog;
   #endif

   // first we need to create a NN which will be based on the number of inputs/ouputs used in the IO object, but we use the values of L1 and L2 coded in the DB
   // for this strategy, so the in/out values update the public struct and create the network
   n.nnIn=df.nnIn;
   n.nnOut=df.nnOut;
   createNewNetwork();

   CMLPReportShell repShell;
   datetime st, et;
   double decay=0.001;
   int restarts=2;
   double wStep=0.01;
   int maxITS=0;
   int retCode=0;
   int trainingError=0;
   int nPoints=df.dataFrame.Size();

   ResetLastError();
   st=TimeLocal();

   //no.MLPTrainLM(ps, dataFrame, nPoints, decay, restarts, retCode, repShell);
   no.MLPTrainLBFGS(ps,df.dataFrame,nPoints,decay,restarts,wStep,maxITS,retCode,repShell);
   if (retCode==2||retCode==6) {
      trainingError= no.MLPRMSError(ps, df.dataFrame, nPoints);
   }  else {
      printf("Training Response:%d",retCode);
   }
   

   #ifdef _WRITELOG
      et=TimeLocal();
      ss=StringFormat("# Gradient calculations:%d\n #Hessian calculations%d\n #Cholesky decompositions:%d\n Training error:%2.8f\n Restarts:%d\n Code Response:%d",
         repShell.GetNGrad(),repShell.GetNHess(),repShell.GetNCholesky(),DoubleToString(trainingError, 8),restarts,retCode );
      writeLog;
      ss=StringFormat(" -> End training network at:%s %s %s",TimeToString(et,TIME_DATE),TimeToString(et,TIME_MINUTES),TimeToString(et,TIME_SECONDS));
      writeLog;
   #endif

   isTrained=true;

   //saveNetwork();

}

