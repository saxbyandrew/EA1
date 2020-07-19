//+------------------------------------------------------------------+
//|                                                         test.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Math\Alglib\alglib.mqh>

input int nNeuronEntra= 35;      //Number of neurons in the input layer 
input int nNeuronSal= 1;         //Number of neurons in the output layer
input int nNeuronCapa1= 45;      //Number of neurons in the hidden layer 1 (cannot be <1)
input int nNeuronCapa2= 10;      //Number of neurons in the hidden layer 2 (cannot be <1)

input mis_TIPO_EAred tipoEAred            = _OPTIMIZA;        //Executed task type
input mis_PLAZO_OPTIM plazoOptim          = _DIARIO;          //Time interval for network optimization
input int horaOptim                       = 3;                //Local time for network optimization

input int velaIniDesc= 15;
input int historialEntrena= 1500;

input bool optimInicio                    = true;         //Optimize the neural network when launching the EA

CMultilayerPerceptronShell *objRed;
CMatrixDouble arDatosAprende(0, 0);

enum mis_PROPIEDADES_RED {N_CAPAS, N_NEURONAS, N_ENTRADAS, N_SALIDAS, N_PESOS};
enum mis_PLAZO_OPTIM {_DIARIO, _DIA_ALTERNO, _FIN_SEMANA};
enum mis_TIPO_EAred {_OPTIMIZA, _EJECUTA};

double fechaUltLectura;
bool reOptimizada= false;


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
  }
//+------------------------------------------------------------------+
//---------------------------------- CREATE AND OPTIMIZE THE NEURAL NETWORK --------------------------------------------------
bool gestionRed(CMultilayerPerceptronShell &objRed, string simb, bool normEntrada= true , bool normSalida= true,
                bool imprDatos= true, bool barajar= true)
{
   double tasaAprende= 0.001;             //Network training ratio
   int ciclosEntren= 2;                   //Number of training cycles
   ResetLastError();
   bool creada= creaRedNeuronal(objRed);                                //create the neural network
  if(creada) 
   {
      preparaDatosEntra(objRed, simb, arDatosAprende);                  //download input/output data in arDatosAprende
      if(imprDatos) imprimeDatosEntra(simb, arDatosAprende);            //display data to evaluate credibility
      if(normEntrada || normSalida) normalizaDatosRed(objRed, arDatosAprende, normEntrada, normSalida); //option input/output data normalization
      if(barajar) barajaDatosEntra(arDatosAprende, nNeuronEntra+nNeuronSal);    //iterate over data array strings
      errorMedioEntren= entrenaEvalRed(objRed, arDatosAprende, ciclosEntren, tasaAprende);      //perform training/optimization
      salvaRedFich(arObjRed[codS], "copiaSegurRed_"+simb);      //save the network to the disk file
   }
   else infoError(GetLastError(), __FUNCTION__);
   
   return(_LastError==0);
}

//--------------------------------- CREATE THE NETWORK --------------------------------------
bool creaRedNeuronal(CMultilayerPerceptronShell &objRed)
{
   bool creada= false;
   int nEntradas= 0, nSalidas= 0, nPesos= 0;
   if(nNeuronCapa1<1 && nNeuronCapa2<1) CAlglib::MLPCreate0(nNeuronEntra, nNeuronSal, objRed);   	//LINEAR OUTPUT   
   else if(nNeuronCapa2<1) CAlglib::MLPCreate1(nNeuronEntra, nNeuronCapa1, nNeuronSal, objRed);   	//LINEAR OUTPUT
   else CAlglib::MLPCreate2(nNeuronEntra, nNeuronCapa1, nNeuronCapa2, nNeuronSal, objRed);   		//LINEAR OUTPUT                    
   creada= existeRed(objRed);
   if(!creada) Print("Error creating a NEURAL NETWORK ==> ", __FUNCTION__, " ", _LastError);
   else
   {
      CAlglib::MLPProperties(objRed, nEntradas, nSalidas, nPesos);
      Print("Created the network with nº layers", propiedadRed(objRed, N_CAPAS));
      Print("Nº neurons in the input layer ", nEntradas);
      Print("Nº neurons in the hidden layer 1 ", nNeuronCapa1);
      Print("Nº neurons in the hidden layer 2 ", nNeuronCapa2);
      Print("Nº neurons in the output layer ", nSalidas);
      Print("Nº of the weight", nPesos);
   }
   return(creada);
}

