/**
 * Testing bed and vector image renderer for swept helical forms.
 * Used in wavespiralstudio: https://github.com/pixelpusher/wavespiralvolumetric/tree/spiralspaper
 *
 * Copyright Evan Raskob, 2018.
 * evanraskob@gmail.com
 *
 * Released under the AGPL 3.0+ license: https://www.gnu.org/licenses/agpl-3.0.en.html
 *
 *
 */

import toxi.geom.*;
import processing.svg.*;

LineStrip2D strip; //container for final list of points
Spline2D spline = new Spline2D(); //B-spline implementation used only in some profiles

// common shape and scale variables:

float xScale = 23.07f; // horizontal scale in mm
float zScale = 23.164747f; // vertical scale in mm
float adjust = 0.2219f; // empirically-derived adjustment factor to make sure size in mm fits printable model dimensions
float scaleFactor = height; // scaling factor to fit on screen properly
float x = xScale*scaleFactor*adjust; // screen-adjusted horizontal coordinate
float z = zScale*scaleFactor*adjust; // screen-adjusted vertical coordinate


double xBase = 0; // an optional minimum or "base" length in the x-direction

// Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
// for elliptical shapes). Minimum angle is 0, of course.
double maxAngle = Math.PI*2d; 

// vector shape output variables
byte profileNumber = 0; // number of the profile to draw, from 0-4
String profileName = "B-spline";
String profileDate = year() + "-" + month() + "-" + day();

boolean recording = true; // record to SVG or not



void setup()
{ 
  size(1080, 720, P3D);
  noLoop();
}



// non-symmetrical, B-spline leaf-shaped profile
void makeProfile1()
{
  profileName = "B-spline-1";

  spline = new Spline2D();

  int tightness = 10; // tightness for B-spline curve generation

  // pointy on bottom
  spline.add(0, 0);    
  spline.add(x*0.66, z*0.4); //underhang
  spline.add(x, z);
  spline.add(x*0.3, z*0.66); // overhang
  spline.add(0, 0); // close spline
  strip = spline.toLineStrip2D(tightness);
}


// for spiral 008
void makeProfile2()
{
  // rounded teardrop shape, with too-small tail (this profile has an error)
  profileName = "Param ellipse 008";

  // pointy on top v2    
  double inc = Math.PI/24d;
  double offset = Math.PI/2d;

  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double envelope = Math.abs(angle/(maxAngle/2) - 1);
    //double envelope = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*0.2d); // little pointy on top

    envelope -= 1d;
    envelope = envelope*envelope; // smoothing
    envelope = envelope*envelope; //quadratic/rounder

    double xx = (1d-envelope)*x;

    strip.add((float)(0.5d*xx*(Math.cos(angle+offset)+1d)), 
      (float)(0.5d*xx*(Math.sin(angle+offset)+1d)));
  }
}



// for 005 & 006
void makeProfile3()
{
  // like a symmetrical leaf petal
  profileName = "Param ellipse 005-6";

  double inc = Math.PI/24d; // the resolution of the curve (smaller = more detail)
  double offset = Math.PI/8d; // smaller values ( < PI/2) curl shape CCW, larger values in CW direction
  // note: helix B uses offset of PI/3
  double curviness = 1/5d; // how curvy/paisley-like the final shape is. 0 is flattened, 0.5 is circular
  // and is max before outline splits

  float x0=0, z0=0;

  // pointy on top v2 
  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double envelope = Math.abs(angle/(maxAngle/2) - 1); // -1 to 1
    envelope = Math.sin(envelope*Math.PI*curviness); // little pointy on top
    
    double xx = envelope*x;  
    double curvinessMax = Math.sin(Math.PI*curviness);

    float newz = (float)(0.5d*xx/curvinessMax*(Math.cos(angle+offset)+1d));
    float newx = (float)(0.5d*xx/curvinessMax*(Math.sin(angle+offset)+1d)); 
    strip.add(newx, newz);

    // save first points to connect later
    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }
    strip.add(newx, newz);
  }
  strip.add(x0, z0);
}


