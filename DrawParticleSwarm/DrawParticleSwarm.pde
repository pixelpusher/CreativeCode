// Swarming points using GLModel and GLCamera, using sprite textures.
// By Evan Raskob


import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*; 
import codeanticode.glgraphics.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import java.nio.FloatBuffer;

ImageParticleSwarm swarm;
ParticleExpander particleExpander;

TriangleMesh triMesh;

Vec3D prev=new Vec3D();
Vec3D p=new Vec3D();
Vec3D q=new Vec3D();

Vec2D rotation=new Vec2D();

boolean mouseWasDown = false;

float MIN_DIST = 7.0f;
float weight=0;


LinkedList<ImageParticleSwarm> swarms;
GLTexture tex;




void setup() 
{
  size(640, 480, GLConstants.GLGRAPHICS);  

  GL gl;
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
  gl = pgl.beginGL();  // always use the GL object returned by beginGL
  gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  pgl.endGL();

  swarms = new LinkedList<ImageParticleSwarm>();
  particleExpander = new ParticleExpander();

  triMesh =new TriangleMesh("mesh1");

  // any particle texture... small is better
  tex = new GLTexture(this, "whitetoady.png");
}



void draw() 
{    
  background(0);

  // rotate around center of screen (accounted for in mouseDragged() function)
  translate(width/2, height/2, 0);
  rotateX(rotation.x);
  rotateY(rotation.y);

  // draw mesh as polygon (in white)
  drawMesh();

  // draw mesh unique points only (in green)
  drawMeshUniqueVerts();

  GLGraphics renderer = (GLGraphics)g;

  renderer.beginGL();  
  renderer.setDepthMask(false);
  
  // now models
  
  int currentTime = millis();
  
  for (ImageParticleSwarm swarm : swarms)
  {
    swarm.update(particleExpander, currentTime);
    swarm.render();
  }
  
  renderer.setDepthMask(true);
  renderer.endGL();
  // udpate rotation
  rotation.addSelf(0.014, 0.0237);
}







void vertex(Vec3D v) {
  vertex(v.x, v.y, v.z);
}



void mouseReleased()
{
  swarm = new ImageParticleSwarm(this, tex);
  if (swarm.makeModel( triMesh ))
  {
    swarms.add( swarm );

    if (swarms.size() > 10)
    {
      ImageParticleSwarm first = swarms.removeFirst();
      first.destroy();
    }
  }
  // clear tri mesh
  triMesh.clear();
}


void mousePressed()
{
  Vec3D pos=new Vec3D(mouseX-width/2, mouseY-height/2, 0);
  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);
  Vec3D a=pos.add(0, 0, weight);
  Vec3D b=pos.add(0, 0, -weight);

  // store current points for next iteration
  prev=pos;
  p.set(pos);
  q.set(pos);
}



void mouseDragged()
{
  // get 3D rotated mouse position
  Vec3D pos=new Vec3D(mouseX-width/2, mouseY-height/2, 0);
  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);
  // use distance to previous point as target stroke weight
  weight+=(sqrt(pos.distanceTo(prev))*2-weight)*0.1;
  // define offset points for the triangle strip

  //println("weight " + weight);

  //if (weight < MIN_DIST && triMeshes.size() > 0)
  if (true)
  {

    Vec3D a=pos.add(0, 0, weight);
    Vec3D b=pos.add(0, 0, -weight);

    // add 2 faces to the mesh
    triMesh.addFace(p, b, q);
    triMesh.addFace(p, a, b);
    // store current points for next iteration
    prev=pos;
    p=a;
    q=b;
  }
}




void drawMesh() {

  noStroke();    
  fill(255, 80);
  beginShape(TRIANGLES);
  // iterate over all faces/triangles of the mesh
  for (Iterator i=triMesh.faces.iterator(); i.hasNext();) {
    Face f=(Face)i.next();
    // create vertices for each corner point
    vertex(f.a);
    vertex(f.b);
    vertex(f.c);
  }
  endShape();
}



void drawMeshUniqueVerts() {
  //  noStroke();

  stroke(0, 255, 0);
  strokeWeight(4);

  beginShape(POINTS);

  // get unique vertices, use with indices
  float[] triVerts = triMesh.getUniqueVerticesAsArray(); 
  for (int i=0; i < triVerts.length; i += 3)
  {  
    vertex(triVerts[i], triVerts[i+1], triVerts[i+2]);
  }
  endShape();
}







void keyPressed() 
{
  switch(key) 
  {
  case 'x': 
    //mesh.saveAsOBJ(sketchPath("doodle.obj"));
    //mesh.saveAsSTL(sketchPath("doodle.stl"));
    break;
  case ' ':
    // now models
    for (ImageParticleSwarm swarm : swarms)
    {
      swarm.destroy();
    }
    swarms.clear();
    break;
  }
}

