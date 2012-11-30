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

const int ListenBaseTimeOut = 1;
 
#define AMP_PWR_PIN A3 // using the Mono Amp breakout board from Sparkfun which has on/off capability: https://www.sparkfun.com/products/11044

const int speakerPin = 3;

char payload[] = "tweet"; // what we broadcast
const int PayloadLength = 5;
char inPayload [PayloadLength];

int payloadLength = PayloadLength; // length of above message

byte needToSend;

// boilerplate for low-power waiting
ISR(WDT_vect) { Sleepy::watchdogEvent(); }

int ListenTimeOut = 5000;
int listenStartTime = 0;

volatile boolean finishedSquawking = false;

enum Mode { SQUAWK, SHUT_UP, LISTEN };

Mode mode = SHUT_UP;


//--------------------------- 
// SETUP --------------------
//---------------------------

void setup () 
{  

  pinMode (A0, INPUT);
  randomSeed (analogRead (A0) );

  pinMode (AMP_PWR_PIN, OUTPUT);  // amp on/off pin
  digitalWrite (AMP_PWR_PIN, LOW); // turn off amp
  rf12_initialize(1, RF12_868MHZ, 33); // initialise wireless broadcaster?
  
  startSquawking();

}

void startSquawking()
{

  mode = SQUAWK;
  startPlayback(sample, sizeof(sample));
  rf12_sleep (1000);

}
  

void loop() { 

  if (finishedSquawking) {

    finishedSquawking = false;

    mode = SHUT_UP;
    digitalWrite(speakerPin, LOW);
    digitalWrite(AMP_PWR_PIN, LOW);
    rf12_sleep (-1);

    // we're playing a sound - broadcast call
    if (rf12_canSend()) rf12_sendStart(0, payload, sizeof (payload));

    mode = LISTEN; // listen for other birds
    listenStartTime = millis();
    ListenTimeOut = ListenBaseTimeOut + random (1, 9) * 1; 
    
  }  

  boolean doneReceiving = false;
  switch (mode) {

    case LISTEN: {
      doneReceiving = rf12_recvDone();
      int timeDiff = millis() - listenStartTime;
      // has time run out?
      if ( timeDiff > ListenTimeOut ) 
        startSquawking(); // start squawking again
      else if (doneReceiving && (rf12_crc == 0) && matchPayload () ) {
        if (finishedSquawking == true) startSquawking(); // discovered a bird, squawk again
      }
      break;
    }

  }
  
} 


boolean matchPayload()
{
  
  // check message length to see if it is the same as the payload we're looking for
  if ( rf12_len != sizeof payload) return false;
    
  memcpy(&inPayload, (byte*) rf12_data, sizeof inPayload);
  
  // test each character in the message for a match  
  for (byte i = 0; i < PayloadLength; ++i)
    if (payload[i] != char(inPayload[i]))
       return false;
 
  // otherwise, matched it 
  return true;
  
}

