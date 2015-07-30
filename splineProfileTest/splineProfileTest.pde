import toxi.geom.*;

LineStrip2D strip;
Spline2D spline;
float thick;
float triSize;

void setup()
{ 
  size(720, 720, P3D);

  
  spline = new Spline2D();
  float minThickness = 0.15; // percentage, 0 - 1
  float spikiness = 720/5;
  triSize =  1.0f*spikiness + minThickness*spikiness;
  float spiralRadius = 80/5;
  //float spikiness = 160*3;


  int diameterQuality = 6;


  float angle = 0;
  float inc = TWO_PI/diameterQuality;
  float r = triSize;

  thick = minThickness * spikiness;

  spline.add(0, 0);
  spline.add(thick*3, triSize/3);
  spline.add(thick*4, 4*triSize/5);
  spline.add(-thick/2, triSize/2);
  spline.add(0, 0); // close spline

  strip = spline.toLineStrip2D(diameterQuality);
}


void draw() 
{
  translate(width/2, height/2);
  ArrayList<Vec2D> simplified = new ArrayList<Vec2D>();

  simplified = (ArrayList<Vec2D>) Simplify.simplifyDouglasPeucker( strip.getVertices(), 4);
  
  int numVerts = strip.getVertices().size();
 
  float diam = 10;
  
  Vec2D pv = strip.get(0);

  background(0);
  
  strokeWeight(1);
  stroke(0,250,0);
  line (0,0, 0,height);
  line (0,-height, 0,height);
  line (-width,0, width,0);
  

  ellipseMode(CENTER);
  strokeWeight(1);

  for (int i=1; i < numVerts; i++)
  { 
    fill(255.0 * i/float(numVerts));
    stroke(255, 255, 0);

    ellipse(pv.x, pv.y, diam, diam);
    Vec2D cv = strip.get(i);
    line(pv.x, pv.y, cv.x, cv.y);
    println("i:" + i + " :: dist to prev: " + cv.distanceToSquared(pv));

    pv = cv;
  }
 
 stroke(0,250,250);
 for (int i=1; i < simplified.size(); i++)
  { 
    fill(255.0 * i/float(numVerts));
    stroke(0, 0, 255, 180);

    ellipse(pv.x, pv.y, diam, diam);
    Vec2D cv = simplified.get(i);
    line(pv.x, pv.y, cv.x, cv.y);
   
    pv = cv;
  }




  noFill();
  strokeWeight(3);
  stroke(0, 250, 250);
  
  for (Vec2D p : spline.getPointList())
  {
    text(""+p.x+","+p.y, p.x, p.y);
    ellipse(p.x, p.y, diam*1.5, diam*1.5);
  }
  strokeWeight(0.5);
  stroke(250, 180, 0);
  
  line(thick,-height, thick, height);
  line(-thick,-height, -thick, height);

line(-width, triSize, width, triSize);

  noLoop();
}

