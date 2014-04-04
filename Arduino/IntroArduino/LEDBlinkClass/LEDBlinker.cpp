#include "LEDBlinker.h"


byte LEDBlinker::blink(word ms) {
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
    		digitalWrite(pin, LOW);
    }

    return ready;
}

inline void LEDBlinker::off() {
	state = false;
	digitalWrite(pin, LOW);
}

inline void LEDBlinker::on()  {
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
}