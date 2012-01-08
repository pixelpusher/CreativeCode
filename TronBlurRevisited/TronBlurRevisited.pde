// Tron Blur Lighting Edition OLW Version
//
// Original concept and code by David Bollinger
// http://www.davebollinger.com (site is broken?)
//
// Modified and adapted by Evan Raskob 2012
// Added healing, unblocking, image cross-fading, etc
// http://pixelist.info
// http://openlabworkshops.org
//
// Licensed under the GNU Affero 3.0+
// http://www.gnu.org/licenses/agpl.html
//
// The image used is licensed as CC Attribution 2.0 Generic: http://creativecommons.org/licenses/by/2.0/deed.en
// by Flickr user Juliancolton2:
// http://www.flickr.com/photos/juliancolton/5360064817/
//

/**
 * Press 'p' to toggle the maze path overlay<br>
 * Click to advance early to next set of random parameters<br>
 * press ` to save to a file
 */


final int [] dxs = {
  1, 0, -1, 0
};
final int [] dys = {
  0, -1, 0, 1
};

final color overLayColor = color(255, 255, 255, 40);

int imgMode = BLEND;

final int imgModes[] = { 
  BLEND
};

Grid grid;
ArrayList<Walker> walkers;
int minwalkers = 40;
int maxwalkers = 120;
int nwalkers;
PImage srcImg, dstImg;

float mixingRatio = 0.3;

int currentseed = 0;
int nextwait = 0;

int minImgWidth, minImgHeight;

boolean bOverlayPath = true;
boolean fillImg = false;
int thickness = 1;



void setup() {
  //srcImg = loadImage("lightning2.png");

  //srcImg = loadImage("snowflake_juliancolton.png");
  srcImg = loadImage("Budapest_central_OSM.png");
  dstImg = loadImage("London_Geenwish_Isle_Dogs.png");

  minImgWidth = min(srcImg.width, dstImg.width);
  minImgHeight = min(srcImg.height, dstImg.height);

  size(minImgWidth, minImgHeight);

  //size(600,257);

  grid = new Grid(width, height, 2);
  strokeWeight(thickness);  

  //framerate(30);
  walkers = new ArrayList<Walker>(maxwalkers);
  background(0);
  //image(dstImg, 0,0);
  next();
}

void keyPressed() {
  if (key=='`') saveFrame("flake-######.png");
  if (key=='p') bOverlayPath = !bOverlayPath;
}

void mousePressed() {
  if (mouseButton == RIGHT)
  {
    nextwait=0;
    next();
  }
}


// carve out region
void mouseDragged()
{
  int carveDim = 20;
  
  grid.emptyRegion((pmouseX-carveDim/2)/grid.rez, (pmouseY-carveDim/2)/grid.rez, carveDim/grid.rez, carveDim/grid.rez);
  grid.blockRegion((mouseX-carveDim/2)/grid.rez, (mouseY-carveDim/2)/grid.rez, carveDim/grid.rez, carveDim/grid.rez);
}




void draw() {
  smooth();

  if (nextwait > 0) {
    if (--nextwait <= 0) next();
    else return;
  }

  srcImg.loadPixels();

  fill(0);
  noStroke();
  rectMode(CENTER);
  rect(mouseX, mouseY, 20, 20);

  rectMode(CORNER);

  for (int i=0, sz=walkers.size(); i<sz; i++) {
    Walker w = (Walker)walkers.get(i);
    w.move();
    w.draw(bOverlayPath);
  }
  if (grid.isFullySolid()) {
    nextwait = 2*30;
  }
}