//--------------------------------- EXISTING NETWORK --------------------------------------------
bool existeRed(CMultilayerPerceptronShell &objRed)
{
   bool resp= false;
   int nEntradas= 0, nSalidas= 0, nPesos= 0;
   CAlglib::MLPProperties(objRed, nEntradas, nSalidas, nPesos);
   resp= nEntradas>0 && nSalidas>0;
   return(resp);
}



//---------------------------------- NETWORK PROPERTIES  -------------------------------------------
int propiedadRed(CMultilayerPerceptronShell &objRed, mis_PROPIEDADES_RED prop= N_CAPAS, int numCapa= 0)
{           //set numCapa layer index if the number of N_NEURONAS neurons is requested
   int resp= 0, numEntras= 0, numSals= 0, numPesos= 0;
   if(prop>N_NEURONAS) CAlglib::MLPProperties(objRed, numEntras, numSals, numPesos);    
   switch(prop)
   {
      case N_CAPAS:
         resp= CAlglib::MLPGetLayersCount(objRed);
         break;
      case N_NEURONAS:
         resp= CAlglib::MLPGetLayerSize(objRed, numCapa);
         break;
      case N_ENTRADAS:
         resp= numEntras;
         break;
      case N_SALIDAS:
         resp= numSals;
         break;
      case N_PESOS:
         resp= numPesos;
   }
   return(resp);
}   

//---------------------------------- PREPARE INPUT/OUTPUT DATA --------------------------------------------------
void preparaDatosEntra(CMultilayerPerceptronShell &objRed, string simb, CMatrixDouble &arDatos, bool normEntrada= true , bool normSalida= true)
{
   int fin= 0, fila= 0, colum= 0,
       nEntras= propiedadRed(objRed, N_ENTRADAS),
       nSals= propiedadRed(objRed, N_SALIDAS);
   double valor= 0, arResp[];   
   arDatos.Resize(historialEntrena, nEntras+nSals);
   fin= velaIniDesc+historialEntrena;
   for(fila= velaIniDesc; fila<fin; fila++)
   {                   
      for(colum= 0; colum<NUM_INDIC;  colum++)
      {
         valor= valorIndic(codS, fila, colum);
         arDatos[fila-1].Set(colum, valor);
      }
      calcEstrat(fila-nVelasPredic, arResp);
      for(colum= 0; colum<nSals; colum++) arDatos[fila-1].Set(colum+nEntras, arResp[colum]);
   }
   return;
}

//---------------------------------- DISPLAY INPUT/OUTPUT DATA --------------------------------------------------
void imprimeDatosEntra(string simb, CMatrixDouble &arDatos)
{
   string encabeza= "indic1;indic2;indic3...;resultEstrat",     //indicator names separated by ";"
          fichImprime= "dataEntrenaRed_"+simb+".csv";
   bool entrar= false, copiado= false;
   int fila= 0, colum= 0, resultEstrat= -1, nBuff= 0,
       nFilas= arDatos.Size(),
       nColum= nNeuronEntra+nNeuronSal,
       puntFich= FileOpen(fichImprime, FILE_WRITE|FILE_CSV|FILE_COMMON);
   FileWrite(puntFich, encabeza);
   for(fila= 0; fila<nFilas; fila++)
   {
      linea= IntegerToString(fila)+";"+TimeToString(iTime(simb, PERIOD_CURRENT, velaIniDesc+fila), TIME_MINUTES)+";";                
      for(colum= 0; colum<nColum;  colum++) 
         linea= linea+DoubleToString(arDatos[fila][colum], 8)+(colum<(nColum-1)? ";": "");
      FileWrite(puntFich, linea);
   }
   FileFlush(puntFich);
   FileClose(puntFich);
   Alert("Download file= ", fichImprime);
   Alert("Path= ", TerminalInfoString(TERMINAL_COMMONDATA_PATH)+"\\Files");
   return;
}