// for 005 & 006
void makeProfile3b()
{
  // like a symmetrical leaf petal
  profileName = "Param ellipse 005-6";

  double inc = Math.PI/24d; // the resolution of the curve (smaller = more detail)
  double offset = Math.PI/8d; // smaller values ( < PI/2) curl shape CCW, larger values in CW direction
  // note: helix B uses offset of PI/3
  double curviness = 1/5d; // how curvy/paisley-like the final shape is. 0 is flattened, 0.5 is circular
  // and is max before outline splits

  float x0=0, z0=0;

  // pointy on top v2 
  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double envelope = Math.abs(angle/(maxAngle/2) - 1); // -1 to 1
    //envelope = Math.sin(envelope*Math.PI*curviness); // little pointy on top
    
    //double xx = envelope*x;  
    //double curvinessMax = Math.sin(Math.PI*curviness);

    float ax = (float)Math.cos(angle+offset) + 1f;
    ax *= 0.5;
    ax *= ax;
    float az = (float)Math.sin(angle+offset) + 1f;
    az *= 0.5;
    az *= az;

    float newz = (float)(1d*x*ax*envelope);
    float newx = (float)(1d*x*az*envelope); 
    strip.add(newx, newz);

    // save first points to connect later
    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }
    strip.add(newx, newz);
  }
  strip.add(x0, z0);
}



// for 005 & 006 // rewrite parametrically
void makeProfile3c()
{
  // like a symmetrical leaf petal
  profileName = "Param ellipse NEW";

  double inc = Math.PI/24d; // the resolution of the curve (smaller = more detail)

  float x0=0, z0=0;

  float flattenParam = 1/3f;

  // pointy on top v2 
  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    float ax = (float)(x*Math.cos(angle))*0.5;
    float sinTheta = (float)Math.sin(angle);
    float sin2Theta = (float)Math.sin(2*angle);

    float newz = ax+x/2;
    float newx = ax;
    
    if (angle < PI)
    {
      newx = 0.5*x*(flattenParam*sinTheta + (flattenParam/2)*sin2Theta);
    }
    else 
    {
      newx = 1.33*x*(flattenParam*sinTheta - (flattenParam/2)*sin2Theta);
    }
    
    float rotAngle = -PI/3;
    
    float nx = newz*cos(rotAngle)+newx*sin(rotAngle);
    float nz = newx*cos(rotAngle)-newz*sin(rotAngle);
        
    // save first points to connect later
    if (angle == 0)
    {
      x0 = nx;
      z0 = nz;
    }
    strip.add(nx, nz);
  }
  strip.add(x0, z0);
}



// like 005 but rounder
void makeProfile6()
{
  // like a symmetrical leaf petal
  profileName = "Param ellipse 005 round";

  double inc = Math.PI/24d; // the resolution of the curve (smaller = more detail)
  double offset = Math.PI/8d; // smaller values ( < PI/2) curl shape CCW, larger values in CW direction
  // note: helix B uses offset of PI/3
  double curviness = 0.5d; // how curvy/paisley-like the final shape is. 0 is circular, 0.5 is max before outline splits

  float x0=0, z0=0;

  // pointy on top v2 
  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double envelope = Math.abs(angle/(maxAngle/2) - 1); // -1 to 1
    envelope = Math.sin(envelope*Math.PI*curviness); // little pointy on top
    
    double xx = envelope*x;
    double curvinessMax = Math.sin(Math.PI*curviness);

    float newx = (float)(0.5d*xx/curvinessMax*(Math.cos(angle+offset)+1d));
    float newz = (float)(0.5d*xx/curvinessMax*(Math.sin(angle+offset)+1d)); 
    strip.add(newx, newz);

    // save first points to connect later
    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }
    strip.add(newx, newz);
  }
  strip.add(x0, z0);
}


