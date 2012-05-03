// listens for beats
public interface IBeatListener
{
  public void beatChanged(int beat);  // when a beat changes value, e.g. from 0 to 1
  public void beatReset();  // when a Beat object wraps back to 0 (counts out all the beats)
}


// Simple class representing a "beat" based on a time interval
// and maximum number of beats
class Beat
{
  // 120bpm in ms
  int beatInterval = (int)(60000f/120f);
  private int lastBeat = 0;
  private int maxBeats = 4;
  private float partialBeat = 0f;
  private int _currentBeat = 0;
  private int _lastTime = 0;

  private ArrayList<IBeatListener> listeners;

  Beat()
  {
    lastTime = millis();
    listeners = new ArrayList<IBeatListener>();
  }

  Beat(int mb)
  {
    maxBeats = mb;
    listeners = new ArrayList<IBeatListener>(); 
    _lastTime =  millis();
  } 

  int getMaxBeats()
  {
    return maxBeats;
  } 

  Beat setMaxBeats(int mb)
  {
    maxBeats = mb;
    return this;
  } 

  int getCurrentBeat()
  {
    return _currentBeat;
  }

  float getPartialBeat()
  {
    return partialBeat;
  }


  Beat addListener(IBeatListener ibl)
  {
    listeners.add(ibl);
    return this;
  }

  Beat removeListener(IBeatListener ibl)
  {
    listeners.remove(ibl);
    return this;
  }

  Beat removeAllListeners()
  {
    listeners.clear();
    return this;
  }


  // start the beats in motion
  void reset(int startTimeMillis)
  {
    partialBeat = 0f;
    _currentBeat = lastBeat = 0;
    _lastTime = startTimeMillis;
  }

  void reset()
  {
    reset(millis());
  }

  void defaults()
  {
    // 120bpm in ms
    beatInterval = (int)(60000f/120f);
    lastBeat = 0;
    maxBeats = 4;
    partialBeat = 0f;
    _currentBeat = 0;
    _lastTime = 0;
  }

  //---------------------------
  // set the interval btw beats in ms, reset beat count
  void setBeatInterval(int bms)
  {
    beatInterval = bms;
    reset();    
  }


  // -----------------------------------
  // Decide whether or not we are on a beat, and which
  // beat.  Returns an int from 0..(maxBeats-1) 

  float update()
  {
    return update( millis() );
  }


  float update(int currentTimeMillis)
  {
    // get beat interval
    int _interval = (currentTimeMillis - _lastTime);

    // see if a beat worth of time has elapsed
    if (_interval > beatInterval)
    {
      //increment current beat
      _currentBeat = (_currentBeat + 1) % maxBeats;

      // we may have missed the beat by a fraction or a second!
      _interval -= beatInterval;

      // for debugging
      //println("interval:" + beatInterval);

      // update current time, taking into account
      // time past the beat interval (that we missed because Processing was SLOOOW)
      _lastTime = currentTimeMillis - _interval;
    }

    partialBeat =  (_currentBeat + (float)_interval/(float)beatInterval);

    // check if beat changed
    if (lastBeat != _currentBeat)
    {
      lastBeat = _currentBeat;
      
      for (IBeatListener ibl : listeners)
        ibl.beatChanged( _currentBeat );

      if (_currentBeat == 0)
      {
        for (IBeatListener ibl : listeners)
          ibl.beatReset( );
      }
    }      
    
    
    return _currentBeat;
  }
  
  void destroy()
  {
    removeAllListeners();
  }
  
// end class Beat
}