//------------------------------------ NORMALIZE INPUT/OUTPUT DATA-------------------------------------
void normalizaDatosRed(CMultilayerPerceptronShell &objRed, CMatrixDouble &arDatos, bool normEntrada= true, bool normSalida= true)
{
   int fila= 0, colum= 0, maxFila= arDatos.Size(),
       nEntradas= propiedadRed(objRed, N_ENTRADAS),
       nSalidas= propiedadRed(objRed, N_SALIDAS);
   double maxAbs= 0, minAbs= 0, maxRel= 0, minRel= 0, arMaxMinRelEntra[], arMaxMinRelSals[];
   ushort valCaract= StringGetCharacter(";", 0);
   if(normEntrada) StringSplit(intervEntrada, valCaract, arMaxMinRelEntra);
   if(normSalida) StringSplit(intervSalida, valCaract, arMaxMinRelSals);
   for(colum= 0; normEntrada && colum<nEntradas; colum++)
   {
      maxAbs= arDatos[0][colum];
      minAbs= arDatos[0][colum];
      minRel= StringToDouble(arMaxMinRelEntra[0]);
      maxRel= StringToDouble(arMaxMinRelEntra[1]); 
      for(fila= 0; fila<maxFila; fila++)                //define maxAbs and minAbs of each data column
      {
         if(maxAbs<arDatos[fila][colum]) maxAbs= arDatos[fila][colum];
         if(minAbs>arDatos[fila][colum]) minAbs= arDatos[fila][colum];            
      }
      for(fila= 0; fila<maxFila; fila++)                //set the new normalized value
         arDatos[fila].Set(colum, normValor(arDatos[fila][colum], maxAbs, minAbs, maxRel, minRel));
   }
   for(colum= nEntradas; normSalida && colum<(nEntradas+nSalidas); colum++)
   {
      maxAbs= arDatos[0][colum];
      minAbs= arDatos[0][colum];
      minRel= StringToDouble(arMaxMinRelSals[0]);
      maxRel= StringToDouble(arMaxMinRelSals[1]);
      for(fila= 0; fila<maxFila; fila++)
      {
         if(maxAbs<arDatos[fila][colum]) maxAbs= arDatos[fila][colum];
         if(minAbs>arDatos[fila][colum]) minAbs= arDatos[fila][colum];            
      }
      minAbsSalida= minAbs;
      maxAbsSalida= maxAbs;
      for(fila= 0; fila<maxFila; fila++)
         arDatos[fila].Set(colum, normValor(arDatos[fila][colum], maxAbs, minAbs, maxRel, minRel));
   }
   return;
}

//------------------------------------ NORMALIZATION FUNCTION ---------------------------------
double normValor(double valor, double maxAbs, double minAbs, double maxRel= 1, double minRel= -1)
{
   double valorNorm= 0;
   if(maxAbs>minAbs) valorNorm= (valor-minAbs)*(maxRel-minRel))/(maxAbs-minAbs) + minRel;
   return(valorNorm);
} 

//------------------------------------ ITERATE OVER INPUT/OUTPUT DATA STRING BY STRING -----------------------------------
void barajaDatosEntra(CMatrixDouble &arDatos, int nColum)
{
   int fila= 0, colum= 0, filaDestino= 0, nFilas= arDatos.Size();
   double filaTmp[];
   ArrayResize(filaTmp, nColum);
   MathSrand(GetTickCount());          //reset a random descendant series
   while(fila<nFilas)
   {
      filaDestino= randomEntero(0, nFilas-1);   //receive a target string in arbitrary manner
      if(filaDestino!=fila)
      {
         for(colum= 0; colum<nColum; colum++) filaTmp[colum]= arDatos[filaDestino][colum];
         for(colum= 0; colum<nColum; colum++) arDatos[filaDestino].Set(colum, arDatos[fila][colum]);
         for(colum= 0; colum<nColum; colum++) arDatos[fila].Set(colum, filaTmp[colum]);
         fila++;
      }
   }
   return;
}

