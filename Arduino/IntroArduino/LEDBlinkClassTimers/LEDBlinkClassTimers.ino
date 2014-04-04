
// A simple example that uses independent
// timers to turn LEDs on and off.
//
//
// by Evan Raskob
// e.raskob@rave.ac.uk

#include "LEDBlinker.h"
#include <JeeLib.h>

MilliTimer timer1;  // timer for 1st LED


// create two LEDBlinker objects attached to two different ports
LEDBlinker led1(13);
LEDBlinker led2(12);

void setup()
{
  timer1.set(4000);
  led1.off();
  
  led2.on();
  led2.set(2000);  // set this LED to turn off in 2000ms
}

boolean stage2 = false;


void loop()
{
  // wait for the 1st timer to be finished
  if (timer1.poll())
  {
    //now we move to stage 2!
    stage2 = true;
  }
  
  // only if the first timer has finished...
  if (stage2)
  {
     led1.blink(200);
  }
  
  
  // need to update the LEDs each loop
  // because there is no argument (number),
  // it only triggers once
 
  led2.blink(); 
  
}
  



