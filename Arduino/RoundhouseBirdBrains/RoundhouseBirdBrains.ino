/*                 JeeNode / JeeNode USB / JeeSMD 
 -------|-----------------------|----|-----------------------|----       
 |       |D3  A1 [Port2]  D5     |    |D3  A1 [port1]  D4     |    |
 |-------|IRQ AIO +3V GND DIO PWR|    |IRQ AIO +3V GND DIO PWR|    |
 | D1|TXD|                                           ---- ----     |
 | A5|SCL|                                       D12|MISO|+3v |    |
 | A4|SDA|   Atmel Atmega 328                    D13|SCK |MOSI|D11 |
 |   |PWR|   JeeNode / JeeNode USB / JeeSMD         |RST |GND |    |
 |   |GND|                                       D8 |BO  |B1  |D9  |
 | D0|RXD|                                           ---- ----     |
 |-------|PWR DIO GND +3V AIO IRQ|    |PWR DIO GND +3V AIO IRQ|    |
 |       |    D6 [Port3]  A2  D3 |    |    D7 [Port4]  A3  D3 |    |
 -------|-----------------------|----|-----------------------|----
 */


#include "Sounds.h"
#include <JeeLib.h>


#define AMP_PWR_PIN A3 // using the Mono Amp breakout board from Sparkfun which has on/off capability: https://www.sparkfun.com/products/11044
//#define DEBUG 1
//#define DEBUGLED


Port three (3);

const int speakerPin = 3;


// boilerplate for low-power waiting
ISR(WDT_vect) { 
  Sleepy::watchdogEvent(); 
}

volatile boolean finishedSquawking = false;

enum Mode { 
  SQUAWK, SHUT_UP, LISTEN, SLEEPING };  // all possible modes

Mode mode = SHUT_UP;  // current operating mode (for AI) 


//--------------------------- 
// SETUP --------------------
//---------------------------

void setup () 
{  
  //#ifdef DEBUG
  //Serial.begin(9600);
  //Serial.println("STARTING");
  //#endif


  three.mode(INPUT);


  pinMode (A0, INPUT);
  pinMode (A2, INPUT);
  randomSeed (analogRead (A0) );

  pinMode (AMP_PWR_PIN, OUTPUT);  // amp on/off pin
  digitalWrite (AMP_PWR_PIN, LOW); // turn off amp
  //  rf12_initialize(1, RF12_868MHZ, 33); // initialise wireless broadcaster?
  //rf12_sleep (0); // in 32 * ms, so 32 seconds in this case 

  startSquawking();

}





void loop() 
{ 

  if (finishedSquawking) 
  {
    finishedSquawking = false;
    digitalWrite(speakerPin, LOW);
    digitalWrite(AMP_PWR_PIN, LOW);    

    mode = SHUT_UP;
  }  

  if (mode == SHUT_UP)
  {
    Sleepy::loseSomeTime(40);
    delay(10);

    int ldr = three.anaRead();
    Serial.println(ldr);

    if (ldr > 800 )
      startSquawking(); // start squawking again
  }

  // end main loop
} 


void startSleeping()
{
  rf12_sleep (0); // turn off radio      
}


void startSquawking()
{
#ifdef DEBUG
  Serial.print("SQUAWKING ");
  Serial.println(millis());
#endif      

  mode = SQUAWK;

  startPlayback(sample, sizeof(sample));
}






