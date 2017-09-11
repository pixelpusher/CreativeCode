import toxi.geom.*;
import processing.svg.*;

LineStrip2D strip;
int diameterQuality = 10;

void setup()
{ 
  size(1200, 1200, P3D);

  float spiralThickness = 23.07f; // in mm
  float spiralRadius = 14.172489f; // in mm
  float adjust = 0.2219f;
  float spikiness = 23.164747f;
  float minThickness = 0.08916104f; // percentage, 0 - 1
  float scaleFactor = 0.5*width/spikiness;

  float y =  spikiness*scaleFactor;
  float yBase = 1f*spikiness;

  float x = spiralThickness*scaleFactor;
  float xBase = 0; // minRMS*spiralThickness; // TODO: is this right??

  makeProfile2(x, y);
}



void makeProfile1(float x, float y)
{
  Spline2D spline = new Spline2D();

  // pointy on bottom
  spline.add(0, 0);    
  spline.add(x*0.66, y*0.4); //underhang
  spline.add(x, y);
  spline.add(x*0.3, y*0.66); // overhang
  spline.add(0, 0); // close spline
  strip = spline.toLineStrip2D(diameterQuality);
}

void makeProfile2(float x, float y)
{
  // pointy on top v2    
  double inc = Math.PI/24d;
  double maxAngle = Math.PI*2d;
  double offset = Math.PI/2d;

  strip = new LineStrip2D();

  for (double angle=0; angle<maxAngle; angle+=inc)
  {
    double prog = Math.abs(angle/(maxAngle/2) - 1);
    prog -= 1d;
    prog = prog*prog; // smoothing
    prog = prog*prog; //cubic?

    double xx = (1d-prog)*x;

    strip.add((float)(0.5d*xx*(Math.cos(angle+offset)+1d)), (float)(0.5d*xx*(Math.sin(angle+offset)+1d)));
  }
}


void draw() 
{
  beginRecord(SVG, "spline.svg");
  translate(3*width/4, 3*height/4);
  rotate(PI);
  int numVerts = strip.getVertices().size();

  float diam = 10;

  Vec2D pv = strip.get(0);

  background(255);
  ellipseMode(CENTER);
  strokeWeight(2);

  for (int i=1; i < numVerts; i++)
  { 
    float fade = i/float(numVerts);
    fade = 1f-0.875*
      fade*fade;

    Vec2D cv = strip.get(i);

    fill(10, 80, 10, fade*255);
    stroke(10);

    line(pv.x, pv.y, cv.x, cv.y);

    noStroke();
    ellipse(pv.x, pv.y, diam, diam);


    pv = cv;
  }
  /* 
   noFill();
   strokeWeight(3);
   stroke(0, 250, 250);
   
   for (Vec2D p : spline.getPointList())
   {
   text(""+p.x+","+p.y, p.x, p.y);
   ellipse(p.x, p.y, diam*1.5, diam*1.5);
   }
   */
  endRecord();   
  noLoop();
}