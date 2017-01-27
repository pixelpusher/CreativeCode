static final String mouseEventsFile = "mouseEvents.txt";
static final String jtKeyEventsFile = "jtKeyEvents.txt";

boolean rendering = false; // make this true to render to a movie file

jtMouseEvent currentME = null;
jtKeyEvent currentKE = null;

int recScreenWidth = myW;
int recScreenHeight = myH;


// TODO:
// need toggleRecording() to turn on/off recording safely


void stopRecording()
{
  if (!rendering) 
  {
    jtKeyEvents.add(new jtKeyEvent(' ', "pressed"));
    saveEvents();
  }
}
//////////////////////////////////////


void saveEvents()
{
  noLoop();
  ListIterator mit = jtMouseEvents.listIterator();
  String[] outStrings = new String[jtMouseEvents.size()+1];
  // first line is width & height
  outStrings[0] = width + " " + height;

  while (mit.hasNext ())
  {
    outStrings[mit.nextIndex()+1] = ((jtMouseEvent)mit.next()).toString();
  }   
  String sString = "jtMouseEvents_" + year() + month() + day() + "_" + hour() + "-" + minute() + "-" + second()+".txt";
  saveStrings(sString, outStrings);
  outStrings = null;

  outStrings = new String[jtKeyEvents.size()];
  ListIterator kit = jtKeyEvents.listIterator();

  while (kit.hasNext ())
  {
    outStrings[kit.nextIndex()] = ((jtKeyEvent)kit.next()).toString();
  }   
  sString = "jtKeyEvent_" + year() + month() + day() + "_" + hour() + "-" + minute() + "-" + second()+".txt";
  saveStrings(sString, outStrings);

  println("SAVED!");
  loop();
}

// get the sketch time, whether we are rendering or not
long sketchTime()
{
  if (!rendering) return System.currentTimeMillis();
  else return fakeTime;
}

void loadRecording()
{
  String mlines[] = loadStrings(mouseEventsFile);
  String mlist[] = split(mlines[0], ' ');
  recScreenWidth = int(mlist[0]);
  recScreenHeight = int(mlist[1]);
  
  println("recScreenWidth: " + recScreenWidth);
  println("myW:" + myW);
  println("formatted:" + formatRecMouseXPos("1000"));
  

  for (int i=1; i < mlines.length; i++) {
    //println(i+":" + mlines[i]+":" + mlines[i].length());
    if ( mlines[i] != null && mlines[i].length() > 4 )
    {
      // x,px,y,py,state,time
      mlist = split(mlines[i], ' ');
      jtMouseEvents.add(new jtMouseEvent(formatRecMouseXPos(mlist[0]), formatRecMouseXPos(mlist[1]), formatRecMouseYPos(mlist[2]),
        formatRecMouseYPos(mlist[3]), int(mlist[4]), (new Long(mlist[5])).longValue()));
      //println("read mouse event:" + mouseEvents.getLast());
    }
  }

  String klines[] = loadStrings(jtKeyEventsFile);
  for (int i=0; i < klines.length; i++) {
    // x,y,state,time
    String klist[] = split(klines[i], ' ');
    /* 
    print("key line read("+klist.length+")");
    for(int s=0; s< klist.length; s++)
       print(klist[s]+"__");
    print(":\n");
    */
    // look for case where space was pressed
    if (klist[0].length() < 1) 
    { 
      jtKeyEvents.add(new jtKeyEvent(' ', int(klist[2]), (new Long(klist[3])).longValue()));
    } else
      jtKeyEvents.add(new jtKeyEvent(klist[0].charAt(0), int(klist[1]), (new Long(klist[2])).longValue()));
      
    //println("read key event:" + jtKeyEvents.getLast());
  }
  mlines = null;
  klines = null;


  currentME = null;
  currentKE = null;

  if (jtMouseEvents.size() > 0)
    currentME = (jtMouseEvent)jtMouseEvents.removeFirst();
  if (jtKeyEvents.size() > 0)
    currentKE = (jtKeyEvent)jtKeyEvents.removeFirst();

  if (currentME==null || currentKE==null)
  {
    println("No data found!");
    exit();
  } 
  else
  {  
    // set start time to time of 1st mouse event
    if (currentME._time <= currentKE._time) startTime=currentME._time;
    else startTime=currentKE._time;

    println("START TIME: " + startTime);
    

    fakeTime = startTime;

    smouseX    = currentME._x;
    smouseY    = currentME._y;
    spmouseX   = currentME._px;
    spmouseY   = currentME._py;
    smState    = currentME._state;

    skey       = currentKE._key;
    skeyState  = currentKE._state;
  }
}


/* 
 *increment current time value and decide if we stop looping or not.
 */
void updateRecording()
{

  //long timeInc = (1000/25);


  boolean handledMouseEvents = false;
  boolean handledjtKeyEvents = false;

  while (!handledMouseEvents || !handledjtKeyEvents)
  {

    /* this is crap.. should handle these in a single data structure. */

    if (!handledjtKeyEvents)
    {
      if (currentKE == null) handledjtKeyEvents = true;
      else
      {
        if (fakeTime > currentKE._time)
        {
          //println("key: " + currentKE);
          //println("key time:" + currentKE._time + " / " + fakeTime);

          skey = currentKE._key;
          skeyState = currentKE._state;
          if (skeyState == 1)
            handleKeyPressed();
          else
            handleKeyReleased();


          // remove next first
          try
          {
            currentKE = (jtKeyEvent)jtKeyEvents.removeFirst();
          } 
          catch (java.util.NoSuchElementException noe)
          {
            currentKE = null;
            handledjtKeyEvents = true;
          }

          //println("Handling key event:" + currentKE);
          // remove first

        } 
        else handledjtKeyEvents = true;
      }
    // done handling key events
    }


    if (!handledMouseEvents)
    {
      if ( currentME == null) handledMouseEvents = true;
      else
      {
        //print("handling m event");

        if (fakeTime >= currentME._time)
        {
          
          //println("m event time:" + currentME._time + " / " + fakeTime);
          //println("m: " + currentME);
          
          smouseX    = currentME._x;
          smouseY    = currentME._y;
          spmouseX   = currentME._px;
          spmouseY   = currentME._py;
          
          smState    = currentME._state;
      
        
          //up, pressed, dragged, released, moved
          
          switch (smState)
          {
            // mouse up
            case 0: handleMouseReleased();
            break;
            
            // mouse press
            case 1: handleMousePressed();
            break;
            
            // mouse drag
            case 2: handleMouseDragged();
            break;

            // mouse release
            case 3: handleMouseReleased();
            break;
            
            // mouse move
            case 4: handleMouseMoved();
            break;
            
            default: println("ERROR");
            break;
            
          }

          // remove next first
          try
          {
            currentME = (jtMouseEvent)jtMouseEvents.removeFirst();
          } 
          catch (java.util.NoSuchElementException noe)
          {
            currentME = null;
            handledMouseEvents = true;
          }

        } 
        else handledMouseEvents = true;
      }
     // done handling mouse events
    }

    
  // done handling events
  }

  long timeInc = (long)(1000.0/fakeFrameRate);

  /*
   1. add time interval btween frames to current time
   2. for each event in queue with time less than interval, execute mouse or key event
   3. if key event is 1 pressed, stop looping.
   */
  
  fakeTime += timeInc;  // in ms, 1000 per frame
  //println("CURRENT TIME: " + fakeTime);
  
  if (jtMouseEvents.isEmpty() && jtKeyEvents.isEmpty())
  exit();

}