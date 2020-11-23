//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "EAEnum.mqh"


//=========
class EAStrategyUpdate {
//=========

//=========
private:
//=========
   string               ss;

   PositionBase         base;
   Position             position;
   Timing               timing;
   Technicals           tech;
   Network              nnetwork;

   int  strategyNumber, passNumber;

   void strategyUpdate();
   void networkUpdate();
   void technicalsUpdate();

   void databaseUpdate(string tableName,string fieldName, double val);
   void databaseUpdate(string tableName, string fieldName, int intValue);

//=========
protected:
//=========


//=========
public:
//=========
   EAStrategyUpdate();
   ~EAStrategyUpdate();
   

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyUpdate::EAStrategyUpdate() {

   #ifdef _DEBUG_STRATEGY_UPDATE
      printf ("EAStrategyUpdate ->  Object Created ....");
      writeLog
      pss
   #endif

       //--- Open the optimization database in the common terminal folder
   if (_optimizeDBHandle==NULL) {
      _optimizeDBHandle=DatabaseOpen(_optimizeDBName, DATABASE_OPEN_READWRITE | DATABASE_OPEN_COMMON);
      if (_optimizeDBHandle==INVALID_HANDLE) {
         #ifdef _DEBUG_MYEA
            ss=StringFormat("OnInit ->  Failed to open optimization DB with errorcode:%d",GetLastError());
            writeLog
            pss
         #endif
         ExpertRemove();
      } else {
         #ifdef _DEBUG_MYEA
            ss="OnInit -> Open optimization DB success";
            writeLog
            pss
         #endif
      }
   }


   // Get the selected pass value record to be used to update the main DB. This value is MANUALLY selected by me, and refers to a single
   // optimization row of values to be used in a copy into the main DB. NOTE the strategyType value refers to the long / short etc number and
   // is equal to the optimizationRefNumber which was initially chosen to filter which strategy needs to be optimized

   string sql="SELECT COUNT(), strategyNumber, passNumber FROM OPTIMIZATION WHERE reload=1";
   ss=sql;
   pss
   writeLog

   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> EAStrategyUpdate DatabaseRead DB request failed code:%d",GetLastError()); 
      pss
      writeLog
      //ExpertRemove();
   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
      ss=" -> EAStrategyUpdate DatabaseRead -> SUCCESS";
      writeLog
      pss
      #endif 
   }

   DatabaseRead(request);
   DatabaseColumnInteger    (request,1,strategyNumber);
   DatabaseColumnInteger    (request,2,passNumber);

   #ifdef _DEBUG_STRATEGY_UPDATE
      ss=StringFormat("EAStrategyUpdate -> StrategyNumber:%d Pass Number:%d",strategyNumber,passNumber);
      writeLog
      pss
   #endif 

