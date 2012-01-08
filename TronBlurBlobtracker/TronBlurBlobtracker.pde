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

import processing.video.*;



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
int maxwalkers = 80;
int nwalkers;
PImage srcImg, dstImg;

float mixingRatio = 0.3;

int currentseed = 0;
int nextwait = 0;

int minImgWidth, minImgHeight;

boolean bOverlayPath = true;
boolean fillImg = false;
int thickness = 1;


// camera tracking etc
static final float FADE_AMOUNT = 0.94;
float BRIGHT_THRESH = 0.3;

int numPixels;
int[] previousFrame, diffFrame;
float[] frameBrights;
PImage diffFrameImg;
Capture video;

boolean saveTheFrame = false;
boolean usingCamera = false;


void setup() {
  //srcImg = loadImage("lightning2.png");

  //srcImg = loadImage("snowflake_juliancolton.png");
  srcImg = loadImage("Budapest_central_OSM.png");
  dstImg = loadImage("London_Geenwish_Isle_Dogs.png");

  //  minImgWidth = min(srcImg.width, dstImg.width);
  //  minImgHeight = min(srcImg.height, dstImg.height);

  minImgWidth = 640;
  minImgHeight = 480;

  size(minImgWidth, minImgHeight,JAVA2D);

  hint(DISABLE_DEPTH_TEST);
  
  //size(600,257);

  video = new Capture(this, 320, 240, 30);
  numPixels = video.width * video.height;
  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
  diffFrame     = new int[numPixels];
  frameBrights = new float[numPixels];

  diffFrameImg = createImage(video.width, video.height, ARGB);

  grid = new Grid(width, height, 4);
  strokeWeight(thickness);  

  //framerate(30);
  walkers = new ArrayList<Walker>(maxwalkers);
  background(0);
  //image(dstImg, 0,0);
  next();
}

void keyReleased() {
  if (key=='`') saveFrame("flake-######.png");
  else
    if (key=='p') bOverlayPath = !bOverlayPath;
  else
    if (key=='c') usingCamera = !usingCamera;
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

  fill(0);
  noStroke();
  rectMode(CENTER);
  rect(mouseX, mouseY, carveDim, carveDim);

  rectMode(CORNER);
  
  grid.emptyRegion((pmouseX-carveDim/2)/grid.rez, (pmouseY-carveDim/2)/grid.rez, carveDim/grid.rez, carveDim/grid.rez);
  grid.blockRegion((mouseX-carveDim/2)/grid.rez, (mouseY-carveDim/2)/grid.rez, carveDim/grid.rez, carveDim/grid.rez);
}




void draw() {

  handleCamera();

  noSmooth();

  if (nextwait > 0) {
    if (--nextwait <= 0) next();
    else return;
  }
  
  srcImg.loadPixels();

  for (int i=0, sz=walkers.size(); i<sz; i++) {
    Walker w = (Walker)walkers.get(i);
    w.move();
    w.draw(bOverlayPath);
  }
  if (grid.isFullySolid()) {
    nextwait = 2*30;
  }

  //if (keyPressed && key == 'i')
  //{
    image(diffFrameImg, 0, 0,width,height);
  //}
}


void next() {

  //swap images
  //PImage tmp = srcImg;
  //srcImg = dstImg;
  //dstImg = tmp;

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


void handleCamera()
{

  if (video.available()) 
  {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available
    //loadPixels();
    
    diffFrameImg.loadPixels();

    for (int i = 0; i < numPixels; ++i) 
    { 
      // For each pixel in the video frame...
      color currColor = video.pixels[i];
      color prevColor = previousFrame[i];


      if (brightness(currColor) > brightness(prevColor))
      {
        // Extract the red, green, and blue components from current pixel
        int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
        int currG = (currColor >> 8) & 0xFF;
        int currB = currColor & 0xFF;

        // Extract red, green, and blue components from previous pixel
        int prevR = (prevColor >> 16) & 0xFF;
        int prevG = (prevColor >> 8) & 0xFF;
        int prevB = prevColor & 0xFF;
        // Compute the difference of the red, green, and blue values

        int diffR = abs(currR - prevR);
        int diffB = abs(currB - prevB);
        int diffG = abs(currG - prevG);

        int newR = int( lerp(currR, prevR, FADE_AMOUNT) );
        int newG = int( lerp(currG, prevG, FADE_AMOUNT) );
        int newB = int( lerp(currB, prevB, FADE_AMOUNT) );

        previousFrame[i] = 0xff000000 | (newR << 16) | (newG << 8) | newB;       
        diffFrame[i]     = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;


        if (usingCamera)
        {
          frameBrights[i] = brightness(diffFrame[i])/255f;

          //       diffFrameImg.pixels[i] = diffFrame[i];
          //pixels[i] = (frameBrights[i] > BRIGHT_THRESH) ? 0xff000000 : pixels[i];
          
          diffFrameImg.pixels[i] = (frameBrights[i] > BRIGHT_THRESH) ? 0xff000000 : 0x00000000;

          int ix = (i % width) / (grid.rez/2);
          int iy = i/width;
          iy /= grid.rez/2;

          if (frameBrights[i] > BRIGHT_THRESH) 
          {
            grid.block(ix, iy);
          }
          else
            grid.unblock(ix, iy);
        }
      }
      else
      {
        previousFrame[i] = currColor;
        diffFrame[i] = 0x00000000;  // no alpha, black
        diffFrameImg.pixels[i] = diffFrame[i];
      }
    }
    // end for each pixel
  }
  diffFrameImg.updatePixels();
  //updatePixels();
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
    grid[r][c] = SOLID;
  }
  
  void block(int c, int r) {
    if (grid[r][c] == SOLID) solidcount--;
    grid[r][c] = BLOCKED;
//    this.set(c, r, BLOCKED);
  }

  // unblock without removing solids
  void unblock(int c, int r) {
    if (grid[r][c] == BLOCKED)
        grid[r][c] = EMPTY;
//      this.set(c, r, EMPTY);
  }

  void empty(int c, int r) {
    if (grid[r][c] == SOLID) solidcount--;
    this.set(c, r, EMPTY);
  }
}




// ==================================================
// Super Fast Blur v1.1
// by Mario Klingemann 
// <http://incubator.quasimondo.com>
// ==================================================
void fastblur(PImage img, int radius)
{
  if (radius<1) {
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
  int vmin[] = new int[max(w, h)];
  int vmax[] = new int[max(w, h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++) {
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++) {
    rsum=gsum=bsum=0;
    for (i=-radius;i<=radius;i++) {
      p=pix[yi+min(wm, max(i, 0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++) {

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if (y==0) {
        vmin[x]=min(x+radius+1, wm);
        vmax[x]=max(x-radius, 0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++) {
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for (i=-radius;i<=radius;i++) {
      yi=max(0, yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++) {
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if (x==0) {
        vmin[y]=min(y+radius+1, hm)*w;
        vmax[y]=max(y-radius, 0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }
}

