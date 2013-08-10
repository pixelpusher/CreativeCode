#include <JeeLib.h>

MilliTimer sendTimer;


void setup () 
{
  Serial.begin(57600);
  Serial.println("[timedSend]");
  sendTimer.set(0);
}

void loop () 
{  
  if (sendTimer.poll(5000)) // 5 seconds
  {
    Serial.println("5 seconds elapsed");
  }
}
