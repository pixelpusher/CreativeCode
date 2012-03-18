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

import processing.opengl.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;

ToxiclibsSupport gfx;
Vec3D p1, p2, p3;
TriangleMesh origMesh, mesh;
AxisAlignedCylinder cyl;

float MESH_X_SCALE = 60.0;
float MESH_Y_SCALE = 60.0;


void setup() 
{
  size(640, 480, OPENGL);

//  mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("mesh.stl"), STLReader.TRIANGLEMESH);
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
  lights();
  
  //scale(0.5,0.5);
  p1.set(mouseX, mouseY, 0); // mouse pos on screen

  p3 = p1.sub(0, 60, -2*height);  // just for testing
  

  PGraphics buffer = this.g;
  // draw axes
  gfx.origin(p1, 200);
  drawMeshBetween(p1, p2, MESH_X_SCALE, MESH_Y_SCALE, origMesh, buffer);
  drawMeshBetween(p1, p3, MESH_X_SCALE, MESH_Y_SCALE, origMesh, buffer);
}



void drawMeshBetween(Vec3D p1, Vec3D p2, float scaleX, float scaleY, TriangleMesh mesh, PGraphics buffer)
{
  //place p1-p2 vector diff at origin
  gfx.setGraphics(buffer);

  Vec3D meshDiff = p2.sub(p1);
  float meshMag = meshDiff.magnitude();
  Vec3D dir = meshDiff.getNormalized();
  
  // scale properly
  Vec3D meshScale = new Vec3D(scaleX, scaleY, meshMag/2);

  // scale from point to point
  mesh = mesh.getScaled(meshScale);

  // get current rotation
  float[] axis=Quaternion.getAlignmentQuat(dir,Vec3D.Z_AXIS).toAxisAngle();

  buffer.noStroke();
  buffer.pushMatrix();

  // move to 1st points
  gfx.translate(p1);
  
  // align the Z axis of the box with the direction vector  
  rotate(axis[0],axis[1],axis[2],axis[3]);
  

// draw rotated coordinate system
  gfx.origin(new Vec3D(),100);
  gfx.mesh(mesh, false, 10);
  buffer.popMatrix();
}


void keyReleased()
{
}
   
