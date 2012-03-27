/* 
 * Copyright (c) 2012 Evan Raskob
 * 
 * for testing out realtime interactive rendering to 3D tv screens (that take dual images) 
 * 
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License 3.0 for more details.
 * 
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

import toxi.geom.*;
import toxi.geom.mesh.*;

import toxi.processing.*;
import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;


ToxiclibsSupport gfx;
Vec3D p1, p2, p3;
TriangleMesh origMesh, mesh;
AxisAlignedCylinder cyl;
PeasyCam cam;

float MESH_X_SCALE = 60.0;
float MESH_Y_SCALE = 60.0;
PGraphics leftBuffer, rightBuffer;
float panAmt = -4.6;
float panAngle = -0.04;

void init() {
  frame.dispose();  
  frame.setUndecorated(true);
  super.init();
}


void setup() 
{
  size(1920, 1080, P3D);
  frame.setLocation(1280, 0);

  leftBuffer = createGraphics(width/2, height/2, P3D);
  rightBuffer = createGraphics(width/2, height/2, P3D);

  cam = new PeasyCam(this, height);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(500);
  cam.pan(-panAmt,0);

  mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("mesh.stl"), STLReader.TRIANGLEMESH);
  //mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("mesh-flipped.stl"),STLReader.TRIANGLEMESH).flipYAxis();
  gfx=new ToxiclibsSupport(this);

  p1 = new Vec3D();
  p2 = new Vec3D(0, 0, -2*height);


  cyl=new YAxisCylinder(new Vec3D(0, 0, 0), 1, 1);
  //origMesh = (TriangleMesh)cyl.toMesh();
  origMesh =(TriangleMesh)new AABB(new Vec3D(), 1).toMesh();

  origMesh.transform(new Matrix4x4().translateSelf(0, 0, 1));
}

void draw() 
{  
  background(0);
  //scale(0.5,0.5);
  p1.set(mouseX/2-width/2, mouseY-height/2, height/2); // mouse pos on screen

  p3 = p1.sub(0, 60, 2*height);  // just for testing

  //cam.getState().apply(picker.getBuffer());
  

  cam.lookAt(0,0,0);
  cam.rotateY(panAngle);
  cam.pan(panAmt*2,0);
  drawIntoBuffer(leftBuffer);  
  
  
  cam.lookAt(0,0,0);
  cam.rotateY(-panAngle);
  cam.pan(-panAmt*2,0);
  drawIntoBuffer(rightBuffer);
  
  
  cam.beginHUD();
  image(leftBuffer, 0, 0,width/2,height);
  image(rightBuffer, width/2, 0,width/2,height);
  cam.endHUD();
}



void drawIntoBuffer(PGraphics buffer)
{
  buffer.beginDraw();
  buffer.background(0);
  buffer.lights();
  cam.getState().apply(buffer);
  
  //buffer.scale(0.5,0.5,0.5);
  gfx.setGraphics(buffer);
  // draw axes
  gfx.origin(p1, 200);
  drawMeshBetween(p1, p2, origMesh, buffer);
  drawMeshBetween(p1, p3, origMesh, buffer);
  buffer.endDraw();
}


void drawMeshBetween(Vec3D p1, Vec3D p2, TriangleMesh mesh, PGraphics buffer)
{
  //place p1-p2 vector diff at origin
  gfx.setGraphics(buffer);

  Vec3D meshDiff = p1.sub(p2);
  float meshMag = meshDiff.magnitude();
  Vec3D dir = meshDiff.getNormalized();
  Vec3D meshScale = new Vec3D(MESH_X_SCALE, MESH_Y_SCALE, meshMag/2);

  // scale from point to point
  mesh = mesh.getScaled(meshScale);

  // align the Z axis of the box with the direction vector
  mesh.pointTowards(dir);

  buffer.noStroke();
  buffer.pushMatrix();
  gfx.translate(p2);
  gfx.mesh(mesh, false, 10);
  buffer.popMatrix();
}


void keyReleased()
{
  switch(key)
  {
    case '1': panAmt += 0.1;
    break;
    
    case '2': panAmt -= 0.1;
    break;
    
    case '[': panAngle += 0.01;
    break;
    
    case ']': panAngle -= 0.01;
    break;
    
  }
  println("pan amount:" + panAmt);
  println("pan angle:" + panAngle);
}
   
