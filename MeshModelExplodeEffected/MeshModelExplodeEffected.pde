// Integration between GLGraphics and Toxiclibs. 
//
// Adapted from NoiseSurfaceDemo example from toxiclibs,
// which comes with the following license:

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.volume.*;
import toxi.math.noise.*;
import java.nio.FloatBuffer;

import processing.opengl.*;
import codeanticode.glgraphics.*;

import javax.media.opengl.*;
import remixlab.proscene.*;

Scene scene;


int DIMX=32;
int DIMY=20;
int DIMZ=16;
int numV=4;

float[] verts;
float[] norms;
float speed = 0.4f;

float camZ = 0;

float ISO_THRESHOLD = 0.1;
float NS=1.3;
Vec3D SCALE=new Vec3D(1, 2, 1).scaleSelf(250);

float currScale=1;

TriangleMesh mesh;

GLTexture tex, tex1;

// used to store mesh on GPU
GLModel surf;


void setup() {
  size(1024, 768, GLConstants.GLGRAPHICS);
  
  VolumetricSpace volume=new VolumetricSpaceArray(SCALE, DIMX, DIMY, DIMZ);
  // fill volume with noise
  for (int z=0; z<DIMZ; z++) {
    for (int y=0; y<DIMY; y++) {
      for (int x=0; x<DIMX; x++) {        
        if (random(0, 5) < 1.1)
          volume.setVoxelAt(x, y, z, (float)SimplexNoise.noise(x*NS, y*NS, z*NS)*0.5);
      }
    }
  }
  //volume.closeSides();
  // store in IsoSurface and compute surface mesh for the given threshold value
  mesh=new TriangleMesh("iso"); 
  IsoSurface surface=new HashIsoSurface(volume, 0.333333);
  surface.computeSurfaceMesh(mesh, ISO_THRESHOLD);

  // update lighting information
  mesh.computeVertexNormals();
  // get flattened vertex array
  verts=mesh.getMeshAsVertexArray();
  // in the array each vertex has 4 entries (XYZ + 1 spacing)
  numV=verts.length/4;  
  norms=mesh.getVertexNormalsAsArray();

  surf = new GLModel(this, numV, GLModel.POINT_SPRITES, GLModel.STREAM);
  //surf = new GLModel(this, numV, GLModel.POINTS, GLModel.STREAM);
  //surf = new GLModel(this, numV, GLModel.TRIANGLES, GLModel.STREAM);
  surf.beginUpdateVertices();
  for (int i = 0; i < numV; i++) surf.updateVertex(i, verts[4 * i], verts[4 * i + 1], verts[4 * i + 2]);
  surf.endUpdateVertices(); 

  surf.initNormals();
  surf.beginUpdateNormals();
  for (int i = 0; i < numV; i++) surf.updateNormal(i, norms[4 * i], norms[4 * i + 1], norms[4 * i + 2]);
  surf.endUpdateNormals();  

  // Setting the color of all vertices to green, but not used, see comments in the draw() method.
  surf.initColors();
  surf.beginUpdateColors();
  for (int i = 0; i < numV; i++) surf.updateColor(i, 0, 255, 0, 80);
  surf.endUpdateColors(); 

  // Setting model shininess.
  surf.setShininess(16);


  // FOR POINT SPRITES ONLY:


  // any particle texture... small is better
  tex = new GLTexture(this, "whitetoady.png");
 // tex1 = new GLTexture(this, "particle.png");

  
  float pmax = surf.getMaxPointSize();
  //println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   

  surf.initTextures(1);
  surf.setTexture(0, tex);
  //surf.setTexture(0, tex1);

  // Setting the maximum sprite to the 90% of the maximum point size.
  surf.setMaxSpriteSize(0.9 * pmax);
  // Setting the distance attenuation function so that the sprite size
  // is 20 when the distance to the camera is 400.

  surf.setSpriteSize(20, 300);
  surf.setBlendMode(ADD);
}