   //strategyUpdate();
   //networkUpdate();
   technicalsUpdate();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAStrategyUpdate::~EAStrategyUpdate() {


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyUpdate::databaseUpdate(string tableName, string fieldName, int intValue) {

   string sql=StringFormat("UPDATE %s SET %s=%1.2f WHERE strategyNumber=%d",tableName,fieldName,intValue,strategyNumber);
   if (!DatabaseExecute(_mainDBHandle,sql)) {
      #ifdef _DEBUG_STRATEGY_UPDATE
         ss="EAStrategyUpdate -> databaseUpdate -> FAILED";
         writeLog
         pss
         ss=sql;
         writeLog
         pss
         #endif 
      return;
   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
      ss="EAStrategyUpdate -> databaseUpdate -> SUCCESS";
         writeLog
         pss
         ss=sql;
         writeLog
         pss
      #endif 

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyUpdate::databaseUpdate(string tableName, string fieldName, double doubleValue) {

   string sql=StringFormat("UPDATE %s SET %s=%1.2f WHERE strategyNumber=%d",tableName,fieldName,doubleValue,strategyNumber);
   if (!DatabaseExecute(_mainDBHandle,sql)) {
      #ifdef _DEBUG_STRATEGY_UPDATE
         ss="EAStrategyUpdate -> databaseUpdate -> FAILED";
         writeLog
         pss
         ss=sql;
         writeLog
         pss
         #endif 
      return;
   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
      ss="EAStrategyUpdate -> databaseUpdate -> SUCCESS";
         writeLog
         pss
         ss=sql;
         writeLog
         pss
      #endif 

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyUpdate::strategyUpdate() {

   int cnt;

   // Get all fields from the base optimization strategy table, filtered by the passNumber which in turn was "selected" 
   // by flagging the reload field. NOTE COUNT is a sanity check as we can only receive 1 row
   string sql=StringFormat("SELECT COUNT(), * FROM STRATEGY WHERE passNumber = %d",passNumber);
   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> EAStrategyUpdate -> strategyUpdateDatabaseRead DB request failed code:%d",GetLastError()); 
      pss
      writeLog
      ExpertRemove();
   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
      ss="  -> EAStrategyUpdate -> strategyUpdate DatabaseRead -> SUCCESS";
      writeLog
      pss
      #endif 
   }

   DatabaseRead(request);
   DatabaseColumnInteger   (request,0,cnt);
   DatabaseColumnDouble    (request,1,position.lotSize);
   DatabaseColumnDouble    (request,2,position.fpt);
   DatabaseColumnDouble    (request,3,position.flt);
   DatabaseColumnInteger   (request,4,position.maxPositions);
   DatabaseColumnInteger   (request,5,base.maxDaily);
   DatabaseColumnInteger   (request,6,position.maxDailyHold);
   DatabaseColumnInteger   (request,7,position.maxMg);
   DatabaseColumnDouble    (request,8,position.mgMultiplier);
   DatabaseColumnDouble    (request,9,position.hedgeLossAmount);

   #ifdef _DEBUG_STRATEGY_UPDATE
      ss=StringFormat("EAStrategyUpdate -> strategyUpdate -> StrategyNumber:%d Pass Number:%d",strategyNumber,passNumber);
      writeLog
      pss
   #endif 

   // Only 1 row is allowed which should be unique as in the passNumber is unique
   if (cnt>1) {
      #ifdef _DEBUG_STRATEGY_UPDATE
         ss="EAStrategyUpdate -> ERROR the count > 1";
         writeLog
         pss
         ExpertRemove();
      #endif 

   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
         ss=StringFormat("EAStrategyUpdate -> strategyUpdate -> will update passnumber:%d %.2f %.2f %.2f",passNumber,position.lotSize,position.fpt,position.mgMultiplier);
         writeLog
         pss
      #endif 


      // INT
      databaseUpdate("STRATEGY","maxPositions",position.maxPositions);
      databaseUpdate("STRATEGY","maxDaily",base.maxDaily);
      databaseUpdate("STRATEGY","maxDailyHold",position.maxDailyHold);
      databaseUpdate("STRATEGY","maxMg",position.maxMg);
      // DOUBLES
      databaseUpdate("STRATEGY","lotSize",position.lotSize);
      databaseUpdate("STRATEGY","fpt",position.fpt);
      databaseUpdate("STRATEGY","flt",position.flt);
      databaseUpdate("STRATEGY","mgMultiplier",position.mgMultiplier);
      databaseUpdate("STRATEGY","hedgeLossAmount",position.hedgeLossAmount);

   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyUpdate::networkUpdate() {

   int cnt;

   // Get all fields from the base optimization strategy table, filtered by the passNumber which in turn was "selected" 
   // by flagging the reload field. NOTE COUNT is a sanity check as we can only receive 1 row

   string sql=StringFormat("SELECT COUNT(), * FROM NNETWORK WHERE passNumber = %d",passNumber);
   int request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat("EAStrategyUpdate -> networkUpdate DatabaseRead DB request failed code:%d",GetLastError()); 
      pss
      writeLog
      ExpertRemove();
   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
      ss="EAStrategyUpdate  -> networkUpdate DatabaseRead -> SUCCESS";
      writeLog
      pss
      #endif 
   }

   DatabaseRead(request);
   DatabaseColumnInteger   (request,0,cnt);
   DatabaseColumnInteger   (request,1,nnetwork.networkType);
   DatabaseColumnInteger   (request,2,nnetwork.dfSize);
   DatabaseColumnDouble    (request,3,nnetwork.triggerThreshold);
   DatabaseColumnInteger   (request,4,nnetwork.trainWeightsThreshold);
   DatabaseColumnInteger   (request,5,nnetwork.numHiddenLayer1);
   DatabaseColumnInteger   (request,6,nnetwork.numHiddenLayer2);
   DatabaseColumnInteger   (request,7,nnetwork.restarts);
   DatabaseColumnDouble    (request,8,nnetwork.decay);
   DatabaseColumnDouble    (request,9,nnetwork.wStep);
   DatabaseColumnInteger   (request,10,nnetwork.maxITS);


   #ifdef _DEBUG_STRATEGY_UPDATE
      ss=StringFormat("EAStrategyUpdate -> networkUpdate -> StrategyNumber:%d Pass Number:%d",strategyNumber,passNumber);
      writeLog
      pss
   #endif 

   // Only 1 row is allowed which should be unique as in the passNumber is unique
   if (cnt>1) {
      #ifdef _DEBUG_STRATEGY_UPDATE
         ss="EAStrategyUpdate -> ERROR the count > 1";
         writeLog
         pss
         ExpertRemove();
      #endif 

   } else {
      #ifdef _DEBUG_STRATEGY_UPDATE
         ss=StringFormat("EAStrategyUpdate -> will update passnumber:%d %d %d %.5f",passNumber,nnetwork.networkType,nnetwork.dfSize,nnetwork.triggerThreshold);
         writeLog
         pss
      #endif 


      // INT
      databaseUpdate("NNETWORKS","networkType",(int) nnetwork.networkType);
      databaseUpdate("NNETWORKS","dfSize",nnetwork.dfSize);
      databaseUpdate("NNETWORKS","trainWeightsThreshold",nnetwork.trainWeightsThreshold);
      databaseUpdate("NNETWORKS","numHiddenLayer1",nnetwork.numHiddenLayer1);
      databaseUpdate("NNETWORKS","numHiddenLayer2",nnetwork.numHiddenLayer2);
      databaseUpdate("NNETWORKS","restarts",nnetwork.restarts);
      databaseUpdate("NNETWORKS","maxITS",nnetwork.maxITS);

      // DOUBLES
      databaseUpdate("NNETWORKS","triggerThreshold",nnetwork.triggerThreshold);
      databaseUpdate("NNETWORKS","decay",nnetwork.decay);
      databaseUpdate("NNETWORKS","wStep",nnetwork.wStep);


   }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EAStrategyUpdate::technicalsUpdate() {

   string sql;
   int request;

   #ifdef _DEBUG_TECHNICAL_PARAMETERS
      ss="EAStrategyUpdate -> technicalsUpdate -> .... ";
      pss
      writeLog
   #endif

   sql=StringFormat("SELECT * FROM TECHNICALS where passNumber=%d",passNumber);  
   request=DatabasePrepare(_optimizeDBHandle,sql);
   if (request==INVALID_HANDLE) {
      ss=StringFormat(" -> EAStrategyUpdate -> technicalsUpdate DB request failed %d with code:%d",passNumber, GetLastError()); 
      writeLog
      pss
      ss=sql;
      writeLog
      pss
      ExpertRemove();
   } else {


      while (DatabaseRead(request)) {

         DatabaseColumnText         (request,1,tech.indicatorName);
         DatabaseColumnInteger      (request,2,tech.period);
         DatabaseColumnInteger      (request,3,tech.movingAverage);
         DatabaseColumnInteger      (request,4,tech.slowMovingAverage);
         DatabaseColumnInteger      (request,5,tech.fastMovingAverage);
         DatabaseColumnInteger      (request,6,tech.movingAverageMethod);
         DatabaseColumnInteger      (request,7,tech.appliedPrice);
         DatabaseColumnDouble       (request,8,tech.stepValue);
         DatabaseColumnDouble       (request,9,tech.maxValue);
         DatabaseColumnInteger      (request,10,tech.signalPeriod);
         DatabaseColumnInteger      (request,11,tech.tenkanSen);
         DatabaseColumnInteger      (request,12,tech.kijunSen);
         DatabaseColumnInteger      (request,13,tech.spanB);
         DatabaseColumnInteger      (request,14,tech.kPeriod);
         DatabaseColumnInteger      (request,15,tech.dPeriod);
         DatabaseColumnInteger      (request,16,tech.stocPrice);
         DatabaseColumnInteger      (request,17,tech.ttl);
         DatabaseColumnText         (request,18,tech.inputPrefix); 
         DatabaseColumnDouble       (request,19,tech.lowerLevel);
         DatabaseColumnDouble       (request,20,tech.upperLevel);

         // Create a update string for the main database
         sql=StringFormat("UPDATE TECHNICALS SET period=%d, movingAverage=%d, slowMovingAverage=%d, fastMovingAverage=%d, movingAverageMethod=%d,"
         "appliedPrice=%d, stepValue=%.5f, maxValue=%.5f, signalPeriod=%d, tenkanSen=%d, kijunSen=%d, spanB=%d, kPeriod=%d, dPeriod=%d"
         " WHERE strategyNumber=%d AND inputPrefix='%s'",tech.period,tech.movingAverage,tech.slowMovingAverage,tech.fastMovingAverage,tech.movingAverageMethod,
         tech.appliedPrice,tech.stepValue,tech.maxValue,tech.signalPeriod,tech.tenkanSen,tech.kijunSen,tech.spanB,tech.kPeriod,tech.dPeriod,strategyNumber,tech.inputPrefix);
         if (!DatabaseExecute(_mainDBHandle, sql)) {
            ss=StringFormat(" -> Failed to insert NEW values with code %d",GetLastError());
            pss
            writeLog
            ss=sql;
            pss
            writeLog
         } else {
         #ifdef _DEBUG_OPTIMIZATION
            ss="-> EAStrategyUpdate -> technicalsUpdate DB request SUCCESS";
            pss
            writeLog
         #endif
         }
         
      }
   }

}


