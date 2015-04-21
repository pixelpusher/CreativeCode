/*
||
 || @file ButtonClickLEDClassExample.pde
 || @version 1.1
 || @author Evan Raskob
 || @contact  - http://pixelist.info - e.raskob@rave.ac.uk 
 ||
 || @description
 || | Modified callback version of Button class.  Blinks an LED connected
 || | to pin 13 when a button connected to pin 8 is pressed, stops on release.
 || | Uses Tom Igoe's port of Button. 
 || #
 ||
 || @license
 || | Copyright (c) 2015 Evan Raskob. All rights reserved.
 || | This code is subject to AlphaLicence.txt
 || | alphabeta.alexanderbrevig.com/AlphaLicense.txt
 || #
 ||
 */
 
 // TODO: add queue to hold/test/activate buttons and add addButton() and
 // removeButton() functions

#include <Button.h>
#include "LEDBlinker.h";


// utility functions & vars for setting/stopping animations
//
typedef void (*animation_t)(void); // animation callback - make the code more readable
animation_t animation;  // need this function to run code each loop()

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
// for more buttons, copy the above code and rename to button2, etc.

LEDBlinker led1(13); // led blink object on pin 13

const int DEBUG_PIN = DEBUG_PIN; // status light for when something happens

int blinkRate = 250; // ms LED is on and off for

void blinkDebugLED(int time);  // blink the debug LED

void ledOff();
void ledBlink();

void setButtonPressAnimation(Button &b)
void setButtonReleaseAnimation(Button &b);


void setup()
{
  pinMode(DEBUG_PIN,OUTPUT);              //debug to led DEBUG_PIN
  digitalWrite(DEBUG_PIN,LOW);            // turn it off to start

  //button.clickHandler(ledOff);      // function to run when button is pressed
  //button.holdHandler(setLEDBlinkAnimation,1000);   // function to run when button is released

  button.pressHandler(setButtonPressAnimation);
  button.releaseHandler(setButtonReleaseAnimation);   // function to run when button is released
  
  animation = 0; // start as 0 (none)
}


void loop()
{
  // necessary to constantly update the button state and
  // check for presses
  button.isPressed();

  //now, run the current animation function

  runAnimation();
}



///////////////////////////////////////////////////////
// Functions for button callbacks
///////////////////////////////////////////////////////

void setButtonPressAnimation(Button &b)
{
  if (led1.idle())
  {  
    blinkDebugLED(100);
    
    led1.stop();    // reset the timer first - very important!
    led1.on();
    setAnimation(ledBlink);
  }
  else
  {
    led1.off();
  }
}


void setButtonReleaseAnimation(Button &b)
{
  setAnimation(ledOff);
}

void ledBlink()
{
  led1.blink(blinkRate); // set this one to blink every 250ms
}

void ledOff()
{
  stopAnimation();
  led1.stop(); // stop blinking and turn off
  led1.off();
}


//
// utility function to blink an LED
//
void blinkDebugLED(int time)
{
    digitalWrite(DEBUG_PIN,HIGH);
    delay(time);
    digitalWrite(DEBUG_PIN,LOW);
    delay(time);
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




