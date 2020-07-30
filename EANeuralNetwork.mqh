//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"





#include "EAEnum.mqh"
#include "EAModelBase.mqh"
#include <Math\Alglib\alglib.mqh>
#include <Arrays\ArrayDouble.mqh>

class EADataFrame;
class EAInputsOutputs;

class EANeuralNetwork  {

//=========
private:
//=========
   string   ss;
   void     networkProperties();
   void     createNewNetwork();
   bool     saveNetwork();
   bool     loadNetwork();
   CAlglib  *no;
   CMultilayerPerceptronShell *ps;

//=========
protected:
//=========


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
   bool           isTrained, createNewDataFrame;
   void           trainNetwork(EADataFrame &df);
   void           networkForcast(double &inputs[], double &outputs[]);


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::EANeuralNetwork(int dnnNumber, EAInputsOutputs &io) {

   #ifdef _DEBUG_DNN
      ss="EANeuralNetwork -> Object Created ....";
      writeLog
      printf(ss);
   #endif

   string sql, fileName;
   int request, fileHandle, numInput, numOutput;

   isTrained=false;
   nnArray=new CArrayDouble;

   sql=StringFormat("SELECT * FROM NNETWORKS WHERE strategyNumber=%d AND dnnNumber=%d",usp.strategyNumber,dnnNumber);
   request=DatabasePrepare(_mainDBHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_DNN
         ss=StringFormat("EANeuralNetwork ->  DB query failed with code %d",GetLastError());
         writeLog
         printf(ss);
      #endif    
   }
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_DNN
         ss=StringFormat("EANeuralNetwork -> DB read failed with code %d",GetLastError());
         writeLog
         printf(ss);
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
      ss=StringFormat("EANeuralNetwork -> DB Read StrategyNumber:%d I:%d L1:%d L2:%d O:%d fileName:%s",n.strategyNumber,n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,fileName);
      writeLog
      printf(ss);
   #endif  

   // Check if the model has changed and we need to resize
   numInput=ArraySize(io.inputs);
   numOutput=ArraySize(io.outputs);
   if (numInput!=n.numInput || numOutput!=n.numOutput) {
      n.numInput=numInput;
      n.numOutput=numOutput;
      sql=StringFormat("UPDATE NNETWORKS SET numInput=%d, numOutput=%d WHERE strategyNumber=%d AND dnnNumber=%d",n.numInput,n.numOutput,usp.strategyNumber,dnnNumber);
      if (!DatabaseExecute(_mainDBHandle,sql)) { 
         ss=sql;
         #ifdef _DEBUG_DNN
            writeLog
         #endif
         printf(ss);
         ss=StringFormat("EANeuralNetwork -> DB update request failed with code ", GetLastError());
         #ifdef _DEBUG_DNN 
            writeLog
         #endif
         printf(ss);
      } else {
         #ifdef _DEBUG_DNN
            ss=StringFormat("EANeuralNetwork ->  DB updated and changed Inputs:%d Outputs:%d ",n.numInput,n.numOutput);
            writeLog
            printf(ss);
         #endif 
      }
   }

   // Check which mode we are executing in
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {         // If we are optimizing there will be no nn??.bin file yet or a old one may exist 
      createNewDataFrame=true;                     // In optimization we always create a new DF to then train against      
      return;                                      // A blank network which will be created and used once the DF has been created and will be trained
   } else { 

      if (FileIsExist(fileName,FILE_COMMON)) {
         ss="*****************************************************************";
         printf(ss);   
         ss="* EANeuralNetwork ->  attempting to open a bin file ...         *";
         printf(ss);
         ss="* Remove the existing .bin file to force a new NN to be created *";
         printf(ss);
         ss="*****************************************************************";
         printf(ss);
         if (fileHandle=FileOpen(fileName,FILE_READ|FILE_BIN|FILE_ANSI|FILE_COMMON)) {  // Open the existing nn.bin
            if (nnArray.Load(fileHandle)) {
               ss=StringFormat("EANeuralNetwork -> SUCCESS loaded from file:%s",fileName);
               printf(ss);
               loadNetwork();
               createNewDataFrame=false;
            } else {
               ss=StringFormat("EANeuralNetwork -> ERROR loading file:%s -> %d",fileName, GetLastError());
               printf(ss);
               ExpertRemove();
            }
         } else {
            ss=StringFormat("EANeuralNetwork -> ERROR file:%s is missing -> %d",fileName, GetLastError());
            printf(ss);
            ExpertRemove();
         }
      } else {
         ss=StringFormat("EANeuralNetwork -> File %s does not exist yet, should be created after nn training",fileName);
         printf(ss);
      }
   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::~EANeuralNetwork() {

   delete nnArray;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkProperties()  {


   int nInputs=0, nOutputs= 0, nWeights= 0;
   no.MLPProperties(ps, nInputs, nOutputs, nWeights);

   /*
   showPanel {
      string s1=StringFormat("I:%d L1:%d L2:%d O:%d W:%d",nInputs,pb.dnnLayer1,pb.dnnLayer2,nOutputs,nWeights);
      mp.updateInfo2Label(20,s1);
   }
   */

   ss=StringFormat("networkProperties -> I:%d L1:%d L2:%d O:%d W:%d ",nInputs,n.numHiddenLayer1,n.numHiddenLayer2,nOutputs,nWeights);
   printf(ss);


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::createNewNetwork()  {


   if (no==NULL || ps==NULL) {
      no=new CAlglib();
      if (CheckPointer(no)==POINTER_INVALID) {
            ss="EANeuralNetwork -> ERROR created Network object";
            #ifdef _DEBUG_DNN
               writeLog
            #endif
         printf(ss);
         ExpertRemove();
      } else {
         ss="EANeuralNetwork -> SUCCESS created Network object";
         #ifdef _DEBUG_DNN
            writeLog
            printf(ss);
         #endif
      }

      ps=new CMultilayerPerceptronShell();
      if (CheckPointer(ps)==POINTER_INVALID) {
         ss="EANeuralNetwork -> ERROR created MultilayerPerceptronShell object";
            #ifdef _DEBUG_DNN
               writeLog
            #endif
         printf(ss);
         ExpertRemove();
      } else {
         ss="EANeuralNetwork -> SUCCESS created MultilayerPerceptronShell object";
         #ifdef _DEBUG_DNN
            writeLog
            printf(ss);
         #endif
      }

      switch (n.networkType) {
         case _NN_2: no.MLPCreateC2(n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,ps);
         break;
         case _NN_C2:no.MLPCreate2(n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,ps);
         break;
         case _NN_R2:no.MLPCreateR2(n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,0,1,ps);
         break;
      }
      ss="EANeuralNetwork -> Created Network and Shell";
      printf(ss);
      networkProperties();
   } else {
      ss="EANeuralNetwork -> Network and Shell already exists";
      printf(ss);
      networkProperties();
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::saveNetwork() {


   #ifdef _DEBUG_DNN
      ss=StringFormat("saveNetwork -> Saving network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      writeLog
      printf(ss);
   #endif 

   int k=0, i=0, j=0, numLayers=0, network[], nLayer1=1, functionType=0, fileHandle;
   double threshold=0, weights=0, media=0, sigma=0;
   string fileName;


      numLayers= no.MLPGetLayersCount(ps);
      nnArray.Add(numLayers);                                                                                                                              

      ArrayResize(network, numLayers);

      for(k= 0; k<numLayers; k++) {
         network[k]= no.MLPGetLayerSize(ps, k);
         nnArray.Add(network[k]);                                                           
      }

      for(k= 0; k<numLayers; k++) {
         for(i= 0; i<network[k]; i++) {
            if(k==0) {
               no.MLPGetInputScaling(ps, i, media, sigma);
               nnArray.Add(media);                                                          
               nnArray.Add(sigma); 
               #ifdef _DEBUG_DNN
                  ss=StringFormat("MLPGetInputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  printf(ss);
               #endif 
            } else if (k==numLayers-1) {
               no.MLPGetOutputScaling(ps, i, media, sigma);
               nnArray.Add(media);                                                          
               nnArray.Add(sigma);
               #ifdef _DEBUG_DNN
                  ss=StringFormat("MLPGetOutputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  printf(ss);
               #endif                                                           
            }
            no.MLPGetNeuronInfo(ps, k, i, functionType, threshold);
            nnArray.Add(functionType);                                                      
            nnArray.Add(threshold); 
            #ifdef _DEBUG_DNN
               ss=StringFormat("MLPGetNeuronInfo -> functionType -> %.5f -- threshold -> %.5f ",functionType,threshold);
               writeLog
               printf(ss);
            #endif                                                         

            for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
               weights= no.MLPGetWeight(ps, k, i, k+1, j);
               nnArray.Add(weights);  
               #ifdef _DEBUG_DNN
                  ss=StringFormat("MLPGetWeight -> weight -> %.5f ",weights);
                  writeLog
                  printf(ss);
               #endif                                                      
            }
         }      
      }

   #ifdef _DEBUG_DNN
      for (int i=0;i<nnArray.Total();i++) {
         ss=StringFormat(" -> idx:%d Val:%.5f ",i,nnArray.At(i));
         writeLog
         printf(ss);
      }
   #endif

   fileName=StringFormat("%s%s.bin",IntegerToString(n.strategyNumber),IntegerToString(n.fileNumber));
   // Now create it
   if (fileHandle=FileOpen(fileName,FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON)) {
      if (nnArray.Save(fileHandle)) {
         #ifdef _DEBUG_DNN
            ss=StringFormat("saveNetwork -> SUCCESS created file:%s",fileName);
            writeLog
            printf(ss);
         #endif
      } else {
         #ifdef _DEBUG_DNN
            ss=StringFormat("saveNetwork -> ERROR saving file:%s -> %d",fileName, GetLastError());
            writeLog
            printf(ss);
         #endif
      }
   } else {
      #ifdef _DEBUG_DNN
         ss=StringFormat("saveNetwork -> ERROR creating file:%s-> %d",fileName, GetLastError());
         writeLog
         printf(ss);
      #endif
   }; 

   FileClose(fileHandle);

   return true;
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::loadNetwork() {


   int k=0, i=0, j=0, idx=0, numLayers=0, network[], functionType=0;
   double threshold=0, weights=0, media=0, sigma=0;

      numLayers=nnArray.At(idx++);
      ArrayResize(network, numLayers);
      for(k= 0; k<numLayers; k++) network[k]= (int)nnArray.At(idx++); 
      createNewNetwork();

         for(k= 0; k<numLayers; k++) {
            for(i= 0; i<network[k]; i++) {
               if(k==0) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  #ifdef _DEBUG_DNN
                     ss=StringFormat("-> NetworkInputScaling Layers:%d idx:%d media:%2.2f sigma:%2.2f",k,i,media,sigma);
                     writeLog
                     printf(ss);
                  #endif
                  no.MLPSetInputScaling(ps, i, media, sigma);
               }
               else if(k==numLayers-1) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  #ifdef _DEBUG_DNN
                     ss=StringFormat("-> NetworkOutputScaling idx:%d media:%2.2f sigma:%2.2f",i,media,sigma);
                     writeLog
                     printf(ss);
                  #endif
                  no.MLPSetInputScaling(ps, i, media, sigma);
                  no.MLPSetOutputScaling(ps, i, media, sigma);
               }
               functionType= (int)nnArray.At(idx++);
               threshold= nnArray.At(idx++);
               no.MLPSetNeuronInfo(ps, k, i, functionType, threshold);
               for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
                  weights= nnArray.At(idx++);
                  #ifdef _DEBUG_DNN
                     ss=StringFormat("-> Loading weight:%2.5f",weights);
                     writeLog
                     printf(ss);
                  #endif 
                  no.MLPSetWeight(ps, k, i, k+1, j, weights);
               }
            }      
         }
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkForcast(double &inputs[], double &outputs[]) {

   #ifdef _DEBUG_DNN
      string s1;
   #endif


   no.MLPProcess(ps, inputs, outputs);    // Ask the network for a prediction

   #ifdef _DEBUG_DNN
      s1=""; ss="networkForcast -> In:";
      for (int i=0;i<ArraySize(inputs);i++) {
         s1=StringFormat("%0.5f",inputs[i]);
         ss=ss+":"+s1;
      }
      printf(ss);
      writeLog
      ss="networkForcast -> Out:";
      for (int j=0;j<ArraySize(outputs);j++) {
         s1=StringFormat("%0.5f",outputs[j]);
         ss=ss+":"+s1;
      }
      printf(ss);
      writeLog
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
      datetime ts=TimeCurrent();
      ss="trainNetwork -> ...";
      writeLog
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

//TODO
   //no.MLPTrainLM(ps, dataFrame, nPoints, decay, restarts, retCode, repShell);
   no.MLPTrainLBFGS(ps,df.dataFrame,nPoints,decay,restarts,wStep,maxITS,retCode,repShell);
   if (retCode==2||retCode==6) {
      trainingError= no.MLPRMSError(ps, df.dataFrame, nPoints);
   }  else {
      printf("Training Response:%d",retCode);
   }
   

   #ifdef _DEBUG_DNN
      et=TimeLocal();
      ss=StringFormat("#Gradient calculations:%d\n #Hessian calculations%d\n #Cholesky decompositions:%d\n Training error:%2.8f\n Restarts:%d\n Code Response:%d",
         repShell.GetNGrad(),repShell.GetNHess(),repShell.GetNCholesky(),DoubleToString(trainingError, 8),restarts,retCode );
         writeLog
         printf(ss);
   #endif

   isTrained=true;

   if (MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {
      #ifdef _DEBUG_DNN
         ss=" -> In MQL_VISUAL_MODE or MQL_TESTER so save the trained network";
         writeLog
         printf(ss);
      #endif
      if (saveNetwork()) {
         #ifdef _DEBUG_DNN
            ss=" -> Nework saved success";
            writeLog
            printf(ss);
         #endif
      } else {
         #ifdef _DEBUG_DNN
            ss=" -> Nework saved error";
            writeLog
            printf(ss);
         #endif
         ExpertRemove();
      }
   }  
}

