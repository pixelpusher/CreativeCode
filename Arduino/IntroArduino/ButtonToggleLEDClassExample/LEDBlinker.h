
// Built on top of MilliTimer by Jeelabs <jc@wippler.nl>
// 2014-04-04 <e.raskob@rave.ac.uk> http://opensource.org/licenses/mit-license.php

#ifndef _LED_h
#define _LED_h

/// @file
/// LED library definitions.


#include <Arduino.h> // Arduino 1.0
#include <stdint.h>
#include <avr/pgmspace.h>

typedef uint16_t word;
typedef uint8_t byte;

/// Modified version of Jeelib's Millisecond Timer class
/// by Evan Raskob
/// e.raskob@rave.ac.uk
///
/// The millisecond timer can be used for timeouts up to 60000 milliseconds.
/// Setting the timeout to zero disables the timer.
///
/// * for periodic use, poll the timer object with "if (led.blink(123)) ..."
/// * for one-shot use, call "led.set(123)" and poll as "if (led.blink())"

class LEDBlinker {
  word next;
  byte armed;
  int blinks;

public:
  byte state;
  int pin;
  LEDBlinker (int p) : 
  armed (0), blinks(0), pin(p), state(LOW) { 
    pinMode(p, OUTPUT); 
  }

  /// poll until the timer fires
  /// @param ms Periodic repeat rate of the time, omit for a one-shot timer.
  byte blink(word ms =0);
  /// Return the number of milliseconds before the timer will fire
  word remaining() const;
  /// Returns true if the timer is not armed
  byte idle() const { 
    return !armed; 
  }
  // returns number of blinks in the current cycle (since last set() call)
  word getBlinks() const {
    return blinks;
  }
  /// set the one-shot timeout value
  /// @param ms Timeout value. Timer stops once the timer has fired.
  void set(word ms);
  void off();
  void on();
  void stop();
  
};

#endif

