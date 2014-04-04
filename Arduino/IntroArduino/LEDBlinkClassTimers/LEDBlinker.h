
// Built on top of MilliTimer by Jeelabs <jc@wippler.nl>
// 2014-04-04 <e.raskob@rave.ac.uk> http://opensource.org/licenses/mit-license.php

#ifndef LED_h
#define LED_h

/// @file
/// LED library definitions.

#if ARDUINO >= 100
#include <Arduino.h> // Arduino 1.0
#else
#include <WProgram.h> // Arduino 0022
#endif
#include <stdint.h>
#include <avr/pgmspace.h>


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
    
public:
	byte state;
	int pin;
    LEDBlinker (int p) : armed (0), pin(p), state(LOW) { pinMode(p, OUTPUT); }
    
    /// poll until the timer fires
    /// @param ms Periodic repeat rate of the time, omit for a one-shot timer.
    byte blink(word ms =0);
    /// Return the number of milliseconds before the timer will fire
    word remaining() const;
    /// Returns true if the timer is not armed
    byte idle() const { return !armed; }
    /// set the one-shot timeout value
    /// @param ms Timeout value. Timer stops once the timer has fired.
    void set(word ms);
    void off();
    void on();
};

#endif
