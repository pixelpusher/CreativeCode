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
Button button1 = Button(8,BUTTON_PULLUP);

Button button2 = Button(7,BUTTON_PULLUP);

Button button3 = Button(6,BUTTON_PULLUP);

// for more buttons, copy the above code...


LEDBlinker led1(13);



void setup(){
  pinMode(12,OUTPUT);              //debug to led 12
  digitalWrite(12,LOW);            // turn it off to start
   
  button1.clickHandler(setLEDBlinkAnimationSlow);
  button2.clickHandler(setLEDBlinkAnimationMed);
  button3.clickHandler(setLEDBlinkAnimationFast);

  Animation = 0; // start as 0 (none)
}


void loop()
{
  // necessary to constantly update the button state and
  // check for presses
  button1.isPressed();
  button2.isPressed();
  button3.isPressed();


  //now, run the current animation function

  runAnimation();
}


//
// Event handlers
//
void setLEDBlinkAnimationSlow(Button &b)
{
  led1.set(0);    // reset the timer first - very important!
  setAnimationFunction(ledBlinkSlow);
}


void setLEDBlinkAnimationMed(Button &b)
{
  led1.set(0);    // reset the timer first - very important!
  setAnimationFunction(ledBlinkSlow);
}

void setLEDBlinkAnimationFast(Button &b)
{
  led1.set(0);    // reset the timer first - very important!
  setAnimationFunction(ledBlinkFast);
}


//
// Animations
//
void ledBlinkSlow()
{
  led1.blink(1500); // set this one to blink every 1500ms
}

void ledBlinkMed()
{
  led1.blink(750); // set this one to blink every 750ms
}

void ledBlinkFast()
{
  led1.blink(250); // set this one to blink every 250ms
}



