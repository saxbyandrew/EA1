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

class EAInputsOutputs;

class EANeuralNetwork  {

//=========
private:
//=========
   struct NeuralNetwork {
      int strategyNumber;
      int typeReference;
      int fileNumber;
      EAEnum networkType;
      int numInput;
      int numHiddenLayer1;
      int numHiddenLayer2;
      int numOutput;
      string optimizationStart;
      int dfSize;
      // not in database
      string fileName;
   } n;


   string   ss;
   string   optimizationStartTime;
   void     networkProperties();
   void     createNewNetwork();
   bool     saveNetwork();
   bool     loadNetwork();
   void     loadNetwork(int typeReference, EAInputsOutputs &io);
   void     trainNetwork();

   CAlglib  *no;
   CMultilayerPerceptronShell *ps;
   CMatrixDouble  dataFrame;

//=========
protected:
//=========
      
   void     setDataFrameSize(int x, int y) {dataFrame.Resize(x,y); };
   void     addDataFrameValues(double &inputs[], double &outputs[]);

//=========
public:
//=========
EANeuralNetwork(int typeReference, EAInputsOutputs &io);
~EANeuralNetwork();

   CArrayDouble   *nnArray;
   bool           isTrained, rebuild_DataFrame;

   void     networkForcast(double &inputs[], double &outputs[]);
   void     buildDataFrame(EAInputsOutputs &io);



};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::EANeuralNetwork(int typeReference, EAInputsOutputs &io) {

   #ifdef _DEBUG_NN
      ss="EANeuralNetwork -> Object Created ....";
      writeLog
      pss
   #endif
   
   int fileHandle;


   // Load the size parameters for this NN
   loadNetwork(typeReference,io);

   // OPTIMIZATION MODE
   // Check which mode we are executing in
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {                                    // If we are optimizing there will be no nn??.bin file yet or a old one may exist 
      #ifdef _DEBUG_NN
         string ss=StringFormat("OnTesterInit -> .... starting on:%s",optimizationStartTime);
         pss
         writeLog
      #endif
      return;                                                                 // A blank network which will be created and used once the DF has been created and will be trained
   }  

   // NORMAL RUN MODE
   if (FileIsExist(n.fileName,FILE_COMMON)) {
      ss="*****************************************************************";
      pss   
      ss=StringFormat("* EANeuralNetwork ->  attempting to open a existing bin file ... %s",n.fileName);
      pss
      ss="*****************************************************************";
      pss
      if (fileHandle=FileOpen(n.fileName,FILE_READ|FILE_BIN|FILE_ANSI|FILE_COMMON)) {  // Open the existing nn.bin
         if (nnArray.Load(fileHandle)) {
            ss=StringFormat("EANeuralNetwork -> SUCCESS loaded from file:%s",n.fileName);
            pss
            loadNetwork();
            
         } else {
            ss=StringFormat("EANeuralNetwork -> ERROR loading file:%s -> %d",n.fileName, GetLastError());
            pss
            ExpertRemove();
         }
      } else {
         ss=StringFormat("EANeuralNetwork -> ERROR file:%s is missing -> %d",n.fileName, GetLastError());
         pss
         ExpertRemove();
      }
   } else {
      ss=StringFormat("EANeuralNetwork -> File %s does not exist yet, needs be created ",n.fileName);
      pss
      // Entry here should happen on after a refresh on optimization before a flat file for the
      // networks exists
      // This have been moved into the on bar section as for some reason if called from here 
      // all values returned are EMPTYVALUES
      //buildDataFrame(io);
      //rebuild_DataFrame=true;
      
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
void EANeuralNetwork::addDataFrameValues(double &inputs[], double& outputs[]) {

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
void EANeuralNetwork::buildDataFrame(EAInputsOutputs &io) {

   static int barCnt=n.dfSize;

   #ifdef _DEBUG_NN  
      string ss;
      ss=StringFormat(" buildDataFrame -> with barCnt:%d",barCnt);
      writeLog
      pss
   #endif

   // Grab the number of frame as specified in the nn.dfSize
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {  
      if (barCnt>0) {
         // Add a frame
         io.getInputs(1);
         io.getOutputs(1);
         addDataFrameValues(io.inputs,io.outputs); 
         barCnt--;
         return;  
      }  
      // All frames have been added now train the new network
      #ifdef _DEBUG_NN  
         ss="************** training network in optimization mode";
         writeLog
         pss
         #endif
      trainNetwork();
      return;
   } 

   
   while (barCnt>0) {
      #ifdef _DEBUG_NN  
         ss=StringFormat(" buildDataFrame -> with bar:%d",barCnt);
         writeLog
         pss
      #endif
      io.getInputs(barCnt);
      io.getOutputs(barCnt);
      addDataFrameValues(io.inputs,io.outputs); 
      barCnt--;
   }
   // Data frame created on bars specified in the last optimization run
   // start date
   trainNetwork(); // Train and Save the network
   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::loadNetwork(int typeReference, EAInputsOutputs &io) {

   string sql;
   int request, fileHandle, numInput, numOutput;

   sql=StringFormat("SELECT * FROM NNETWORKS WHERE strategyNumber=%d AND typeReference=%d",usp.strategyNumber,typeReference);
   request=DatabasePrepare(_mainDBHandle,sql);
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_NN
         ss=StringFormat("EANeuralNetwork ->  DB query failed with code %d",GetLastError());
         writeLog
         pss
      #endif    
   }
   #ifdef _DEBUG_NN
      ss=StringFormat("EANeuralNetwork ->  %s",sql);
      pss
      writeLog
   #endif 
   if (!DatabaseRead(request)) {
      #ifdef _DEBUG_NN
         ss=StringFormat("EANeuralNetwork -> DB read failed with code %d",GetLastError());
         writeLog
         pss
      #endif   
   } else {
         DatabaseColumnInteger(request,0,n.strategyNumber);
         DatabaseColumnInteger(request,1,n.typeReference);
         DatabaseColumnInteger(request,2,n.fileNumber);
         DatabaseColumnInteger(request,3,n.networkType);
         DatabaseColumnInteger(request,4,n.numInput);
         DatabaseColumnInteger(request,5,n.numHiddenLayer1);
         DatabaseColumnInteger(request,6,n.numHiddenLayer2);
         DatabaseColumnInteger(request,7,n.numOutput);
         DatabaseColumnText   (request,8,n.optimizationStart);
         DatabaseColumnInteger(request,9,n.dfSize);
         n.fileName=StringFormat("%s%s.bin",IntegerToString(n.strategyNumber),IntegerToString(n.fileNumber));
   }

   #ifdef _DEBUG_NN
      ss=StringFormat("EANeuralNetwork -> DB Read StrategyNumber:%d I:%d L1:%d L2:%d O:%d fileName:%s",n.strategyNumber,n.numInput,n.numHiddenLayer1,n.numHiddenLayer2,n.numOutput,n.fileName);
      writeLog
      pss
   #endif  

   // Check if the model has changed and we need to resize
   numInput=ArraySize(io.inputs);
   numOutput=ArraySize(io.outputs);
   if (numInput!=n.numInput || numOutput!=n.numOutput) {
      n.numInput=numInput;
      n.numOutput=numOutput;
      sql=StringFormat("UPDATE NNETWORKS SET numInput=%d, numOutput=%d WHERE strategyNumber=%d AND typeReference=%d",n.numInput,n.numOutput,usp.strategyNumber,typeReference);
      if (!DatabaseExecute(_mainDBHandle,sql)) { 
         ss=sql;
         #ifdef _DEBUG_NN
            writeLog
         #endif
         pss
         ss=StringFormat("EANeuralNetwork -> DB update request failed with code ", GetLastError());
         #ifdef _DEBUG_NN 
            writeLog
         #endif
         pss
      } else {
         #ifdef _DEBUG_NN
            ss=StringFormat("EANeuralNetwork ->  DB updated and changed Inputs:%d Outputs:%d ",n.numInput,n.numOutput);
            writeLog
            pss
         #endif 
      }
   }

   // Create a DF based on new or loaded values
   dataFrame.Resize(n.dfSize,numInput+numOutput); 

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkProperties()  {


   int nInputs=0, nOutputs= 0, nWeights= 0;
   no.MLPProperties(ps, nInputs, nOutputs, nWeights);

   
   showPanel {
      string s1=StringFormat("I:%d L1:%d L2:%d O:%d W:%d",nInputs,n.numHiddenLayer1,n.numHiddenLayer2,nOutputs,nWeights);
      ip.updateInfo2Label(20,s1);
   }
   

   ss=StringFormat("networkProperties -> I:%d L1:%d L2:%d O:%d W:%d ",nInputs,n.numHiddenLayer1,n.numHiddenLayer2,nOutputs,nWeights);
   pss


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::createNewNetwork()  {


   if (no==NULL || ps==NULL) {
      no=new CAlglib();
      if (CheckPointer(no)==POINTER_INVALID) {
            ss="EANeuralNetwork -> ERROR created Network object";
            #ifdef _DEBUG_NN
               writeLog
            #endif
         pss
         ExpertRemove();
      } else {
         ss="EANeuralNetwork -> SUCCESS created Network object";
         #ifdef _DEBUG_NN
            writeLog
            pss
         #endif
      }

      ps=new CMultilayerPerceptronShell();
      if (CheckPointer(ps)==POINTER_INVALID) {
         ss="EANeuralNetwork -> ERROR created MultilayerPerceptronShell object";
            #ifdef _DEBUG_NN
               writeLog
            #endif
         pss
         ExpertRemove();
      } else {
         ss="EANeuralNetwork -> SUCCESS created MultilayerPerceptronShell object";
         #ifdef _DEBUG_NN
            writeLog
            pss
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
      pss
      networkProperties();
   } else {
      ss="EANeuralNetwork -> Network and Shell already exists";
      pss
      networkProperties();
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::saveNetwork() {


   #ifdef _DEBUG_NN
      ss=StringFormat("saveNetwork -> Saving network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      writeLog
      pss
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
               #ifdef _DEBUG_NN
                  ss=StringFormat("MLPGetInputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  pss
               #endif 
            } else if (k==numLayers-1) {
               no.MLPGetOutputScaling(ps, i, media, sigma);
               nnArray.Add(media);                                                          
               nnArray.Add(sigma);
               #ifdef _DEBUG_NN
                  ss=StringFormat("MLPGetOutputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  pss
               #endif                                                           
            }
            no.MLPGetNeuronInfo(ps, k, i, functionType, threshold);
            nnArray.Add(functionType);                                                      
            nnArray.Add(threshold); 
            #ifdef _DEBUG_NN
               ss=StringFormat("MLPGetNeuronInfo -> functionType -> %.5f -- threshold -> %.5f ",functionType,threshold);
               writeLog
               pss
            #endif                                                         

            for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
               weights= no.MLPGetWeight(ps, k, i, k+1, j);
               nnArray.Add(weights);  
               #ifdef _DEBUG_NN
                  ss=StringFormat("MLPGetWeight -> weight -> %.5f ",weights);
                  writeLog
                  pss
               #endif                                                      
            }
         }      
      }

   #ifdef _DEBUG_NN
      for (int i=0;i<nnArray.Total();i++) {
         ss=StringFormat(" -> idx:%d Val:%.5f ",i,nnArray.At(i));
         writeLog
         pss
      }
   #endif

   fileName=StringFormat("%s%s.bin",IntegerToString(n.strategyNumber),IntegerToString(n.fileNumber));
   // Now create it
   if (fileHandle=FileOpen(fileName,FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON)) {
      if (nnArray.Save(fileHandle)) {
         #ifdef _DEBUG_NN
            ss=StringFormat("saveNetwork -> SUCCESS created file:%s",fileName);
            writeLog
            pss
         #endif
      } else {
         #ifdef _DEBUG_NN
            ss=StringFormat("saveNetwork -> ERROR saving file:%s -> %d",fileName, GetLastError());
            writeLog
            pss
         #endif
      }
   } else {
      #ifdef _DEBUG_NN
         ss=StringFormat("saveNetwork -> ERROR creating file:%s-> %d",fileName, GetLastError());
         writeLog
         pss
      #endif
   }; 

   FileClose(fileHandle);

   return true;
} 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::loadNetwork() {

   #ifdef _DEBUG_NN
      ss="loadNetwork -> ";
      pss
      writeLog
   #endif


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
                  #ifdef _DEBUG_NN
                     ss=StringFormat("loadNetwork -> NetworkInputScaling Layers:%d idx:%d media:%2.2f sigma:%2.2f",k,i,media,sigma);
                     writeLog
                     pss
                  #endif
                  no.MLPSetInputScaling(ps, i, media, sigma);
               }
               else if(k==numLayers-1) {
                  media= nnArray.At(idx++);
                  sigma= nnArray.At(idx++);
                  #ifdef _DEBUG_NN
                     ss=StringFormat("loadNetwork -> NetworkOutputScaling idx:%d media:%2.2f sigma:%2.2f",i,media,sigma);
                     writeLog
                     pss
                  #endif
                  no.MLPSetInputScaling(ps, i, media, sigma);
                  no.MLPSetOutputScaling(ps, i, media, sigma);
               }
               functionType= (int)nnArray.At(idx++);
               threshold= nnArray.At(idx++);
               no.MLPSetNeuronInfo(ps, k, i, functionType, threshold);
               for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
                  weights= nnArray.At(idx++);
                  #ifdef _DEBUG_NN
                     ss=StringFormat("loadNetwork -> Loading weight:%2.5f",weights);
                     writeLog
                     pss
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

   #ifdef _DEBUG_NN
      string s1;
   #endif


   no.MLPProcess(ps, inputs, outputs);    // Ask the network for a prediction

   #ifdef _DEBUG_NN
      s1=""; ss="networkForcast -> In:";
      for (int i=0;i<ArraySize(inputs);i++) {
         s1=StringFormat("%0.5f",inputs[i]);
         ss=ss+":"+s1;
      }
      pss
      writeLog
      ss="networkForcast -> Out:";
      for (int j=0;j<ArraySize(outputs);j++) {
         s1=StringFormat("%0.5f",outputs[j]);
         ss=ss+":"+s1;
      }
      pss
      writeLog
   #endif

   showPanel {
      for (int i=0;i<n.numInput;i++) {
         ss=ss+" "+StringFormat("%0.2f",inputs[i]);
      }
      ip.updateInfo2Label(21,ss);
      ss="";
      for (int j=0;j<n.numOutput;j++) {
         ss=ss+" "+StringFormat("%0.2f",outputs[j]);
      }
      ip.updateInfo2Label(22,ss);
   }
   


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::trainNetwork() {

   #ifdef _DEBUG_NN
      datetime ts=TimeCurrent();
      ss="trainNetwork -> ...";
      writeLog
      pss
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
   int nPoints=dataFrame.Size();

   ResetLastError();
   st=TimeLocal();

//TODO
   //no.MLPTrainLM(ps, dataFrame, nPoints, decay, restarts, retCode, repShell);
   no.MLPTrainLBFGS(ps,dataFrame,nPoints,decay,restarts,wStep,maxITS,retCode,repShell);
   if (retCode==2||retCode==6) {
      trainingError= no.MLPRMSError(ps, dataFrame, nPoints);
   }  else {
      printf("Training Response:%d",retCode);
   }
   

   #ifdef _DEBUG_NN
      et=TimeLocal();
      ss=StringFormat("#Gradient calculations:%d\n #Hessian calculations%d\n #Cholesky decompositions:%d\n Training error:%2.8f\n Restarts:%d\n Code Response:%d",
         repShell.GetNGrad(),repShell.GetNHess(),repShell.GetNCholesky(),DoubleToString(trainingError, 8),restarts,retCode );
         writeLog
         pss
   #endif

   isTrained=true;

   // if we are in optimization mode we don't need to save the trained network as
   // each iteratoin will be different based on different IO inputs. Only after a choosen set
   // of inputs can we save a network for continued use as the IO input will have constant values
   if (MQLInfoInteger(MQL_OPTIMIZATION)) return;

   if (MQLInfoInteger(MQL_VISUAL_MODE) || MQLInfoInteger(MQL_TESTER)) {
      #ifdef _DEBUG_NN
         ss=" -> In MQL_VISUAL_MODE or MQL_TESTER so save the trained network";
         writeLog
         pss
      #endif
      if (saveNetwork()) {
         #ifdef _DEBUG_NN
            ss=" -> Nework saved success";
            writeLog
            pss
         #endif
      } else {
         #ifdef _DEBUG_NN
            ss=" -> Nework saved error";
            writeLog
            pss
         #endif
         ExpertRemove();
      }
   }  
}

