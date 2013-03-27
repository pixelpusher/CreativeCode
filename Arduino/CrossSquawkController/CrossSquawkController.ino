#include <JeeLib.h>

#define SLEEPYTIME 2000  // how long to between sleep messages, in milliseconds

// boilerplate for low-power waiting
ISR(WDT_vect) { 
  Sleepy::watchdogEvent(); 
}

char payload[] = "tw"; // what we broadcast
char sleepPayload[] = "sl"; // what we broadcast
Port one (1);


enum Mode { 
  SQUAWK, SLEEPING };  // all possible modes

Mode mode = SLEEPING;



void setup () {
#ifdef DEBUG
  Serial.begin(57600);
  delay(100);
#endif

  Sleepy::loseSomeTime(32);
  rf12_initialize(1, RF12_868MHZ, 33);
  rf12_sleep(RF12_SLEEP);
  // wait another 2s for the power supply to settle

  one.mode(INPUT);

  Sleepy::loseSomeTime(2000);



}

void loop () {

  blinkBlue(1);
  Sleepy::loseSomeTime(1000);

  int millivolt = map(analogRead(6), 0, 1023, 0, 6600);

#ifdef DEBUG
  Serial.println(millivolt);    
  delay(50);
#endif



  if (millivolt < 3400) // power is too low...
  {
    blinkBlue(3);

    // stop responding to interrupts
    cli();

    // zzzzz... this code is now in the Ports library
    Sleepy::powerDown();
  }


  if ( mode == SLEEPING )
  {
    rf12_sleep (-1); // wake up radio
    delay(20);
    rf12_recvDone(); // must call this to clear the buffer otherwise can't send!

    boolean cleared = false;
    unsigned int cnt = 0;

    while (cnt < 5000 && !cleared)
    {
      delay(1);
      ++cnt;
      cleared = rf12_canSend();
    } 


    int state = one.digiRead();

    if (state == HIGH)
    {
      blinkBlue(2);      
      rf12_sendStart(0, sleepPayload, sizeof (sleepPayload));
    }
    else
      blinkBlue(4);      
    rf12_sendStart(0, payload, sizeof (payload));
  }      
  delay(60);
  Sleepy::loseSomeTime(SLEEPYTIME);
}


void blinkBlue(byte times)
{
  // blink the blue LED just because we can
  PORTB |= bit(1);
  DDRB |= bit(1);
  for (byte i = 0; i < times*2; ++i) {
    Sleepy::loseSomeTime(80);
    PINB = bit(1); // toggles
  }
}

