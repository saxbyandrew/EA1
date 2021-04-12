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
#include <Arrays\ArrayString.mqh>


class EANeuralNetwork  {

//=========
private:
//=========

   string   ss;

   void     networkProperties();
   void     createNewNetwork();
   bool     saveNetwork();
   void     loadNetwork();
   void     updateValuesToDatabase();
   void     copyValuesFromDatabase(int strategyNumber);
   void     copyValuesFromOptimizationInputs();
   void     normalizeDataFrame(CArrayString &nnHeadings);
   void     trainNetwork();
   void     setMinMaxValueRange(double val, int idx);

   CAlglib  *no;
   CMultilayerPerceptronShell *ps;
   CMatrixDouble  dataFrame;
   double inputs[], iMinVal[], iMaxVal[];


//=========
protected:
//=========
      
   Network nn;

//=========
public:
//=========
EANeuralNetwork(int strategyNumber);
~EANeuralNetwork();

   CArrayDouble   *nnStore;
   datetime getOptimizationStartDateTime();
   int      getDataFrameSize() {return nn.dfSize;};
   void     setDataFrameArraySizes(int nnIn, int nnOut);
   EAEnum   networkForcast(CArrayDouble &nnIn, CArrayDouble &nnOut, double &prediction[], CArrayString &nnHeadings);
   void     buildDataFrame(CArrayDouble &nnIn, CArrayDouble &nnOut, CArrayString &nnHeadings);

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