void makeProfile4()
{
  // ghost-shaped (rounded, angled teardrop)
  profileName = "Param cubic ellipse 012";

  double inc = Math.PI/48d; // the resolution of the curve (smaller = more detail)
  double offset = Math.PI/8d; // smaller means curlier on the bottom, PI/2 means symmetrical
  double curviness = 0.4d; // how curvy/paisley-like the final shape is. 0 is circular, 0.5 is max before outline splits

  float x0=0, z0=0;

  double centerOffX = 2.8; // Shape central offset in horizonal direction
  double centerOffZ = 2.2; // Shape central offset in vertical direction

  for (double angle=0; angle<=maxAngle; angle+=inc)
  {    
    double envelope = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*curviness); // this will modify the elliptical profile shape
    double envelopeMin = Math.sin(Math.abs(Math.PI/(maxAngle/2) - 1d)*Math.PI*curviness); //  minimum value, for offsetting curve to 0

    //envelope = 0.75d + 0.25d*Math.cos(8*Math.PI * envelope);

    envelope -= 1d; // 0 to -1 to 0
    envelope = envelope*envelope*Math.abs(envelope); // smoothing, petal-like
    envelope = 2d-envelope; // 0-1 range

    envelopeMin -= 1d;
    envelopeMin = envelopeMin*envelopeMin*Math.abs(envelopeMin); // smoothing, petal-like
    envelopeMin = 2d-envelopeMin; // 0-1 range

    double xx = envelope*x + envelope*xBase;
    double xxMin = envelopeMin*x + envelopeMin*xBase;

    float newz = (float)(0.185d*xx*(Math.sin(angle+offset)+centerOffX)-xxMin*(Math.sin(Math.PI+offset)+centerOffX)*0.185d);
    float newx = (float)(0.185d*xx*(Math.cos(angle+offset)+centerOffZ)-xxMin*(Math.cos(Math.PI+offset)+centerOffZ)*0.185d);

    // save first points to connect later
    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }
    strip.add(newx, newz);
  }
  strip.add(x0, z0);
}



void makeProfile5()
{
  // looks a bit like a cat paw - sinusoidally-modulated ellipse
  profileName = "Param cubic ellipse 011";

  double inc = Math.PI/48d; // the resolution of the curve (smaller = more detail)
  double envelopeMin = 0.75d; // values greater than 0.65 are more circular, less than that and outline sections cross one another

  float x0=0, z0=0; // initial points

  double centerOffX = 1.15d; // Shape central offset in horizonal direction
  double centerOffZ = 2.8d;  // Shape central offset in vertical direction

  for (double angle=0; angle<=maxAngle; angle+=inc)
  {
    double envelope = Math.abs(angle/(maxAngle/2) - 1); // this will modify the elliptical profile shape

    envelope = envelopeMin + (1-envelopeMin)*Math.cos(8*Math.PI * envelope);  
    envelope -= 1d; // 0 to -1 to 0
    envelope = envelope*envelope*Math.abs(envelope); // smoothing, petal-like

    double xx = (2d-envelope)*x + envelope*xBase;

    float newx = (float)(0.25d*xx*(Math.sin(angle)+centerOffX))-xScale*3.6;
    float newz = (float)(0.25d*xx*(Math.cos(angle)+centerOffZ))-xScale*11;

    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }

    strip.add(newx, newz);
  }
  strip.add(x0, z0);     // END SIN SPIKES 2
}


