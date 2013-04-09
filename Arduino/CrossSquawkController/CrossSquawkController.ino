#include <JeeLib.h>

//#define DEBUG

#define SLEEPYTIME 1250  // how long to between sleep messages, in milliseconds

#define TIMES_TO_BROADCAST 12

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

Mode mode = WAITING;

//
// time variables
//
byte now[6];

byte wakeTimeArray[] = {
  9, 30, 0};  // wake in morning
int wakeTime=0;

byte wakeTimeEndArray[] = {
  10, 15, 0};  // wake in morning

byte sleepTimeArray[] = {
  19, 0, 0}; // sleep at night
int sleepTime=0;

byte squawkTimeIntervalArray[] = {
  8, 15, 0}; // time to squawk for
int squawkTimeInterval=0;

int lastWakeTime = 0; // last time we woke, in seconds
//
//


#ifdef DEBUG
byte testTime[] = {
  2, 1, 3}; 
#endif



//
// Greater-than time?
// Compares left to right, returns true if left is later in time than right
// assuming 24 hr clock cycles where 12am is earliest
//
boolean gtTime( byte* tl, byte* tr )
{
  // 00 11 22
  // hh mm ss

#ifdef DEBUG
  Serial.print(tl[0]);
  Serial.print(":");
  Serial.println(tr[0]);
#endif

  if (tl[0] < tr[0]) return false;
  if (tl[0] > tr[0]) return true;

#ifdef DEBUG
  Serial.println("meq");
#endif

  // if equal...
  if (tl[1] > tr[1]) return true;

#ifdef DEBUG
  Serial.println("tru");
#endif

  if (tl[1] < tr[1]) return false;


#ifdef DEBUG
  Serial.println("seq");
#endif

  // if equal...    
  if (tl[2] > tr[2]) return true;
  if (tl[2] < tr[2]) return false;

  return false;
}


void setup () {
#ifdef DEBUG
  Serial.begin(57600);
  delay(100);
  Serial.println("[starting Cross Squawk Controller]");
  delay(100);
#endif

  Sleepy::loseSomeTime(32);
  rf12_initialize(1, RF12_868MHZ, 33);
  rf12_sleep(RF12_SLEEP);
  // wait another 2s for the power supply to settle

  two.mode(INPUT);

  Sleepy::loseSomeTime(2000);
}



//
// LOOP
//

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
  Serial.print("rtc:");
  for (byte i = 0; i < 6; ++i) {
    Serial.print(' ');
    Serial.print((int) now[i]);
  }
  Serial.println();
  delay(50);
#endif


  // TODO
  // use hours (24hr format) to test whether we should sleep or wake up!
  // 0  1  2  3  4  5
  // yy mm dd hh mm ss


#ifdef DEBUG
  Serial.print("now: ");
  Serial.print(nowTime);
  Serial.print(", wake: ");
  Serial.print(wakeTime);
  Serial.print(", sleep: ");
  Serial.println(sleepTime);

  byte now2[] = { 
    now[3], now[4], now[5]     };

  Serial.println( (int)gtTime(now2,wakeTimeArray) );
  delay(100);
#endif


  byte nowShifted[] = { 
    now[3], now[4], now[5]     };

  //Serial.println( (int)!gtTime(nowShifted,wakeTimeArray) );
  //Serial.println( (int)gtTime(nowShifted,sleepTimeArray) );

  if ( !gtTime(nowShifted,wakeTimeArray)  || gtTime(nowShifted,sleepTimeArray) ) 
  {
    mode = SLEEPING;
#ifdef DEBUG
    delay(50);
    Serial.println("SLEEP MODE");
    Serial.print("rtc");
    for (byte i = 0; i < 6; ++i) {
      Serial.print(' ');
      Serial.print((int) now[i]);
    }
    Serial.println();
    delay(100);
#endif
  }
  else if ( gtTime(nowShifted, wakeTimeArray ) && !gtTime(nowShifted,wakeTimeEndArray) )
  {
#ifdef DEBUG
    delay(50);
    Serial.println("SQUAWK MODE");
    delay(60);
#endif

    mode = SQUAWK;
  }
  else
    mode = WAITING;



  if ( mode == SLEEPING )
  {

#ifdef DEBUG
    delay(50);
    Serial.println("SLEEP BROADCASTING");
    Serial.println();
    delay(60);
#endif

    rf12_sleep (-1); // wake up radio
    delay(20);

    for (int v=0; v<TIMES_TO_BROADCAST; ++v)
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
      delay(100);
      Sleepy::loseSomeTime(SLEEPYTIME);
    }


#ifdef DEBUG
    delay(50);
    Serial.println("long sleep");
#endif

    Sleepy::loseSomeTime(12000);
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

    //sleep for 10 minutes
    blinkBlue(4);
    for (byte c=0; c<10; ++c)
      Sleepy::loseSomeTime(60000);

    //    rf12_sendStart(0, payload, sizeof (payload));

  }
  else if (mode==SQUAWK)
  {

#ifdef DEBUG
    delay(50);
    Serial.println("squawking");
    Serial.println();
    delay(50);
#endif

    //sleep for 30 minutes
    blinkBlue(5);

    rf12_sleep (-1); // wake up radio
    delay(20);

    for (int v=0; v<4; ++v)
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

      blinkBlue(1);
      rf12_sendStart(0, payload, sizeof (payload));
      delay(80);
      Sleepy::loseSomeTime(SLEEPYTIME);
    }


#ifdef DEBUG
    delay(50);
    Serial.println("long sleep");
#endif

    Sleepy::loseSomeTime(4000);
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







