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

const int ListenBaseTimeOut = 2000;

#define AMP_PWR_PIN A3 // using the Mono Amp breakout board from Sparkfun which has on/off capability: https://www.sparkfun.com/products/11044
//#define DEBUG 1

#ifdef DEBUG
const int RandomTime = 1;
#else
const int RandomTime = 250;
#endif

const int SleepFactor = 2; // proportion of time to sleep for vs. listening (2 = double listen time)
const int speakerPin = 3;

char payload[] = "tweet"; // what we broadcast
const int PayloadLength = 5;
char inPayload [PayloadLength];

int payloadLength = PayloadLength; // length of above message

byte needToSend;

// boilerplate for low-power waiting
ISR(WDT_vect) { 
  Sleepy::watchdogEvent(); 
}

int ListenTimeOut = 2000; // will change
int listenStartTime = 0;

volatile boolean finishedSquawking = false;

enum Mode { SQUAWK, SHUT_UP, LISTEN };  // all possible modes

Mode mode = SHUT_UP;  // current operating mode (for AI) 


//--------------------------- 
// SETUP --------------------
//---------------------------

void setup () 
{  
#ifdef DEBUG
  Serial.begin(57600);
  Serial.println("STARTING");
#endif

  pinMode (A0, INPUT);
  randomSeed (analogRead (A0) );

  pinMode (AMP_PWR_PIN, OUTPUT);  // amp on/off pin
  digitalWrite (AMP_PWR_PIN, LOW); // turn off amp
  rf12_initialize(1, RF12_868MHZ, 33); // initialise wireless broadcaster?

  startSquawking();
}



void startSquawking()
{
#ifdef DEBUG
      Serial.print("SQUAWKING ");
      Serial.println(millis());
#endif      

  mode = SQUAWK;
  startPlayback(sample, sizeof(sample));
  rf12_sleep (1000); // in 32 * ms, so 32 seconds in this case 
}


void loop() 
{ 
  boolean doneReceiving = false;

  if (finishedSquawking) 
  {
    finishedSquawking = false;

    mode = SHUT_UP;
    digitalWrite(speakerPin, LOW);
    digitalWrite(AMP_PWR_PIN, LOW);
    rf12_sleep (-1); // wake up radio
    delay(20);
    // we're playing a sound - broadcast call

    int cnt = 0;
    boolean cleared = false;

    rf12_recvDone(); // must call this to clear the buffer otherwise can't send!

    while (cnt < 5000 && !cleared)
    {
      delay(1);
      ++cnt;
      cleared = rf12_canSend();
    } 

    if (cleared) 
    {
#ifdef DEBUG
      Serial.print("SENDING ");
      Serial.println(millis());
#endif      

      rf12_sendStart(0, payload, sizeof (payload));
      delay(60); 
    }
    
    rf12_sleep (1000); // in 32 * ms, so 32 seconds in this case
    Sleepy::loseSomeTime((ListenBaseTimeOut + random (1, 9) * RandomTime)*SleepFactor);
    delay(10); // settle
    rf12_sleep (-1); // wake up radio
    delay(10); // settle
    
    mode = LISTEN; // listen for other birds
    listenStartTime = millis();
    //ListenTimeOut = ListenBaseTimeOut + random (1, 9) * 250; 
    ListenTimeOut = ListenBaseTimeOut + random (1, 9) * RandomTime; 

  }  
  else 
  {
    doneReceiving = rf12_recvDone();

    switch (mode) 
    {

      case LISTEN: 
      {
          /* DEBUG */
#ifdef DEBUG
          if (doneReceiving) Serial.println("DONE RECEIVING");
#endif      
  
          int timeDiff = millis() - listenStartTime;
          // has time run out?
          if ( timeDiff > ListenTimeOut ) 
            startSquawking(); // start squawking again
          else if (doneReceiving && (rf12_crc == 0) && matchPayload () ) {
            startSquawking(); // discovered a bird, squawk again
          }
          break;
      }
      
      
    // end switch(mode)  
    }
  // end else  
  }
  
// end main loop
} 


boolean matchPayload()
{

  // check message length to see if it is the same as the payload we're looking for
  if ( rf12_len != sizeof payload) 
  {
#ifdef DEBUG
    memcpy(&inPayload, (byte*) rf12_data, sizeof inPayload);
    // test each character in the message for a match  
    Serial.print("PAYLOAD:");    
    for (byte i = 0; i < PayloadLength; ++i)
      Serial.print(inPayload[i]);
    Serial.println();    
#endif    
    return false;
  }

  memcpy(&inPayload, (byte*) rf12_data, sizeof inPayload);
#ifdef DEBUG
  Serial.println("matching");
#endif

  // test each character in the message for a match  
  for (byte i = 0; i < PayloadLength; ++i)
    if (payload[i] != char(inPayload[i]))
      return false;

#ifdef DEBUG
  Serial.println("matched");
#endif
  // otherwise, matched it 
  return true;

}