//---------------------------------- RANDOM MOVING -------------------------------------------------------
int randomEntero(int minRel= 0, int maxRel= 1000)
{
   int num= (int)MathRound(randomDouble((double)minRel, (double)maxRel));
   return(num);
}

//---------------------------------- NETWORK TRAINING-------------------------------------------
double entrenaEvalRed(CMultilayerPerceptronShell &objRed, CMatrixDouble &arDatosEntrena, int ciclosEntrena= 2, double tasaAprende= 0.001)
{
   bool salir= false;
   double errorMedio= 0; string mens= "Entrenamiento Red";
   int k= 0, i= 0, codResp= 0,
       historialEntrena= arDatosEntrena.Size();
   CMLPReportShell infoEntren;
   ResetLastError();
   datetime tmpIni= TimeLocal();
   Alert("Neural network optimization start...");
   Alert("Wait a few minutes according to the amount of applied history.");
   Alert("...///...");
   if(propiedadRed(objRed, N_PESOS)<500)
      CAlglib::MLPTrainLM(objRed, arDatosEntrena, historialEntrena, tasaAprende, ciclosEntrena, codResp, infoEntren);
   else
      CAlglib::MLPTrainLBFGS(objRed, arDatosEntrena, historialEntrena, tasaAprende, ciclosEntrena, 0.01, 0, codResp, infoEntren);
   if(codResp==2 || codResp==6) errorMedio= CAlglib::MLPRMSError(objRed, arDatosEntrena, historialEntrena);
   else Print("Cod entrena Resp: ", codResp);
   datetime tmpFin= TimeLocal();
   Alert("NGrad ", infoEntren.GetNGrad(), " NHess ", infoEntren.GetNHess(), " NCholesky ", infoEntren.GetNCholesky());
   Alert("codResp ", codResp," Average training error "+DoubleToString(errorMedio, 8), " ciclosEntrena ", ciclosEntrena);
   Alert("tmpEntren ", DoubleToString(((double)(tmpFin-tmpIni))/60.0, 2), " min", "---> tmpIni ", TimeToString(tmpIni, _SEG), " tmpFin ", TimeToString(tmpFin, _SEG));
   infoError(GetLastError(), __FUNCTION__);
   return(errorMedio);
}


//-------------------------------- SAVE THE NETWORK TO THE DISK -------------------------------------------------
bool salvaRedFich(CMultilayerPerceptronShell &objRed, string nombArch= "")
{
   bool redSalvada= false;
   int k= 0, i= 0, j= 0, numCapas= 0, arNeurCapa[], neurCapa1= 1, funcTipo= 0, puntFichRed= 9999;
   double umbral= 0, peso= 0, media= 0, sigma= 0;
   if(nombArch=="") nombArch= "copiaSegurRed";
   nombArch= nombArch+".red";
   FileDelete(nombArch, FILE_COMMON);
   ResetLastError();
   puntFichRed= FileOpen(nombArch, FILE_WRITE|FILE_BIN|FILE_COMMON);
   redSalvada= puntFichRed!=INVALID_HANDLE;
   if(redSalvada)
   {
      numCapas= CAlglib::MLPGetLayersCount(objRed);   
      redSalvada= redSalvada && FileWriteDouble(puntFichRed, numCapas)>0;
      ArrayResize(arNeurCapa, numCapas);
      for(k= 0; redSalvada && k<numCapas; k++)
      {
         arNeurCapa[k]= CAlglib::MLPGetLayerSize(objRed, k);
         redSalvada= redSalvada && FileWriteDouble(puntFichRed, arNeurCapa[k])>0;
      }
      for(k= 0; redSalvada && k<numCapas; k++)
      {
         for(i= 0; redSalvada && i<arNeurCapa[k]; i++)
         {
            if(k==0)
            {
               CAlglib::MLPGetInputScaling(objRed, i, media, sigma);
               FileWriteDouble(puntFichRed, media);
               FileWriteDouble(puntFichRed, sigma);
            }
            else if(k==numCapas-1)
            {
               CAlglib::MLPGetOutputScaling(objRed, i, media, sigma);
               FileWriteDouble(puntFichRed, media);
               FileWriteDouble(puntFichRed, sigma);
            }
            CAlglib::MLPGetNeuronInfo(objRed, k, i, funcTipo, umbral);
            FileWriteDouble(puntFichRed, funcTipo);
            FileWriteDouble(puntFichRed, umbral);
            for(j= 0; redSalvada && k<(numCapas-1) && j<arNeurCapa[k+1]; j++)
            {
               peso= CAlglib::MLPGetWeight(objRed, k, i, k+1, j);
               redSalvada= redSalvada && FileWriteDouble(puntFichRed, peso)>0;
            }
         }      
      }
      FileClose(puntFichRed);
   }
   if(!redSalvada) infoError(_LastError, __FUNCTION__);
   return(redSalvada);
} 

