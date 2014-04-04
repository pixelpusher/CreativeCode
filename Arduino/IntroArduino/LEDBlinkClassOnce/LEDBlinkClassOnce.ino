
// A simple example that uses independent
// timers to turn LEDs on and off.
//
//
// by Evan Raskob
// e.raskob@rave.ac.uk

#include "LEDBlinker.h"

// create two LEDBlinker objects attached to two different ports
LEDBlinker led1(13);
LEDBlinker led2(12);

void setup()
{
  led1.off();
  led1.set(2000);  // set this LED to turn on in 2000ms
  
  led2.on();
  led2.set(2000);  // set this LED to turn off in 2000ms
}

void loop()
{
  // need to update the LEDs each loop
  // because there is no argument (number),
  // it only triggers once
  led1.blink(); 
  led2.blink(); 
}
  



