//+------------------------------------------------------------------+
//|                                                                  |
//|                        Copyright 2019, Andrew Saxby              |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019 Andrew Saxby"
#property link      "https://www.mql5.com"
#property version   "1.00"


#include <Object.mqh>


class EAScreenObject : public CObject {

//=========
private:
//=========


//=========
protected:
//=========

//=========
public:
//=========

      CWnd           *labelObject;  // Text Information
      CWnd           *valueObject;  // Changing value information
      string         sqlFieldName;
      string         screenName;
      int            rowNumber;
      int            columnNumber;
      bool           isVisible;


EAScreenObject();
~EAScreenObject();


};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EAScreenObject::EAScreenObject() {
}
EAScreenObject::~EAScreenObject() {

}