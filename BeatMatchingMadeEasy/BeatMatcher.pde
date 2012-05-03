//interface for an object that does something on a beat
public interface IBeatEvent
{
  public void trigger();
}


public class BeatEventList<IBeatEvent> extends ArrayList<IBeatEvent>
{
}

class BeatMatcher implements IBeatListener
{
  // array list of events for each beat, in order (e.g. beat 0..maxBeats has an arraylist of events attached to it)
  private BeatEventList[] events;

  private ArrayList<IBeatEvent> resetEvents; // when beats are reset


  BeatMatcher(int maxBeats)
  {
    events = new BeatEventList[maxBeats];
    resetEvents = new ArrayList<IBeatEvent>();

    for (int i=0; i<events.length; i++)
    {
      events[i] = new BeatEventList();  // default - not matched
    }
  }

  BeatMatcher addResetEvent(IBeatEvent ibe) 
  {
    resetEvents.add( ibe );
    return this;
  }

  BeatMatcher removeResetEvent(IBeatEvent ibe) 
  {
    resetEvents.remove( ibe );
    return this;
  }

  BeatMatcher clearResetEvents()  
  {
    resetEvents.clear(  );
    return this;
  }

  BeatMatcher addBeatEvent(int beat, IBeatEvent ibe) 
  {
    BeatEventList ibes = events[beat];
    ibes.add( ibe );
    return this;
  }

  BeatMatcher removeBeatEvent(int beat, IBeatEvent ibe) 
  {
    BeatEventList ibes = events[beat];
    ibes.remove( ibe );
    return this;
  }

  BeatMatcher clearBeatEvents(int beat)  // start 
  {
    BeatEventList ibes = events[beat];
    ibes.clear( );
    return this;
  }

  BeatMatcher clearAllBeatEvents()
  {
    for (int i=0; i<events.length; i++)
    {
      events[i].clear();
    }
    return this;
  }
  
  public void beatChanged(int beat)  // when a beat changes value, e.g. from 0 to 1
  {
    BeatEventList ibes = events[beat];
    ListIterator<IBeatEvent> li = ibes.listIterator();

    while ( li.hasNext () )
    {
      IBeatEvent ibe = li.next();
      ibe.trigger();
    }
  }

  public void beatReset()  // when a Beat object wraps back to 0 (counts out all the beats)
  {
    for ( IBeatEvent ibe : resetEvents )
      ibe.trigger();
  }

  public void clear()
  {
    clearResetEvents();
    clearAllBeatEvents();
  }

  // end class BeatMatcher
}