void makeProfile7()
{
  // for 005 & 006 -- modified version of 3

  // like a symmetrical leaf petal
  profileName = "Param ellipse 005-6";

  double inc = Math.PI/24d; // the resolution of the curve (smaller = more detail)
  double offset = Math.PI/8d; // smaller values ( < PI/2) curl shape CCW, larger values in CW direction
  // note: helix B uses offset of PI/3
  double curviness = 1/5d; // how curvy/paisley-like the final shape is. 0 is flattened, 0.5 is circular
  // and is max before outline splits

  double curvinessMax = Math.sin(Math.PI*curviness);

  float x0=0, z0=0;

  // pointy on top v2 
  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double envelope = Math.abs(angle/(maxAngle/2) - 1); // abs(-1 to 1)
    
    envelope = Math.sqrt(envelope);
    
    // flattened
    //envelope *= envelope;
    
    // rounder
    //double envelope = (Math.cos(angle)+ 1d)*0.5d; // abs(-1 to 1)
    
    //envelope = Math.sin(envelope*Math.PI*curviness); // little pointy on top
    envelope = (envelope + 1d)/2d;
    double xx = envelope*x;  

    float newz = (float)(0.25d*xx/curvinessMax*(Math.cos(angle+offset)+1d));
    float newx = (float)(0.25d*xx/curvinessMax*(Math.sin(angle+offset)+1d));
        
    float rotAngle = PI/8;
    
    //float nz = newz*cos(rotAngle)-newx*sin(rotAngle);
    //float nx = newz*cos(rotAngle)+newx*sin(rotAngle);
    
    float nz = newz;
    float nx = newx;
    
    strip.add(nx, nz);

    // save first points to connect later
    if (angle == 0)
    {
      x0 = nx;
      z0 = nz;
    }
    //strip.add(newx, newz);
  }
  strip.add(x0, z0);
}


void draw() 
{  
  strip = new LineStrip2D();

  switch(profileNumber)
  {
  case 1:   
    makeProfile1();
    recording = true;
    break;

  case 2:   
    makeProfile2();
    recording = true;
    break;

  case 3:   
    makeProfile3c();
    recording = true;
    break;

  case 4:   
    makeProfile4();
    recording = true;
    break;

  case 5:   
    makeProfile5();
    recording = true;
    break;

  default:
    recording = false;
    background(255);
    fill(0);
    textSize(48);
    text("enter a number from 1-4 to render a profile", width/6, height/6);  
    break;
  }

  if (recording)
  {
    beginRecord(SVG, "profile_" + profileName + "_" + profileDate + ".svg");
    background(255);
    ellipseMode(CENTER);
    stroke(0);
    textSize(24);
    fill(0, 255);

    text(profileName + ", " + profileDate, width/12, height/24);
    fill(0, 10);

    pushMatrix();
    scale(-1, -1);

    translate(-4*width/5, -5*height/6);

    int numVerts = strip.getVertices().size();

    float diam = 10;

    //Vec2D pv = strip.get(0);

    strokeWeight(2);
    beginShape();

    for (int i=1; i < numVerts; i++)
    { 
      Vec2D cv = strip.get(i);
      vertex(cv.y, cv.x);
      // DEBUG vertices
      //println(cv);
    }
    endShape(CLOSE);

    for (int i=1; i < numVerts; i++)
    { 
      float fade = i/float(numVerts);
      fade = 1f-0.875*
        fade*fade;

      Vec2D cv = strip.get(i);

      fill(10, 80, 10, fade*255);    
      noStroke();
      ellipse(cv.y, cv.x, diam, diam);
    }
    endShape(CLOSE);

    // draw axes
    noFill();
    strokeWeight(3);
    stroke(0, 0, 0);
    line(0, 0, 600, 0);
    line(0, 0, 0, 600);

    // draw spline control points
    if (profileNumber == 1)
    {
      noFill();
      strokeWeight(3);
      stroke(0, 250, 250);

      for (Vec2D p : spline.getPointList())
      {
        //text(""+p.x+","+p.y, p.x, p.y);
        ellipse(p.y, p.x, diam*1.5, diam*1.5);
      }
    }
    popMatrix();
    endRecord();
  }
  noLoop();
}


void keyReleased()
{
  profileNumber = (byte)(key-48); 
  println(profileNumber);
  redraw();
}
