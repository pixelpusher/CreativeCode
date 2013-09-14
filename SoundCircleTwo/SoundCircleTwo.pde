// By Evan Raskob 2011
// under a GNU Affero 3.0+ license
//
// uses GLGraphics library and ControlP5 library
//


import processing.opengl.*;
import javax.media.opengl.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import codeanticode.glgraphics.*;
import controlP5.*;

ControlP5 controlP5;
Slider spacing, diam, smoothing, thickness;


Minim minim;
AudioInput in;
FFT fft;

// number of points to draw per ring
final int BUFFER_SIZE = 1024;
float rotation = 0f;

int ringX, ringY;

void setup()
{
  size(300, 300, GLConstants.GLGRAPHICS);

  ringX = (width*2)/5;
  ringY = height/2;

  minim = new Minim(this);
  // get a line in from Minim, default bit depth is 16
  in = minim.getLineIn(Minim.MONO, BUFFER_SIZE);
  fft = new FFT(in.bufferSize(), in.sampleRate());

  // initialize the rings variables (NECESSARY)
  initRings(in);

  // GUI controls
  controlP5 = new ControlP5(this);
  spacing = controlP5.addSlider("spacing", 0.0, 1.0, 0.2, 10, 5, 100, 20);
  diam = controlP5.addSlider("diameter", 0.05, 1, 0.5, 10, 30, 100, 20);
  smoothing = controlP5.addSlider("smoothing", 0.0f, 1.0f, 0.5f, 10, 55, 100, 20);
  thickness = controlP5.addSlider("thickness", 0.0f, 1.0f, 0.95f, 10, 80, 100, 20);


  // this is optional OpenGL stuff that makes your screen look good
  GLGraphics renderer = (GLGraphics)g;
  renderer.beginGL();  
  renderer.gl.glDisable(GL.GL_DEPTH_TEST);
  renderer.gl.glClearColor(0.0, 0.0, 0.0, 0.08); 
  renderer.gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  renderer.endGL();
}


void draw()
{
  smooth();
  background(0);
  hint(DISABLE_DEPTH_TEST);

  // perform fft on live input - could use another source here!
  fft.forward(in.mix);

  // update rings (using the live input, again could use another source here!)
  updateRings(in);

  drawRings(ringX, ringY);
}

void mouseMoved()
{
  println(mouseX + " " + mouseY);
  rotation = map(mouseX,0,width,-PI,PI);
}


void mouseClicked()
{
  /*
  if (!controlP5.isMouseOver())
  {
    ringX = mouseX;
    ringY = mouseY;
  }
  */
}

