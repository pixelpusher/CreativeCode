// All code is licensed under GNU AGPL 3.0+ http://www.gnu.org/licenses/agpl.html
//
// By Evan Raskob 2012
// info@pixelist.info
//
// for a project with Ravensbourne http://rave.ac.uk


import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;
//import damkjer.ocd.*;
// using toxiclibs for vectors, better than Processing's built-in ones
import toxi.geom.Vec2D;
import controlP5.*;


ControlP5 gui;


// glow texture params
float fx = 0.13;
float fy = 0.67;

int numPoints = 100;

Textfield presetName; // for saving gui presets
DropdownList filesList = null;
String[] savedFiles = null;




float speed = 0.01; // how fast it gains harmonics
float periods = 0; // how many humps the sine wave has
float waveHeight;  // the height of the wave

void setup()
{  
  size(640, 480, GLConstants.GLGRAPHICS);

  waveHeight = height/2;

  //  noCursor();
  {
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
    gl = pgl.beginGL();  // always use the GL object returned by beginGL
    gl.glClearColor(0.0, 0.0, 0.0, 1); 
    gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
    pgl.endGL();
  }


  //
  // set up the GL glow textures and shaders
  //
  setupGLGlow();


  //
  // setup controlP5 GUI
  //
  gui = new ControlP5(this);
  int guiX = 10;
  int guiY = 200;  

  Slider slider = gui.addSlider("fx", 0.01f, 1f, 0.1f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("fy", 0.01f, 1f, 0.1f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+4;
  slider = gui.addSlider("speed", -HALF_PI/10f, HALF_PI/10f, 0.1f, guiX, guiY, 300, 20);
  guiY += slider.getHeight()+4;
  slider = gui.addSlider("wavePoints", 2, width*4, 100, guiX, guiY, int(width/1.5), 20);
}


// GUI callback functions (when a slider is dragged)

void wavePoints(float val)
{
  numPoints = int(val);
}


void draw()
{
  periods += speed;
  //periods = map(mouseX, 0,width, 1, 20);  
  //waveHeight = height/2 * sin(frameCount/20); 


  background(0);
  hint(DISABLE_DEPTH_TEST);

  offscreen.beginDraw();
  offscreen.background(0);       

  offscreen.gl.glDisable( GL.GL_DEPTH_TEST );
  offscreen.gl.glEnable( GL.GL_BLEND );
  offscreen.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);


  offscreen.fill(255);
  offscreen.noStroke();

  for (int index = 0; index < numPoints; index++)
  {
    float heightValue = waveHeight * 
      sin( map(index, 0, numPoints, -periods*TWO_PI, periods*TWO_PI) ) 
      + waveHeight;

    offscreen.rect( map(index, 0, numPoints,0,width), heightValue, 5, 5);
  }

  offscreen.endDraw();

  
  //
  // Do the glow - after drawing to the offscreen graphics (directly above)
  //
  doGLGLow();


  PGraphicsOpenGL gpgl = (PGraphicsOpenGL) g;  // g may change
  GL ggl = gpgl.beginGL();  // always use the GL object returned by beginGL
  ggl.glDepthMask(false);  
  ggl.glDisable( GL.GL_DEPTH_TEST );
  ggl.glEnable( GL.GL_BLEND );
  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //  ggl.glAlphaFunc(GL.GL_GREATER,0.0);

  //  image(bgImage, 0, 0, width*2, height*2);

  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_SRC_COLOR);

  image(destTex, 0, 0, destTex.width*2, destTex.height*2);
  gpgl.endGL();
}