//-------------------------------- RESTORE THE NETWORK FROM THE DISK -------------------------------------------------
bool recuperaRedFich(CMultilayerPerceptronShell &objRed, string nombArch= "")
{
   bool exito= false;
   int k= 0, i= 0, j= 0, nEntradas= 0, nSalidas= 0, nPesos= 0,
       numCapas= 0, arNeurCapa[], funcTipo= 0, puntFichRed= 9999;
   double umbral= 0, peso= 0, media= 0, sigma= 0;
   if(nombArch=="") nombArch= "copiaSegurRed";
   nombArch= nombArch+".red";
   puntFichRed= FileOpen(nombArch, FILE_READ|FILE_BIN|FILE_COMMON);
   exito= puntFichRed!=INVALID_HANDLE;
   if(exito)
   {
      numCapas= (int)FileReadDouble(puntFichRed);
      ArrayResize(arNeurCapa, numCapas);
      for(k= 0; k<numCapas; k++) arNeurCapa[k]= (int)FileReadDouble(puntFichRed); 
      if(numCapas==2) CAlglib::MLPCreate0(nNeuronEntra, nNeuronSal, objRed);
      else if(numCapas==3) CAlglib::MLPCreate1(nNeuronEntra, nNeuronCapa1, nNeuronSal, objRed);
      else if(numCapas==4) CAlglib::MLPCreate2(nNeuronEntra, nNeuronCapa1, nNeuronCapa2, nNeuronSal, objRed);
      exito= existeRed(arObjRed[0]);
      if(!exito) Print("neural network generation error ==> ", __FUNCTION__, " ", _LastError);
      else
      {
         CAlglib::MLPProperties(objRed, nEntradas, nSalidas, nPesos);
         Print("Restored the network having nº layers", propiedadRed(objRed, N_CAPAS));
         Print("Nº neurons in the input layer ", nEntradas);
         Print("Nº neurons in the hidden layer 1 ", nNeuronCapa1);
         Print("Nº neurons in the hidden layer 2 ", nNeuronCapa2);
         Print("Nº neurons in the output layer ", nSalidas);
         Print("Nº of the weight", nPesos);
         for(k= 0; k<numCapas; k++)
         {
            for(i= 0; i<arNeurCapa[k]; i++)
            {
               if(k==0)
               {
                  media= FileReadDouble(puntFichRed);
                  sigma= FileReadDouble(puntFichRed);
                  CAlglib::MLPSetInputScaling(objRed, i, media, sigma);
               }
               else if(k==numCapas-1)
               {
                  media= FileReadDouble(puntFichRed);
                  sigma= FileReadDouble(puntFichRed);
                  CAlglib::MLPSetOutputScaling(objRed, i, media, sigma);
               }
               funcTipo= (int)FileReadDouble(puntFichRed);
               umbral= FileReadDouble(puntFichRed);
               CAlglib::MLPSetNeuronInfo(objRed, k, i, funcTipo, umbral);
               for(j= 0; k<(numCapas-1) && j<arNeurCapa[k+1]; j++)
               {
                  peso= FileReadDouble(puntFichRed);
                  CAlglib::MLPSetWeight(objRed, k, i, k+1, j, peso);
               }
            }      
         }
      }
   }
   FileClose(puntFichRed);
   return(exito);
} 

