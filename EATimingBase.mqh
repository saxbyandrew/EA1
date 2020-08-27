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

class EATimingBase : public CObject{

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
  EATimingBase();
  ~EATimingBase();

  virtual int Type() const {return _TIMING_BASE;};
  bool              sessionTimes();
  datetime          sessionTimes(EAEnum action);

};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATimingBase::EATimingBase() {

  #ifdef _DEBUG_STRATEGY_TIME
      ss="EATimingBase ->  Object Created ....";
      writeLog;
      pss
  #endif


}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EATimingBase::~EATimingBase() {

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK EATimingBase::getDayName(int dayOfWeek) {

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
void EATimingBase::getMarketSessionTimes() {

    #ifdef _DEBUG_STRATEGY_TIME
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
        #ifdef _DEBUG_STRATEGY_TIME
            ss=StringFormat(" -> Index:%d Start:%s End:%s",l,TimeToString(sessionStart, TIME_MINUTES),TimeToString(sessionEnd,TIME_MINUTES));
            writeLog;
            pss
        #endif 
        ++l;      
      }

      if (ustp.sessionTradingTime=="Session Time") {  
        sessionStart=sessionTimes(_FS_START);
        sessionEnd=sessionTimes(_LS_END);
        ustp.tradingStart=StringFormat("%s %s",TimeToString(sessionStart,TIME_DATE),TimeToString(sessionStart,TIME_MINUTES));
        ustp.tradingEnd=StringFormat("%s %s",TimeToString(sessionEnd,TIME_DATE),TimeToString(sessionEnd,TIME_MINUTES));
      }
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime EATimingBase::sessionTimes(EAEnum action) {

  #ifdef _DEBUG_STRATEGY_TIME Print(__FUNCTION__); #endif  

  MqlDateTime tm, tmLast; 
  datetime    closeDateTime=NULL;  
  int i;

  // make sure we have uptodate session times;
  getMarketSessionTimes();

  switch (action) { 

      case _CLOSE_AT_EOD:                                               // Strategy is requesting a EOD CLOSE  
        if (ustp.sessionTradingTime=="Any Time") 
          closeDateTime=sessionTimes(_LS_END);                          // Use end of last session
        if (ustp.sessionTradingTime=="Fixed Time") 
          closeDateTime=StringToTime(ustp.tradingEnd);                  // Use stategies end time 
        if (ustp.sessionTradingTime=="Session Time")  
          closeDateTime=sessionTimes(_LS_END);                          // Use end of session                                                      
         // Also check for delayed close/hold over requested from strategy
        if (usp.maxDailyHold>0) {                        
          TimeToStruct(closeDateTime+usp.maxDailyHold*86400,tm);        // Future date/time + number of days in the future (usp.maxTotalDaysToHold)
        return(StructToTime(tm));                                         // Return date time is stategy offset
        }         
        return closeDateTime;                                                // Return date time with NO offset                            
      break;

      case _FS_START:  // Get the start date/time of the first active session
        for (i=0;i<ArraySize(ustp.marketSessions);i++) {
            if (ustp.marketSessions[i]==_YES) {
              #ifdef _DEBUG_STRATEGY_TIME
                  Print(" -> _FS_START:",(StructToTime(ast[i].start)+ustp.marketOpenDelay*60));
                  Print(" -> With marketOpenDelay in secounds:",ustp.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].start)+ustp.marketOpenDelay*60);
            }
        }
        break;
      case _FS_END:  // Get the end date/time of the first active session
        for (i=0;i<ArraySize(ustp.marketSessions);i++) {
            if (ustp.marketSessions[i]==_YES) {
              #ifdef _DEBUG_STRATEGY_TIME
                  Print(" -> _FS_END:",(StructToTime(ast[i].end)+ustp.marketOpenDelay*60));
                  Print(" -> With usp.marketOpenDelay in secounds:",ustp.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].end)+ustp.marketCloseDelay*60);
            }
        }
        break;   
      case _LS_START:  // start of Last date/time session of the day for the last active session
        for (i=ArraySize(ustp.marketSessions)-1;i>=0;i--) {
            if (ustp.marketSessions[i]==_YES) {
              #ifdef _DEBUG_STRATEGY_TIME
                  Print(" -> _LS_START:",(StructToTime(ast[i].start)+ustp.marketOpenDelay*60));
                  Print(" -> With marketOpenDelay in secounds:",ustp.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].start)+ustp.marketOpenDelay*60);
            }
        }
      break; 
      case _LS_END:  // end of Last date/time session of the day for the last active session
        for (i=ArraySize(ustp.marketSessions)-1;i>=0;i--) {
            if (ustp.marketSessions[i]==_YES) {
              #ifdef _DEBUG_STRATEGY_TIME
                  Print(" -> _LS_END:",(StructToTime(ast[i].end)+ustp.marketOpenDelay*60));
                  Print(" -> With marketOpenDelayin secounds :",ustp.marketOpenDelay*60);
              #endif 
              return (StructToTime(ast[i].end)+ustp.marketCloseDelay*60);
            }
        }
      break;  
  }

  return TimeCurrent();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EATimingBase::sessionTimes() {

  #ifdef _DEBUG_STRATEGY_TIME Print(__FUNCTION__); #endif  

  MqlDateTime current;   
  TimeCurrent(current); 
  
    // No time or session restrictions apply
  if (ustp.sessionTradingTime=="Any Time") {  
      #ifdef _DEBUG_STRATEGY_TIME
        Print(" -> Trading allowed at any time");
      #endif           
      return true;   
  }
   // Can we trade weekends
  if (ustp.allowWeekendTrading&&(current.day_of_week==0||current.day_of_week==6)) {
      #ifdef _DEBUG_STRATEGY_TIME
        Print(" -> NO Weekend trading");
      #endif
      return false; // Its the weekend      
  }   
   // Get allowable trading times
  if (ustp.sessionTradingTime=="Fixed Time") {
      #ifdef _DEBUG_STRATEGY_TIME
        string ss=StringFormat(" -> Current Time:%s trading allowed %s to %s ",TimeToString(TimeCurrent()),ustp.tradingStart,ustp.tradingEnd);
        Print(ss) ;
      #endif
      // Fixed time 
      if (TimeCurrent()>StringToTime(ustp.tradingStart)&&TimeCurrent()<StringToTime(ustp.tradingEnd)) {
        #ifdef _DEBUG_STRATEGY_TIME
            Print(" -> FIXED_TIME trading ALLOWED ");
        #endif
        return true;
      } else {
        #ifdef _DEBUG_STRATEGY_TIME
            Print(" -> FIXED_TIME trading NOT ALLOWED outside of time range");
        #endif
        return false; 
      }  
  }
  if (ustp.sessionTradingTime==_SESSION_TIME) {  
    
      // Check curent time against Strategy start and end times based on session +/- offsets
      if (TimeCurrent()>sessionTimes(_FS_START)&&TimeCurrent()<sessionTimes(_LS_END)) {     
        #ifdef _DEBUG_STRATEGY_TIME
            Print(" -> SESSION_TIME trading ALLOWED ");
            string ss=StringFormat(" SESSION_TIME   Current Time:%s -- _FS_START %s -- _LS_END %s",TimeToString(TimeCurrent()), TimeToString(sessionTimes(_FS_START)), TimeToString(sessionTimes(_LS_END)));
            PrintFormat(ss);
        #endif 
        ustp.tradingStart=TimeToString(sessionTimes(_FS_START),TIME_DATE);
        ustp.tradingEnd=TimeToString(sessionTimes(_LS_END),TIME_DATE);
        return true;
      } else {
        #ifdef _DEBUG_STRATEGY_TIME
            PrintFormat(" -> SESSION_TIME trading NOT ALLOWED outside of range");
        #endif 
      }
  }
  return false;
}


