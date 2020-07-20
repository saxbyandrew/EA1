//+------------------------------------------------------------------+
//|                                  Script descarga Indicadores.mq5 |
//|                             Copyright 2015, José Miguel Soriano. |
//+------------------------------------------------------------------+

#property copyright "José Miguel Soriano; Spain"
#property link      "josemiguel1812@hotmail.es"
#property version   "1.000"

#property script_show_confirm
#property script_show_inputs
//1 

#define HIDDEN_LAYER   1  
#define FUNC_OUTPUT        -5
            //1= func tangente hiperbólica; 2= e^(-x^2); 3= x>=0 raizC(1+x^2) x<0 e^x; 4= func sigmoide;
            //5= binomial x>0.5? 1: 0; -5= func lineal
#include <Math\Alglib\alglib.mqh>

enum myNetworkProperties {N_LAYERS, N_NEURONS, N_INPUTS, N_OUTPUTS, N_WEIGHTS};
//---------------------------------  parametros entrada  ---------------------
sinput int paramIn= 10;                 //Num neurons input layer
                                             //2^8= 256 2^9= 512; 2^10= 1024; 2^12= 4096; 2^14= 16384 
sinput int nHiddenLayer1= 0;                  //Num hidden layer 1 neurons (<1 does not exist)
sinput int nHiddenLayer2= 0;                  //Num hidden layer 2 neurons (<1 does not exist)                                             //2^8= 256 2^9= 512; 2^10= 1024; 2^12= 4096; 2^14= 16384 
sinput int paramOut= 1;                    //Num output layer neurons

sinput int    trainingHistory= 800;         //Training history
sinput int    historialEvalua= 200;          //Prediction history
sinput int    trainingCycles= 2;              //Training Cycles
sinput double learningRate= 0.001;            //Learning rate
sinput string inputNormalization= "";             //Input normalization: desired min and max (empty = does NOT normalize)
sinput string ouputNormalization= "";              //Output normalization: min and max desired (empty = does not normalize)
sinput bool   printTrainingData= true;             //Print training/evaluation data
      
// ------------------------------ VARIABLES GLOBALES -----------------------------     
int _TextFile= 0;
ulong contFlush= 0; 
CMultilayerPerceptronShell neuralNetwork;
CMatrixDouble learnData(0, 0);
CMatrixDouble evaluateData(0, 0);
double minAbsoluteOutput= 0, maxAbsoluteOutput= 0;
string EAName= "ScriptBinDec";

//+------------------------------------------------------------------+
void OnStart()              //Conversor binario a decimal
{
   string stringData= "BINARY-DECIMAL Conversion Script",
   mens= "", cadNumBin= "", cadNumRed= "";
   int contentHits= 0, arNumBin[],
   start= trainingHistory+1,
   end= trainingHistory+historialEvalua;
   double arSalRed[], arNumEntra[], output= 0, threshold= 0, weight= 0;
   double errorMediumEnter= 0;
   bool normInput= inputNormalization!="", normOutput= ouputNormalization!="", correct= false,
        created= createNeuralNetwork(neuralNetwork);        
   if(created) 
   {
      openCSVFile(_TextFile, EAName+"-infRN", ".csv",stringData);
      prepareDataInputOutput(neuralNetwork, learnData, inputNormalization!="", ouputNormalization!="");
      normalizeNetwork(neuralNetwork, learnData, normInput, normOutput);
      errorMediumEnter= trainNetwork(neuralNetwork, learnData);
      writeToCSVFile("-------------------------", _TextFile);
      writeToCSVFile("RESPUESTA RED------------", _TextFile);
      writeToCSVFile("-------------------------", _TextFile);
      writeToCSVFile("numBinEntra;numDecSalidaRed;correct", _TextFile);
      for(int k= start; k<=end; k++)
      {
         cadNumBin= decimalToBinary(k, arNumBin, 2, paramIn);
         ArrayCopy(arNumEntra, arNumBin);
         output= answerNetwork(neuralNetwork, arNumEntra, arSalRed);
         output= MathRound(output);
         correct= k==(int)output;
         writeToCSVFile(cadNumBin+";"+IntegerToString((int)output)+";"+correct, _TextFile);
         cadNumRed= "";
      }
   }      
   closeCSVFile(_TextFile);
   return;
}

