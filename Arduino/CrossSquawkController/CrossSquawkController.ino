#include <JeeLib.h>

#define DEBUG

#define SLEEPYTIME 1500  // how long to between sleep messages, in milliseconds

// boilerplate for low-power waiting
ISR(WDT_vect) { 
  Sleepy::watchdogEvent(); 
}

PortI2C myport (1 /*, PortI2C::KHZ400 */);
DeviceI2C rtc (myport, 0x68);

char payload[] = "tw"; // what we broadcast
char sleepPayload[] = "sl"; // what we broadcast
Port two (2);


enum Mode { 
  SQUAWK, WAITING, SLEEPING };  // all possible modes

Mode mode = SLEEPING;
byte now[6];


void setup () {
#ifdef DEBUG
  Serial.begin(57600);
  delay(100);
  Serial.println("[starting Cross Squawk Controller]");
#endif

  Sleepy::loseSomeTime(32);
  rf12_initialize(1, RF12_868MHZ, 33);
  rf12_sleep(RF12_SLEEP);
  // wait another 2s for the power supply to settle

  two.mode(INPUT);

  Sleepy::loseSomeTime(2000);
}

void loop () {

  blinkBlue(1);


  Sleepy::loseSomeTime(1000);

  int millivolt = map(analogRead(6), 0, 1023, 0, 6600);
  

#ifdef DEBUG
  delay(50);
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

  getDate(now);
  // yy mm dd hh mm ss

#ifdef DEBUG
  delay(50);
  Serial.print("rtc:");
  for (byte i = 0; i < 6; ++i) {
    Serial.print(' ');
    Serial.print((int) now[i]);
  }
  Serial.println();
#endif


  // TODO
  // use hours (24hr format) to test whether we should sleep or wake up!
  // 0  1  2  3  4  5
  // yy mm dd hh mm ss

  if ( (now[3] < 8 && now[4] < 30)  || now[3] > 15) 
  {
    mode == SLEEPING;
#ifdef DEBUG
    delay(50);
    Serial.println("SLEEP MODE");
    Serial.print("rtc");
    for (byte i = 0; i < 6; ++i) {
      Serial.print(' ');
      Serial.print((int) now[i]);
    }
    Serial.println();
#endif
  }
  else if (now[3] == 8 && now[4] > 30)
  {
    mode == SQUAWK;
  }
  else
    mode == WAITING;



  if ( mode == SLEEPING )
  {
    rf12_sleep (-1); // wake up radio
    delay(20);

    for (int v=0; v<10; ++v)
    {
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

      blinkBlue(2);
      rf12_sendStart(0, sleepPayload, sizeof (sleepPayload));
      delay(60);
      Sleepy::loseSomeTime(SLEEPYTIME);
    }


#ifdef DEBUG
    delay(50);
    Serial.println("long sleep");
#endif

    Sleepy::loseSomeTime(6000);
  }
  else if (mode == WAITING)
  {
    /*int state = two.digiRead();
     
     if (state == HIGH)
     { }
     */
#ifdef DEBUG
    delay(50);
    Serial.println("sleeping for 30 minutes");
    Serial.print("rtc");
    for (byte i = 0; i < 6; ++i) {
      Serial.print(' ');
      Serial.print((int) now[i]);
    }
    Serial.println();
#endif

    //sleep for 30 minutes
    blinkBlue(4);
    for (byte c=0; c<30; ++c)
      Sleepy::loseSomeTime(100);

    //    rf12_sendStart(0, payload, sizeof (payload));

  }
  else if (mode==SQUAWK)
  {

#ifdef DEBUG
    delay(50);
    Serial.println("squawking");
    Serial.print("rtc");
    for (byte i = 0; i < 6; ++i) {
      Serial.print(' ');
      Serial.print((int) now[i]);
    }
    Serial.println();
#endif

    //sleep for 30 minutes
    blinkBlue(6);

    rf12_sendStart(0, payload, sizeof (payload));
    Sleepy::loseSomeTime(2000);
  }
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



static void getDate (byte* buf) {
  rtc.send();
  rtc.write(0);	
  rtc.stop();

  rtc.receive();
  buf[5] = bcd2bin(rtc.read(0));
  buf[4] = bcd2bin(rtc.read(0));
  buf[3] = bcd2bin(rtc.read(0));
  rtc.read(0);
  buf[2] = bcd2bin(rtc.read(0));
  buf[1] = bcd2bin(rtc.read(0));
  buf[0] = bcd2bin(rtc.read(1));
  rtc.stop();
}


static byte bin2bcd (byte val) {
  return val + 6 * (val / 10);
}

static byte bcd2bin (byte val) {
  return val - 6 * (val >> 4);
}




