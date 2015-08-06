import toxi.geom.*;
import java.util.List;

LineStrip2D strip;
Spline2D spline;
float thick;
float triSize;
PShape splineShape = null, splinePointsShape = null, splinePolygonShape = null;

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
  stroke(0, 250, 0);
  line (0, 0, 0, height);
  line (0, -height, 0, height);
  line (-width, 0, width, 0);


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

  for (Vec2D p : spline.getPointList ())
  {
    text(""+p.x+","+p.y, p.x, p.y);
    ellipse(p.x, p.y, diam*1.5, diam*1.5);
  }
  strokeWeight(0.5);
  stroke(250, 180, 0);

  line(thick, -height, thick, height);
  line(-thick, -height, -thick, height);

  line(-width, triSize, width, triSize);

  noLoop();
}


PShape createProfilesShape(List<Vec3D> curvePoints, ReadonlyVec3D[] tanVecs, ReadonlyVec3D[] outwardVecs, List<Vec2D> profilePoints)
{
  PShape retained = null;

  if (tanVecs.length != outwardVecs.length && tanVecs.length != curvePoints.size())
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

  for (int i=0; i < curvePoints.size(); i++)
  {
    int numProfilePoints = profilePoints.size();
    for (int j=0; j < numProfilePoints; j++)
    {
      Vec2D pp = profilePoints.get(j);
      ReadonlyVec3D v0 = curvePoints.get(i);
      ReadonlyVec3D v1 = outwardVecs[i].getNormalized();

      float x = v0.x() + pp.y()*v1.x();  
      float y = v0.y() + pp.y()*v1.y();
      float z = v0.z() + pp.x();
      retained.stroke(250, 250, 0, 100);
      retained.vertex( x, y, z );
    }
  }

  retained.endShape();
  return retained;
}



PShape createProfilesPointsShape(List<Vec3D> curvePoints, ReadonlyVec3D[] tanVecs, ReadonlyVec3D[] outwardVecs, List<Vec2D> profilePoints)
{
  PShape retained = null;

  if (tanVecs.length != outwardVecs.length && tanVecs.length != curvePoints.size())
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

  for (int i=0; i < curvePoints.size(); i++)
  {
    int numProfilePoints = profilePoints.size();
    for (int j=0; j < numProfilePoints; j++)
    {
      Vec2D pp = profilePoints.get(j);
      ReadonlyVec3D v0 = curvePoints.get(i);
      ReadonlyVec3D v1 = outwardVecs[i].getNormalized();

      float x = v0.x() + pp.y()*v1.x();  
      float y = v0.y() + pp.y()*v1.y();
      float z = v0.z() + pp.x();

      float r = (200.0*j)/numProfilePoints + 55.0;

      retained.stroke(40, 10, r, 220);  
      retained.vertex( x, y, z );
    }
  }

  retained.endShape();
  return retained;
}





