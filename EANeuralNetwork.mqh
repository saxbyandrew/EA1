//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#define _DEBUG_DNN
//#define _DEBUG_DATAFRAME

#include "EAEnum.mqh"
#include "EAModelBase.mqh"
#include <Math\Alglib\alglib.mqh>
#include <Arrays\ArrayDouble.mqh>

class EADataFrame;
clase EAInputsOutputs;

class EANeuralNetwork  {

//=========
private:
//=========

   void     networkProperties();
   void     createNewNetwork();
   bool     saveNetwork();
   bool     loadNetwork();
   //string   networkFileName();
   //void     saveNetworkToDisk();
   //void     loadNetworkFromDisk();

   
   

//=========
protected:
//=========
      CAlglib  no;
      CMultilayerPerceptronShell ps;

      struct NeuralNetwork {
         int strategyNumber;
         int fileNumber;
         int dnnNumber;
         EAEnum networkType;
         int numInput;
         int numHiddenLayer1;
         int numHiddenLayer2;
         int numOutput;
      } n;
      


//=========
public:
//=========
EANeuralNetwork(int dnnNumber, EAInputsOutputs &io);
~EANeuralNetwork();

   CArrayDouble   *nnArray;
   bool           isTrained;
   void           trainNetwork(EADataFrame &df);
   void           networkForcast(double &inputs[], double &outputs[]);

   //void     addTargetValues();


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::EANeuralNetwork(int dnnNumber, EAInputsOutputs &io) {

   #ifdef _DEBUG_DNN
      string ss;
      printf(" -> EANeuralNetwork Object Created ....");
   #endif

   string sql, fileName;
   int request, fileHandle, numInput, numOutput;

   isTrained=false;
   nnArray=new CArrayDouble;

   sql=StringFormat("SELECT * FROM NNETWORKS WHERE strategyNumber=%d AND dnnNumber=%d",usp.strategyNumber,dnnNumber);
   request=DatabasePrepare(_dbHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_DNN
         printf(" -> EANeuralNetwork DB query failed with code %d",GetLastError());
      #endif    
   }
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_DNN
         printf(" -> DB read failed with code %d",GetLastError());
      #endif   
   } else {
         DatabaseColumnInteger(request,0,n.strategyNumber);
         DatabaseColumnInteger(request,1,n.fileNumber);
         DatabaseColumnInteger(request,2,n.dnnNumber);
         DatabaseColumnInteger(request,3,n.networkType);
         DatabaseColumnInteger(request,4,n.numInput);
         DatabaseColumnInteger(request,5,n.numHiddenLayer1);
         DatabaseColumnInteger(request,6,n.numHiddenLayer2);
         DatabaseColumnInteger(request,7,n.numOutput);
         fileName=StringFormat("%s%s.bin",IntegerToString(n.strategyNumber),IntegerToString(n.fileNumber));
   }

   #ifdef _DEBUG_DNN
      printf(" -> EANeuralNetwork DB Read StrategyNumber:%d Inputs:%d Outputs:%d fileName:%s",n.strategyNumber,n.numInput,n.numOutput,fileName);
   #endif  

   // Check if the model has changed and we need to resize
   numInput=ArraySize(io.inputs);
   numOutput=ArraySize(io.outputs);
   if (numInput!=n.numInput || numOutput!=n.numOutput) {
      n.numInput=numInput;
      n.numOutput=numOutput;
      sql=StringFormat("UPDATE NNETWORKS SET numInput=%d, numOutput=%d WHERE strategyNumber=%d AND dnnNumber=%d",n.numInput,n.numOutput,usp.strategyNumber,dnnNumber);
      if (!DatabaseExecute(_dbHandle,sql)) {
         printf(sql);
         printf(" -> DB update request failed with code ", GetLastError());
      } else {
         #ifdef _DEBUG_DNN
            printf(" -> EANeuralNetwork DB updated and changed:%d Inputs:%d Outputs:%d ",n.numInput,n.numOutput);
         #endif 
      }
   }

   // Check which mode we are executing in
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {         // If we are optimizing there will be no nn??.bin file yet        
      return;                                      // A blank network which will be created and used once the DF has been created and will be trained
   } else {    
      #ifdef _DEBUG_DNN
         printf(" -> EANeuralNetwork attempt to open bin file ...");
      #endif                                     // Open the existing nn.bin
      if (fileHandle=FileOpen(fileName,FILE_READ|FILE_BIN|FILE_ANSI|FILE_COMMON)) {
         if (!nnArray.Load(fileHandle)) {
            #ifdef _DEBUG_DNN
               printf( " -> SUCCESS loaded file:%s",fileName);
            #endif
            // Now load and create the NN using the parameters previously stored the NN is auto created based on the 
            // values read in from the bin file.
            loadNetwork();

         } else {
            #ifdef _DEBUG_DNN
               printf( " -> ERROR loading file:%s -> %d",fileName, GetLastError());
            #endif
            ExpertRemove();
         }
      } else {
         #ifdef _DEBUG_DNN
            printf( " -> ERROR file:%s is missing -> %d",fileName, GetLastError());
         #endif
         ExpertRemove();
      }
   }





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

