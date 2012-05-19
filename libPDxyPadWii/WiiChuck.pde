//
// Interfce for responding to WiiChuck events
//
public interface IWiiChuckListener
{
  public void zPressed();
  public void zReleased();
  public void cPressed();
  public void cReleased();  
  public void stateUpdated(WiiChuck chuck);
}

//
// WiiChuck storage and events class
//
//

class WiiChuck
{
  float roll, pitch;
  int ax, ay, az, stickX, stickY;

  boolean debug = false;

  // button states
  final static int UP = 0;
  final static int PRESSED = 1;
  final static int HELD = 2;  // anything greater than PRESSED means held (and we keep counting...)
  final static int RELEASED = 3;

  final static int NUM_VALUES = 9;

  int zButton, cButton, zPressed, cPressed; // should be above states only - could use enum but I'm lazy today

  private LinkedList<IWiiChuckListener> listeners;  // event listeners (see above)


  WiiChuck()
  { 
    listeners = new LinkedList<IWiiChuckListener>();
    cPressed = UP;
    zPressed = UP;
  }


  void addListener(IWiiChuckListener wiiLi)
  {
    listeners.add(wiiLi);
  }

  void removeListener(IWiiChuckListener wiiLi)
  {
    listeners.remove(wiiLi);
  }


  void update(String values[])  // for converting from Serial object
  {
    if (values.length == NUM_VALUES)
    {
      /*
      print("VALUES:" );
       for (int i=0; i<values.length; ++i)
       print(" ["+i+"]:"+values[i]);
       println();
       */

      int _roll=int(values[0]);
      int _pitch=int(values[1]);
      int _ax=int(values[2]);
      int _ay=int(values[3]);
      int _az=int(values[4]);
      int _stickX=int(values[5]);
      int _stickY=int(values[6]);
      int _zPressed=int(values[7]);
      int _cPressed=int(trim(values[8])); // get rid of whitespace!

      roll =  _roll * DEG_TO_RAD;
      pitch =  _pitch * DEG_TO_RAD;

      ax = _ax;
      ay = _ay;
      az = _az;  

      stickX = _stickX;
      stickY = _stickY;

      //zButton = _zButton; // if held, keep counting...
      //cButton = _cButton;
      if ( zPressed != _zPressed)
      {
        zPressed = _zPressed;

        if ( _zPressed == UP )
          for ( IWiiChuckListener wiiLi : listeners)
            wiiLi.zReleased();

        else
          for ( IWiiChuckListener wiiLi : listeners)
            wiiLi.zPressed();
      }  

      if ( cPressed != _cPressed)
      {
        println("CHANGED");
        cPressed = _cPressed;

        if ( _cPressed == UP )
          for ( IWiiChuckListener wiiLi : listeners)
            wiiLi.cReleased();
        else
          for ( IWiiChuckListener wiiLi : listeners)
            wiiLi.cPressed();
      }         

      for ( IWiiChuckListener wiiLi : listeners)     
        wiiLi.stateUpdated( this );
    }
    if (debug) println(this.toString());
  }

void destroy()
{
  listeners.clear();
}

String toString()
{
  String me = "{ ";

  me += "roll:" + roll;
  me += ", ";
  me += "pitch:" + pitch;
  me += ", ";
  me += "ax:" + ax;
  me += ", ";
  me += "ay:" + ay;
  me += ", ";
  me += "az:" + az;
  me += ", ";
  me += "x:" + stickX;
  me += ", ";
  me += "y:" + stickY;
  me += ", ";
  me += "c:" + cPressed;
  me += ", ";
  me += "z:" + zPressed;

  me += " }";

  return me;
}



//end class WiiChuck
}
