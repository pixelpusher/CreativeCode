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
import java.util.List;
import org.apache.commons.collections4.iterators.LoopingListIterator;

ArrayList<Profile> profileGenerators = new ArrayList<Profile>(); // objects that will generate profile geometry
LoopingListIterator<Profile> profilesIter = new LoopingListIterator<Profile>(profileGenerators); // current profile to render

// common shape and scale variables:

double xScale = 23.07d; // horizontal scale in mm
double zScale = 23.164747d; // vertical scale in mm
double adjust = 0.2219d; // empirically-derived adjustment factor to make sure size in mm fits printable model dimensions
double scaleFactor = height; // scaling factor to fit on screen properly
double x = xScale*scaleFactor*adjust; // screen-adjusted horizontal coordinate
double z = zScale*scaleFactor*adjust; // screen-adjusted vertical coordinate
double xBase = 0; // an optional minimum or "base" length in the x-direction

String profileDate = year() + "-" + month() + "-" + day();

boolean recording = false; // record to SVG or not




void setup()
{ 
  size(1080, 720, P3D);

  profilesIter.add( new Profile() {

    private Spline2D spline = new Spline2D();

    public final String getName() { 
      return "B-spline-1";
    }

    ///////////////// for spiral 003 (A) /////////////////////////////////
    public final LineStrip2D calcPoints(double x, double z) 
    {
      Spline2D spline = new Spline2D();

      float fx = (float)x; // precision not needed here
      float fz = (float)z;

      int tightness = 10; // tightness for B-spline curve generation

      // pointy on bottom
      spline.add(0, 0);    
      spline.add(fx*0.66, fz*0.4); //underhang
      spline.add(fx, fz);
      spline.add(fx*0.3, fz*0.66); // overhang
      spline.add(0, 0); // close spline

      return spline.toLineStrip2D(tightness);
    }
    public List<Vec2D> getControlPoints() { 
      return this.spline.getPointList();
    };
  }
  );

  ///////////////// for spiral 008 /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      return "Param ellipse 008";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      LineStrip2D strip = new LineStrip2D();
      // pointy on top v2
      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 

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
      return strip;
    }
    public List<Vec2D> getControlPoints() {       
      return null;
    }
  }
  );



  ///////////////// for spirals 005 & 006 /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      return "Param ellipse 005-6";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      // like a symmetrical leaf petal

LineStrip2D strip = new LineStrip2D();

      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 

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
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );



  ///////////////// 2nd variant: for spirals 005 & 006 /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      return "Param ellipse 005-6";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      // like a symmetrical leaf petal
      LineStrip2D strip = new LineStrip2D();

      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 

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
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );



  ///////////////// 3rd variant: smooth parametric rewrite for spirals 005 & 006 /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      return "Param ellipse 005-6 smooth";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      // like a symmetrical leaf petal
LineStrip2D strip = new LineStrip2D();

      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 

      double inc = Math.PI/24d; // the resolution of the curve (smaller = more detail)

      float x0=0, z0=0;

      double flattenParam = 1/3d;

      // pointy on top v2 
      for (double angle=0; angle<maxAngle; angle+=inc)
      {
        double ax = x*Math.cos(angle)*0.5d;
        double sinTheta = Math.sin(angle);
        double sin2Theta = Math.sin(2d*angle);

        double newz = ax+x/2;
        double newx = ax;

        if (angle < PI)
        {
          newx = 0.5d*x*(flattenParam*sinTheta + (flattenParam/2)*sin2Theta);
        } else 
        {
          newx = 1.33d*x*(flattenParam*sinTheta - (flattenParam/2)*sin2Theta);
        }

        double rotAngle = -Math.PI/3d;

        float nx = (float)(newz*Math.cos(rotAngle)+newx*Math.sin(rotAngle));
        float nz = (float)(newx*Math.cos(rotAngle)-newz*Math.sin(rotAngle));

        // save first points to connect later
        if (angle == 0)
        {
          x0 = nx;
          z0 = nz;
        }
        strip.add(nx, nz);
      }
      strip.add(x0, z0);
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );


  ///////////////// like 005 but rounder /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      return "Param ellipse 005 round";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      LineStrip2D strip = new LineStrip2D();
      
      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 
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
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );


  ///////////////// for helix 012? teardrop /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      // ghost-shaped (rounded, angled teardrop)
      return "Param cubic ellipse 012";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      LineStrip2D strip = new LineStrip2D();
      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 
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
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );


  ///////////////// for helix 013 cat's paw /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      // looks a bit like a cat paw - sinusoidally-modulated ellipse
      return "Param cubic ellipse 012";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      LineStrip2D strip = new LineStrip2D();
      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 
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

        float newx = (float)(0.25d*xx*(Math.sin(angle)+centerOffX)-xScale*3.6d);
        float newz = (float)(0.25d*xx*(Math.cos(angle)+centerOffZ)-xScale*11d);

        if (angle == 0)
        {
          x0 = newx;
          z0 = newz;
        }

        strip.add(newx, newz);
      }
      strip.add(x0, z0);
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );


  ///////////////// for for 005 & 006 -- modified version of 3 /////////////////////////////////
  profilesIter.add( new Profile() {
    public final String getName() { 
      // like a symmetrical leaf petal
      return "Param ellipse 005-6 v2";
    }

    public final LineStrip2D calcPoints(double x, double z) 
    {
      LineStrip2D strip = new LineStrip2D();
      // Maximum angle for parametric sinusoidal shape envelope - needs to be 2PI so we get an elliptical, closed shape (only 
      // for elliptical shapes). Minimum angle is 0, of course.
      double maxAngle = Math.PI*2d; 
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
      return strip;
    }
    public List<Vec2D> getControlPoints() { 
      return null;
    }
  }
  );
}


/////////////////////////////////////////////////////////////////////
///// DRAW //////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

void draw() 
{  

  if (!recording)
  {
    background(255);
    fill(0);
    textSize(48);
    text("press a key", width/6, height/6);
  } else 
  {
    recording = false;

    if (profilesIter.hasNext()) 
    {
      Profile profile = profilesIter.next();
      LineStrip2D strip = profile.calcPoints(x, z);

      beginRecord(SVG, "profile_" + profile.getName() + "_" + profileDate + ".svg");
      background(255);
      ellipseMode(CENTER);
      stroke(0);
      textSize(24);
      fill(0, 255);

      text(profile.getName() + ", " + profileDate, width/12, height/24);
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

      List<Vec2D> controlPoints = profile.getControlPoints();

      if (controlPoints != null)
      {
        noFill();
        strokeWeight(3);
        stroke(0, 250, 250);

        for (Vec2D p : controlPoints)
        {
          //text(""+p.x+","+p.y, p.x, p.y);
          ellipse(p.y, p.x, diam*1.5, diam*1.5);
        }
      }

      popMatrix();
      endRecord();
    }
  }
  noLoop();
}


void keyReleased()
{
  recording = true;
  loop();
  redraw();
}
