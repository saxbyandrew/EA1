

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
      int               versionNumber;
      // Not stored in DB !     
      int               marketSessions[4];         // Local store for YES/NO conversion from timing. values  
      int               maxDailyHold;
};

struct Technicals {
      int               strategyNumber;
      string            indicatorName;
      int               instanceNumber;
      ENUM_TIMEFRAMES   period;
      string            enumTimeFrames;
      int               movingAverage;
      int               slowMovingAverage;
      int               fastMovingAverage;
      ENUM_MA_METHOD    movingAverageMethod;
      string            enumMAMethod;
      ENUM_APPLIED_PRICE appliedPrice;
      string            enumAppliedPrice;
      double            stepValue;
      double            maxValue;
      int               signalPeriod;
      int               tenkanSen;
      int               kijunSen;
      int               spanB;
      int               kPeriod;
      int               dPeriod;
      ENUM_STO_PRICE    stocPrice;
      string            enumStoPrice;
      ENUM_APPLIED_VOLUME appliedVolume;
      string            enumAppliedVolume;
      int               useBuffers;
      int               ttl;
      double            incDecFactor;
      string            inputPrefix;
      double            lowerLevel;
      double            upperLevel;
      int               versionNumber;
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
      int               versionNumber;

      // not in database
      int               numInput;
      int               numOutput;
      int               numWeights;
};

struct Strategy {
      int               isActive;
      int               strategyNumber;
      int               magicNumber;
      int               deviationInPoints; 
      int               maxSpread;
      double            brokerAdminPercent;
      double            interBankPercentage;
      int               maxDaily;
      EAEnum            runMode; 
      int               entryBars;
      int               versionNumber;
      double            lotSize; 
      double            fpt;                    // Dollar Value
      double            flt;                    // same
      int               maxPositions;
      int               maxDailyHold;           // 0 close today +1 close tomorrow etc
      int               maxMg; 
      double            mgMultiplier;
      double            hedgeLossAmount;
      double            swapCosts;
      int               inProfitClosePosition;
      int               inLossClosePosition;
      int               inLossOpenMartingale;
      int               inLossOpenLongHedge;
      int               closeAtEOD;
};

