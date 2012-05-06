//
// Interfce for responding to WiiChuck events
//
public interface IWiiChuckListener
{
  public void zPressed();
  public void cPressed();
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
  final int PRESSED = 1;
  final int HELD = 2;  // anything greater than PRESSED means held (and we keep counting...)

  final int NUM_VALUES = 9;

  int zButton, cButton, zPressed, cPressed; // should be above states only - could use enum but I'm lazy today

  private LinkedList<IWiiChuckListener> listeners;  // event listeners (see above)


  WiiChuck()
  { 
    listeners = new LinkedList<IWiiChuckListener>();
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
      update(int(values[0]), int(values[1]), int(values[2]), int(values[3]), int(values[4]), int(values[5]), 
      int(values[6]), int(values[7]), int(values[8]));
  }

  void update(int _roll, int _pitch, int _ax, int _ay, int _az, int _stickX, int _stickY, int _zPressed, int _cPressed)
  {
    roll =  _roll * DEG_TO_RAD;
    pitch =  _pitch * DEG_TO_RAD;

    ax = _ax;
    ay = _ay;
    az = _az;  

    stickX = _stickX;
    stickY = _stickY;

    //zButton = _zButton; // if held, keep counting...
    //cButton = _cButton;

    zPressed = _zPressed;
    cPressed = _cPressed;

    for ( IWiiChuckListener wiiLi : listeners)
    {
      wiiLi.stateUpdated( this );

      if (zPressed == 1)  
      {
        zPressed = PRESSED;
        wiiLi.zPressed();
      }
      else
        zPressed = this.UP;

      if (cPressed == 1)
      {
        cPressed = PRESSED;
        wiiLi.cPressed();
      }
      else
        cPressed = this.UP;
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