// like before, but create faces instead of lines
//
PShape createFilledProfilesShape(List<Vec3D> curvePoints, ReadonlyVec3D[] tanVecs, ReadonlyVec3D[] outwardVecs, List<Vec2D> profilePoints)
{
  PShape retained = null;

  if (tanVecs.length != outwardVecs.length && tanVecs.length != curvePoints.size())
  {
    println("Error in createProfilesShape: point arrays must be same length!");
    return null;
  }

  retained = createShape();
  retained.beginShape(TRIANGLES);  
  retained.enableStyle();

  // first perpendicular frames

  // need this curve point and current and next profile points, plus
  // next curve point and current and next profile points

  int faces = 0;

  for (int i=0; i < curvePoints.size()-1; i++)
  {
    int numProfilePoints = profilePoints.size();
    for (int j=0; j < numProfilePoints-1; j++)
    {
      Vec2D pp = profilePoints.get(j);
      Vec2D ppn = profilePoints.get(j+1);

      ReadonlyVec3D v0 = curvePoints.get(i);
      ReadonlyVec3D v1 = outwardVecs[i].getNormalized();

      ReadonlyVec3D v0n = curvePoints.get(i+1);
      ReadonlyVec3D v1n = outwardVecs[i+1].getNormalized();

      // current curve point and next in profile (1)
      float x0 = v0.x() + pp.y()*v1.x();  
      float y0 = v0.y() + pp.y()*v1.y();
      float z0 = v0.z() + pp.x();

      // (2)
      float x1 = v0.x() + ppn.y()*v1.x();  
      float y1 = v0.y() + ppn.y()*v1.y();
      float z1 = v0.z() + ppn.x();

      // next curve point and next in profile (3)

      float x0n = v0n.x() + pp.y()*v1n.x();  
      float y0n = v0n.y() + pp.y()*v1n.y();
      float z0n = v0n.z() + pp.x();

      // (4)
      float x1n = v0n.x() + ppn.y()*v1n.x();  
      float y1n = v0n.y() + ppn.y()*v1n.y();
      float z1n = v0n.z() + ppn.x();

      retained.fill(random(0, 255), random(0, 255), random(0, 255));

      // 1-3-2
      retained.vertex( x0, y0, z0);
      retained.vertex( x0n, y0n, z0n);
      retained.vertex( x1, y1, z1);

      ++faces;

      // 2-3-4
      retained.vertex( x1, y1, z1);
      retained.vertex( x0n, y0n, z0n);
      retained.vertex( x1n, y1n, z1n);

      ++faces;
    }
  }
  
  //
  // add end cap
  //
  int numProfilePoints = profilePoints.size();
  Vec3D endProfilePoints[] = new Vec3D[numProfilePoints];

  for (int j=0; j < numProfilePoints; j++)
  {
    Vec2D pp = profilePoints.get(j);
    ReadonlyVec3D v0 = curvePoints.get(curvePoints.size()-1);
    ReadonlyVec3D v1 = outwardVecs[curvePoints.size()-1].getNormalized();

    // current curve point
    float x = v0.x() + pp.y()*v1.x();
    float y = v0.y() + pp.y()*v1.y();
    float z = v0.z() + pp.x();
    
    endProfilePoints[j] = new Vec3D(x,y,z); 
  }
  
  // find average (center) point of cap
  Vec3D centerPoint = new Vec3D(0,0,0);
  for (Vec3D p : endProfilePoints)
    centerPoint.addSelf(p);
  centerPoint.scaleSelf(1.0/endProfilePoints.length);
  
  println("center point: " + centerPoint);
  
  // profile points go clockwise, so we go backwards
  int j=numProfilePoints;
  while (j>1)
  {
    --j;
    Vec3D v0 = endProfilePoints[j];
    Vec3D v1 = endProfilePoints[j-1];
    
    retained.vertex( v0.x(), v0.y(), v0.z());
    retained.vertex( v1.x(), v1.y(), v1.z());
    retained.vertex( centerPoint.x(), centerPoint.y(), centerPoint.z());
  }
  /////// finished with end cap
  
  
  //
  // add start cap
  //
  
  for (j=0; j < numProfilePoints; j++)
  {
    Vec2D pp = profilePoints.get(j);
    ReadonlyVec3D v0 = curvePoints.get(0);
    ReadonlyVec3D v1 = outwardVecs[0].getNormalized();

    // current curve point
    float x = v0.x() + pp.y()*v1.x();
    float y = v0.y() + pp.y()*v1.y();
    float z = v0.z() + pp.x();
    
    endProfilePoints[j] = new Vec3D(x,y,z); 
  }
  
  // find average (center) point of cap
  centerPoint.set(0,0,0);
  for (Vec3D p : endProfilePoints)
    centerPoint.addSelf(p);
  centerPoint.scaleSelf(1.0/endProfilePoints.length);
  
  // profile points go clockwise, but this is the start, so we go clockwise
  j=0;
  while (j < numProfilePoints-1)
  {
    Vec3D v0 = endProfilePoints[j];
    Vec3D v1 = endProfilePoints[j+1];
    
    retained.vertex( v0.x(), v0.y(), v0.z());
    retained.vertex( v1.x(), v1.y(), v1.z());
    retained.vertex( centerPoint.x(), centerPoint.y(), centerPoint.z());
    ++j;
  }




  println("added " + faces + " faces");
  retained.endShape();
  return retained;
}

