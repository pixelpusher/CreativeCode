boolean theMouseDown = false;
int smouseX  =0, 
smouseY  =0, 
spmouseX =0, 
spmouseY =0, 
smState  =0;

float startMouseX = 0;
float endMouseX   = 0;
float startMouseY = 0;
float endMouseY   = 0;

LinkedList jtMouseEvents;


int formatRecMouseXPos(String mXp)
{
  return (int)((float)myW *  float(mXp)/(float)recScreenWidth);
}


int formatRecMouseYPos(String mYp)
{
  return (int)((float)myH * float(mYp)/(float)recScreenHeight);
}



int sketchMouseX()
{
  if (!rendering) return mouseX;
  else return smouseX;
}

int sketchMouseY()
{
  if (!rendering) return mouseY;
  else return smouseY;
}

int sketchpMouseX()
{
  if (!rendering) return pmouseX;
  else return spmouseX;
}

int sketchpMouseY()
{
  if (!rendering) return pmouseY;
  else return spmouseY;
}

void mousePressed()
{
  if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "pressed"));
  // check for key down - if special key, draw circular slider to select gesture

  handleMousePressed();
}

void handleMousePressed()
{
  theMouseDown = true;
  startMouseX=sketchMouseX();
  startMouseY=sketchMouseY();

  //println("pressed: " + sketchMouseX() + ", " + sketchMouseY());
}



void mouseDragged()
{
  if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "dragged"));
  handleMouseDragged();
}

void handleMouseDragged()
{
  theMouseDown = true;

    //if (G.distToLast(sketchMouseX(), sketchMouseY()) > minMove) {
    //    G.addPoint((float)sketchMouseX(), (float)sketchMouseY(), 0f);
    //    G.smooth();
    //    G.compile();
    //  }
    //}
 
}

void mouseMoved()
{
  if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "moved"));
  handleMouseMoved();
}

void handleMouseMoved()
{
  theMouseDown = false;
}


void mouseReleased()
{
  if (!rendering) jtMouseEvents.add(new jtMouseEvent(mouseX, pmouseX, mouseY, pmouseY, "released"));
  handleMouseReleased();
}  

void handleMouseReleased()
{
  theMouseDown = false;
}