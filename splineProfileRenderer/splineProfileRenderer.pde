import toxi.geom.*;
import processing.svg.*;

LineStrip2D strip; //container for final list of points
Spline2D spline = new Spline2D(); //used only in some profiles


float xScale = 23.07f; // in mm
float adjust = 0.2219f; // empirically-derived adjustment factor to make sure size in mm fits printable model dimensions
float zScale = 23.164747f;
float scaleFactor = height;
float z = zScale*scaleFactor*adjust;
float x = xScale*scaleFactor*adjust;

double xBase = 0; // an optional minimum or "base" length in the x-direction

// needs to be 2PI so we get an elliptical, closed shape (only for elliptical shapes). Minimum angle is 0, of course.
double maxAngle = Math.PI*2d; 


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
  // rounded teardrop shape, with too-small tail (was an error)
  profileName = "Param ellipse 008";


  // pointy on top v2    
  double inc = Math.PI/24d;
  double maxAngle = Math.PI*2d;
  double offset = Math.PI/2d;

  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double prog = Math.abs(angle/(maxAngle/2) - 1);
    //double prog = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*0.2d); // little pointy on top

    prog -= 1d;
    prog = prog*prog; // smoothing
    prog = prog*prog; //quadratic/rounder

    double xx = (1d-prog)*x;

    strip.add((float)(0.5d*xx*(Math.cos(angle+offset)+1d)), 
      (float)(0.5d*xx*(Math.sin(angle+offset)+1d)));
  }
}



// for 005 & 006
void makeProfile3()
{
  // like a symmetrical leaf petal
  profileName = "Param ellipse 005-6";

  double inc = Math.PI/24d;
  double maxAngle = Math.PI*2d;
  double offset = Math.PI/6d;

  // pointy on top v2 
  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    //double prog = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*0.5d); // full sin
    double prog = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*0.2d); // little pointy on top
    //prog = prog*prog; // smoothing
    //prog = prog*prog; //cubic?

    double xx = 2*prog*x;  //yeah, float/double conversion blah blah

    strip.add((float)(0.5d*xx*(Math.cos(angle+offset)+1d)), (float)(0.5d*xx*(Math.sin(angle+offset)+1d)));
  }
}


void makeProfile4()
{
  // ghost-shaped (rounded, angled teardrop)
  profileName = "Param cubic ellipse 012";

  double inc = Math.PI/48d; // the resokution of the curve (smaller = more detail)
  double maxAngle = Math.PI*2d; // needs to be 2PI so we get an elliptical, closed shape
  double offset = Math.PI/8d; // smaller means curlier on the bottom, PI/2 means symmetrical

  float x0=0, z0=0;

  double centerOffX = 2.8;
  double centerOffZ = 2.2; // try 1.2 or 1.8

  for (double angle=0; angle<=maxAngle; angle+=inc)
  {
    //double prog = Math.abs(angle/(maxAngle/2) - 1); //-1 to 1 --> 1 to 0 to 1
    double prog = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*0.4d); // little pointy on top

    //prog = 0.75d + 0.25d*Math.cos(8*Math.PI * prog);

    prog -= 1d; // 0 to -1 to 0
    prog = prog*prog*Math.abs(prog); // smoothing, petal-like
    //prog = prog*prog; //cubic?

    double xx = (2d-prog)*x + prog*xBase;

    float newz = (float)(0.185d*xx*(Math.sin(angle+offset)+centerOffX)-55*centerOffX);
    float newx = (float)(0.185d*xx*(Math.cos(angle+offset)+centerOffZ)-55*centerOffZ);

    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }



    strip.add(newx, newz);
  }
  strip.add(x0, z0);     // END SIN SPIKES 2
}


void makeProfile5()
{
  // looks a bit like a cat paw - sinusoidally-modulated ellipse
  profileName = "Param cubic ellipse 011";

  double inc = Math.PI/48d;
  double maxAngle = Math.PI*2d;
  double offset = Math.PI/3d;

  float x0=0, z0=0;

  double centerOffX = 1.15d;
  double centerOffZ = 2.8d; // try 1.2 or 1.8

  for (double angle=0; angle<=maxAngle; angle+=inc)
  {
    double prog = Math.abs(angle/(maxAngle/2) - 1); //-1 to 1 --> 1 to 0 to 1
    //double prog = Math.sin(Math.abs(angle/(maxAngle/2) - 1)*Math.PI*0.2d); // little pointy on top

    prog = 0.75d + 0.25d*Math.cos(8*Math.PI * prog); 

    prog -= 1d; // 0 to -1 to 0
    prog = prog*prog*Math.abs(prog); // smoothing, petal-like
    //prog = prog*prog; //cubic?

    double xx = (2d-prog)*x + prog*xBase;

    float newx = (float)(0.25d*xx*(Math.sin(angle+offset)+centerOffX))-xScale*3.6;
    float newz = (float)(0.25d*xx*(Math.cos(angle+offset)+centerOffZ))-xScale*11;

    if (angle == 0)
    {
      x0 = newx;
      z0 = newz;
    }



    strip.add(newx, newz);
  }
  strip.add(x0, z0);     // END SIN SPIKES 2
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
    makeProfile3();
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
    text("enter a number from 1-4 to render a profile", width/2, height/2);  
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
      println(cv);
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