//--------------------------------------- REQUEST THE NETWORK RESPONSE ---------------------------------
double respuestaRed(CMultilayerPerceptronShell &ObjRed, double &arEntradas[], double &arSalidas[], bool desnorm= false)
{
   double resp= 0, nNeuron= 0;
   CAlglib::MLPProcess(ObjRed, arEntradas, arSalidas);   
   if(desnorm)             //If output data normalization should be changed
   {
      nNeuron= ArraySize(arSalidas);
      for(int k= 0; k<nNeuron; k++)
         arSalidas[k]= desNormValor(arSalidas[k], maxAbsSalida, minAbsSalida, arMaxMinRelSals[1], arMaxMinRelSals[0]);
   }
   resp= arSalidas[0];
   return(resp);
}
/---------------------------------- ON TIMER --------------------------------------
void OnTimer()
{
   bool existe= false;
   string fichRed= "";
   if(tipoEAred==_OPTIMIZA)            //EA works in the "optimizer" mode
   {
      bool optimizar= false;
      int codS= 0,
          hora= infoFechaHora(TimeLocal(), _HORA);    //receive the full current time
      if(!redOptimizada) optimizar= horaOptim==hora && permReoptimDia();
      fichRed= "copiaSegurRed_"+Symbol()+".red";      //define the neural network file name
      existe= buscaFich(fichRed, "*.red");            //search the disk for the file where the neural network has been saved
      if(!existe || optimizar)
         redOptimizada= gestionRed(objRed, simb, intervEntrada!="", intervSalida!="", imprDatosEntrena, barajaDatos);
      if(hora>(horaOptim+6)) redOptimizada= false;    //upon 6 hours of the estimated time, the real optimized network is considered obsolete
      guardaVarGlobal(redOptimizada);                 //save "reoptimizada" (re-optimized) value on the disk
   }
   else if(tipoEAred==_EJECUTA)        //EA works in the "actuator" mode
   {
      datetime fechaUltOpt= 0;
      fichRed= "copiaSegurRed_"+Symbol()+".red";      //define neural network file name
      existe= buscaFich(fichRed, "*.red");            //search the disk for the file where the neural network has been saved
      if(existe)
      {
         fechaUltOpt= fechaModifFich(0, fichRed);     //define the last optimization date (network file modification)
         if(fechaUltOpt>fechaUltLectura)              //if the optimization date is later than the last reading
         {
            recuperaRedFich(objRed, fichRed);         //read and generate the new neural network
            fechaUltLectura= (double)TimeCurrent();
            guardaVarGlobal(fechaUltLectura);         //save the new reading date to the disk
            Print("Network restored after optimization... "+simb);      //display the message on a screen
         }
      }
      else Alert("tipoEAred==_EJECUTA --> Neural network file not found: "+fichRed+".red");
   }
   return;
}
//--------------------------------- ENABLE RE-OPTIMIZATION ---------------------------------
bool permReoptimDia()
{
   int diaSemana= infoFechaHora(TimeLocal(), _DSEM);
   bool permiso= (plazoOptim==_DIARIO && diaSemana!=6 && diaSemana!=0) ||     //optimize [every day from Tuesday to Saturday]
                 (plazoOptim==_DIA_ALTERNO && diaSemana%2==1) ||              //optimize [Tuesday, Thursday and Saturday]
                 (plazoOptim==_FIN_SEMANA && diaSemana==5);                   //optimize [Saturday]
   return(permiso);
}

//-------------------------------------- LOOK FOR FILE --------------------------------------------
bool buscaFich(string fichBusca, string filtro= "*.*", int carpeta= FILE_COMMON)
{
   bool existe= false;
   string fichActual= "";
   long puntBusca= FileFindFirst(filtro, fichActual, carpeta);
   if(puntBusca!=INVALID_HANDLE)
   {
      ResetLastError();
      while(!existe)
      {
         FileFindNext(puntBusca, fichActual);
         existe= fichActual==fichBusca;
      }
      FileFindClose(puntBusca);
   }
   else Print("File not found!");
   infoError(_LastError, __FUNCTION__);
   return(existe);