/*
 * Show how the cross product can be used to find a vector perpendicular (at right angles) to 2 vectors.
 *
 * 2015 by Evan Raskob <info@pixelist.info>
 *
 * This example is in the public domain.
 */

import toxi.geom.*;
import toxi.geom.mesh.*;
import java.util.Iterator;
import peasy.*;

PeasyCam cam;


Vec3D a, b, c;

void setup()
{
  size(960, 480, P3D);

  a = new Vec3D(280, -80, -80); // end of one vector
  b = new Vec3D(-80, -80, -80); // shared middle point of both vectors
  c = new Vec3D(-80, -80, 180); // end point of another vector
  
  // set up 3D camera
  
  cam = new PeasyCam(this, width);
  cam.setMinimumDistance(0);
  cam.setMaximumDistance(width*200);
  cam.setResetOnDoubleClick(true);

}


void draw()
{
  background(0);
  
  // draw 3D axes
  stroke(0,200,0,120);
  strokeWeight(0.5);
  line(0,-height,0, 0,height,0);
  stroke(200,0,0);
  line(-width,0,0, width,0,0);
  stroke(0,0,200);
  line(0,0,-width, 0,0,width);


  // calculate vectors
  Vec3D ab = a.sub(b);
  Vec3D cb = c.sub(b);
  Vec3D crossed = ab.cross(cb).normalizeTo(100);
  
  // draw cones to show direction
  Cone coneAB = new Cone(a, ab, 1, 10, 20);
  noStroke();
  fill(255, 100, 80);
  drawMesh(coneAB.toMesh(16));
  noFill();
  
  Cone coneCB = new Cone(c, cb, 1, 10, 20);
  noStroke();
  fill(255, 255, 0);
  drawMesh(coneCB.toMesh(16));
  noFill();

  Vec3D crossStart = crossed.add(b);
  Cone coneCr = new Cone(crossStart, crossed, 1, 10, 20);
  noStroke();
  fill(255,0,255);
  drawMesh(coneCr.toMesh(16));
  noFill();

  // draw vectors
  beginShape(LINES);
  strokeWeight(3);

  stroke(255, 100, 80);
  vertex(a.x(), a.y(), a.z());
  vertex(b.x(), b.y(), b.z());

  stroke(255, 255, 0);
  vertex(c.x(), c.y(), c.z());
  vertex(b.x(), b.y(), b.z());

  stroke(255, 0, 255);
  vertex(crossed.x()+b.x(), crossed.y()+b.y(), crossed.z()+b.z());
  vertex(b.x(), b.y(), b.z());
  endShape();
}


void drawMesh(Mesh3D mesh)
{
    beginShape(TRIANGLES);
  // iterate over all faces/triangles of the mesh
  for(Iterator i=mesh.getFaces().iterator(); i.hasNext();) {
    Face f=(Face)i.next();
    // create vertices for each corner point
    vertex(f.a);
    vertex(f.b);
    vertex(f.c);
  }
  endShape();
}

void vertex(Vec3D v) {
  vertex(v.x,v.y,v.z);
}

