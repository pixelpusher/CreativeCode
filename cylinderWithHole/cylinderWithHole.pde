import toxi.geom.*;
import toxi.geom.mesh.TriangleMesh;
import toxi.geom.mesh.Mesh3D;
import toxi.geom.mesh.Face;
import peasy.*;
import java.util.Iterator;

PeasyCam cam;


float baseStartZ = -25f;
float baseEndZ = 25f;

double baseStartRadius = 380d;
double baseEndRadius = 420d;
int resolution = 48;

PShape meshy = null;


TriangleMesh mesh;

// create a circular path with the number of points (e.g. resolution)
LineStrip3D makeHiResCircle3D(Vec3D pos, double r, int res)
{
  LineStrip3D result = new LineStrip3D();
  double TWOPI = Math.PI*2d;
  double radiansPerPoint = TWOPI / res;

  double angle = 0d;
  while (angle < TWOPI+radiansPerPoint)
  {
    Vec3D pt = new Vec3D( 
    (float)(Math.cos(angle)*r)+pos.x(), 
    (float)(Math.sin(angle)*r)+pos.y(), 
    pos.z()
      );
    result.add(pt);
    println(pt);

    angle +=  radiansPerPoint;
  }
  println("done");
  return result;
}


void setup()
{
  size(800, 600, P3D);

  cam = new PeasyCam(this, width);
  cam.setMinimumDistance(10);
  cam.setMaximumDistance(width);
  cam.setResetOnDoubleClick(true);


  LineStrip3D c1 = makeHiResCircle3D(new Vec3D(0, 0, baseStartZ), baseStartRadius, resolution);
  LineStrip3D c2 = makeHiResCircle3D(new Vec3D(0, 0, baseStartZ), baseEndRadius, resolution);

  mesh = makeMesh(c1, c2);


  LineStrip3D c3 = makeHiResCircle3D(new Vec3D(0, 0, baseEndZ), baseStartRadius, resolution);
  LineStrip3D c4 = makeHiResCircle3D(new Vec3D(0, 0, baseEndZ), baseEndRadius, resolution);

  mesh.addMesh( makeMesh(c4, c3) );


// inner walls
 c3 = makeHiResCircle3D(new Vec3D(0, 0, baseStartZ), baseStartRadius, resolution);
 c4 = makeHiResCircle3D(new Vec3D(0, 0, baseEndZ), baseStartRadius, resolution);

 mesh.addMesh( makeMesh(c4, c3) );


// outer walls
 c3 = makeHiResCircle3D(new Vec3D(0, 0, baseStartZ), baseEndRadius, resolution);
 c4 = makeHiResCircle3D(new Vec3D(0, 0, baseEndZ), baseEndRadius, resolution);

 mesh.addMesh( makeMesh(c3, c4) );

  meshy = meshToRetained(mesh, false);
}



void draw()
{
  background(0);  
  strokeWeight(8);
  stroke(255, 0, 255);
  point(0, 0);

  // draw 3D axes
  stroke(0, 200, 0, 120);
  strokeWeight(0.5);
  line(0, -height, 0, 0, height, 0);
  stroke(200, 0, 0);
  line(-width, 0, 0, width, 0, 0);
  stroke(0, 0, 200);
  line(0, 0, -width, 0, 0, width);

  PGL pgl = beginPGL();

  pgl.enable(PGL.CULL_FACE);
  // make sure we are culling the right faces - STL files need anti-clockwise winding orders for triangles
  pgl.frontFace(PGL.CCW);
  pgl.cullFace(PGL.BACK);

  if (meshy != null) shape(meshy);

  endPGL();


  //noFill();
  //strokeWeight(4);

 // drawStripPoints(c1);
 // drawStripPoints(c2);
}


//
// just for convenience
//
void vertex(Vec3D p)
{
  vertex(p.x(), p.y(), p.z());
}



// 
// Draw a line strip as points.
//
void drawStripPoints(LineStrip3D l)
{
  strokeWeight(3);
  stroke(color(255, 255));
  beginShape(POINTS);
  for (Vec3D p : l)
  {
    vertex(p.x(), p.y(), p.z() );
  }
  endShape();
}

//
// Make a triangle mesh from two lists of 3D points with the same number of points.
// Assumes the point lists are clockwise.
//
TriangleMesh makeMesh(LineStrip3D strip1, LineStrip3D strip2)
{
  int strip1Size = strip1.getVertices().size();
  int strip2Size = strip2.getVertices().size();

  if (strip1Size != strip2Size) return null;

  TriangleMesh mesh = new TriangleMesh("mesh", strip2Size*2*3, strip2Size*2 );

  Iterator<Vec3D> strip1Iter = strip1.iterator();
  Iterator<Vec3D> strip2Iter = strip2.iterator();

  Vec3D p1, // prev point in strip 1 
  p2, // current point in strip 1 
  p3, // prev point in strip 2
  p4; // current point in strip 2

  p1 = strip1Iter.next();
  p3 = strip2Iter.next();

  while (strip1Iter.hasNext ())
  {
    p2 =  strip1Iter.next();
    p4 =  strip2Iter.next();

    // 1-3-2
    mesh.addFace(p1, p3, p2);

    //2-3-4
    mesh.addFace(p2, p3, p4);

    p1 = p2;
    p3 = p4;
  }

  return mesh;
}




PShape meshToRetained(Mesh3D mesh, boolean smth) {        
  PShape retained = createShape();

  retained.beginShape(TRIANGLES);
  //retained.enableStyle();
  mesh.computeFaceNormals();

  if (smth) 
  {  
    mesh.computeVertexNormals();

    for (Face f : mesh.getFaces ()) {
      retained.normal(f.a.normal.x, f.a.normal.y, f.a.normal.z);
      retained.vertex(f.a.x, f.a.y, f.a.z);
      retained.normal(f.b.normal.x, f.b.normal.y, f.b.normal.z);
      retained.vertex(f.b.x, f.b.y, f.b.z);
      retained.normal(f.c.normal.x, f.c.normal.y, f.c.normal.z);
      retained.vertex(f.c.x, f.c.y, f.c.z);
    }
  } else {
    int i=0;
    for (Face f : mesh.getFaces ()) {
      // println("triangles"+ i++);
      retained.normal(f.normal.x, f.normal.y, f.normal.z);
      retained.vertex(f.a.x, f.a.y, f.a.z);
      retained.vertex(f.b.x, f.b.y, f.b.z);
      retained.vertex(f.c.x, f.c.y, f.c.z);
    }
  }
  retained.endShape();
  return retained;
}