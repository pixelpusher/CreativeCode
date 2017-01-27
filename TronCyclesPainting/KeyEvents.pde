import java.util.Arrays;

boolean keyDown = false;
boolean keyHandled = false;
char skey = ' ';
int skeyState = 0;

LinkedList jtKeyEvents;

long intervals[] = new long[3];
long medianTime;
int index = 0;

char sketchKey()
{
  if (!rendering) return key;
  else return skey;
}

void keyPressed()
{
  if (!rendering) jtKeyEvents.add(new jtKeyEvent(key, "pressed"));  
  handleKeyPressed();
}

void handleKeyPressed()  
{ 
  if (!keyHandled)
  {
    keyHandled = true;

    switch (sketchKey()) {

    case '%': 
      rendering = !rendering;
      break;

    case '1': 
      if (!rendering) saveEvents();
      break;

    case '+':
    case '=':
      break;

    case '-':
      break;

    case '\\': 
      break;

    case ']': 
      break;

    case '[': 
      break;


    default: 
      if (!keyDown)
      {
        keyDown = true;
        long currentTime = sketchTime();
        long timeInterval = currentTime - lastTime;
        lastTime = currentTime;

        intervals[index] = timeInterval/4;
        index = (index + 1) % intervals.length;
        Arrays.sort(intervals);
        medianTime = intervals[(intervals.length-1)/2];  /// middle element
        println("Median time: " + medianTime); 
      }
    }
  }
}//end key pressed


void keyReleased()
{
  if (!rendering) jtKeyEvents.add(new jtKeyEvent(key, "released"));
  handleKeyReleased();
}

void handleKeyReleased()
{ 
  keyDown = false;
}