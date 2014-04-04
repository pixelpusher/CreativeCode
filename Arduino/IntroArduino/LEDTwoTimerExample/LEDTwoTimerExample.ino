#include <JeeLib.h>

// A simple example that uses independent
// timers to blink LEDs.
//
// Requires you to install Jeelib: 
// http://jeelabs.net/projects/jeelib/wiki 
//
// by Evan Raskob
// e.raskob@rave.ac.uk


MilliTimer LED1Timer;  // timer for 1st LED
MilliTimer LED2Timer;  // timer for 1st LED

boolean LED1_isOn = false;  // keeps track of whether LED is on or off
boolean LED2_isOn = false;  // keeps track of whether LED is on or off

int LED1_Pin = 13;    // pin this LED is attached to
int LED2_Pin = 12;    // pin this LED is attached to


void setup () 
{
  pinMode(LED1_Pin, OUTPUT);
  pinMode(LED2_Pin, OUTPUT);
}

void loop () 
{  
  //  
  // handle LED 1 blinking
  if (LED1Timer.poll(1000)) // 1000ms = 1 second
  {
    if (LED1_isOn) {
      digitalWrite(LED1_Pin, HIGH);
    }
    else
    {
      digitalWrite(LED1_Pin, LOW);
    }
    LED1_isOn = !LED1_isOn; 
  }
  
  //
  // handle LED 2 blinking
  if (LED2Timer.poll(750)) // 750ms = 0.75 second
  {
    if (LED2_isOn) {
      digitalWrite(LED2_Pin, HIGH);
    }
    else
    {
      digitalWrite(LED2_Pin, LOW);
    }
    LED2_isOn = !LED2_isOn; 
  }

 
  
  
}