//-------------------------------- INITIALIZE TEXT FILE  ---------------------------------
bool openCSVFile(int &csvHandle, string csvFileName= "EA", string extension= ".csv", string stringData= "")
{
   bool error= false;
   string csvFullFileName= csvFileName + extension;
   ResetLastError();
   csvHandle= FileOpen(csvFullFileName, FILE_WRITE|FILE_TXT|FILE_COMMON);
   error= (csvHandle==INVALID_HANDLE);
   if(stringData!="")
   {
      FileWrite(csvHandle, csvFullFileName+ ";;;Path= ;"+ TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\Files");
      FileWrite(csvHandle, stringData);
   }     
   return(!error);
}

//---------------------------------- CLOSE AND DUMP DEBUG TEXT FILE
void closeCSVFile(int csvHandle)
{
   ResetLastError();
   if(csvHandle!=INVALID_HANDLE)
   {
      FileFlush(csvHandle);
      FileClose(csvHandle);
      Print("Path= ", TerminalInfoString(TERMINAL_COMMONDATA_PATH));
   }
   return;
}

//--------------------------- WRITE TEXT  -------------------------------------------
void writeToCSVFile(string stringData, int csvHandle, int size= 10)
{
   ResetLastError();
   if(csvHandle!=INVALID_HANDLE)
   {
      FileWrite(csvHandle, stringData);
      size++;
      if(contFlush%size==0) FileFlush(csvHandle);
   }
}

//---------------------------------- CREATES NEURAL NETWORK -----------------------------------------
bool createNeuralNetwork(CMultilayerPerceptronShell &networkObject)
{
   bool created= false;
   int nInputs= 0, nOutputs= 0, nWeights= 0;
   if(nHiddenLayer1<1 && nHiddenLayer2<1) CAlglib::MLPCreate0(paramIn, paramOut, networkObject);   	//output LINEAL   
   else if(nHiddenLayer2<1) CAlglib::MLPCreate1(paramIn, nHiddenLayer1, paramOut, networkObject);   	//output LINEAL
   else CAlglib::MLPCreate2(paramIn, nHiddenLayer1, nHiddenLayer2, paramOut, networkObject);   		//output LINEAL                    
   created= existingNetwork(networkObject);
   if(!created) Print("Error creating neural network ==> ", __FUNCTION__, " ", _LastError);
   else
   {
      CAlglib::MLPProperties(networkObject, nInputs, nOutputs, nWeights);
      Print("created network ", networkProperties(networkObject, N_LAYERS));
      Print("Nº Inputs ", nInputs);
      Print("Nº Layer 1 ", nHiddenLayer1);
      Print("Nº Layer 2 ", nHiddenLayer2);
      Print("Nº Output  ", nOutputs);
      Print("Nº Weights ", nWeights);
      Print("History", IntegerToString(trainingHistory));
   }
   return(created);
}

//--------------------------------- THERE IS A NETWORK --------------------------------------------
bool existingNetwork(CMultilayerPerceptronShell &networkObject)
{
   bool resp= false;
   int nInputs= 0, nOutputs= 0, nWeights= 0;
   CAlglib::MLPProperties(networkObject, nInputs, nOutputs, nWeights);
   resp= nInputs>0 && nOutputs>0;
   return(resp);
}

//---------------------------------- PREPARES INPUT / OUTPUT DATA --------------------------------------------------
void prepareDataInputOutput(CMultilayerPerceptronShell &networkObject, CMatrixDouble &arDatos, bool normInput= true , bool normOutput= true)
{
   int row= 0, column= 0, numDec= 0, arNumBin[],
       nInputs= networkProperties(networkObject, N_INPUTS),
       nOutputs= networkProperties(networkObject, N_OUTPUTS);
   string str= "", cadNum= "";
   arDatos.Resize(trainingHistory, nInputs+nOutputs);
   if(printTrainingData) writeToCSVFile("numBin;numDec", _TextFile);
   for(row= 0; row<trainingHistory; row++)
   {
      numDec= row+1;
      cadNum= decimalToBinary(numDec, arNumBin, 2, nInputs);    //10000= 14 digitos en binario; 4000= 12 digitos en binario; 1000= 10 digitos
      for(column= 0; column<nInputs; column++) arDatos[row].Set(column, arNumBin[column]);    
      for(column= 0; column<nOutputs; column++) arDatos[row].Set(column+nInputs, numDec);
      if(printTrainingData) 
      {
         for(column= 0; column<(nInputs); column++) str= DoubleToString(arDatos[row][column], 0)+str;
         writeToCSVFile(str+";"+IntegerToString(numDec), _TextFile);
         str= "";
      }
   }
   if(printTrainingData)
   {
      writeToCSVFile(str, _TextFile);     
      Alert("Download file= ", EAName+"-infRN.csv");
      Alert("Path= ", TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\Files");
   }
   return;
}

//---------------------------------- NETWORK PROPERTIES  -------------------------------------------
int networkProperties(CMultilayerPerceptronShell &networkObject, myNetworkProperties prop= N_LAYERS, int layerNumber= 0) {           
   // if N_NEURONS is requested, the layerNumber must be specified

   int resp= 0, nInputs= 0, nOutputs= 0, nWeights= 0;
   if(prop>N_NEURONS) CAlglib::MLPProperties(networkObject, nInputs, nOutputs, nWeights);    
   switch(prop)     //myNetworkProperties{N_LAYERS, N_NEURONS, N_INPUTS, N_OUTPUTS, N_WEIGHTS};
   {
      case N_LAYERS:
         resp= CAlglib::MLPGetLayersCount(networkObject);
         break;
      case N_NEURONS:
         resp= CAlglib::MLPGetLayerSize(networkObject, layerNumber);
         break;
      case N_INPUTS:
         resp= nInputs;
         break;
      case N_OUTPUTS:
         resp= nOutputs;
         break;
      case N_WEIGHTS:
         resp= nWeights;
   }
   return(resp);
}   

//------------------------------------ STANDARDIZES NETWORK INPUT/OUTPUT  -------------------------------------
void normalizeNetwork(CMultilayerPerceptronShell &networkObject, CMatrixDouble &arDatos, bool normInput= true, bool normOutput= true)
{
   int row= 0, column= 0, maxRows= arDatos.Size(),
       nInputs= networkProperties(networkObject, N_INPUTS),
       nOutputs= networkProperties(networkObject, N_OUTPUTS);
   double maxAbs= 0, minAbs= 0, maxRel= 0, minRel= 0;
   string arMaxMinRelEntra[], arMaxMinRelSals[];
   ushort valCaract= StringGetCharacter(";", 0);
   if(normInput) StringSplit(inputNormalization, valCaract, arMaxMinRelEntra);
   if(normOutput) StringSplit(ouputNormalization, valCaract, arMaxMinRelSals);
   for(column= 0; normInput && column<nInputs; column++)
   {
      maxAbs= arDatos[0][column];
      minAbs= arDatos[0][column];
      minRel= StringToDouble(arMaxMinRelEntra[0]);
      maxRel= StringToDouble(arMaxMinRelEntra[1]); 
      for(row= 0; row<maxRows; row++)		// we identify maxAbs and minRel from each data column
      {
         if(maxAbs<arDatos[row][column]) maxAbs= arDatos[row][column];
         if(minAbs>arDatos[row][column]) minAbs= arDatos[row][column];            
      }
      for(row= 0; row<maxRows; row++)		// we set the new normalized value
         arDatos[row].Set(column, normalizeValue(arDatos[row][column], maxAbs, minAbs, maxRel, minRel));
   }
   for(column= nInputs; normOutput && column<(nInputs+nOutputs); column++)
   {
      maxAbs= arDatos[0][column];
      minAbs= arDatos[0][column];
      minRel= StringToDouble(arMaxMinRelSals[0]);
      maxRel= StringToDouble(arMaxMinRelSals[1]);
      for(row= 0; row<maxRows; row++)
      {
         if(maxAbs<arDatos[row][column]) maxAbs= arDatos[row][column];
         if(minAbs>arDatos[row][column]) minAbs= arDatos[row][column];            
      }
      minAbsoluteOutput= minAbs;
      maxAbsoluteOutput= maxAbs;
      for(row= 0; row<maxRows; row++)
         arDatos[row].Set(column, normalizeValue(arDatos[row][column], maxAbs, minAbs, maxRel, minRel));
   }
   return;
}

//------------------------------------ STANDARDIZATION FUNCTION  ---------------------------------
double normalizeValue(double value, double maxAbs, double minAbs, double maxRel= 1, double minRel= -1)
{
   double normalizedResult= 0;
   if(maxAbs>minAbs) normalizedResult= (value-minAbs)*(maxRel-minRel)/(maxAbs-minAbs) + minRel;
   return(normalizedResult);
} 

//-------------------------------------NETWORK TRAINING ----------------------------------------
double trainNetwork(CMultilayerPerceptronShell &networkObject, CMatrixDouble &trainingData)
{      
   bool exit= false;
   double errorM= 0;
   string mens= "Network Training";
   int k= 0, i= 0, codResp= 0,
       historial= trainingData.Size();
       
   CMLPReportShell infoEntren;
   ResetLastError();
   datetime tmpIni= TimeLocal();
   Alert("Initiating NEURONAL NETWORK OPTIMIZATION...");
   Alert("Wait a few minutes... depending on the amount of history involved.");
   Alert("...///...");
   if(networkProperties(networkObject, N_WEIGHTS)<500)
      CAlglib::MLPTrainLM(networkObject, trainingData, historial, learningRate, trainingCycles, codResp, infoEntren);
   else
      CAlglib::MLPTrainLBFGS(networkObject, trainingData, historial, learningRate, trainingCycles, 0.01, 0, codResp, infoEntren);
   if(codResp==2 || codResp==6) errorM= CAlglib::MLPRMSError(networkObject, trainingData, historial);
   datetime tmpFin= TimeLocal();
   Alert("NGrad ", infoEntren.GetNGrad(), " NHess ", infoEntren.GetNHess(), " NCholesky ", infoEntren.GetNCholesky());
   Alert("codResp ", codResp," Average error Enter "+DoubleToString(errorM, 8), " trainingCycles ", trainingCycles);
   Alert("tmpEntren ", DoubleToString(((double)(tmpFin-tmpIni))/60.0, 2), " min", "---> tmpIni ", TimeToString(tmpIni, TIME_SECONDS), " tmpFin ", TimeToString(tmpFin, TIME_SECONDS));
   if(GetLastError()>0) Print("Error: ", GetLastError(), " ", __FUNCTION__);
   return(errorM);
}

//--------------------------------------- REQUEST REPLY TO NETWORK ---------------------------------
double answerNetwork(CMultilayerPerceptronShell &networkObject, double &arEntradas[], double &arSalidas[])
{
   double resp= 0, nNeuron= 0;
   CAlglib::MLPProcess(networkObject, arEntradas, arSalidas);
   resp= arSalidas[0];
   return(resp);
}

//-------------------------------------TEN NUMBER to BINARY ------------------------------------
string decimalToBinary(int numDec, int &destinationNumber[], int baseNum= 2, int nFigures= 6)
{
   string numCad= "";
   bool exit= false;
   int i= 0, k= 1, longCad= 0, numIni= numDec;
   while(!exit)
   {
      ArrayResize(destinationNumber, k);
      destinationNumber[k-1]= numIni%baseNum;
      numIni= numIni/baseNum;
      exit= numIni<baseNum;      
      k++;
   }
   ArrayResize(destinationNumber, k);
   destinationNumber[k-1]= numIni;
   for(i= 0; i<k; i++) numCad= IntegerToString(destinationNumber[i])+numCad;
   longCad= k;
   if(longCad<nFigures)
   {
      ArrayResize(destinationNumber, nFigures);
      for(k= 0; k<(nFigures-longCad); k++)
      {
         numCad= "0"+numCad;
         destinationNumber[k+longCad]= 0;
      }
   }
   return(numCad);
}

