#include <JeeLib.h>

MilliTimer sendTimer;

int intervals[]  = { 200, 400, 2000, 4000, 200 };  // the intervals between events
int numIntervals = 5; // the number of intervals in the above list
int currentInterval = 0; // start at the first one which is 0 ( the max one is numIntervals-1 )


void setup () 
{
  Serial.begin(57600);
  Serial.println("[intervals example]");
  sendTimer.set(0);
  currentInterval = 0;
}


void loop () 
{
  int currentIntervalTime = intervals[currentInterval];
  int currentTime = millis();
  
  if (sendTimer.poll( currentIntervalTime )) // 5 seconds
  {
    Serial.print( currentTime );
    Serial.print(" - another interval passed: ");
    Serial.println( currentInterval );
    
    currentInterval = currentInterval + 1;
    
    // check if we've just reaeched the last interval
    if (currentInterval > numIntervals)
    {
      currentInterval = 0;
    }
    
    Serial.print( currentTime );    
    Serial.print(" - Next interval: ");
    Serial.println( currentInterval );
  }
}


