/*
 * Spiral Geometry Test
 * by Evan Raskob AKA pixelpusher info@pixelist.info
 */


import java.util.Iterator;
import toxi.geom.*;
import toxi.math.*;
import toxi.volume.*;
import processing.opengl.*;
import peasy.*;


PeasyCam cam;
SpiralLineStrip3D spiral = null;
PShape spiralShape = null;
PShape vectorsShape = null;
float diffVecLength; 
Vec3D[] outwardVecs, tanVecs;

boolean drawOutlines = true; // by default, draw outlines of key geometry (see keyReleased)


void setup()
{
  size(1280, 720, P3D);

  cam = new PeasyCam(this, width);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(width*20);
  cam.setResetOnDoubleClick(true);

  float turns = 3.2; 

  diffVecLength = width/20; // length of the inwrds pointing diff vectors
  //diffVecLength = 1; // normalize

  spiral = new SpiralLineStrip3D( new Vec3D(0, 0, 0), new Vec3D(0, 1, 0) );
  spiral.setRadius( this.width/3, false)
    .setTurns(turns, false)
      .setDistanceBetweenTurns(this.height/(turns*2), false)
        .setNumPoints(int(turns) * 12, false)
          .setEdgeThickness( this.height/(turns*8) ); 

  spiralShape = pointsToShape(spiral.getVertices());
  vectorsShape = makePerpVectorsShape(spiral.getVertices());

  setupSplines();

  splineShape = createProfilesShape(spiral.getVertices(), tanVecs, outwardVecs, strip.getVertices());
  splinePointsShape = createProfilesPointsShape(spiral.getVertices(), tanVecs, outwardVecs, strip.getVertices());
  splinePolygonShape = createFilledProfilesShape( spiral.getVertices(), tanVecs, outwardVecs, strip.getVertices());
  background(0);
}



PShape pointsToShape(List<Vec3D> points) {        
  final PShape retained = createShape();

  retained.enableStyle();
  retained.beginShape();
  retained.noFill();
  retained.stroke(220);
  retained.strokeWeight(2);
  //retained.ambient(100);


  float strokeInc = 255.0/points.size(); 
  float strokeVal = strokeInc;

  for (ReadonlyVec3D v : points) {

    retained.stroke(strokeVal, 80, strokeVal);
    retained.vertex(v.x(), v.y(), v.z());
    strokeVal += strokeInc;
  }

  retained.endShape();
  return retained;
}


PShape makePerpVectorsShape(final List<Vec3D> points)
{
  int numPoints = points.size();

  // inwards pointing vector at each spiral point

  outwardVecs = new Vec3D[ points.size() ];
  for (int i=0; i < outwardVecs.length; i++)
    outwardVecs[i] = new Vec3D(0, 0, 0);

  tanVecs = new Vec3D[ points.size() ];
  for (int i=0; i < tanVecs.length; i++)
    tanVecs[i] = new Vec3D(0, 0, 0);


  // take the next point and subtract from previous point to get inwards pointing vector

  for (int i=1; i < numPoints-1; i++)
  {
    // tangents
    tanVecs[i] = points.get(i+1).sub( points.get(i-1) );
    tanVecs[i].normalizeTo(diffVecLength);

    Vec3D v0 = points.get(i).sub( points.get(i-1) );
    Vec3D v1 = points.get(i).sub( points.get(i+1) );

    outwardVecs[i] = v0.add(v1);

    outwardVecs[i].normalizeTo(diffVecLength);
  }

  tanVecs[0].set(tanVecs[1]);
  tanVecs[numPoints-1].set(tanVecs[numPoints-2]);

  outwardVecs[0].set(outwardVecs[1]);
  outwardVecs[numPoints-1].set(outwardVecs[numPoints-2]);


  PShape retained = createShape();

  retained.enableStyle();
  retained.beginShape(LINES);
  retained.noFill();
  retained.stroke(240, 80, 0);
  retained.strokeWeight(2);

  for (int i=0; i < points.size(); i++)
  {
    ReadonlyVec3D v0 = points.get(i);
    ReadonlyVec3D v1 = outwardVecs[i];

    // outwards vector
    retained.stroke(240, 80, 0);
    retained.vertex(v0.x(), v0.y(), v0.z());
    retained.vertex(v0.x()+v1.x(), v0.y()+v1.y(), v0.z()+v1.z());

    v1 = tanVecs[i];

    //tan vector
    retained.stroke(0, 80, 240);
    retained.vertex(v0.x(), v0.y(), v0.z());
    retained.vertex(v0.x()+v1.x(), v0.y()+v1.y(), v0.z()+v1.z());
  }

  retained.endShape();

  return retained;
}



void draw()
{
  background(0);
  //hint(DISABLE_DEPTH_TEST);

  if (drawOutlines)
  {


    if (spiralShape != null) shape(spiralShape);
    if (vectorsShape != null) shape(vectorsShape);
    if (splineShape != null) shape(splineShape);
    if (splinePointsShape != null) shape(splinePointsShape);
  } else
  {

    // make sure we are culling the right faces - STL files need anti-clockwise winding orders for triangles
    PGL pgl = beginPGL();
    pgl.enable(PGL.CULL_FACE);
    pgl.frontFace(PGL.CCW);
    pgl.cullFace(PGL.BACK);

    if (splinePolygonShape != null) shape(splinePolygonShape);
    endPGL(); // restores the GL defaults for Processing
  }
}


void keyPressed()
{
  if (key == 'm')
  {
    drawOutlines = !drawOutlines;
  }
  else if (key == ' ')
  {
    println("random noise...");

    noLoop();
    // add random noise to spiral points
    List<Vec3D> points = spiral.getVertices();
    float l = spiral.getLength()/12.0;

    println("spiral length: " + l);

    for (Vec3D p : points)
    {
      float rx = random(-l, l);
      float ry = random(-l, l);
      float rz = random(-l, l);

      p.addSelf( rx, ry, rz );
    }

    spiralShape = pointsToShape(points);
    vectorsShape = makePerpVectorsShape(points);
    splineShape = createProfilesShape( points, tanVecs, outwardVecs, strip.getVertices());
    splinePointsShape = createProfilesPointsShape( points, tanVecs, outwardVecs, strip.getVertices());
    splinePolygonShape = createFilledProfilesShape( points, tanVecs, outwardVecs, strip.getVertices());


    loop();
  }
}

