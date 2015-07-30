import toxi.geom.*;
import java.util.List;

LineStrip2D strip;
Spline2D spline;
float thick;
float triSize;
PShape splineShape = null, splinePointsShape = null;

void setupSplines()
{
  spline = new Spline2D();
  float minThickness = 0.15; // percentage, 0 - 1
  float spikiness = width/6;
  triSize =  1.0f*spikiness + minThickness*spikiness;
  float spiralRadius = spiral.getRadius();
  

  int diameterQuality = 3;
  
  float angle = 0;
  float inc = TWO_PI/diameterQuality;

  thick = spiral.getEdgeThickness();

  spline.add(0, 0);
  spline.add(thick*2, triSize/4);
  spline.add(thick*3, 4*triSize/5);
  spline.add(thick, triSize/2);
  spline.add(0, 0); // close spline

  strip = spline.toLineStrip2D(diameterQuality);
}


void drawSplineProfile() 
{
  translate(width/2, height/2);
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


PShape createProfilesShape(ReadonlyVec3D[] curvePoints, ReadonlyVec3D[] tanVecs, ReadonlyVec3D[] outwardVecs, List<Vec2D> profilePoints)
{
  PShape retained = null;
  
  if (tanVecs.length != outwardVecs.length && tanVecs.length != curvePoints.length)
  {
    println("Error in createProfilesShape: point arrays must be same length!");
    return null;
  }
  
  retained = createShape();
  retained.beginShape();  
  retained.enableStyle();
  retained.noFill();
  retained.strokeWeight(3);
  

  // first perpendicular frames
  
  for (int i=0; i < curvePoints.length; i++)
  {
      int numProfilePoints = profilePoints.size();
      for (int j=0; j < numProfilePoints; j++)
      {
        Vec2D pp = profilePoints.get(j);
        ReadonlyVec3D v0 = curvePoints[i];
        ReadonlyVec3D v1 = outwardVecs[i].getNormalized();
        
        float x = v0.x() + pp.y()*v1.x();  
        float y = v0.y() + pp.y()*v1.y();
        float z = v0.z() + pp.x();
        retained.stroke(250,250,0,100);
        retained.vertex( x,y,z );
      }
  }
  
  retained.endShape();
  return retained;
}



PShape createProfilesPointsShape(ReadonlyVec3D[] curvePoints, ReadonlyVec3D[] tanVecs, ReadonlyVec3D[] outwardVecs, List<Vec2D> profilePoints)
{
  PShape retained = null;
  
  if (tanVecs.length != outwardVecs.length && tanVecs.length != curvePoints.length)
  {
    println("Error in createProfilesShape: point arrays must be same length!");
    return null;
  }
  
  retained = createShape();
  retained.beginShape(POINTS);  
  retained.enableStyle();
  retained.noFill();
  retained.strokeWeight(8);
  

  // first perpendicular frames
  
  for (int i=0; i < curvePoints.length; i++)
  {
      int numProfilePoints = profilePoints.size();
      for (int j=0; j < numProfilePoints; j++)
      {
        Vec2D pp = profilePoints.get(j);
        ReadonlyVec3D v0 = curvePoints[i];
        ReadonlyVec3D v1 = outwardVecs[i].getNormalized();
        
        float x = v0.x() + pp.y()*v1.x();  
        float y = v0.y() + pp.y()*v1.y();
        float z = v0.z() + pp.x();
        
        float r = (200.0*j)/numProfilePoints + 55.0;
    
        retained.stroke(r,100,0,200);  
        retained.vertex( x,y,z );
      }
  }
  
  retained.endShape();
  return retained;
}





// like before, but create faces instead of lines
//
PShape createFilledProfilesShape(ReadonlyVec3D[] curvePoints, ReadonlyVec3D[] tanVecs, ReadonlyVec3D[] outwardVecs, List<Vec2D> profilePoints)
{
  PShape retained = null;
  
  if (tanVecs.length != outwardVecs.length && tanVecs.length != curvePoints.length)
  {
    println("Error in createProfilesShape: point arrays must be same length!");
    return null;
  }
  
  retained = createShape();
  retained.beginShape(TRIANGLES);  
  retained.enableStyle();
  retained.noFill();
  retained.stroke(240,240,0,100);
  retained.strokeWeight(3);

  // first perpendicular frames
  
  for (int i=0; i < curvePoints.length; i++)
  {
      int numProfilePoints = profilePoints.size();
      for (int j=0; j < numProfilePoints; j++)
      {
        Vec2D pp = profilePoints.get(j);
        ReadonlyVec3D v0 = curvePoints[i];
        ReadonlyVec3D v1 = outwardVecs[i].getNormalized();
        
        float x = v0.x() + pp.y()*v1.x();  
        float y = v0.y() + pp.y()*v1.y();
        float z = v0.z() + pp.x();
        retained.normal( v1.x(), v1.y(), v1.z() );
        retained.vertex( x,y,z );
      }
  }
  
  retained.endShape();
  return retained;
}

