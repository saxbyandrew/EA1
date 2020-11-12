

struct Timing {
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
      int               marketSessions[4];         // Local store for YES/NO conversion from timing. values  
};

struct Technicals {
      int               strategyNumber;
      string            indicatorName;
      int               instanceNumber;
      ENUM_TIMEFRAMES   period;
      int               movingAverage;
      int               slowMovingAverage;
      int               fastMovingAverage;
      int               movingAverageMethod;
      ENUM_APPLIED_PRICE appliedPrice;
      double            stepValue;
      double            maxValue;
      int               signalPeriod;
      int               tenkanSen;
      int               kijunSen;
      int               spanB;
      int               kPeriod;
      int               dPeriod;
      unsigned          useBuffers;
      int               totalBuffers;
      int               ttl;
      string            inputPrefix;
      double            lowerLevel;
      double            upperLevel;
};

struct Network {
      int               strategyNumber;
      int               fileNumber;
      EAEnum            networkType; 
      int               numHiddenLayer1;
      int               numHiddenLayer2;
      int               year;
      int               month;
      int               day;
      int               hour;
      int               minute;
      int               dfSize;
      int               csvWriteDF;
      int               restarts;
      double            decay;
      double            wStep;
      int               maxITS;
      int               trainWeightsThreshold;
      double            triggerThreshold;

      // not in database
      int               numInput;
      int               numOutput;
      int               numWeights;
};

struct PositionBase {
      int               strategyNumber;
      int               magicNumber;
      int               deviationInPoints; 
      int               maxDaily;
      EAEnum            runMode; 
};

struct Position {
      int               strategyNumber;
      double            lotSize; 
      double            fpt;       // Dollar Value
      double            flt;       // same
      int               maxPositions;
      int               maxDailyHold;        // 0 close today +1 close tomorrow etc
      int               maxMg; 
      double            maxMulti;
      double            hedgeLossAmount;
      unsigned          closingTypes;
};

