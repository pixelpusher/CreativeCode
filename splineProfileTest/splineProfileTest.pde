import toxi.geom.*;

LineStrip2D strip;

void setup()
{ 
  size(720, 720, P3D);
 
  background(0);

  Spline2D spline = new Spline2D();
  float spikiness = 360/5;
  float triSize =  1.0f*spikiness;
  float spiralRadius = 80/5;
  //float spikiness = 160*3;

  float minThickness = 0.95; // percentage, 0 - 1
  int diameterQuality = 3;


  float angle = 0;
  float inc = TWO_PI/diameterQuality;
  float r = triSize + minThickness * spiralRadius;

  spline.add(0, 0);
  spline.add(minThickness * spiralRadius, r/3);
  spline.add(minThickness * spiralRadius/2, r);
  spline.add(-minThickness * spiralRadius, r/3);
  spline.add(0, 0); // close spline

  strip = spline.toLineStrip2D(diameterQuality);
}


void draw() 
{
  translate(width/2, height/2);
  int numVerts = strip.getVertices().size();
  float diam = 10;
  Vec2D pv = strip.get(0);

  ellipseMode(CENTER);

  for (int i=1; i < numVerts; i++)
  { 
    fill(255.0 * i/float(numVerts));
    stroke(255,255,0);
    
    ellipse(pv.x, pv.y, diam, diam);
    Vec2D cv = strip.get(i);
    line(pv.x, pv.y, cv.x, cv.y);
    println("i:" + i + " :: dist to prev: " + cv.distanceToSquared(pv));

    pv = cv;
  }
  
  noLoop();
}

