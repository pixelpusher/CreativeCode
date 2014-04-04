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

//create a Button object at pin 8
/*
|| Wiring:
|| GND -----/ ------ pin 8
*/
Button button = Button(8,BUTTON_PULLUP);

void setup(){
  pinMode(13,OUTPUT);              //debug to led 13
  button.pressHandler(ledOn);      // function to run when button is pressed
  button.releaseHandler(ledOff);   // function to run when button is released
}


void loop()
{
  // necessary to constantly update the button state and
  // check for presses
  button.isPressed();
}


void ledOn(Button &b)
{
  digitalWrite(13,HIGH);
}


void ledOff(Button &b)
{
  digitalWrite(13,LOW);
}



