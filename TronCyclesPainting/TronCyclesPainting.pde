// Tron 
// 
// Modified and adapted by Evan Raskob 2017
// http://pixelist.info
//
// Licensed under the GNU Affero 3.0+
// http://www.gnu.org/licenses/agpl.html
//

import java.util.LinkedList;
import java.util.ListIterator;

static int FRAMERATE = 30*2; 
long startTime = 0;  // time sketch was started, for calculating recording times and keypresses
long fakeTime  = 0; //"fake" time when we're rendering, in ms
long lastTime = 0;
float fakeFrameRate=30.0; // for rendering

final int [] dxs = {
  1, 0, -1, 0
};
final int [] dys = {
  0, -1, 0, 1
};

final int CYCLE_LIFETIME = 100;

Grid grid;
LinkedList<Cycle> cycles;
final int mincycles = 1;
final int maxcycles = 120;
int ncycles;
boolean respawn = false; // respawn cycless automagically after dying

int scaling = 16;
int currentseed = 0;
int nextwait = 0;

static int myW=1280;
static int myH=720;

int minMove = myW/60;


// handle shutdown properly and save recordings -- needs to be library, really
PEventsHandler disposeHandler;

//PGraphics cycleImageBuffer;

void settings()
{
  //size(srcImg.width,srcImg.height);
  size(myW, myH, P3D);
}

void setup() {
  //fullScreen();

  smooth(4);
  
  // needed to make sure we stop recording properly
  disposeHandler = new PEventsHandler(this);

  grid = new Grid(width/scaling, height/scaling);
  strokeWeight(1);  

  frameRate(FRAMERATE);
  cycles = new LinkedList<Cycle>();
  background(180);
  //image(srcImg, 0,0);
  next();

  // event rendering system
  jtMouseEvents = new LinkedList();
  jtKeyEvents = new LinkedList();

  if (rendering)
  {
    String sString = "cycles_" + year() + month() + day() + "_" + hour() + "-" + minute() + "-" + second()+".mov";
    println("rendering TO DISK: " + sString);

    /*
      mm = new GSMovieMaker(this, width, height, "sString.ogg", GSMovieMaker.THEORA, GSMovieMaker.HIGH, (int)fakeFrameRate);
     mm.start();
     */

    /*mm = new MovieMaker(this, width, height, sString,
     (int)frameRate, MovieMaker.JPEG, MovieMaker.HIGH);
     */
    loadRecording(); // load saved key and mouse presses
    println("...");
  }
} // end setup


void draw() 
{
  background(180);

  if (nextwait > 0) 
  {
    if (--nextwait <= 0) next();
    else return;
  }

  //srcImg.loadPixels();

  int i = 0;

  pushMatrix();
  scale(scaling);

  for (Cycle w : cycles) 
  {
    i++;

    if (w.alive)
    {
      w.move(grid);
    } 
    else 
    {
      if (respawn)
      {
        addCycle(sketchMouseX(), sketchMouseY());
      }
    }
    
    w.draw();
    
  } //end for all Cycles
  popMatrix();

  if (grid.isFullySolid()) 
  {
    nextwait = 2*30;
  }
}


void next() {
  randomSeed(currentseed++);
  float burnone = random(1.0);

  // imgMode = int(random(0,imgModes.length));

  //background(0);
  pushStyle();
  noStroke();
  fill(0, 255);
  rectMode(CORNER);
  rect(0, 0, width, height);
  popStyle();

  grid.clear();
  grid.setDims(width/scaling, height/scaling);
  cycles.clear();
  /*
  ncycles = (int)random(mincycles, maxcycles);
   for (int i=0; i<ncycles; i++) {
   int x = (int)random(grid.getWidth());
   int y = (int)random(grid.getHeight());
   Cycle w = new Cycle(x, y, CYCLE_LIFETIME);
   cycles.add(w);
   grid.set(x, y, Grid.SOLID);
   }
   */
}


Cycle addCycle(int x, int y)
{
  x = x/scaling;
  y = y/scaling;
  Cycle w = new Cycle(x, y, CYCLE_LIFETIME);
  if (cycles.size() >= maxcycles)
  {
    Cycle first = cycles.removeFirst();
    first.freeGrid(grid); // clear up used spaces
  }
  cycles.add(w);
  grid.set(x, y, Grid.SOLID);

  return w;
}

color blendC(color c1, color c2, float t) {

  //int a = (c1 >> 24) & 0xFF;
  int r1 = (c1 >> 16) & 0xFF;  // Faster way of getting red(argb)
  int g1 = (c1 >> 8) & 0xFF;   // Faster way of getting green(argb)
  int b1 = c1 & 0xFF;          // Faster way of getting blue(argb)

  int r2 = (c2 >> 16) & 0xFF;  // Faster way of getting red(argb)
  int g2 = (c2 >> 8) & 0xFF;   // Faster way of getting green(argb)
  int b2 = c2 & 0xFF;          // Faster way of getting blue(argb)

  t = min(max(t, 0), 1.0);

  return color( r1+t*(r2-r1), g1+t*(g2-g1), b1+t*(b2-b1) );
}