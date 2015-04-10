#include "LEDBlinker.h"

// Built on top of MilliTimer by Jeelabs <jc@wippler.nl>
// 2014-04-04 <e.raskob@rave.ac.uk> http://opensource.org/licenses/mit-license.php

/// Modified version of Jeelib's Millisecond Timer class
/// by Evan Raskob
/// e.raskob@rave.ac.uk
///
/// The millisecond timer can be used for timeouts up to 60000 milliseconds.
/// Setting the timeout to zero disables the timer.
///
/// * for periodic use, poll the timer object with "if (led.blink(123)) ..."
/// * for one-shot use, call "led.set(123)" and poll as "if (led.blink())"


byte LEDBlinker::blink(uint16_t ms) {
    byte ready = 0;
    if (armed) {
        word remain = next - millis();
        // since remain is unsigned, it will overflow to large values when
        // the timeout is reached, so this test works as long as poll() is
        // called no later than 5535 millisecs after the timer has expired
        if (remain <= 60000)
            return 0;
        // return a value between 1 and 255, being msecs+1 past expiration
        // note: the actual return value is only reliable if poll() is
        // called no later than 255 millisecs after the timer has expired
        ready = -remain;
    }
    
    set(ms);
    
    if (ready)
    {
    	state = !state;
    	
    	if (state)
    		digitalWrite(pin, HIGH);
    
    	else
        {
    		digitalWrite(pin, LOW);
                blinks++;
        }
    }

    return ready;
}

void LEDBlinker::off() {
	state = false;
	digitalWrite(pin, LOW);
}

void LEDBlinker::on()  {
	state = true;
	digitalWrite(pin, HIGH);
}

word LEDBlinker::remaining() const {
    word remain = armed ? next - millis() : 0;
    return remain <= 60000 ? remain : 0;
}

void LEDBlinker::set(word ms) {
    armed = ms != 0;
    
    if (armed)
        next = millis() + ms - 1;
    else
      blinks = 0;
}

void LEDBlinker::stop()
{
  set(0);
  off();
}
