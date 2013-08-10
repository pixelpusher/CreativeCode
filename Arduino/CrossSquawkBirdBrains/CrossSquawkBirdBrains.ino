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

const int ListenBaseTimeOut = 4000;

#define AMP_PWR_PIN A3 // using the Mono Amp breakout board from Sparkfun which has on/off capability: https://www.sparkfun.com/products/11044
//#define DEBUG 1
#define DEBUGLED

#ifdef DEBUG
const int RandomTime = 1;
#else
const int RandomTime = 500;
#endif


#ifdef DEBUGLED
  Port three (3);
#endif

const int SleepFactor = 10; // proportion of time to sleep for vs. listening (2 = double listen time)
const int speakerPin = 3;
const byte SLEEP_MINUTES = 15; // whole minutes to sleep for when in sleep mode

const char payload[] = "tw"; // what we broadcast
const char sleepPayload[] = "sl"; // what we broadcast

const int PayloadLength = 2;
char inPayload [PayloadLength];

int payloadLength = PayloadLength; // length of above message

byte needToSend;


// boilerplate for low-power waiting
ISR(WDT_vect) { 
  Sleepy::watchdogEvent(); 
}

int ListenTimeOut = 4000; // will change
int listenStartTime = 0;

volatile boolean finishedSquawking = false;

enum Mode { SQUAWK, SHUT_UP, LISTEN, SLEEPING };  // all possible modes

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

#ifdef DEBUGLED
  three.mode(OUTPUT);
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
  rf12_sleep (0); // in 32 * ms, so 32 seconds in this case 
}


void loop() 
{ 
  
  #ifdef DEBUG
      Serial.print("MODE ");
      Serial.println(mode);
      delay(20);
  #endif 

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

    doneReceiving = rf12_recvDone(); // must call this to clear the buffer otherwise can't send!

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
    
    rf12_sleep (0); // in 32 * ms, so 32 seconds in this case
    Sleepy::loseSomeTime(ListenBaseTimeOut + random (1, 9) * RandomTime);
    
    Sleepy::loseSomeTime(ListenBaseTimeOut*SleepFactor);
//    Sleepy::loseSomeTime(ListenBaseTimeOut*SleepFactor/2);
    
    delay(10); // settle
    rf12_sleep (-1); // wake up radio
    delay(10); // settle
    
    mode = LISTEN; // listen for other birds
    listenStartTime = millis();
    //ListenTimeOut = ListenBaseTimeOut + random (1, 9) * 250; 
    ListenTimeOut = ListenBaseTimeOut; 
  }  
  else 
  {
    doneReceiving = rf12_recvDone();

    switch (mode) 
    {

      case LISTEN:
      case SLEEPING:
      {
          /* DEBUG */
#ifdef DEBUG
          if (doneReceiving) Serial.println("DONE RECEIVING");
#endif      
  
          int timeDiff = millis() - listenStartTime;
          // has time run out?
          if ( timeDiff > ListenTimeOut )
          {
            if ( mode != SLEEPING )
              startSquawking(); // start squawking again
          }
          else if (doneReceiving && (rf12_crc == 0)  ) 
          {
            byte state = matchPayload();
            Serial.print("Matched payload: ");
            Serial.println(state);
            
            if (state == 1)
            {
              startSquawking(); // discovered a bird, squawk again
            }
            else if (state == 3)
            {
              mode = SLEEPING;
            }
          }
          break;
      }
    // end switch(mode)  
    }
    
    if (mode == SLEEPING) startSleeping();
    
  // end else  
  }
  
// end main loop
} 


byte matchPayload()
{

  #ifdef DEBUGLED
    byte t=0;
    while(t<8)	
    {
	three.digiWrite(HIGH);
        Sleepy::loseSomeTime(100);
	three.digiWrite(LOW);
        Sleepy::loseSomeTime(100);
        ++t;
    }
  #endif
  
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
  Serial.print("matching: ");
#endif

  // matching payloads
   byte payloadMatch = 1;
   byte sleepMatch = 3;

  // test each character in the message for a match  
  for (byte i = 0; i < PayloadLength; ++i)
  {
    
   #ifdef DEBUG
    Serial.print( char(inPayload[i]));
    Serial.print(' ');
  #endif
    
    if (payload[i] != char(inPayload[i]))
      payloadMatch = 0;
      
    if (sleepPayload[i] != char(inPayload[i]))
      sleepMatch = 0;
  }
  

#ifdef DEBUG
  if (payloadMatch) Serial.println("matched payload");
  if (sleepMatch) Serial.println("matched sleep payload");
#endif

  // otherwise, matched it 
  return payloadMatch+sleepMatch;

}


void startSleeping()
{
  #ifdef DEBUGLED
    byte t=0;
    while(t<8)	
    {
	three.digiWrite(HIGH);
        Sleepy::loseSomeTime(100);
	three.digiWrite(LOW);
        Sleepy::loseSomeTime(100);
        ++t;
    }
  #endif
  
    rf12_sleep (0); // turn off radio      
    for (byte i = 0; i < SLEEP_MINUTES; ++i)
    {
      Sleepy::loseSomeTime(60000);
    }
    delay(10); // settle
    rf12_sleep (-1); // wake up radio
    delay(10); // settle
}



