
// A simple example that uses independent
// timers to blink LEDs. Uses a function to make it
// slightly easier to code.
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
  //nothing to do!
}

void loop()
{
  led1.blink(250); // set this one to blink every 250ms
  led2.blink(750); // set this one to blink every 750ms
}
  



