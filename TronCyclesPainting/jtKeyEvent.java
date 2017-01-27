class jtKeyEvent //extends IEvent
{
  public static final String TYPE = "KEY"; 
  public char _key;
  public int _state;  //0 is up, 1 is pressed
  public long _time;


  jtKeyEvent(char __key, int state, long time)
  {
    _key=__key;
    _state=state;
    _time=time;
  }


  jtKeyEvent(char key, int state)
  {
    this(key,state,System.currentTimeMillis());
  }

  jtKeyEvent(char key, String state)
  {
    int s=0;
    if (state.equals("released")) s=0;
    else if (state.equals("pressed")) s=1;
    
    _key=key;
    _state=s;
    _time=System.currentTimeMillis();
  }
  
  public String toString()
  {
    //return (TYPE + " event: {"+ _key+" "+_state+" "+_time+"}");
    return (_key+" "+_state+" "+_time);
  }
}