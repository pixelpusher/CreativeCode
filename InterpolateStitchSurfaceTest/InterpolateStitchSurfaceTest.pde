// 
// take two spline profile shapes of different sizes and interpolate between each of their
// points to create smoothly joining surfaces.
// Use cross product of diff between points 1-3 and 2-4 to find normal to surface, use that to offset 
// the straight line between the two (multiply bezier interpolation value by normalized diff btw vectors
// in direction of normal


import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import java.util.Iterator;
import peasy.*;

int MAX_RES = 8; // number of points in between curves
float bezCoeff = -0.2;

// create bezier curve for interpolation
// the 2 parameters control curvatures in both halves
BezierInterpolation tween=new BezierInterpolation(bezCoeff, -bezCoeff);

PeasyCam cam;

// there are two paths with 2 points in each (forming a square surface area)
Vec3D currentPathPoint, currentPathDirection, nextCurrentPathPoint;
Vec3D nextPathPoint, nextPathDirection, nextNextPathPoint;

// random values to extrude at each point
float currentValue, nextValue;


void calculate()
{
  currentValue = random(10, 600);
  nextValue = random(10, 600);
  
  // create some arbitrary vectors for the two paths
  currentPathPoint = new Vec3D(random(-200, 200), random(-200, 200), random(-200, 200));
  currentPathDirection = new Vec3D(random(-1, 1), random(-1, 1), random(-1, 1));
  nextCurrentPathPoint = currentPathPoint.add(currentPathDirection.scale(100)); // 100 units in the path direction

  nextPathPoint  = new Vec3D(random(-200, 200), random(-200, 200), random(-200, 200));
  nextPathDirection = currentPathDirection.add(random(-0.1, 0.1), random(-0.1, 0.1), random(-0.1, 0.1)); // add a little noise
  nextNextPathPoint = nextPathPoint.add(nextPathDirection.scale(100)); // 100 units in the path direction
}


void setup()
{
  size(960, 480, P3D);

  calculate();

  // setup 3D camera
  cam = new PeasyCam(this, width);
  cam.setMinimumDistance(-200);
  cam.setMaximumDistance(width*200);
  cam.setResetOnDoubleClick(true);
}


void draw()
{
  background(0);
  
  // draw axes
  colorMode(RGB);
  stroke(0, 200, 0);
  strokeWeight(0.5);
  line(0, -10000, 0, 0, 10000, 0);
  stroke(200, 0, 0);
  line(-10000, 0, 0, 10000, 0, 0);
  stroke(0, 0, 200);
  line(0, 0, -10000, 0, 0, 10000);


  // draw the path points
  beginShape(POINTS);
  noFill();
  strokeWeight(16);
  colorMode(HSB);
  stroke(color(255, 250, 220));
  vertex(currentPathPoint);
  stroke(color(255, 250, 180));
  vertex(nextCurrentPathPoint);
  stroke(color(180, 250, 220));
  vertex(nextPathPoint);
  stroke(color(180, 250, 180));
  vertex(nextNextPathPoint);
  endShape();

  colorMode(RGB);

  // find vectors perpendicular to the surface created by the 4 path points
  Vec3D vCurrent = nextCurrentPathPoint.sub(currentPathPoint).cross( nextPathPoint.sub(currentPathPoint) ).normalize();
  Vec3D vNext = currentPathPoint.sub(nextPathPoint).cross( nextNextPathPoint.sub(nextPathPoint) ).normalize();

  // draw arrows to show directionality
  Cone coneVC = new Cone(vCurrent.scale(100).add(currentPathPoint), vCurrent, 1, 10, 20);
  noStroke();
  fill(255, 100, 80);
  drawMesh(coneVC.toMesh(12));
  noFill();

  Cone coneVN = new Cone(vNext.scale(100).add(nextPathPoint), vNext, 1, 10, 20);
  noStroke();
  fill(255, 100, 80);
  drawMesh(coneVN.toMesh(12));
  noFill();

  // draw perpendicular vectors
  beginShape(LINES);
  strokeWeight(3);

  stroke(255, 0, 255);
  vertex(currentPathPoint);
  vertex(vCurrent.scale(100).add(currentPathPoint));

  vertex(nextPathPoint);
  vertex(vNext.scale(100).add(nextPathPoint));

  endShape();


  // interpolate between the two values and project in the direction of the surface vectors
  

  beginShape(POINTS);
  noFill();
  strokeWeight(6);
  colorMode(HSB);
  
  for (int i=0; i<MAX_RES; i++)
  {
    // calculate linear mix of two vectors perpendicular to the path
    float progress = (float)i/(MAX_RES-1); // make sure it goes to 100%
    
    // Add linear mix of the two.  Because both are normalized, the result will be too.   
    Vec3D currentNormal = vCurrent.scale(1-progress).add(vNext.scale(progress));
    
    // calculate current point inbetween the two, on the surface
    Vec3D currentPoint =  currentPathPoint.scale(1-progress).add(nextPathPoint.scale(progress));
    float value = tween.interpolate(currentValue,nextValue, progress);
    
    stroke(color(255, 255-(int)(progress*255), 200));
    vertex( currentPoint);
    vertex( currentPoint.add ( currentNormal.scale(value) ));
  }
  endShape();

  // draw planar surface formed by the 4 points
  beginShape(TRIANGLES);
  fill(255,80);
  strokeWeight(0.5);
  stroke(255,120);
  // vertices need to be anti-clockwise
  // 1-3-2
  vertex(currentPathPoint);
  vertex(nextPathPoint);
  vertex(nextCurrentPathPoint);
  // 2-3-4
  vertex(nextCurrentPathPoint);
  vertex(nextPathPoint);
  vertex(nextNextPathPoint);
  endShape();
  
  cam.beginHUD();
  noStroke();
  fill(255);
  text("Bez coeff:" + bezCoeff, 24, 16);
  cam.endHUD();
  
}



void keyPressed()
{
  if (key == 'a')
  {
    bezCoeff += 0.1;
    tween.setCoefficients(bezCoeff, -bezCoeff);
  }
  else if (key == 's')
  {
    bezCoeff -= 0.1;
    tween.setCoefficients(bezCoeff, -bezCoeff);
  }
  else
    calculate();
}


void drawMesh(Mesh3D mesh)
{
  beginShape(TRIANGLES);
  // iterate over all faces/triangles of the mesh
  for (Iterator i=mesh.getFaces ().iterator(); i.hasNext(); ) {
    Face f=(Face)i.next();
    // create vertices for each corner point
    vertex(f.a);
    vertex(f.b);
    vertex(f.c);
  }
  endShape();
}

void vertex(Vec3D v) {
  vertex(v.x, v.y, v.z);
}

