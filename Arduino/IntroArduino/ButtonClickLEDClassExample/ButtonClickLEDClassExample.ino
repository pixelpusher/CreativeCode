/*
||
 || @file ButtonExample.pde
 || @version 1.2
 || @author Alexander Brevig
 || @contact alexanderbrevig@gmail.com
 || @contribution Evan Raskob - http://pixelist.info - e.raskob@rave.ac.uk 
 ||
 || @description
 || | Modified callback version of Button class.  Lights an LED connected
 || | to pin 13 when a button connected to pin 8 is pressed.
 || | Uses Tom Igoe's port of Button: https://github.com/tigoe/Button
 || #
 ||
 || @license
 || | Copyright (c) 2009 Alexander Brevig. All rights reserved.
 || | This code is subject to AlphaLicence.txt
 || | alphabeta.alexanderbrevig.com/AlphaLicense.txt
 || #
 ||
 */

#include <Button.h>
#include "LEDBlinker.h";


///////////////////////////////////////////////////////
// Utility Functions: Set and run the current animation
///////////////////////////////////////////////////////
void (*Animation)(void);  // need this to run code each loop()

void setAnimationFunction( void (*func)(void) )
{
  Animation = func;
}

void stopAnimation()
{
  Animation = 0;
}

void runAnimation()
{
    if (Animation) Animation();
}
//////////////////////////////////////////////////////
//// END Utility functions ///////////////////////////
//////////////////////////////////////////////////////


//create a Button object at pin 8
/*
|| Wiring:
 || GND -----/ ------ pin 8
 */
Button button = Button(8,BUTTON_PULLUP);

// for more buttons, copy the above code...


LEDBlinker led1(13);



void setup(){
  pinMode(12,OUTPUT);              //debug to led 12
  digitalWrite(12,LOW);            // turn it off to start
  
  //button.clickHandler(ledOff);      // function to run when button is pressed
  //button.holdHandler(setLEDBlinkAnimation,1000);   // function to run when button is released
  
  button.pressHandler(setLEDBlinkAnimation);
  button.releaseHandler(ledOff);   // function to run when button is released

  Animation = 0; // start as 0 (none)
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
  led1.set(0);    // reset the timer first - very important!
  setAnimationFunction(ledBlink);
}


void ledBlink()
{
  led1.blink(250); // set this one to blink every 250ms
  digitalWrite(12,LOW);
}



void ledOff(Button &b)
{
  digitalWrite(12,HIGH);
  stopAnimation();
  led1.off();
}





