#include <JeeLib.h>

// A simple example that uses independent
// timers to blink LEDs. Uses a function to make it
// slightly easier to code.
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
  LED1_isOn = blinkLED(LED1_Pin, LED1Timer, 1000, LED1_isOn); 
  
  //  
  // handle LED 2 blinking
  LED2_isOn = blinkLED(LED2_Pin, LED2Timer, 750, LED2_isOn);
}




//
// here it is as a function:
//
boolean blinkLED( int pin, MilliTimer timer, int interval, boolean state)
{
  if (timer.poll(interval)) // 1000ms = 1 second
  {
    if (state) {
      digitalWrite(pin, HIGH);
    }
    else
    {
      digitalWrite(pin, LOW);
    }
    state = !state; 
  }
  return state;
}
