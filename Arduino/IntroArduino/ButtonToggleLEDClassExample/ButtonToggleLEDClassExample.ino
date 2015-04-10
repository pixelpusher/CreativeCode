/*
||
 || @file ButtonToggleLEDClassExample.pde
 || @version 1.0
 || @author Evan Raskob
 || @contact http://pixelist.info - e.raskob@rave.ac.uk 
 ||
 || @description
 || | Modified callback version of Button to run an "animation" function each loop.
 || | Toggles a blinking LED connected to pin 13 when a
 || | button connected to pin 8 is clicked.
 || | Uses Tom Igoe's port of Button.
 || #
 ||
 || @license
 || | Copyright (c) 2015 Evan Raskob. All rights reserved.
 || | This code is in the public domain.
 || #
 ||
 */

#include <Button.h>
#include "LEDBlinker.h";


// utility functions & vars for setting/stopping animations
//
typedef void (*animation_t)(void); // animation callback - make the code more readable
animation_t animation = 0;  // need this to run code each loop()

void setAnimation( animation_t ani_func );
void stopAnimation();
void runAnimation();
// end utility funcs



//create a Button object at pin 8
/*
|| Wiring:
 || GND -----/ ------ pin 8
 */
Button button(8,BUTTON_PULLUP_INTERNAL);

// for more buttons, copy the above code...

LEDBlinker led1(13); // led blink object on pin 13



void setup()
{
  pinMode(12,OUTPUT);              //debug to led 12
  digitalWrite(12,LOW);            // turn it off to start

  // function to run when button is pressed and released
  button.clickHandler(setLEDBlinkAnimation);
}


void loop()
{
  // necessary to constantly update the button state and
  // check for presses
  button.isPressed();

  //now, run the current animation function

  runAnimation();
}



void setLEDBlinkAnimation(Button &b)
{
  if (led1.idle())
  { 
    digitalWrite(12,HIGH);
    delay(100);
    digitalWrite(12,LOW);
     
    led1.set(0);    // reset the timer first - very important! 
    led1.on();
    setAnimation(ledBlink);
  }
  else
  {
    stopAnimation();
    led1.stop();
    
    // blink status light longer to show we've stopped
    digitalWrite(12,HIGH);
    delay(400);
    digitalWrite(12,LOW);
  }

}


void ledBlink()
{
  led1.blink(250); // set this one to blink every 250ms

  // stop after 3 blinks
  if (led1.getBlinks() > 3) {  
    stopAnimation();
    led1.stop();
  }
}


void ledOff(Button &b)
{
  stopAnimation();
  led1.stop();
}


///////////////////////////////////////////////////////
// Utility Functions: Set and run the current animation
///////////////////////////////////////////////////////

void setAnimation( animation_t ani_func )
{
  animation = ani_func;
}

void stopAnimation()
{
  animation = 0; // no animation
}

void runAnimation()
{
  if (animation) animation();
}
//////////////////////////////////////////////////////
//// END Utility functions ///////////////////////////
//////////////////////////////////////////////////////