   #ifdef _DEBUG_DNN
      string ss= StringFormat(" -> Inputs:%d Layer 1:%d Layer 2:%d Outputs:%d Weights:%d ",nInputs,usp.dnnLayer1,usp.dnnLayer2,nOutputs,nWeights);
      printf(ss);
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::createNewNetwork()  {

   // TODO error checks

   switch (n.networkType) {
      case _NN_2: no.MLPCreateC2(n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,ps);
      break;
      case _NN_C2:no.MLPCreate2(n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,ps);
      break;
      case _NN_R2:no.MLPCreateR2(n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,0,1,ps);
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

   #ifdef _DEBUG_DNN
      string ss;
      ss=StringFormat(" -> Saving network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      printf(ss);
   #endif 

   bool savedNetwork= false;
   int k= 0, i= 0, j= 0, numLayers= 0, network[], nLayer1= 1, functionType= 0, binFileHandle;
   double threshold= 0, weights= 0, media= 0, sigma= 0;
   
   string nn[];

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

   string fileName;
   int fileHandle;

   fileName=StringFormat("%s%s.bin",IntegerToString(n.strategyNumber,n.fileNumber));
   // Now create it
   if (fileHandle=FileOpen(fileName,FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON)) {
      if (!nnArray.Save(fileHandle)) {
         #ifdef _DEBUG_DNN
            printf( " -> SUCCESS created file:%s",fileName);
         #endif
      } else {
         #ifdef _DEBUG_DNN
            printf( " -> ERROR saving file:%s -> %d",fileName, GetLastError());
         #endif
      }
   } else {
      #ifdef _DEBUG_DNN
         printf( " ->  ERROR creating file:%s-> %d",fileName, GetLastError());
      #endif
   }; 

   FileClose(fileHandle);

   return true;
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::loadNetwork() {

   #ifdef _DEBUG_DNN
      Print(__FUNCTION__);
   #endif

   #ifdef _DEBUG_DNN
      string ss;
      ss=StringFormat(" -> Loading network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      printf(ss);;
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

         for(k= 0; k<numLayers; k++) {
            for(i= 0; i<network[k]; i++) {
               if(k==0) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  //media= FileReadDouble(binFileHandle);
                  //sigma= FileReadDouble(binFileHandle);
                  #ifdef _DEBUG_DNN
                     printf("-> NetworkInputScaling idx:%d media:%2.2f sigma:%2.2f",i,media,sigma);
                  #endif
                  no.MLPSetInputScaling(ps, i, media, sigma);
               }
               else if(k==numLayers-1) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  //media= FileReadDouble(binFileHandle);
                  //sigma= FileReadDouble(binFileHandle);
                  #ifdef _DEBUG_DNN
                     printf("-> NetworkOutputScaling idx:%d media:%2.2f sigma:%2.2f",i,media,sigma);
                  #endif
                  no.MLPSetInputScaling(ps, i, media, sigma);
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
                  #ifdef _DEBUG_DNN
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

   #ifdef _DEBUG_DNN
      string ss, s1;
      ss=StringFormat(" -> Forecast at:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      printf(ss);
   #endif  

   no.MLPProcess(ps, inputs, outputs);    // Ask the network for a prediction

   #ifdef _DEBUG_DNN
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
      printf(ss);
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

   #ifdef _DEBUG_DNN
      datetime ts=TimeCurrent();
      string ss=StringFormat(" -> Started training network at:%s %s %s",TimeToString(ts,TIME_DATE),TimeToString(ts,TIME_MINUTES),TimeToString(ts,TIME_SECONDS));
      printf(ss);
   #endif

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
   

   #ifdef _DEBUG_DNN
      et=TimeLocal();
      ss=StringFormat("# Gradient calculations:%d\n #Hessian calculations%d\n #Cholesky decompositions:%d\n Training error:%2.8f\n Restarts:%d\n Code Response:%d",
         repShell.GetNGrad(),repShell.GetNHess(),repShell.GetNCholesky(),DoubleToString(trainingError, 8),restarts,retCode );
      printf(ss);
      ss=StringFormat(" -> End training network at:%s %s %s",TimeToString(et,TIME_DATE),TimeToString(et,TIME_MINUTES),TimeToString(et,TIME_SECONDS));
      printf(ss);
   #endif

   isTrained=true;

   if (MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {
   
      if (saveNetwork()) {
         #ifdef _DEBUG_DNN
            printf(" -> Nework saved success");
         #endif
      } else {
         #ifdef _DEBUG_DNN
            printf(" -> Nework saved error");
         #endif
      }
   }  

}

