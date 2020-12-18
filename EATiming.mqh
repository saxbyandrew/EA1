//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Object.mqh>

#include "EAEnum.mqh"


class EATiming : public CObject{

//=========
private:
//=========

  string ss;
  //void  copyValuesFromOptimizationInputs();
  //void  updateValuesToDatabase(string sql);

//=========
protected:
//=========

  struct SessionTimes {
      MqlDateTime       start;                            // trading session time slot
      MqlDateTime       end; 
  } ast[5]; 

//=========

  ENUM_DAY_OF_WEEK  getDayName(int dayOfWeek);
  void              getMarketSessionTimes();



//=========
public:
//=========
  EATiming(int strategyNumber);
  ~EATiming();

  Timing timing;    // See EAStructures.mqh

  virtual int Type() const {return _TIMING_BASE;};
  bool              tradingTimes();
  datetime          tradingTimes(EAEnum action);


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATiming::EATiming(int strategyNumber) {

  #ifdef _DEBUG_TIME
      ss="EATiming ->  Object Created ....";
      writeLog;
      pss
  #endif

  string sql=StringFormat("SELECT TIMING.*, maxDailyHold FROM TIMING INNER JOIN STRATEGY ON STRATEGY.strategyNumber=TIMING.strategyNumber WHERE TIMING.strategyNumber=%d",strategyNumber);

  int request=DatabasePrepare(_mainDBHandle,sql);
      DatabaseRead(request);
      DatabaseColumnText      (request,1,timing.sessionTradingTime);
      DatabaseColumnText      (request,2,timing.tradingStart);
      DatabaseColumnText      (request,3,timing.tradingEnd);
      DatabaseColumnText      (request,4,timing.marketSessions1);
      DatabaseColumnText      (request,5,timing.marketSessions2);
      DatabaseColumnText      (request,6,timing.marketSessions3);
      DatabaseColumnInteger   (request,7,timing.marketOpenDelay);
      DatabaseColumnInteger   (request,8,timing.marketCloseDelay);
      DatabaseColumnInteger   (request,9,timing.allowWeekendTrading);
      DatabaseColumnInteger   (request,10,timing.versionNumber);
      DatabaseColumnInteger   (request,11,timing.maxDailyHold);
/*
      // Over write with values given to us during optimization
    if (MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) {
        copyValuesFromOptimizationInputs();  
        #ifdef _DEBUG_TIME
            ss="EATiming -> in MQL_OPTIMIZATION OR MQL_TESTER MODE copy INPUT values";
            writeLog
            pss
        #endif
        
    } else {
        #ifdef _DEBUG_TIME

            ss="EATiming -> Using values directly from the DB";
            writeLog
            pss

        #endif
    }
*/

      #ifdef _DEBUG_PARAMETERS
        printf("Table TIMING -> StrategyNumber:%d sessionTradingTime:%s maxDailyHold:%d ",strategyNumber,timing.sessionTradingTime, timing.maxDailyHold);
      #endif 

      // Convert the 3 text field to a int Array
      if (timing.marketSessions1=="YES") {
          timing.marketSessions[0]=_YES;
      } else {
          timing.marketSessions[0]=_NO; 
      }     
      if (timing.marketSessions2=="YES") {
          timing.marketSessions[1]=_YES; 
      } else {
          timing.marketSessions[1]=_NO; 
      } 
      if (timing.marketSessions3=="YES") {
          timing.marketSessions[2]=_YES;
      } else {
          timing.marketSessions[2]=_NO; 
      }

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATiming::~EATiming() {

}
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATiming::updateValuesToDatabase(string sql) {

    if (!DatabaseExecute(_mainDBHandle, sql)) {
        ss=StringFormat("copyValuesToDatabase -> Failed to insert with code %d", GetLastError());
        pss
        ss=sql;
        pss
        writeLog
    } else {
        #ifdef _DEBUG_LONG_POSITIONS
            ss="copyValuesToDatabase -> UPDATE succcess";
            pss
            ss=sql;
            pss
        #endif
    }  
}
*/
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATiming::copyValuesFromOptimizationInputs() {

    #ifdef _DEBUG_LONG_POSITIONS
        pline
        ss="EAStrategyLong -> copyValuesFromOptimizationInputs";
        writeLog
        pss
        pline
    #endif

    strategy.lotSize=ilsize;
    strategy.fpt=ifpt;
    strategy.flt=iflt;
    strategy.maxPositions=imaxPositions;
    strategy.maxDailyHold=imaxdailyhold;
    strategy.maxMg=imaxmg;
    strategy.maxDaily=imaxdaily;

       // If we are running a single tester line then update the DB
    if (MQLInfoInteger(MQL_TESTER)) {
        strategy.versionNumber++;
        string sql=StringFormat("UPDATE TIMING SET lotSize=%.2f, fpt=%.2f, flt=%.2f, maxPositions=%d, maxDailyHold=%d, maxMg=%d, maxDaily=%d, versionNumber=%d "
            "WHERE strategyNumber=%d",
            strategy.lotSize, strategy.fpt,strategy.flt, strategy.maxPositions, strategy.maxDailyHold, strategy.maxMg, strategy.maxDaily, strategy.versionNumber, strategy.strategyNumber);
        updateValuesToDatabase(sql);
    }
}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK EATiming::getDayName(int dayOfWeek) {

  switch (dayOfWeek) {
      case 0: return SUNDAY;
      case 1: return MONDAY;
      case 2: return TUESDAY;
      case 3: return WEDNESDAY;
      case 4: return THURSDAY;
      case 5: return FRIDAY;
      case 6: return SATURDAY;
  }  
  return SUNDAY;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EATiming::getMarketSessionTimes() {

    #ifdef _DEBUG_TIME
      ss="getMarketSessionTimes ->  ....";
      writeLog;
    #endif

  MqlDateTime tm;
  static datetime sessionStart, sessionEnd, lastDay;
  int l=0;

   // Get session details once a day
  if (lastDay!=iTime(NULL,PERIOD_D1,0)) {
      lastDay=iTime(NULL,PERIOD_D1,0);
      TimeCurrent(tm);
      #ifdef _DEBUG_TIME
        ss=StringFormat(" -> Get session details once a day Today is:%s",TimeToString(TimeCurrent()));
        writeLog;
        pss
      #endif 
      
      // Get and store the current days session times
      while (SymbolInfoSessionTrade(_Symbol,getDayName(tm.day_of_week),l,sessionStart,sessionEnd)) {           
        TimeToStruct(sessionStart,ast[l].start);
        TimeToStruct(sessionEnd,ast[l].end);  
        
        // Trade server returns incorrect date in 1970 !
        // update it to todays date.
        ast[l].start.year=tm.year;
        ast[l].start.day=tm.day;
        ast[l].start.mon=tm.mon;
        ast[l].end.year=tm.year;
        ast[l].end.day=tm.day;
        ast[l].end.mon=tm.mon;
        #ifdef _DEBUG_TIME
            ss=StringFormat(" -> Index:%d Start:%s End:%s",l,TimeToString(sessionStart, TIME_MINUTES),TimeToString(sessionEnd,TIME_MINUTES));
            writeLog;
            pss
        #endif 
        ++l;      
      }

      if (timing.sessionTradingTime=="Session Time") {  
        sessionStart=tradingTimes(_FS_START);
        sessionEnd=tradingTimes(_LS_END);
        timing.tradingStart=StringFormat("%s %s",TimeToString(sessionStart,TIME_DATE),TimeToString(sessionStart,TIME_MINUTES));
        timing.tradingEnd=StringFormat("%s %s",TimeToString(sessionEnd,TIME_DATE),TimeToString(sessionEnd,TIME_MINUTES));
      }
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime EATiming::tradingTimes(EAEnum action) {

    #ifdef _DEBUG_TIME
      ss="EATiming -> tradingTimes";
      writeLog;
      pss
    #endif

  MqlDateTime tm, tmLast; 
  datetime    closeDateTime=NULL;  
  int i;

  // make sure we have uptodate session times;
  getMarketSessionTimes();

  switch (action) { 

      case _CLOSE_AT_EOD:                                               // Strategy is requesting a EOD CLOSE  
        if (timing.sessionTradingTime=="Any Time") 
          closeDateTime=tradingTimes(_LS_END);                          // Use end of last session
        if (timing.sessionTradingTime=="Fixed Time") 
          closeDateTime=StringToTime(timing.tradingEnd);                // Use stategies end time 
        if (timing.sessionTradingTime=="Session Time")  
          closeDateTime=tradingTimes(_LS_END);                          // Use end of session                                                      
         // Also check for delayed close/hold over requested from strategy
        if (timing.maxDailyHold>0) {                        
          TimeToStruct(closeDateTime+timing.maxDailyHold*86400,tm);        // Future date/time + number of days in the future (usp.maxTotalDaysToHold)
        return(StructToTime(tm));                                         // Return date time is stategy offset
        }         
        return closeDateTime;                                                // Return date time with NO offset                            
      break;

      case _FS_START:  // Get the start date/time of the first active session
        for (i=0;i<ArraySize(timing.marketSessions);i++) {
            if (timing.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  ss=StringFormat(" -> _FS_START:%s",TimeToString(StructToTime(ast[i].start)+timing.marketOpenDelay*60));
                  pss
                  writeLog
                  ss=StringFormat(" -> With marketOpenDelay in secounds:%d",timing.marketOpenDelay*60);
                  pss
                  writeLog
              #endif 
              return (StructToTime(ast[i].start)+timing.marketOpenDelay*60);
            }
        }
        break;
      case _FS_END:  // Get the end date/time of the first active session
        for (i=0;i<ArraySize(timing.marketSessions);i++) {
            if (timing.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  ss=StringFormat(" -> _FS_END:%s",TimeToString(StructToTime(ast[i].end)+timing.marketOpenDelay*60));
                  pss
                  writeLog
                  ss=StringFormat(" -> With usp.marketOpenDelay in secounds:%d",timing.marketOpenDelay*60);
                  pss
                  writeLog
              #endif 
              return (StructToTime(ast[i].end)+timing.marketCloseDelay*60);
            }
        }
        break;   
      case _LS_START:  // start of Last date/time session of the day for the last active session
        for (i=ArraySize(timing.marketSessions)-1;i>=0;i--) {
            if (timing.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  ss=StringFormat(" -> _LS_START:%s",TimeToString(StructToTime(ast[i].start)+timing.marketOpenDelay*60));
                  pss
                  writeLog
                  ss=StringFormat(" -> With marketOpenDelay in secounds:%d",timing.marketOpenDelay*60);
                  pss
                  writeLog
              #endif 
              return (StructToTime(ast[i].start)+timing.marketOpenDelay*60);
            }
        }
      break; 
      case _LS_END:  // end of Last date/time session of the day for the last active session
        for (i=ArraySize(timing.marketSessions)-1;i>=0;i--) {
            if (timing.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  ss=StringFormat(" -> _LS_END:%s",TimeToString(StructToTime(ast[i].end)+timing.marketOpenDelay*60));
                  pss
                  writeLog
                  ss=StringFormat(" -> With marketOpenDelayin secounds :%d",timing.marketOpenDelay*60);
                  pss
                  writeLog
              #endif 
              return (StructToTime(ast[i].end)+timing.marketCloseDelay*60);
            }
        }
      break;  
  }

  return TimeCurrent();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATiming::tradingTimes() {

    #ifdef _DEBUG_TIME
      ss="EATiming -> tradingTimes";
      writeLog;
      pss
    #endif

  MqlDateTime current;   
  TimeCurrent(current); 
  
    // No time or session restrictions apply
  if (timing.sessionTradingTime=="Any Time") {  
      #ifdef _DEBUG_TIME
        ss="EATiming -> tradingTimes -> Trading allowed at any time";
        pss
        writeLog
      #endif           
      return true;   
  }
   // Can we trade weekends
  if (timing.allowWeekendTrading&&(current.day_of_week==0||current.day_of_week==6)) {
      #ifdef _DEBUG_TIME
        ss="EATiming -> tradingTimes -> NO Weekend trading";
        pss
        writeLog
      #endif
      return false; // Its the weekend      
  }   
   // Get allowable trading times
  if (timing.sessionTradingTime=="Fixed Time") {
      #ifdef _DEBUG_TIME
        string ss=StringFormat("EATiming -> tradingTimes -> Current Time:%s trading allowed %s to %s ",TimeToString(TimeCurrent()),timing.tradingStart,timing.tradingEnd);
        pss
        writeLog
      #endif
      // Fixed time 
      if (TimeCurrent()>StringToTime(timing.tradingStart)&&TimeCurrent()<StringToTime(timing.tradingEnd)) {
        #ifdef _DEBUG_TIME
            ss="EATiming -> tradingTimes -> FIXED_TIME trading ALLOWED ";
            pss
            writeLog
        #endif
        return true;
      } else {
        #ifdef _DEBUG_TIME
            ss="EATiming -> tradingTimes -> FIXED_TIME trading NOT ALLOWED outside of time range";
            pss
            writeLog
        #endif
        return false; 
      }  
  }
  if (timing.sessionTradingTime=="Session Time") {  
    #ifdef _DEBUG_TIME
      "EATiming ->  tradingTimes -> Using SESSION_TIME trading";
      pss
      writeLog
      string ss=StringFormat(" SESSION_TIME   Current Time:%s -- _FS_START %s -- _LS_END %s",TimeToString(TimeCurrent()), TimeToString(tradingTimes(_FS_START)), TimeToString(tradingTimes(_LS_END)));
      pss
      writeLog
    #endif 
    
      // Check curent time against Strategy start and end times based on session +/- offsets
      if (TimeCurrent()>tradingTimes(_FS_START)&&TimeCurrent()<tradingTimes(_LS_END)) {     
        #ifdef _DEBUG_TIME
            ss="EATiming ->  tradingTimes -> SESSION_TIME trading ALLOWED ";
            pss
            writeLog
            string ss=StringFormat(" SESSION_TIME   Current Time:%s -- _FS_START %s -- _LS_END %s",TimeToString(TimeCurrent()), TimeToString(tradingTimes(_FS_START)), TimeToString(tradingTimes(_LS_END)));
            pss
            writeLog
        #endif 
        timing.tradingStart=TimeToString(tradingTimes(_FS_START),TIME_DATE);
        timing.tradingEnd=TimeToString(tradingTimes(_LS_END),TIME_DATE);
        return true;
      } else {
        #ifdef _DEBUG_TIME
            ss="EATiming ->  tradingTimes -> FSESSION_TIME trading NOT ALLOWED outside of range";
            pss
            writeLog
        #endif 
      }
  }
  return false;
}


