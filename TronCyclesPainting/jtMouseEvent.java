class jtMouseEvent //extends IEvent
{
  public static final String TYPE = "MOUSE"; 
  public int _x; // current x coord of mouse
  public int _px; // prev x coord of mouse
  public int _y;
  public int _py;
  
  public int _state;  //0 is up, 1 is pressed, 2 is dragged, 3 is released
  public long _time;


  jtMouseEvent(int x, int px, int y, int py, int state, long time)
  {
    _x=x;
    _y=y;
    _px=px;
    _py=py;
    _state=state;
    _time=time;
  }


  jtMouseEvent(int x, int y, int state)
  {
    this(x,x,y,y,state,System.currentTimeMillis());
  }
  /*
  jtMouseEvent(int x, int px, int y, int py, int state)
  {
    this(x,px,y,py,state,System.currentTimeMillis());
  }
 */

  jtMouseEvent(int x, int px, int y, int py, String state)
  {
    int s=0;
    if (state.equals("up")) s=0;
    else if (state.equals("pressed")) s=1;
    else if (state.equals("dragged")) s=2;
    else if (state.equals("released")) s=3;
    else if (state.equals("moved")) s=4;
    
    _x=x;
    _y=y;
    _state=s;
    _px=px;
    _py=py;
    _time=System.currentTimeMillis();
  }
  
  public String toString()
  {
    return (_x+" "+_px+" "+_y+" "+_py+" "+_state+" "+_time);
  }
}