   if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER)) {
      copyValuesFromOptimizationInputs();  
   } else {
      copyValuesFromDatabase(strategyNumber);     // Get Technicals from the DB 
   }


   // OPTIMIZATION MODE
   // Check which mode we are executing in
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {                                      // If we are optimizing there will be no nn??.bin file yet or a old one may exist 
      #ifdef _DEBUG_NN
         string ss=StringFormat("EANeuralNetwork -> .... starting time:%s",TimeToString(SeriesInfoInteger(Symbol(),Period(),SERIES_SERVER_FIRSTDATE)));
         writeLog
      #endif
      _systemState=_STATE_BUILD_DATAFRAME;
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
void EANeuralNetwork::setMinMaxValueRange(double val, int idx) {

   // Track the min and max values so that we can normalise the values prior to NN activies
   if (val > iMaxVal[idx]) iMaxVal[idx]=val; 
   if (val < iMinVal[idx]) iMinVal[idx]=val; 
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::setDataFrameArraySizes(int nnIn, int nnOut) {

   nn.numInput=nnIn;
   nn.numOutput=nnOut;

   // Change the dataFrame size based on the iputs and outputs
   dataFrame.Resize(nn.dfSize,nn.numInput+nn.numOutput);

   // Change the double [] used for networkforcasts
   // min/maxVal used to store for normilisation limits
   ArrayResize(inputs,nn.numInput);
   ArrayResize(iMinVal,nn.numInput);
   ArrayResize(iMaxVal,nn.numInput);
   ArrayFill(iMinVal,0,ArraySize(iMinVal),0.0);
   ArrayFill(iMaxVal,0,ArraySize(iMaxVal),0.0);

   #ifdef _DEBUG_NN_DATAFRAME  
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

   osdt.year=nn.year;
   osdt.mon=nn.month;
   osdt.day=nn.day;
   osdt.hour=nn.hour;
   osdt.min=nn.minute;

   return (StructToTime(osdt));
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::normalizeDataFrame(CArrayString &nnHeadings) {

   double val;

   if (FileIsExist("normalized.csv",FILE_COMMON)) return;

   #ifdef _DEBUG_WRITE_CSV
      
      static int csvFileHandle;
      string csvString="";

      if (csvFileHandle==NULL) {
         csvFileHandle=FileOpen("normalized.csv",FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
         FileWrite(csvFileHandle,"Values and Normalized Values");
         FileFlush(csvFileHandle);
      }
   #endif

   // indicator Headings
   #ifdef _DEBUG_WRITE_CSV
      csvString=",";
      for (int j=0; j<nn.numInput+nn.numOutput;j++) { 
         csvString=csvString+nnHeadings.At(j)+",,";
      }
      FileWrite(csvFileHandle,csvString);
      FileFlush(csvFileHandle);
      csvString="";
   #endif

   // min / max values headings
   #ifdef _DEBUG_WRITE_CSV
      csvString=",,";
      for (int k=0; k<nn.numInput;k++) {
         csvString=csvString+DoubleToString(iMinVal[k],3)+","+DoubleToString(iMaxVal[k],3)+",";
      }
      FileWrite(csvFileHandle,csvString);
      FileFlush(csvFileHandle);
      csvString="";
   #endif


   // Main DF size loop
   for (int i=0; i<nn.dfSize; i++) {
      #ifdef _DEBUG_WRITE_CSV
         csvString="Row:"+IntegerToString(i,4)+",";
      #endif

      // Outputs
      for (int l=0; l<nn.numOutput;l++) {
         #ifdef _DEBUG_WRITE_CSV
            csvString=csvString+DoubleToString(dataFrame[i][l+nn.numInput],3)+",";
         #endif
      }

      // Inputs
      for (int m=0; m<nn.numInput;m++) {
         // Normalize
         val=(dataFrame[i][m]-iMinVal[m])/(iMaxVal[m]-iMinVal[m]);
         #ifdef _DEBUG_WRITE_CSV
            csvString=csvString+DoubleToString(dataFrame[i][m],3)+",";
         #endif
         dataFrame[i].Set(m,val);
         #ifdef _DEBUG_WRITE_CSV
            csvString=csvString+DoubleToString(val,3)+",";
         #endif
      }
      
      // Update the min/max indicator value
      #ifdef _DEBUG_WRITE_CSV
         FileWrite(csvFileHandle,csvString);
         FileFlush(csvFileHandle);
         csvString="";
      #endif
   }
   // Update the min/max indicator value
   #ifdef _DEBUG_WRITE_CSV
      FileWrite(csvFileHandle,csvString);
      FileFlush(csvFileHandle);
      FileClose(csvFileHandle);
   #endif
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::buildDataFrame(CArrayDouble &nnIn, CArrayDouble &nnOut, CArrayString &nnheadings) {

   static int csvFileHandle;
   static int rowCnt=0;
   static int barCnt=nn.dfSize;
   string csvString;
   
   //datetime barTime;

   #ifdef _DEBUG_NN_DATAFRAME  
      ss=StringFormat("EANeuralNetwork -> buildDataFrame -> with barCnt:%d",barCnt);
      writeLog
      pss
   #endif

   #ifdef _DEBUG_WRITE_CSV
   // Create a single line for the CSV file
   if (csvFileHandle==NULL) {
      csvFileHandle=FileOpen("df.csv",FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
   }
   csvString=TimeToString(iTime(_Symbol,PERIOD_CURRENT,1))+",";
   csvString=csvString+rowCnt+",";
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
            csvString=csvString+DoubleToString(nnIn.At(i))+",";
         #endif
         
         #ifdef _DEBUG_NN_DATAFRAME
            ss=ss+" "+DoubleToString(dataFrame[rowCnt][i],2);
         #endif
         setMinMaxValueRange(nnIn.At(i),i);
      }
      // tack on output values at the end of the array
      // [row][in,in,in,in,etc,out,out,out,etc]
      for (int j=0; j<nnOut.Total();j++) {
         dataFrame[rowCnt].Set(j+nnIn.Total(),nnOut.At(j));
         
         #ifdef _DEBUG_WRITE_CSV
            csvString=csvString+DoubleToString(nnOut.At(j))+",";
         #endif
         
         #ifdef _DEBUG_NN_DATAFRAME
            ss=ss+" "+DoubleToString(dataFrame[rowCnt][j+nnIn.Total()],2);
         #endif
      }

      // Update the min/max indicator value
      
      #ifdef _DEBUG_WRITE_CSV
         FileWrite(csvFileHandle,csvString);
         FileFlush(csvFileHandle);
      #endif
      

      #ifdef _DEBUG_NN_DATAFRAME
         writeLog
         pss
      #endif 

      rowCnt++; barCnt--;
      return;
   }  

   // All frames have been added now normalise the dataframe
   #ifdef _DEBUG_NN_DATAFRAME  
      ss="EANeuralNetwork -> buildDataFrame -> normalize dataframe ......";
      writeLog
      pss
   #endif
   normalizeDataFrame(nnheadings);

   // All frames have been added now train the new network
   #ifdef _DEBUG_NN_DATAFRAME  
      ss="EANeuralNetwork -> buildDataFrame -> training network ......";
      writeLog
      pss
   #endif
   trainNetwork();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::updateValuesToDatabase() {

   #ifdef _DEBUG_NN_LOADSAVE  
      pline
      ss="EANeuralNetwork -> updateValuesToDatabase";
      writeLog
      pss
      pline
   #endif

   nn.versionNumber++;

   string sql=StringFormat("UPDATE NNETWORKS SET "
      "networkType=%d, numHiddenLayer1=%d, numHiddenLayer2=%d, "
      "dfSize=%d, restarts=%d, decay=%.5f, wStep=%.5f, maxITS=%d, "
      "trainWeightsThreshold=%d, triggerThreshold=%.5f, versionNumber=%d "
      "WHERE strategyNumber=%d",
      nn.networkType,nn.numHiddenLayer1,nn.numHiddenLayer2,
      nn.dfSize,nn.restarts,nn.decay,nn.wStep,nn.maxITS,
      nn.trainWeightsThreshold,nn.triggerThreshold, nn.versionNumber, nn.strategyNumber);
   
   if (!DatabaseExecute(_mainDBHandle, sql)) {
      ss=StringFormat("EANeuralNetwork -> updateValuesToDatabase -> Failed to insert NNETWORK with code %d", GetLastError());
      pss
      ss=sql;
      pss
      writeLog
   } else {
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork -> updateValuesToDatabase -> UPDATE INTO NNETWORK success new version:%d",nn.versionNumber);
         pss
         writeLog
         ss=sql;
         pss
         writeLog
      #endif
   }  

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::copyValuesFromDatabase(int strategyNumber) {

   #ifdef _DEBUG_NN
      ss="EANeuralNetwork -> selectValuesFromDatabase -> ...";
      writeLog
   #endif

   string sql;
   int request, dfFileHandle;

   sql=StringFormat("SELECT * FROM NNETWORKS WHERE strategyNumber=%d",strategyNumber);
   request=DatabasePrepare(_mainDBHandle,sql);
   #ifdef _DEBUG_NN
         ss=sql;
         writeLog
         pss
   #endif  
   if (request==INVALID_HANDLE) {
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork ->  DB query failed with code %d",GetLastError());
         writeLog
         pss
         ss=sql;
         writeLog
         pss
      #endif  
   } else {
      DatabaseRead(request);

      DatabaseColumnInteger(request,0,nn.strategyNumber);
      DatabaseColumnInteger(request,1,nn.fileNumber);
      DatabaseColumnInteger(request,2,nn.networkType);
      DatabaseColumnInteger(request,3,nn.numHiddenLayer1);
      DatabaseColumnInteger(request,4,nn.numHiddenLayer2);
      DatabaseColumnInteger(request,5,nn.year);
      DatabaseColumnInteger(request,6,nn.month);
      DatabaseColumnInteger(request,7,nn.day);
      DatabaseColumnInteger(request,8,nn.hour);
      DatabaseColumnInteger(request,9,nn.minute);
      DatabaseColumnInteger(request,10,nn.dfSize);
      DatabaseColumnInteger(request,11,nn.csvWriteDF);
      DatabaseColumnInteger(request,12,nn.restarts);
      DatabaseColumnDouble (request,13,nn.decay);
      DatabaseColumnDouble (request,14,nn.wStep);
      DatabaseColumnInteger(request,15,nn.maxITS);
      DatabaseColumnInteger(request,16,nn.trainWeightsThreshold);
      DatabaseColumnDouble (request,17,nn.triggerThreshold);
      DatabaseColumnInteger(request,18,nn.versionNumber);

      // Over write DB loaded values with values given to us from inputs
      /*
      if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER)) {
         #ifdef _DEBUG_NN_LOADSAVE
            ss="EANeuralNetwork ->  copy input values MQL_OPTIMIZATION ....";
            writeLog
            pss
         #endif
         copyValuesFromOptimizationInputs();     
      } 
      */ 


      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork -> DB Read StrategyNumber:%d L1:%d L2:%d dfSize:%d Version:%d",
         nn.strategyNumber,nn.numHiddenLayer1,nn.numHiddenLayer2,nn.dfSize,nn.versionNumber);
         writeLog
         pss
      #endif 
   }

   #ifdef _RUN_PANEL
      ss=StringFormat("EANeuralNetwork fileName:%s dfSize:%d",nn.fileName,nn.dfSize);
      showPanel ip.updateInfoLabel(22,0,ss);
   #endif

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::copyValuesFromOptimizationInputs() {

   #ifdef _DEBUG_NN_LOADSAVE
      ss="EANeuralNetwork -> copyValuesFromOptimizationInputs ->";
      writeLog
      pss
   #endif

   nn.fileNumber=ifileNumber;
   nn.networkType=inetworkType;
   nn.dfSize=idataFrameSize;
   nn.triggerThreshold=itriggerThreshold;
   nn.trainWeightsThreshold=itrainWeightsThreshold;
   nn.numHiddenLayer1=innLayer1;
   nn.numHiddenLayer2=innLayer2;
   nn.restarts=irestarts;
   nn.decay=idecay;
   nn.wStep=iwStep;
   nn.maxITS=imaxITS;
   nn.trainWeightsThreshold=itrainWeightsThreshold;
   nn.triggerThreshold=itriggerThreshold;

   nn.csvWriteDF=1;
   nn.year=2021;
   nn.month=03;
   nn.day=03;
   nn.hour=03;
   nn.minute=0;
   

   #ifdef _DEBUG_NN_LOADSAVE
      ss=StringFormat("EANeuralNetwork -> copyValuesFromOptimizationInputs -> L1:%d L2:%d Threshold:%.5f",nn.numHiddenLayer1,nn.numHiddenLayer2,nn.triggerThreshold);
      writeLog
      pss
   #endif
      
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::networkProperties()  {

   #ifdef _DEBUG_NN_PROPERTIES
      pline
      ss="EANeuralNetwork -> networkProperties ->";
      writeLog
      pline
      string nnType;
   #endif

   int nInputs=0, nOutputs= 0, nWeights= 0;
   no.MLPProperties(ps, nInputs, nOutputs, nWeights);

   #ifdef _RUN_PANEL
   showPanel {
      string s1=StringFormat("EANeuralNetwork -> networkProperties -> I:%d L1:%d L2:%d O:%d W:%d",nInputs,nn.numHiddenLayer1,nn.numHiddenLayer2,nOutputs,nWeights);
      ip.updateInfoLabel(21,0,s1);
   }
   #endif
   
   #ifdef _DEBUG_NN_PROPERTIES
      switch (nn.networkType) {
         case _NN_2: nnType="MLPCreateC2";
         break;
         case _NN_C2:nnType="MLPCreate2";
         break;
         case _NN_R2:nnType="MLPCreateR2";
         break;
      }

      ss=StringFormat("EANeuralNetwork -> networkProperties -> I:%d L1:%d L2:%d O:%d W:%d Type:%s",nInputs,nn.numHiddenLayer1,nn.numHiddenLayer2,nOutputs,nWeights,nnType);
      writeLog
   #endif

   nn.numInput=nInputs;
   nn.numOutput=nOutputs;
   nn.numWeights=nWeights;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EANeuralNetwork::createNewNetwork()  {

   #ifdef _DEBUG_NN_LOADSAVE
      pline
      datetime ts=TimeCurrent();
      ss="EANeuralNetwork -> createNewNetwork ->";
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
         #ifdef _DEBUG_NN_LOADSAVE
            ss="EANeuralNetwork -> createNewNetwork -> SUCCESS created Network object";
            writeLog
         #endif
      }

      ps=new CMultilayerPerceptronShell();
      if (CheckPointer(ps)==POINTER_INVALID) {
         #ifdef _DEBUG_NN_LOADSAVE
            ss="EANeuralNetwork -> createNewNetwork -> ERROR created MultilayerPerceptronShell object";
            writeLog
         #endif
         ExpertRemove();
      } else {
         #ifdef _DEBUG_NN_LOADSAVE
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


      switch (nn.networkType) {
         case _NN_2: no.MLPCreateC2(nn.numInput,nn.numHiddenLayer1,nn.numHiddenLayer2,nn.numOutput,ps);
            //ss="EANeuralNetwork -> createNewNetwork -> MLPCreateC2";
            //writeLog
         break;
         case _NN_C2:no.MLPCreate2(nn.numInput,nn.numHiddenLayer1,nn.numHiddenLayer2,nn.numOutput,ps);
            //ss="EANeuralNetwork -> createNewNetwork -> MLPCreate2";
            //writeLog
         break;
         case _NN_R2:no.MLPCreateR2(nn.numInput,nn.numHiddenLayer1,nn.numHiddenLayer2,nn.numOutput,-1,1,ps);
            //ss="EANeuralNetwork -> createNewNetwork -> MLPCreateR2";
            //writeLog
         break;
      }
      #ifdef _DEBUG_NN_LOADSAVE
         ss="EANeuralNetwork -> createNewNetwork -> Created NEW Network and Shell";
         writeLog
      #endif
      networkProperties();
   } else {
      #ifdef _DEBUG_NN_LOADSAVE
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

      nnStore.Add(nn.numInput);
      nnStore.Add(nn.numOutput);
      numLayers=no.MLPGetLayersCount(ps);
      nnStore.Add(numLayers);     

      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork -> saveNetwork -> Inputs:%d Outputs:%d Layers:%d",nn.numInput,nn.numOutput,numLayers);
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
               #ifdef _DEBUG_NN_LOADSAVE_DETAILED
                  ss=StringFormat("MLPGetInputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  pss
               #endif 
            } else if (k==numLayers-1) {
               no.MLPGetOutputScaling(ps, i, media, sigma);
               nnStore.Add(media);                                                          
               nnStore.Add(sigma);
               #ifdef _DEBUG_NN_LOADSAVE_DETAILED
                  ss=StringFormat("MLPGetOutputScaling -> media -> %.5f -- sigma -> %.5f ",media,sigma);
                  writeLog
                  pss
               #endif                                                           
            }
            no.MLPGetNeuronInfo(ps, k, i, functionType, threshold);
            nnStore.Add(functionType);                                                      
            nnStore.Add(threshold); 
            #ifdef _DEBUG_NN_LOADSAVE_DETAILED
               ss=StringFormat("MLPGetNeuronInfo -> functionType -> %.5f -- threshold -> %.5f ",functionType,threshold);
               writeLog
               pss
            #endif                                                         

            for(j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
               weights= no.MLPGetWeight(ps, k, i, k+1, j);
               nnStore.Add(weights);  
               #ifdef _DEBUG_NN_LOADSAVE_DETAILED
                  ss=StringFormat("MLPGetWeight -> weight -> %.5f ",weights);
                  writeLog
                  pss
               #endif                                                      
            }
         }      
      }

   #ifdef _DEBUG_WRITE_CSV
      // Create a single line for the CSV file
      if (nn.csvWriteDF) {
         csvFileName=StringFormat("%s%s_saved.csv",IntegerToString(nn.strategyNumber),IntegerToString(nn.fileNumber));
         csvFileHandle=FileOpen(csvFileName,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 
         csvString=TimeToString(iTime(_Symbol,PERIOD_CURRENT,1))+",";
         csvString=csvString+"Saved Network";
         FileWrite(csvFileHandle,csvString);
      }
      for (int i=0;i<nnStore.Total();i++) {
         ss=StringFormat(" -> idx:%d Val:%.5f ",i,nnStore.At(i));
         if (nn.csvWriteDF) {
            csvString=DoubleToString(nnStore.At(i));
            FileWrite(csvFileHandle,csvString);
         }
         writeLog
         pss
      }
      if (nn.csvWriteDF) {
         FileFlush(csvFileHandle);
         FileClose(csvFileHandle);
      }
   
   #endif

   binFileName=StringFormat("%s%s.bin",IntegerToString(nn.strategyNumber),IntegerToString(nn.fileNumber));
   binFileHandle=FileOpen(binFileName,FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON);
   
   if (nnStore.Save(binFileHandle)) {
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork -> saveNetwork -> SUCCESS created file:%s",binFileName);
         writeLog
         pss
      #endif
   } else {
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork ->  saveNetwork -> ERROR saving file:%s -> %d",binFileName, GetLastError());
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

   // entry at this point can occur in 1 of 3 ways
   // 1 first time after optimization where the .bin file does not exist the DF will need to be 
   // created and the network trained using parameters choosen after optimization
   // 2 every other time the EA is started where the existing .bin file will be reread
   // 3 After optimization using a single run test

   binFileName=StringFormat("%s%s.bin",IntegerToString(nn.strategyNumber),IntegerToString(nn.fileNumber));

   // If we enter here for option (3) remove the nn.bin first 
   // We run this if we are in tester mode
   if (MQLInfoInteger(MQL_TESTER)) {
      if (FileIsExist(binFileName,FILE_COMMON)) {
         if (FileDelete(binFileName,FILE_COMMON)) {
            #ifdef _DEBUG_NN_LOADSAVE
            ss="EANeuralNetwork -> loadNetwork -> MQL_TESTER MODE -> NN bin file removed successfully";
               pss
               writeLog
            #endif
         }
      }
   }


   // Use the existing nn.bin if it exists
   if (FileIsExist(binFileName,FILE_COMMON)) {
      pline  
      ss=StringFormat("EANeuralNetwork -> loadNetwork ->  attempting to open a existing bin file ... %s",binFileName);
      pss
      pline

      #ifdef _DEBUG_WRITE_CSV
         if (nn.csvWriteDF) {
            csvFileName=StringFormat("%s%s_loaded.csv",IntegerToString(nn.strategyNumber),IntegerToString(nn.fileNumber));
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
            
            nn.numInput=nnStore.At(idx++);
            nn.numOutput=nnStore.At(idx++);
            numLayers=nnStore.At(idx++);
            #ifdef _DEBUG_WRITE_CSV 
               if (nn.csvWriteDF) {
                  FileWrite(csvFileHandle,DoubleToString(nn.numInput,5)); 
                  FileWrite(csvFileHandle,DoubleToString(nn.numOutput,5)); 
                  FileWrite(csvFileHandle,DoubleToString(numLayers,5)); 
               }
            #endif
            ArrayResize(network, numLayers);
            #ifdef _DEBUG_NN_LOADSAVE
               ss=StringFormat("EANeuralNetwork -> loadNetwork -> Inputs:%d Outputs:%d Layers:%d",nn.numInput,nn.numOutput,numLayers);
               writeLog
               pss
            #endif  
            for(k= 0; k<numLayers; k++) {
               network[k]= (int)nnStore.At(idx++); 
                  #ifdef _DEBUG_WRITE_CSV if (nn.csvWriteDF) FileWrite(csvFileHandle,IntegerToString(network[k]));  #endif
            }
            createNewNetwork();

            // Populate the network with its values
            for(k= 0; k<numLayers; k++) {
               for(i= 0; i<network[k]; i++) {
                  if(k==0) {
                     media= nnStore.At(idx++);
                     sigma= nnStore.At(idx++);
                     #ifdef _DEBUG_NN_LOADSAVE_DETAILED
                        ss=StringFormat("EANeuralNetwork -> loadNetwork -> NetworkInputScaling Layers:%d idx:%d media:%2.2f sigma:%2.2f",k,i,media,sigma);
                        writeLog
                        pss
                     #endif
                     no.MLPSetInputScaling(ps, i, media, sigma);
                     #ifdef _DEBUG_WRITE_CSV
                        if (nn.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(media,5));  
                        if (nn.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(sigma,5));  
                     #endif
                  }
                  else if(k==numLayers-1) {
                     media= nnStore.At(idx++);
                     sigma= nnStore.At(idx++);
                     #ifdef _DEBUG_NN_LOADSAVE_DETAILED
                        ss=StringFormat("EANeuralNetwork -> loadNetwork -> NetworkOutputScaling idx:%d media:%2.2f sigma:%2.2f",i,media,sigma);
                        writeLog
                        pss
                     #endif
                     no.MLPSetInputScaling(ps, i, media, sigma);
                     no.MLPSetOutputScaling(ps, i, media, sigma);
                     #ifdef _DEBUG_WRITE_CSV
                        if (nn.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(media,5));  
                        if (nn.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(sigma,5));  
                     #endif
                  }
                  functionType= (int)nnStore.At(idx++);
                  threshold= nnStore.At(idx++);
                  #ifdef _DEBUG_WRITE_CSV
                     if (nn.csvWriteDF) FileWrite(csvFileHandle,IntegerToString(functionType));     
                     if (nn.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(threshold,5));       
                  #endif
                  no.MLPSetNeuronInfo(ps, k, i, functionType, threshold);
                  for (j= 0; k<(numLayers-1) && j<network[k+1]; j++) {
                     weights= nnStore.At(idx++);
                     #ifdef _DEBUG_WRITE_CSV if (nn.csvWriteDF) FileWrite(csvFileHandle,DoubleToString(weights,5));  #endif
                     #ifdef _DEBUG_NN_LOADSAVE_DETAILED
                        ss=StringFormat("EANeuralNetwork ->  loadNetwork -> Loading weight:%2.5f",weights);
                        writeLog
                        pss
                     #endif 
                     no.MLPSetWeight(ps, k, i, k+1, j, weights);
                  }
               }      
            }
         } else {
            #ifdef _DEBUG_NN_LOADSAVE
               ss=StringFormat("EANeuralNetwork -> loadNetwork -> ERROR loading file:%s -> %d",binFileName, GetLastError());
               pss
            #endif
            ExpertRemove();
         }
         FileClose(binFileHandle);
         #ifdef _DEBUG_WRITE_CSV if (nn.csvWriteDF) FileClose(csvFileHandle);  #endif
      }

      // network created based on bin file with weights and biaes, now ready to be used via calls to 
      // networkForcast(double &inputs[], double &outputs[]);
      _systemState=_STATE_NORMAL;

   } else {
      // No NN flat file exists so force the system to read and recreate one
      #ifdef _DEBUG_NN_LOADSAVE
         ss=StringFormat("EANeuralNetwork -> loadNetwork -> File %s does not exist yet, needs be created ",binFileName);
         writeLog
         pss
      #endif

      // We must rebuild the DF, retrain the network and save it as a .bin file.
      _systemState=_STATE_REBUILD_NETWORK;
      
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAEnum EANeuralNetwork::networkForcast(CArrayDouble &nnIn, CArrayDouble &nnOut, double &prediction[], CArrayString &nnHeadings) {

   static int csvFileHandle;
   string csvFileName, csvString, s1;
   
   

   #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
      // Create a single line for the CSV file
      if (nn.csvWriteDF) {
         if (csvFileHandle==NULL) {
            csvFileName=StringFormat("%s%sforcast.csv",IntegerToString(nn.strategyNumber),IntegerToString(nn.fileNumber));
            csvFileHandle=FileOpen(csvFileName,FILE_COMMON|FILE_READ|FILE_WRITE|FILE_ANSI|FILE_CSV,","); 

            csvString="Date / Time,";
            for (int i=0;i<nnHeadings.Total();i++) {
               csvString=csvString+nnHeadings.At(i)+",";
            }
            FileWrite(csvFileHandle,csvString);
            FileFlush(csvFileHandle);
         } 
         csvString=TimeToString(iTime(_Symbol,PERIOD_CURRENT,1))+",";
         
      }
   #endif


   // Array TYPE .. Convert to normal double [] for inputs
   for (int i=0;i<nnIn.Total();i++) inputs[i]=nnIn.At(i);

   // Ask the network for a prediction note we are also passing back the prediction[] for now
   no.MLPProcess(ps, inputs, prediction);   

   #ifdef _DEBUG_NN_FORCAST_WRITE_CSV
      if (nn.csvWriteDF) {

         for (int m=0;m<nnOut.Total();m++) {
            if (nnOut[m]==0) {ss="Down";} else {ss="Up";}
            csvString=csvString+ss+","+DoubleToString(prediction[0])+" "+prediction[1]+",";
         }
         for (int l=0;l<ArraySize(inputs);l++) {
            csvString=csvString+DoubleToString(inputs[l])+",";
         }

      }
      FileWrite(csvFileHandle,csvString);
      FileFlush(csvFileHandle);
   #endif

   #ifdef _DEBUG_NN_FORCAST
      s1=""; ss="EANeuralNetwork -> networkForcast -> In:";
      for (int i=0;i<ArraySize(inputs);i++) {
         s1=StringFormat("%0.5f",inputs[i]);
         ss=ss+":"+s1;
      }
      pss
      writeLog
      ss="EANeuralNetwork -> networkForcast -> Out:";
      for (int j=0;j<nnOut.Total();j++) {
         s1=StringFormat("%0.5f",nnOut[j]);
         ss=ss+":"+s1;
      }
      pss
      writeLog
   #endif

   #ifdef _RUN_PANEL
   showPanel {
      for (int i=0;i<nn.numInput;i++) {
         ss=ss+" "+StringFormat("%0.2f",inputs[i]);
      }
      ip.updateInfoLabel(23,0,ss);
      ss="";
      for (int j=0;j<nn.numOutput;j++) {
         ss=ss+" "+StringFormat("%0.2f",nnOut[j]);
      }
      ip.updateInfoLabel(24,0,ss);
   }
   #endif

   if (prediction[0]>=nn.triggerThreshold) {
      #ifdef _DEBUG_NN_FORCAST
         ss=StringFormat("EANeuralNetwork -> networkForcast -> _OPEN_NEW_POSITION %0.5f",prediction[0]);
         pss
         writeLog
      #endif
      return _OPEN_NEW_POSITION;
   }

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
   if (nn.numWeights<nn.trainWeightsThreshold) {
      no.MLPTrainLM(ps,dataFrame,nPoints,nn.decay,nn.restarts,retCode,repShell);
      #ifdef _DEBUG_NN_TRAINING
         ss=StringFormat("EANeuralNetwork -> MLPTrainLM weights:%d  Threshold:%d - Points:%d Decay:%.5f restarts:%d",nn.numWeights, nn.trainWeightsThreshold, nPoints,nn.decay,nn.restarts);
         writeLog
      #endif
      if (retCode==-9) ss="EANeuralNetwork -> internal matrix inverse subroutine failed (-9)";                    writeLog
      if (retCode==-2) ss="EANeuralNetwork -> if there is a point with class number outside of [0..NOut-1] (-2)"; writeLog
      if (retCode==-1) ss="EANeuralNetwork -> if wrong parameters specified (NPoints<0, Restarts<1) (-1)";        writeLog
      if (retCode==2)  ss="EANeuralNetwork -> Success task has been solved (2)";                                  writeLog
   } else {
      no.MLPTrainLBFGS(ps,dataFrame,nPoints,nn.decay,nn.restarts,nn.wStep,nn.maxITS,retCode,repShell);
      #ifdef _DEBUG_NN_TRAINING
         ss=StringFormat("EANeuralNetwork -> MLPTrainLBFGS Points:%d Decay:%.5f restarts:%d WStep:%.5f maxITS:%d",nPoints,nn.decay,nn.restarts,nn.wStep,nn.maxITS);
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
            repShell.GetNGrad(),repShell.GetNHess(),repShell.GetNCholesky(),DoubleToString(rmsError, 8),nn.restarts,retCode );
         writeLog
      #endif
   }  
   

   // 1 if we are in optimization mode we don't need to save the trained network as flat file
   // each iteration will be different based on different IO inputs. Only after a choosen set
   // of inputs can we save a network for continued use as the IO input will have constant values (2)
   if (MQLInfoInteger(MQL_OPTIMIZATION)) {
      _systemState=_STATE_NORMAL;
      return;
   }


   // 2 We save the network to disk if this is the first time a new set of parameters after a optimization run
   // this occurs if there is no existing disk file nn.bin or if a reload of the strategy was pressed. 
   if (_systemState==_STATE_REBUILD_NETWORK) {

      #ifdef _DEBUG_NN
         ss="EANeuralNetwork -> trainNetwork -> Now save the trained network to disk";
         writeLog
      #endif
      if (saveNetwork()) {
         #ifdef _DEBUG_NN_LOADSAVE
            ss="EANeuralNetwork -> trainNetwork -> Network save SUCCESS";
            writeLog
         #endif
         _systemState=_STATE_NORMAL;
         // Also update the DB Network Values
         updateValuesToDatabase();

      } else {
         #ifdef _DEBUG_NN_LOADSAVE
            ss="EANeuralNetwork -> trainNetwork -> Nework save ERROR";
            writeLog
         #endif
         ExpertRemove();
      }
   }  
}
