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


class EANeuralNetwork  {

//=========
private:
//=========

   string   ss;
   
   void     networkProperties();
   void     createNewNetwork();
   bool     saveNetwork();
   void     loadNetwork();
   void     copyValuesFromDatabase(int strategyNumber);
   void     copyValuesFromOptimizationInputs();
   void     trainNetwork();

   CAlglib  *no;
   CMultilayerPerceptronShell *ps;
   CMatrixDouble  dataFrame;
   double inputs[];


//=========
protected:
//=========
      
   Network nnetwork;

//=========
public:
//=========
EANeuralNetwork(int strategyNumber);
~EANeuralNetwork();

   CArrayDouble   *nnStore;
   datetime getOptimizationStartDateTime();
   int      getDataFrameSize() {return nnetwork.dfSize;};
   void     setDataFrameArraySizes(int nnIn, int nnOut);
   EAEnum   networkForcast(CArrayDouble &nnIn, CArrayDouble &nnOut, double &prediction[]);
   void     buildDataFrame(CArrayDouble &nnIn, CArrayDouble &nnOut);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::EANeuralNetwork(int strategyNumber) {

   #ifdef _DEBUG_NN
      ss=StringFormat("EANeuralNetwork -> Constructor strategyNumber:%d ....",strategyNumber);
      writeLog
      pss
   #endif

   nnStore=new CArrayDouble;
   if (CheckPointer(nnStore)==POINTER_INVALID) {
      printf("EANeuralNetwork -> Error creating nnStore");
      ExpertRemove();
   }

   // Load the property parameters for this NN regardless of runmode
   copyValuesFromDatabase(strategyNumber);

   // OPTIMIZATION MODE
   // Check which mode we are executing in
   if (_runMode==_RUN_OPTIMIZATION) {                                    // If we are optimizing there will be no nn??.bin file yet or a old one may exist 
      #ifdef _DEBUG_NN
         string ss=StringFormat("EANeuralNetwork -> .... starting time:%s",TimeToString(SeriesInfoInteger(Symbol(),Period(),SERIES_SERVER_FIRSTDATE)));
         writeLog
      #endif
      return;                                                                 // A blank network which will be created and used once the DF has been created and will be trained
   }  

   // Entry at this point can occur in 1 or 2 ways
   // 1 first time after optimization where the .bin file does not exist the DF will need to be 
   // created and the network trained using parameters choosen after optimization
   // 2 every other time the EA is started where the existing .bin file will be reread
   // NORMAL RUN MODE
   
   loadNetwork();
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EANeuralNetwork::~EANeuralNetwork() {

   delete nnStore;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::setDataFrameArraySizes(int nnIn, int nnOut) {

   nnetwork.numInput=nnIn;
   nnetwork.numOutput=nnOut;

   // Change the dataFrame size based on the iputs and outputs
   dataFrame.Resize(nnetwork.dfSize,nnetwork.numInput+nnetwork.numOutput);

   // Change the double [] used for networkforcasts
   ArrayResize(inputs,nnetwork.numInput);


   #ifdef _DEBUG_DATAFRAME  
      ss=StringFormat("EANeuralNetwork -> setDataFrameArraySizes -> inputs[]:%d ",ArraySize(inputs));
      writeLog
      pss
   #endif 

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime EANeuralNetwork::getOptimizationStartDateTime() {

   MqlDateTime osdt; // optimization Start Date and Time

   osdt.year=nnetwork.year;
   osdt.mon=nnetwork.month;
   osdt.day=nnetwork.day;
   osdt.hour=nnetwork.hour;
   osdt.min=nnetwork.minute;

   return (StructToTime(osdt));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::buildDataFrame(CArrayDouble &nnIn, CArrayDouble &nnOut) {

   static int csvFileHandle;
   static int rowCnt=0;
   static int barCnt=nnetwork.dfSize;
   string csvFileName, csvString;
   
   datetime barTime;

   #ifdef _DEBUG_DATAFRAME  
      pline
      ss=StringFormat("EANeuralNetwork -> buildDataFrame -> with barCnt:%d",barCnt);
      writeLog
      pss
      pline
   #endif

   #ifdef _DEBUG_WRITE_CSV
      // Create a single line for the CSV file
      if (nnetwork.csvWriteDF) {
         if (csvFileHandle==NULL) {
            csvFileName=StringFormat("%s%s.csv",IntegerToString(nnetwork.strategyNumber),IntegerToString(nnetwork.fileNumber));
            csvFileHandle=FileOpen(csvFileName,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
         }
         csvString=TimeToString(iTime(_Symbol,PERIOD_CURRENT,1))+",";
         csvString=csvString+rowCnt+",";
      }
   #endif


   // MQL_OPTIMIZATION _RUN_BUILD_DATAFRAME Grab the number of frame as specified in the nn.dfSize
   // get the current bar in optimization mode calc the inputs and outputs
   // // add to the DF line by line till we have dfSize lines
   // train the network
   if (barCnt>1) {
      // Insert input values
      // [row][in,in,in,in,etc]
      for (int i=0;i<nnIn.Total();i++) {
         dataFrame[rowCnt].Set(i,nnIn.At(i));
         #ifdef _DEBUG_WRITE_CSV
            if (nnetwork.csvWriteDF) {
               csvString=csvString+DoubleToString(nnIn.At(i))+",";
            }
         #endif
         #ifdef _DEBUG_DATAFRAME
            ss=ss+" "+DoubleToString(dataFrame[rowCnt][i],2);
         #endif
      }
      // tack on output values at the end of the array
      // [row][in,in,in,in,etc,out,out,out,etc]

      for (int j=0; j<nnOut.Total();j++) {
         dataFrame[rowCnt].Set(j+nnIn.Total(),nnOut.At(j));
         #ifdef _DEBUG_WRITE_CSV
            if (nnetwork.csvWriteDF) {
               csvString=csvString+DoubleToString(nnOut.At(j))+",";
            }
         #endif
         #ifdef _DEBUG_DATAFRAME
            ss=ss+" "+DoubleToString(dataFrame[rowCnt][j+nnIn.Total()],2);
         #endif
      }
      #ifdef _DEBUG_WRITE_CSV
      if (nnetwork.csvWriteDF) {
         FileWrite(csvFileHandle,csvString);
         FileFlush(csvFileHandle);
      }
      #endif

      #ifdef _DEBUG_DATAFRAME
         writeLog
         pss
      #endif 

      rowCnt++; barCnt--;
      return; 
   }  

   // All frames have been added now train the new network
   #ifdef _DEBUG_DATAFRAME  
      ss="EANeuralNetwork -> buildDataFrame -> training network ......";
      writeLog
      pss
   #endif
   trainNetwork();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::copyValuesFromDatabase(int strategyNumber) {

   #ifdef _DEBUG_NN
      ss="EANeuralNetwork -> copyValuesFromDatabase -> ...";
      writeLog
   #endif

   string sql;
   int request, dfFileHandle;
   // numInput, numOutput;

   sql=StringFormat("SELECT * FROM NNETWORKS WHERE strategyNumber=%d",strategyNumber);
   request=DatabasePrepare(_mainDBHandle,sql);
   #ifdef _DEBUG_NN
         ss=sql;
         writeLog
         pss
   #endif  
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_NN
         ss=StringFormat("EANeuralNetwork ->  DB query failed with code %d",GetLastError());
         writeLog
         pss
         ss=sql;
         writeLog
         pss
      #endif  
   } else {
      DatabaseRead(request);

      DatabaseColumnInteger(request,0,nnetwork.strategyNumber);
      DatabaseColumnInteger(request,1,nnetwork.fileNumber);
      DatabaseColumnInteger(request,2,nnetwork.networkType);
      DatabaseColumnInteger(request,3,nnetwork.numHiddenLayer1);
      DatabaseColumnInteger(request,4,nnetwork.numHiddenLayer2);
      DatabaseColumnInteger(request,5,nnetwork.year);
      DatabaseColumnInteger(request,6,nnetwork.month);
      DatabaseColumnInteger(request,7,nnetwork.day);
      DatabaseColumnInteger(request,8,nnetwork.hour);
      DatabaseColumnInteger(request,9,nnetwork.minute);
      DatabaseColumnInteger(request,10,nnetwork.dfSize);
      DatabaseColumnInteger(request,11,nnetwork.csvWriteDF);
      DatabaseColumnInteger(request,12,nnetwork.restarts);
      DatabaseColumnDouble (request,13,nnetwork.decay);
      DatabaseColumnDouble (request,14,nnetwork.wStep);
      DatabaseColumnInteger(request,15,nnetwork.maxITS);
      DatabaseColumnInteger(request,16,nnetwork.trainWeightsThreshold);
      DatabaseColumnDouble (request,17,nnetwork.triggerThreshold);

      // Over write with values given to us during optimization
      if (_runMode==_RUN_OPTIMIZATION) {
         #ifdef _DEBUG_NN
            ss="EANeuralNetwork ->  copy input values MQL_OPTIMIZATION ....";
            writeLog
            pss
         #endif
         copyValuesFromOptimizationInputs();     
      }  


      #ifdef _DEBUG_NN
         ss=StringFormat("EANeuralNetwork -> DB Read StrategyNumber:%d L1:%d L2:%d dfSize:%d",nnetwork.strategyNumber,nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nnetwork.dfSize);
         writeLog
         pss
      #endif 
   }

   #ifdef _RUN_PANEL
      ss=StringFormat("EANeuralNetwork fileName:%s dfSize:%d",nnetwork.fileName,nnetwork.dfSize);
      showPanel ip.updateInfoLabel(22,0,ss);
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::copyValuesFromOptimizationInputs() {

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="EANeuralNetwork -> copyValuesFromOptimizationInputs ->";
      writeLog
      pss
   #endif

   nnetwork.numHiddenLayer1=innLayer1;
   nnetwork.numHiddenLayer2=innLayer2;
   nnetwork.triggerThreshold=itriggerThreshold;

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss=StringFormat("EANeuralNetwork -> copyValuesFromOptimizationInputs -> L1:%d L2:%d Threshold:%.5f",nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nnetwork.triggerThreshold);
      writeLog
      pss
   #endif
      
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkProperties()  {

   #ifdef _DEBUG_NN
      pline
      ss="EANeuralNetwork -> networkProperties -> ...";
      writeLog
      pline
   #endif

   int nInputs=0, nOutputs= 0, nWeights= 0;
   no.MLPProperties(ps, nInputs, nOutputs, nWeights);

   #ifdef _RUN_PANEL
   showPanel {
      string s1=StringFormat("EANeuralNetwork -> networkProperties -> I:%d L1:%d L2:%d O:%d W:%d",nInputs,nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nOutputs,nWeights);
      ip.updateInfoLabel(21,0,s1);
   }
   #endif
   
   #ifdef _DEBUG_NN
      ss=StringFormat("EANeuralNetwork -> networkProperties -> I:%d L1:%d L2:%d O:%d W:%d ",nInputs,nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nOutputs,nWeights);
      writeLog
   #endif

   nnetwork.numInput=nInputs;
   nnetwork.numOutput=nOutputs;
   nnetwork.numWeights=nWeights;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::createNewNetwork()  {

   #ifdef _DEBUG_NN
      pline
      datetime ts=TimeCurrent();
      ss="EANeuralNetwork -> createNewNetwork -> ...";
      writeLog
      pline
   #endif

   if (no==NULL || ps==NULL) {
      no=new CAlglib();
      if (CheckPointer(no)==POINTER_INVALID) {
            ss="EANeuralNetwork -> createNewNetwork -> ERROR created Network object";
            #ifdef _DEBUG_NN
               writeLog
            #endif
         ExpertRemove();
      } else {
         #ifdef _DEBUG_NN
            ss="EANeuralNetwork -> createNewNetwork -> SUCCESS created Network object";
            writeLog
         #endif
      }

      ps=new CMultilayerPerceptronShell();
      if (CheckPointer(ps)==POINTER_INVALID) {
         #ifdef _DEBUG_NN
            ss="EANeuralNetwork -> createNewNetwork -> ERROR created MultilayerPerceptronShell object";
            writeLog
         #endif
         ExpertRemove();
      } else {
         #ifdef _DEBUG_NN
            ss="EANeuralNetwork -> createNewNetwork -> SUCCESS created MultilayerPerceptronShell object";
            writeLog
         #endif
      }
   /*
   https://www.alglib.net/dataanalysis/neuralnetworks.php
   //---------
   MLPCreate2:
   //---------
   Creates  neural  network  with  NIn  inputs,  NOut outputs, 2 hidden
   layers, with linear output layer. Network weights are  filled  with  small
   random values.
   //---------
   MLPCreateC2:
   /----------
   Creates classifier network with NIn  inputs  and  NOut  possible  classes.
   Network contains 2 hidden layers and linear output  layer  with  SOFTMAX-
   normalization  (so  outputs  sums  up  to  1.0  and  converge to posterior
   probabilities).
   //----------
   MLPCreateR2:
   //----------
   Creates  neural  network  with  NIn  inputs,  NOut outputs, 2 hidden
   layers with non-linear output layer. Network weights are filled with small
   random values. Activation function of the output layer takes values [A,B].

   */


      switch (nnetwork.networkType) {
         case _NN_2: no.MLPCreateC2(nnetwork.numInput,nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nnetwork.numOutput,ps);
         break;
         case _NN_C2:no.MLPCreate2(nnetwork.numInput,nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nnetwork.numOutput,ps);
         break;
         case _NN_R2:no.MLPCreateR2(nnetwork.numInput,nnetwork.numHiddenLayer1,nnetwork.numHiddenLayer2,nnetwork.numOutput,0,1,ps);
         break;
      }
      #ifdef _DEBUG_NN
         ss="EANeuralNetwork -> createNewNetwork -> Created NEW Network and Shell";
         writeLog
      #endif
      networkProperties();
   } else {
      #ifdef _DEBUG_NN
         ss="EANeuralNetwork -> createNewNetwork -> Network and Shell already exists";
         writeLog
      #endif
      networkProperties();
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EANeuralNetwork::saveNetwork() {

   string csvString="";


   #ifdef _DEBUG_NN_LOADSAVE
      pline
      ss=StringFormat("EANeuralNetwork -> saveNetwork -> Saving network:%s:%s",TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_DATE),TimeToString(iTime(_Symbol,PERIOD_CURRENT,1),TIME_MINUTES));
      writeLog
      pss
      pline
   #endif 

   int k=0, i=0, j=0, numLayers=0, network[], nLayer1=1, functionType=0, binFileHandle, csvFileHandle;
   double threshold=0, weights=0, media=0, sigma=0;
   string binFileName, csvFileName;

      nnStore.Add(nnetwork.numInput);
      nnStore.Add(nnetwork.numOutput);
      numLayers=no.MLPGetLayersCount(ps);
      nnStore.Add(numLayers);     

      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork -> saveNetwork -> Inputs:%d Outputs:%d Layers:%d",nnetwork.numInput,nnetwork.numOutput,numLayers);
         writeLog
         pss
      #endif                                                                                                                     

      ArrayResize(network, numLayers);

      for(k= 0; k<numLayers; k++) {
         network[k]= no.MLPGetLayerSize(ps, k);
         nnStore.Add(network[k]);                                                           
      }

      for(k= 0; k<numLayers; k++) {
         for(i= 0; i<network[k]; i++) {
            if(k==0) {
               no.MLPGetInputScaling(ps, i, media, sigma);
               nnStore.Add(media);                                                          
               nnStore.Add(sigma); 
               #ifdef _DEBUG_NN_LOADSAVE
                  ss=StringFormat("MLPGetInputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  pss
               #endif 
            } else if (k==numLayers-1) {
               no.MLPGetOutputScaling(ps, i, media, sigma);
               nnStore.Add(media);                                                          
               nnStore.Add(sigma);
               #ifdef _DEBUG_NN_LOADSAVE
                  ss=StringFormat("MLPGetOutputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  pss
               #endif                                                           
            }
            no.MLPGetNeuronInfo(ps, k, i, functionType, threshold);
            nnStore.Add(functionType);                                                      
            nnStore.Add(threshold); 
            #ifdef _DEBUG_NN_LOADSAVE
               ss=StringFormat("MLPGetNeuronInfo -> functionType -> %.5f -- threshold -> %.5f ",functionType,threshold);
               writeLog
               pss
            #endif                                                         

            for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
               weights= no.MLPGetWeight(ps, k, i, k+1, j);
               nnStore.Add(weights);  
               #ifdef _DEBUG_NN_LOADSAVE
                  ss=StringFormat("MLPGetWeight -> weight -> %.5f ",weights);
                  writeLog
                  pss
               #endif                                                      
            }
         }      
      }

   #ifdef _DEBUG_WRITE_CSV
      // Create a single line for the CSV file
      if (nnetwork.csvWriteDF) {
         csvFileName=StringFormat("%s%s_saved.csv",IntegerToString(nnetwork.strategyNumber),IntegerToString(nnetwork.fileNumber));
         csvFileHandle=FileOpen(csvFileName,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
         csvString=TimeToString(iTime(_Symbol,PERIOD_CURRENT,1))+",";
         csvString=csvString+"Saved Network";
         FileWrite(csvFileHandle,csvString);
      }
      for (int i=0;i<nnStore.Total();i++) {
         ss=StringFormat(" -> idx:%d Val:%.5f ",i,nnStore.At(i));
         if (nnetwork.csvWriteDF) {
            csvString=DoubleToString(nnStore.At(i));
            FileWrite(csvFileHandle,csvString);
         }
         writeLog
         pss
      }
      if (nnetwork.csvWriteDF) {
         FileFlush(csvFileHandle);
         FileClose(csvFileHandle);
      }
   
   #endif

   binFileName=StringFormat("%s%s.bin",IntegerToString(nnetwork.strategyNumber),IntegerToString(nnetwork.fileNumber));
   binFileHandle=FileOpen(binFileName,FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON);
   
   if (nnStore.Save(binFileHandle)) {
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("saveNetwork -> SUCCESS created file:%s",binFileName);
         writeLog
         pss
      #endif
   } else {
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("saveNetwork -> ERROR saving file:%s -> %d",binFileName, GetLastError());
         writeLog
         pss
      #endif
   }

   FileClose(binFileHandle);

   return true;
} 



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::loadNetwork() {

   #ifdef _DEBUG_NN_LOADSAVE
      ss="EANeuralNetwork -> loadNetwork -> ";
      pss
      writeLog
   #endif

   int k=0, i=0, j=0, idx=0, numLayers=0, network[], functionType=0, binFileHandle, csvFileHandle=0;
   double threshold=0, weights=0, media=0, sigma=0;
   string binFileName, csvFileName="", csvString;

   // entry at this point can occur in 1 or 2 ways
   // 1 first time after optimization where the .bin file does not exist the DF will need to be 
   // created and the network trained using parameters choosen after optimization
   // 2 every other time the EA is started where the existing .bin file will be reread
   // NORMAL RUN MODE
   binFileName=StringFormat("%s%s.bin",IntegerToString(nnetwork.strategyNumber),IntegerToString(nnetwork.fileNumber));
   if (FileIsExist(binFileName,FILE_COMMON)) {
      pline  
      ss=StringFormat("* EANeuralNetwork -> loadNetwork ->  attempting to open a existing bin file ... %s",binFileName);
      pss
      pline

      #ifdef _DEBUG_WRITE_CSV
         if (nnetwork.csvWriteDF) {
            csvFileName=StringFormat("%s%s_loaded.csv",IntegerToString(nnetwork.strategyNumber),IntegerToString(nnetwork.fileNumber));
            csvFileHandle=FileOpen(csvFileName,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
            csvString=csvFileName+" Loaded Network";
            FileWrite(csvFileHandle,csvString);
         }
      #endif
      binFileHandle=FileOpen(binFileName,FILE_READ|FILE_BIN|FILE_ANSI|FILE_COMMON);
      if (binFileHandle) {  // Open the existing nn.bin
         if (nnStore.Load(binFileHandle)) {
            ss=StringFormat("EANeuralNetwork -> loadNetwork -> SUCCESS loaded from file:%s",binFileName);
            pss
            writeLog
            // Load the network using a previous save to disk of the bin file which is read into
            // the array nnStore
            
            nnetwork.numInput=nnStore.At(idx++);
            nnetwork.numOutput=nnStore.At(idx++);
            numLayers=nnStore.At(idx++);
            #ifdef _DEBUG_WRITE_CSV 
               if (nnetwork.csvWriteDF) {
                  FileWrite(csvFileHandle,DoubleToString(nnetwork.numInput,5)); 
                  FileWrite(csvFileHandle,DoubleToString(nnetwork.numOutput,5)); 
                  FileWrite(csvFileHandle,DoubleToString(numLayers,5)); 
               }
            #endif
            ArrayResize(network, numLayers);
            #ifdef _DEBUG_NN_LOADSAVE
               ss=StringFormat("EANeuralNetwork -> loadNetwork -> Inputs:%d Outputs:%d Layers:%d",nnetwork.numInput,nnetwork.numOutput,numLayers);
               writeLog
               pss
            #endif  
            for(k= 0; k<numLayers; k++) {
               network[k]= (int)nnStore.At(idx++); 
                  #ifdef _DEBUG_WRITE_CSV if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,IntegerToString(network[k]));  #endif
            }
            createNewNetwork();

            for(k= 0; k<numLayers; k++) {
               for(i= 0; i<network[k]; i++) {
                  if(k==0) {
                     media= nnStore.At(idx++);
                     sigma= nnStore.At(idx++);
                     #ifdef _DEBUG_NN_LOADSAVE
                        ss=StringFormat("EANeuralNetwork -> loadNetwork -> NetworkInputScaling Layers:%d idx:%d media:%2.2f sigma:%2.2f",k,i,media,sigma);
                        writeLog
                        pss
                     #endif
                     no.MLPSetInputScaling(ps, i, media, sigma);
                     #ifdef _DEBUG_WRITE_CSV
                        if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(media,5));  
                        if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(sigma,5));  
                     #endif
                  }
                  else if(k==numLayers-1) {
                     media= nnStore.At(idx++);
                     sigma= nnStore.At(idx++);
                     #ifdef _DEBUG_NN_LOADSAVE
                        ss=StringFormat("EANeuralNetwork -> loadNetwork -> NetworkOutputScaling idx:%d media:%2.2f sigma:%2.2f",i,media,sigma);
                        writeLog
                        pss
                     #endif
                     no.MLPSetInputScaling(ps, i, media, sigma);
                     no.MLPSetOutputScaling(ps, i, media, sigma);
                     #ifdef _DEBUG_WRITE_CSV
                        if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(media,5));  
                        if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(sigma,5));  
                     #endif
                  }
                  functionType= (int)nnStore.At(idx++);
                  threshold= nnStore.At(idx++);
                  #ifdef _DEBUG_WRITE_CSV
                     if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,IntegerToString(functionType));     
                     if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(threshold,5));       
                  #endif
                  no.MLPSetNeuronInfo(ps, k, i, functionType, threshold);
                  for (j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
                     weights= nnStore.At(idx++);
                     #ifdef _DEBUG_WRITE_CSV if (nnetwork.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(weights,5));  #endif
                     #ifdef _DEBUG_NN_LOADSAVE
                        ss=StringFormat("EANeuralNetwork ->  loadNetwork -> Loading weight:%2.5f",weights);
                        writeLog
                        pss
                     #endif 
                     no.MLPSetWeight(ps, k, i, k+1, j, weights);
                  }
               }      
            }
         } else {
            ss=StringFormat("EANeuralNetwork -> loadNetwork -> ERROR loading file:%s -> %d",binFileName, GetLastError());
            pss
            ExpertRemove();
         }
         FileClose(binFileHandle);
         #ifdef _DEBUG_WRITE_CSV if (nnetwork.csvWriteDF) FileClose(csvFileHandle);  #endif
      }

      // network created based on bin file with weights and biaes, now ready to be used via calls to 
      // networkForcast(double &inputs[], double &outputs[]);
      _runMode=_RUN_NORMAL;

   } else {
      // No NN flat file exists so force the system to read and recreate one
      ss=StringFormat("EANeuralNetwork -> loadNetwork -> File %s does not exist yet, needs be created ",binFileName);
      writeLog
      pss
      // We must rebuild the DF, retrain the network and save its as a .bin file.
      _runMode=_RUN_REBUILD_NN;
      
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EANeuralNetwork::networkForcast(CArrayDouble &nnIn, CArrayDouble &nnOut, double &prediction[]) {

   static int csvFileHandle;
   string csvFileName, csvString, s1;
   
   /*
   #ifdef _DEBUG_NN_FORCAST
      
      ss="EANeuralNetwork -> networkForcast -> ";
      pss
      writeLog
   #endif
   */

   #ifdef _DEBUG_WRITE_CSV
      // Create a single line for the CSV file
      if (nnetwork.csvWriteDF) {
         if (csvFileHandle==NULL) {
            csvFileName=StringFormat("%s%sforcast.csv",IntegerToString(nnetwork.strategyNumber),IntegerToString(nnetwork.fileNumber));
            csvFileHandle=FileOpen(csvFileName,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
         }
         csvString=TimeToString(iTime(_Symbol,PERIOD_CURRENT,1))+",";
         csvString=csvString+",";
      }
   #endif

   /*
   #ifdef _DEBUG_NN_FORCAST
      ss=StringFormat("EANeuralNetwork -> networkForcast -> Array Sizes Total:%d Inputs:%d Output:%d",nnIn.Total(), ArraySize(inputs), ArraySize(prediction));
      writeLog
      pss
   #endif
   */

   // Convert to normal double [] for inputs
   for (int i=0;i<nnIn.Total();i++) inputs[i]=nnIn.At(i);

   // Ask the network for a prediction note we are also passing back the prediction[] for now
   no.MLPProcess(ps, inputs, prediction);   

   if (prediction[0]>=nnetwork.triggerThreshold) {
      #ifdef _DEBUG_NN_FORCAST
         ss=StringFormat("EANeuralNetwork -> networkForcast -> _OPEN_NEW_POSITION %0.5f",prediction[0]);
         pss
         writeLog
      #endif

      return _OPEN_NEW_POSITION;
   }

   #ifdef _DEBUG_WRITE_CSV
      if (nnetwork.csvWriteDF) {
         for (int l=0;l<ArraySize(inputs);l++) {
            csvString=csvString+","+l+","+DoubleToString(inputs[l])+",";
         }
         for (int m=0;m<nnOut.Total();m++) {
            csvString=csvString+","+DoubleToString(nnOut[m])+","+DoubleToString(prediction[0]);
         }
      }

      FileWrite(csvFileHandle,csvString);
      FileFlush(csvFileHandle);

   #endif

   #ifdef _DEBUG_NN_FORCAST
      s1=""; ss="networkForcast -> In:";
      for (int i=0;i<ArraySize(inputs);i++) {
         s1=StringFormat("%0.5f",inputs[i]);
         ss=ss+":"+s1;
      }
      pss
      writeLog
      ss="networkForcast -> Out:";
      for (int j=0;j<nnOut.Total();j++) {
         s1=StringFormat("%0.5f",nnOut[j]);
         ss=ss+":"+s1;
      }
      pss
      writeLog
   #endif

   #ifdef _RUN_PANEL
   showPanel {
      for (int i=0;i<nnetwork.numInput;i++) {
         ss=ss+" "+StringFormat("%0.2f",inputs[i]);
      }
      ip.updateInfoLabel(23,0,ss);
      ss="";
      for (int j=0;j<nnetwork.numOutput;j++) {
         ss=ss+" "+StringFormat("%0.2f",nnOut[j]);
      }
      ip.updateInfoLabel(24,0,ss);
   }
   #endif

   return _NO_ACTION;
   
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::trainNetwork() {

   #ifdef _DEBUG_NN_TRAINING
      pline
      ss="EANeuralNetwork -> trainNetwork -> ...";
      writeLog
      pline
   #endif

   createNewNetwork();

   CMLPReportShell repShell;
   int retCode=0;
   double rmsError=0;
   int nPoints=dataFrame.Size();

   ResetLastError();

   // Choose the optimization / training 
   /*
   https://www.alglib.net/translator/man/manual.cpp.html#sub_mlptrainnetwork
   //--------
   MLPTrainLM
   //--------
   Neural network training  using  modified  Levenberg-Marquardt  with  exact
   Hessian calculation and regularization. Subroutine trains  neural  network
   with restarts from random positions. Algorithm is well  suited  for  small
   and medium scale problems (hundreds of weights).
   //-----------
   MLPTrainLBFGS
   //-----------
   Neural  network  training  using  L-BFGS  algorithm  with  regularization.
   Subroutine  trains  neural  network  with  restarts from random positions.
   Algorithm  is  well  suited  for  problems  of  any dimensionality (memory
   requirements and step complexity are linear by weights number).
   */
   if (nnetwork.numWeights<nnetwork.trainWeightsThreshold) {
      no.MLPTrainLM(ps,dataFrame,nPoints,nnetwork.decay,nnetwork.restarts,retCode,repShell);
      #ifdef _DEBUG_NN_TRAINING
         ss=StringFormat("EANeuralNetwork -> MLPTrainLM weights:%d  Threshold:%d - Points:%d Decay:%.5f restarts:%d",nnetwork.numWeights, nnetwork.trainWeightsThreshold, nPoints,nnetwork.decay,nnetwork.restarts);
         writeLog
      #endif
      if (retCode==-9) ss="EANeuralNetwork -> internal matrix inverse subroutine failed (-9)";                    writeLog
      if (retCode==-2) ss="EANeuralNetwork -> if there is a point with class number outside of [0..NOut-1] (-2)"; writeLog
      if (retCode==-1) ss="EANeuralNetwork -> if wrong parameters specified (NPoints<0, Restarts<1) (-1)";        writeLog
      if (retCode==2)  ss="EANeuralNetwork -> Success task has been solved (2)";                                  writeLog
   } else {
      no.MLPTrainLBFGS(ps,dataFrame,nPoints,nnetwork.decay,nnetwork.restarts,nnetwork.wStep,nnetwork.maxITS,retCode,repShell);
      #ifdef _DEBUG_NN_TRAINING
         ss=StringFormat("EANeuralNetwork -> MLPTrainLBFGS Points:%d Decay:%.5f restarts:%d WStep:%.5f maxITS:%d",nPoints,nnetwork.decay,nnetwork.restarts,nnetwork.wStep,nnetwork.maxITS);
         writeLog
      #endif
      if (retCode==-8) ss="EANeuralNetwork -> if both WStep=0 and MaxIts=0 (-8)";                                 writeLog
      if (retCode==-2) ss="EANeuralNetwork -> if there is a point with class number outside of [0..NOut-1] (-2)"; writeLog
      if (retCode==-1) ss="EANeuralNetwork -> if wrong parameters specified (NPoints<0, Restarts<1) (-1)";        writeLog
      if (retCode==2)  ss="EANeuralNetwork -> Success task has been solved (2)";                                  writeLog
   }

   if (retCode<0) {
      #ifdef _DEBUG_NN_TRAINING
         ss="EANeuralNetwork -> trainNetwork -> EXIT ON ERROR retCode<0...";
         writeLog
      #endif
      ExpertRemove();
   }

   if (retCode==2||retCode==6) {
      #ifdef _DEBUG_NN_TRAINING
         rmsError= no.MLPRMSError(ps, dataFrame, nPoints);
         ss=StringFormat("EANeuralNetwork ->\n #Gradient calculations:%d\n #Hessian calculations%d\n #Cholesky decompositions:%d\n Training error:%2.8f\n Restarts:%d\n Code Response:%d",
            repShell.GetNGrad(),repShell.GetNHess(),repShell.GetNCholesky(),DoubleToString(rmsError, 8),nnetwork.restarts,retCode );
         writeLog
      #endif
   }  
   

   // if we are in optimization mode we don't need to save the trained network as flat file
   // each iteratoin will be different based on different IO inputs. Only after a choosen set
   // of inputs can we save a network for continued use as the IO input will have constant values
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {
      _runMode=_RUN_NORMAL;
      return;
   }

   // We save the network to disk if this is the first time a new set of parameters after a optimization run
   // this occurs if there is no existing disk file or if a reload of the strategy was pressed. 

   if (_runMode==_RUN_REBUILD_NN) {
      #ifdef _DEBUG_NN
         ss="EANeuralNetwork -> trainNetwork -> Now nave the trained network to disk";
         writeLog
      #endif
      if (saveNetwork()) {
         #ifdef _DEBUG_NN
            ss="EANeuralNetwork -> trainNetwork -> Nework saved success";
            writeLog
         #endif
         _runMode=_RUN_NORMAL;

      } else {
         #ifdef _DEBUG_NN
            ss="EANeuralNetwork -> trainNetwork -> Nework saved error";
            writeLog
         #endif
         ExpertRemove();
      }
   }  

}