void next() {

  //swap images
  PImage tmp = srcImg;
  srcImg = dstImg;
  dstImg = tmp;

  randomSeed(currentseed++);
  float burnone = random(1.0);

  imgMode = int(random(0, imgModes.length));

  //background(0);
  noStroke();
  fill(0, 100);
  rect(0, 0, width, height);

  grid.wipe();
  grid.setRez((int)(random(1.0, 6.0)));
  walkers.clear();
  nwalkers = (int)random(minwalkers, maxwalkers);
  for (int i=0; i<nwalkers; i++) {
    int x = (int)random(grid.cols);
    int y = (int)random(grid.rows);
    Walker w = new Walker(x, y);
    walkers.add(w);
    w.draw(false);
    grid.occupy(x, y);
  }
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


class Walker {

  int x, y, ox, oy, dir, handedness;
  color c;
  boolean alive;
  int skip = 1;

  Walker(int _x, int _y) {
    ox = x = _x;
    oy = y = _y;
    dir = (int)(random(4));
    c = srcImg.get(_x*grid.rez+grid.rez/2, _y*grid.rez+grid.rez/2);
    handedness = (random(1.0)>0.5) ? 1 : 3;
    alive = true;
    //skip = int(random(1,3));
  }

  void rebirth() {
    int tries = 10;
    do {
      ox = x = (int)random(grid.cols);
      oy = y = (int)random(grid.rows);
      if (grid.isEmpty(x, y)) {
        alive = true;
        grid.occupy(x, y);
        dir = (int)(random(4));
        color c = srcImg.pixels[minImgWidth*(y*grid.rez+grid.rez/2)+x*grid.rez+grid.rez/2];

        draw(false);
        return;
      }
    } 
    while (--tries > 0);
  }  

  void move() {
    if (!alive) rebirth();
    if (!alive) return;
    // only reason we check dir+2 is when just-reborn
    //  and thus just assigned a new random direction
    // otherwise we know it's blocked by our own trail
    int [] checkorder = { 
      (dir+handedness)%4, dir, (dir+handedness*3)%4, (dir+2)%4
    };
    int newx=x, newy=y, newd=dir;
    for (int i=0; i<4; i++) {
      newd = checkorder[i];
      newx = x + dxs[newd]/skip;
      newy = y + dys[newd]/skip;
      if (grid.isEmpty(newx, newy))
        break;
    }

    // move or die
    boolean blocked = grid.isBlocked(newx, newy);

    if (blocked) {
      alive = false;
    } 
    else {
      if ((x!=newx) || (y!=newy)) {
        // "walk" to new coordinates
        ox = x;
        oy = y;
        x = newx;
        y = newy;
        dir = newd;
        grid.occupy(x, y);
      }
    }
  }

  void draw(boolean bOverlayPath) {
    if (!alive) return;

    int ypos = y*grid.rez+grid.rez/2;
    int xpos = x*grid.rez+grid.rez/2;

    // mix src and dst image colors, then blur with current color

    color newc = srcImg.pixels[minImgWidth*ypos+xpos];
    color newc2 = dstImg.pixels[minImgWidth*ypos+xpos];

    c = blendC(c, blendC(newc, newc2, 0.5), mixingRatio);

    //c = blendColor(c, newc, imgMode); 
    fill(c);
    noStroke();
    if (fillImg)
      rect(x*grid.rez, y*grid.rez, grid.rez, grid.rez);

    if (bOverlayPath) {
      //stroke(overLayColor);
      stroke(c);
      line(ox*grid.rez+grid.rez/2, oy*grid.rez+grid.rez/2, 
      x*grid.rez+grid.rez/2, y*grid.rez+grid.rez/2);
    }
  }
}


class Grid {
  static final int EMPTY = 0;
  static final int SOLID = 1;
  static final int BLOCKED = 2;

  int [][] grid;
  int wid, hei;
  int rows, cols, rez;
  int cellcount, solidcount;

  Grid(int w, int h, int r) {
    wid = w;
    hei = h;
    setRez(r);
    grid = new int[hei][wid];
    wipe();
  }

  void setRez(int r) {
    rez = r;
    cols = wid / rez;
    rows = hei / rez;
    cellcount = rows * cols;
  }

  void wipe() {
    for (int r=0; r<rows; r++)
      for (int c=0; c<cols; c++)
        grid[r][c] = EMPTY;
    solidcount = 0;
  }

  void occupyRegion(int x, int y, int w, int h) 
  {
    if (x<0) x = 0;
    if (y<0) y = 0;
    
    int xmax = x+w;
    int ymax = y+h;

    if (xmax > wid) w -= (xmax-wid);
    if (ymax > hei) h -= (ymax-hei);

    for (int i=0; i < w; ++i)
      for (int j=0; j<h; ++j)
      {
        occupy(x+i, y+j);
      }
  }

  void blockRegion(int x, int y, int w, int h) 
  {
    if (x<0) x = 0;
    if (y<0) y = 0;

    int xmax = x+w;
    int ymax = y+h;

    if (xmax > wid) w -= (xmax-wid);
    if (ymax > hei) h -= (ymax-hei);

    for (int i=0; i < w; ++i)
      for (int j=0; j<h; ++j)
      {
        block(x+i, y+j);
      }
  }

  void emptyRegion(int x, int y, int w, int h) 
  {
    if (x<0) x = 0;
    if (y<0) y = 0;
    
    int xmax = x+w;
    int ymax = y+h;

    if (xmax > wid) w -= (xmax-wid);
    if (ymax > hei) h -= (ymax-hei);

    for (int i=0; i < w; ++i)
      for (int j=0; j<h; ++j)
      {
        empty(x+i, y+j);
      }
  }


  boolean isValidCoords(int c, int r) {
    return ((c>=0) && (r>=0) && (c<cols) && (r<rows));
  }
  boolean isFullySolid() {
    return (solidcount>=cellcount);
  }

  void set(int c, int r, int v) 
  {
    if (isValidCoords(c, r))
      grid[r][c] = v;
  }

  int get(int c, int r) {
    if (isValidCoords(c, r))
      return grid[r][c];
    else
      return SOLID;
  }

  boolean isEmpty(int c, int r) {
    return (this.get(c, r) == EMPTY);
  }
  boolean isSolid(int c, int r) {
    return (this.get(c, r) == SOLID);
  }
  boolean isBlocked(int c, int r) {
    int mode = this.get(c, r);
    return (mode == BLOCKED || mode == SOLID);
  }


  void occupy(int c, int r) {
    if (grid[r][c]==EMPTY) solidcount++;
    this.set(c, r, SOLID);
  }
  void block(int c, int r) {
    if (grid[r][c] == SOLID) solidcount--;
    this.set(c, r, BLOCKED);
  }

  void empty(int c, int r) {
    if (grid[r][c] == SOLID) solidcount--;
    this.set(c, r, EMPTY);
  }
}

