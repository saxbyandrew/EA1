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

    struct TimingBase {
      int               strategyNumber;            
      string            sessionTradingTime;         // "Any Time"" OR _"Session "ime" OR "Fixed Time""   
      string            tradingStart;               // NYSE time is 16:50=8:50 premarket to 23:00=16:00 market close
      string            tradingEnd;   
      string            marketSessions1;  
      string            marketSessions2; 
      string            marketSessions3; 
      int               marketOpenDelay;            // min delay Trade around the actual session times as given by the trade server
      int               marketCloseDelay; 
      int               allowWeekendTrading;        // _YES OR _NO 
      int               closeAtEOD;  
      int               maxDailyHold;    
      // Not stored in DB !     
      int               marketSessions[4];         // Local store for YES/NO conversion from tb. values  
    } tb;

  virtual int Type() const {return _TIMING_BASE;};
  bool              sessionTimes();
  datetime          sessionTimes(EAEnum action);

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

  string sql=StringFormat("SELECT sessionTradingTime,tradingStart,tradingEnd,marketSessions1,marketSessions3,marketOpenDelay,"
    "marketCloseDelay, allowWeekendTrading, closeAtEOD, maxDailyHold FROM TIMING, STRATEGY WHERE TIMING.strategyNumber=%d",strategyNumber);

  int request=DatabasePrepare(_mainDBHandle,sql);
      DatabaseRead(request);
      DatabaseColumnText      (request,1,tb.sessionTradingTime);
      DatabaseColumnText      (request,2,tb.tradingStart);
      DatabaseColumnText      (request,3,tb.tradingEnd);
      DatabaseColumnText      (request,4,tb.marketSessions1);
      DatabaseColumnText      (request,5,tb.marketSessions2);
      DatabaseColumnText      (request,6,tb.marketSessions3);
      DatabaseColumnInteger   (request,7,tb.marketOpenDelay);
      DatabaseColumnInteger   (request,8,tb.marketCloseDelay);
      DatabaseColumnInteger   (request,9,tb.allowWeekendTrading);
      DatabaseColumnInteger   (request,10,tb.closeAtEOD);
      DatabaseColumnInteger   (request,11,tb.maxDailyHold);

      #ifdef _DEBUG_PARAMETERS
        printf("Table TIMING -> StrategyNumber:%d sessionTradingTime:%s maxDailyHold:%d ",strategyNumber,tb.sessionTradingTime, tb.maxDailyHold);
      #endif 

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATiming::~EATiming() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
      #ifdef _WRITELOG
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

      if (tb.sessionTradingTime=="Session Time") {  
        sessionStart=sessionTimes(_FS_START);
        sessionEnd=sessionTimes(_LS_END);
        tb.tradingStart=StringFormat("%s %s",TimeToString(sessionStart,TIME_DATE),TimeToString(sessionStart,TIME_MINUTES));
        tb.tradingEnd=StringFormat("%s %s",TimeToString(sessionEnd,TIME_DATE),TimeToString(sessionEnd,TIME_MINUTES));
      }
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime EATiming::sessionTimes(EAEnum action) {

  #ifdef _DEBUG_TIME Print(__FUNCTION__); #endif  

  MqlDateTime tm, tmLast; 
  datetime    closeDateTime=NULL;  
  int i;

  // make sure we have uptodate session times;
  getMarketSessionTimes();

  switch (action) { 

      case _CLOSE_AT_EOD:                                               // Strategy is requesting a EOD CLOSE  
        if (tb.sessionTradingTime=="Any Time") 
          closeDateTime=sessionTimes(_LS_END);                          // Use end of last session
        if (tb.sessionTradingTime=="Fixed Time") 
          closeDateTime=StringToTime(tb.tradingEnd);                  // Use stategies end time 
        if (tb.sessionTradingTime=="Session Time")  
          closeDateTime=sessionTimes(_LS_END);                          // Use end of session                                                      
         // Also check for delayed close/hold over requested from strategy
        if (tb.maxDailyHold>0) {                        
          TimeToStruct(closeDateTime+tb.maxDailyHold*86400,tm);        // Future date/time + number of days in the future (usp.maxTotalDaysToHold)
        return(StructToTime(tm));                                         // Return date time is stategy offset
        }         
        return closeDateTime;                                                // Return date time with NO offset                            
      break;

      case _FS_START:  // Get the start date/time of the first active session
        for (i=0;i<ArraySize(tb.marketSessions);i++) {
            if (tb.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  Print(" -> _FS_START:",(StructToTime(ast[i].start)+tb.marketOpenDelay*60));
                  Print(" -> With marketOpenDelay in secounds:",tb.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].start)+tb.marketOpenDelay*60);
            }
        }
        break;
      case _FS_END:  // Get the end date/time of the first active session
        for (i=0;i<ArraySize(tb.marketSessions);i++) {
            if (tb.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  Print(" -> _FS_END:",(StructToTime(ast[i].end)+tb.marketOpenDelay*60));
                  Print(" -> With usp.marketOpenDelay in secounds:",tb.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].end)+tb.marketCloseDelay*60);
            }
        }
        break;   
      case _LS_START:  // start of Last date/time session of the day for the last active session
        for (i=ArraySize(tb.marketSessions)-1;i>=0;i--) {
            if (tb.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  Print(" -> _LS_START:",(StructToTime(ast[i].start)+tb.marketOpenDelay*60));
                  Print(" -> With marketOpenDelay in secounds:",tb.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].start)+tb.marketOpenDelay*60);
            }
        }
      break; 
      case _LS_END:  // end of Last date/time session of the day for the last active session
        for (i=ArraySize(tb.marketSessions)-1;i>=0;i--) {
            if (tb.marketSessions[i]==_YES) {
              #ifdef _DEBUG_TIME
                  Print(" -> _LS_END:",(StructToTime(ast[i].end)+tb.marketOpenDelay*60));
                  Print(" -> With marketOpenDelayin secounds :",tb.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].end)+tb.marketCloseDelay*60);
            }
        }
      break;  
  }

  return TimeCurrent();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATiming::sessionTimes() {

  #ifdef _DEBUG_TIME Print(__FUNCTION__); #endif  

  MqlDateTime current;   
  TimeCurrent(current); 
  
    // No time or session restrictions apply
  if (tb.sessionTradingTime=="Any Time") {  
      #ifdef _DEBUG_TIME
        Print(" -> Trading allowed at any time");
      #endif           
      return true;   
  }
   // Can we trade weekends
  if (tb.allowWeekendTrading&&(current.day_of_week==0||current.day_of_week==6)) {
      #ifdef _DEBUG_TIME
        Print(" -> NO Weekend trading");
      #endif
      return false; // Its the weekend      
  }   
   // Get allowable trading times
  if (tb.sessionTradingTime=="Fixed Time") {
      #ifdef _DEBUG_TIME
        string ss=StringFormat(" -> Current Time:%s trading allowed %s to %s ",TimeToString(TimeCurrent()),tb.tradingStart,tb.tradingEnd);
        Print(ss) ;
      #endif
      // Fixed time 
      if (TimeCurrent()>StringToTime(tb.tradingStart)&&TimeCurrent()<StringToTime(tb.tradingEnd)) {
        #ifdef _DEBUG_TIME
            Print(" -> FIXED_TIME trading ALLOWED ");
        #endif
        return true;
      } else {
        #ifdef _DEBUG_TIME
            Print(" -> FIXED_TIME trading NOT ALLOWED outside of time range");
        #endif
        return false; 
      }  
  }
  if (tb.sessionTradingTime==_SESSION_TIME) {  
    
      // Check curent time against Strategy start and end times based on session +/- offsets
      if (TimeCurrent()>sessionTimes(_FS_START)&&TimeCurrent()<sessionTimes(_LS_END)) {     
        #ifdef _DEBUG_TIME
            Print(" -> SESSION_TIME trading ALLOWED ");
            string ss=StringFormat(" SESSION_TIME   Current Time:%s -- _FS_START %s -- _LS_END %s",TimeToString(TimeCurrent()), TimeToString(sessionTimes(_FS_START)), TimeToString(sessionTimes(_LS_END)));
            PrintFormat(ss);
        #endif 
        tb.tradingStart=TimeToString(sessionTimes(_FS_START),TIME_DATE);
        tb.tradingEnd=TimeToString(sessionTimes(_LS_END),TIME_DATE);
        return true;
      } else {
        #ifdef _DEBUG_TIME
            PrintFormat(" -> SESSION_TIME trading NOT ALLOWED outside of range");
        #endif 
      }
  }
  return false;
}