void draw() {
  //background(0);

  // need to switch to pure OpenGL mode first
  GLGraphics renderer = (GLGraphics)g;

  // disable depth so we can draw a transparent rectangle on top
  renderer.beginGL();
  renderer.gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
  renderer.gl.glDisable(GL.GL_DEPTH);
  renderer.gl.glDisable(GL.GL_DEPTH_TEST);
  renderer.gl.glEnable(GL.GL_BLEND);
  renderer.endGL();

  // draw black transparent rectangle
  pushMatrix();
  fill(100, 20);
  noStroke();
  //  scale(currScale);
  rectMode(CORNER);
  rect(0, 0, width, height);
  popMatrix();

  renderer.beginGL();
  //renderer.gl.glDisable(GL.GL_BLEND);
 // renderer.gl.glEnable(GL.GL_DEPTH_TEST);
  //renderer.gl.glEnable(GL.GL_DEPTH);
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(mouseY*0.01);
  rotateY(mouseX*0.01);
  translate(0,0,camZ);
//  camZ += speed*2;
  scale(currScale);


  renderer.gl.glEnable(GL.GL_LIGHTING);

  // Disabling color tracking, so the lighting is determined using the colors
  // set only with glMaterialfv()
  renderer.gl.glDisable(GL.GL_COLOR_MATERIAL);

  // Enabling color tracking for the specular component, this means that the 
  // specular component to calculate lighting will obtained from the colors 
  // of the model (in this case, pure green).
  // This tutorial is quite good to clarify issues regarding lighting in OpenGL:
  // http://www.sjbaker.org/steve/omniv/opengl_lighting.html
  //renderer.gl.glEnable(GL.GL_COLOR_MATERIAL);
  //renderer.gl.glColorMaterial(GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR);  

  renderer.gl.glEnable(GL.GL_LIGHT0);
  renderer.gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, new float[] {
    0.2, 0.0, 0.0, 1
  }
  , 0);
  renderer.gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, new float[] {
    0.8, 0, 0, 1
  }
  , 0);  
  renderer.gl.glLightfv(GL.GL_LIGHT0, GL.GL_POSITION, new float[] {
    -1000, 600, 4000, 0
  }
  , 0);
  renderer.gl.glLightfv(GL.GL_LIGHT0, GL.GL_SPECULAR, new float[] { 
    0.8, 0.0, 0.4, 1
  }
  , 0); 



  surf.beginUpdateVertices();

  FloatBuffer vbuf = surf.vertices;
  float vert[] = { 
    0, 0, 0
  };
  for (int n = 0; n < surf.getSize(); ++n) {
    vbuf.position(4 * n);
    vbuf.get(vert, 0, 3);

    // process vert...
    vert[0] += speed*norms[4*n];
    vert[1] += speed*norms[4*n+1];
    vert[2] += speed*norms[4*n+2];

    vbuf.position(4 * n);
    vbuf.put(vert, 0, 3);
  }
  vbuf.rewind();
  surf.endUpdateVertices();

  renderer.model(surf);

  popMatrix();
  renderer.gl.glDisable(GL.GL_LIGHTING);
  // back to processing
  renderer.endGL();
  textSize(24);
  fill(255, 255);
  text("FPS:"+ frameRate, 4, height-24);
}


void keyPressed() {
  if (key=='-') currScale=max(currScale-0.1, 0.5);
  if (key=='=') currScale=min(currScale+0.1, 10);
  else if (key=='s') {
    // save mesh as STL or OBJ file
    mesh.saveAsSTL(sketchPath("noise.stl"));
  }
  if (key=='r') {
    surf.beginUpdateVertices();
    for (int i = 0; i < numV; i++) surf.updateVertex(i, verts[4 * i], verts[4 * i + 1], verts[4 * i + 2]);
    surf.endUpdateVertices();
  }

  else if (key=='x') speed = -speed;
}


void mouseDragged()
{

  if (mouseButton == RIGHT)
  {
    camZ += (mouseY-pmouseY);
  }
}

