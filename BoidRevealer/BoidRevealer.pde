// Using flocking and effects to reveal a map underneath.
// Map image by Eric Fischer using data from OpenStreetMaps (http://www.flickr.com/photos/walkingsf/)
// from http://www.flickr.com/photos/walkingsf/4671589629/sizes/l/in/photostream/
// 
// All images produced by this sketch must be licensed: (CC BY-SA 2.0)  http://creativecommons.org/licenses/by-sa/2.0/
//
// All code is licensed under GNU AGPL 3.0+ http://www.gnu.org/licenses/agpl.html
//
// By Evan Raskob 2012
// info@pixelist.info
//
// for a project with Ravensbourne http://rave.ac.uk
//
// Based on Shiffman's flocking and Evan's scenegraph and Andres Colubri's Neon
//   example from GLGraphics 1.0
//
// Neon effect, based on this discussion:
// http://processing.org/discourse/yabb2/YaBB.pl?num=1262637573/0
// It uses the OCD library for camera motion:
// http://www.gdsstudios.com/processing/libraries/ocd/reference/
//
// ControlP5 for onscreen controls: http://www.sojamo.de/libraries/controlP5/ (version 0.6.12 used)
// GLGraphics for OPENGL rendering tricks: http://glgraphics.sourceforge.net/
//


import processing.opengl.*;
import javax.media.opengl.*;
import codeanticode.glgraphics.*;
//import damkjer.ocd.*;
// using toxiclibs for vectors, better than Processing's built-in ones
import toxi.geom.Vec2D;
import controlP5.*;

// list of things to draw
LinkedList<DrawableNode> nodesToDraw = null;

// list of things to collide with
LinkedList<DrawableNode> nodesToCollide = null;

// our character
DrawableNode myCharacter = null;
ControlP5 gui;

ColorPicker cpFill, cpStroke;

String bgImageSrc = "inv_map_gps_london_Eric_Fischer.jpg";
GLTexture bgImage;

Flock flock;

// this prevents the loading of GUI presets from looping forever... 
boolean loadingGUIPreset = false;

// boids variables:

float desiredseparation = 25.0;
float avoidWallsFactor = 0.8;
float charAttract = 3.8;
float attraction = 0.08;
float neighbordist = 25.0;
color boidFill = color(255, 30, 0);
color boidStroke = color(255, 0, 0);
float boidMaxSpeed = 8, boidMaxForce=0.8;

// texture params
float fx = 0.001;
float fy = 0.001;

Textfield presetName; // for saving gui presets
DropdownList filesList = null;
String[] savedFiles = null;

GLGraphics pgl;
GLGraphicsOffScreen offscreen;
GL gl;

GLTexture srcTex, bloomMask, destTex;
GLTexture tex0, tex2, tex4, tex8, tex16;
GLTexture tmp2, tmp4, tmp8, tmp16;
GLTextureFilter extractBloom, blur, blend4, toneMap;

//Camera cam;

void setup() {
  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);
  noStroke();
  hint( ENABLE_OPENGL_4X_SMOOTH );  
  noCursor();
  {
    PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;  // g may change
    gl = pgl.beginGL();  // always use the GL object returned by beginGL
    gl.glClearColor(0.0, 0.0, 0.0, 1); 
    gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
    pgl.endGL();
  }

  // Loading required filters.
  extractBloom = new GLTextureFilter(this, "ExtractBloom.xml");
  blur = new GLTextureFilter(this, "Blur.xml");
  blend4 = new GLTextureFilter(this, "Blend4.xml");  
  toneMap = new GLTextureFilter(this, "ToneMap.xml");

  destTex = new GLTexture(this, width, height);

  // Initializing bloom mask and blur textures.
  bloomMask = new GLTexture(this, width, height, GLTexture.FLOAT);
  tex0 = new GLTexture(this, width, height, GLTexture.FLOAT);
  tex2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT);
  tmp2 = new GLTexture(this, width / 2, height / 2, GLTexture.FLOAT); 
  tex4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
  tmp4 = new GLTexture(this, width / 4, height / 4, GLTexture.FLOAT);
  tex8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT);
  tmp8 = new GLTexture(this, width / 8, height / 8, GLTexture.FLOAT); 
  tex16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);
  tmp16 = new GLTexture(this, width / 16, height / 16, GLTexture.FLOAT);

  //cam = new Camera(this, 0, 0, 200);

  offscreen = new GLGraphicsOffScreen(this, width, height, true, 4);  
  pgl = (GLGraphics) g;  
  gl = offscreen.gl;
  gl.glClearColor(0.0, 0.0, 0.0, 0.0); 

  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(new PVector(width/2, height/2), boidMaxSpeed, boidMaxForce));
  }


  bgImage = new GLTexture(this, bgImageSrc);

  // create some random nodes

  nodesToDraw = new LinkedList<DrawableNode>();

  /*
  for (int i=0; i < 10; i++)
   {
   // x,y,w,h
   DrawableNode node = new DrawableNode(random(0,width), random(0,height), random(10,40), random(10,40));
   nodesToDraw.add(node);
   }
   */

  // create our "character"
  myCharacter = new DrawableNode(random(0, width), random(0, height), random(10, 40), random(10, 40));
  myCharacter.fillColor= color(0, 255, 0);

  nodesToDraw.add(myCharacter);

  // nothing yet
  nodesToCollide = new LinkedList<DrawableNode>();

  // create our character


  gui = new ControlP5(this);
  cpFill = gui.addColorPicker("boidStroke", 10, 10, 255, 20);
  cpStroke = gui.addColorPicker("boidFill", 10, 80+cpFill.getHeight(), 255, 20);

  int guiX = 10;
  int guiY = 200;

  Slider slider = gui.addSlider("desiredseparation", 2f, 100f, 25f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("avoidWallsFactor", 0f, 1f, 0.8f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  //  slider = gui.addSlider("charAttract",  0.01, 3.8, guiX,  guiY+slider.height(), 100,20);
  slider = gui.addSlider("attraction", 0.01f, 2f, 0.08f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("neighbordist", 8f, 80f, 25f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("boidMaxSpeed", 1f, 300f, 120f, guiX, guiY, 100, 20); 
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("boidMaxForce", 0.01f, 3f, 0.8f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("fx", 0.01f, 1f, 0.1f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("fy", 0.01f, 1f, 0.1f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+4;

  presetName = gui.addTextfield("preset", guiX, guiY, 200, 20);

    guiY += slider.getHeight()+36;
  
  refreshPresetFilesList(guiX,guiY);
  
  frameRate(60);
}



void draw() {

  background(0);
  hint(DISABLE_DEPTH_TEST);

  boolean b = gui.window(this).isMouseOver(); // returns true or false
  if (b)
  {
    boidStroke = cpStroke.getColorValue();
    boidFill = cpFill.getColorValue();
  }
  else if (mousePressed)
  {    
    //    float dx = mouseX - myCharacter.pos.x;
    //    float dy = mouseY - myCharacter.pos.y;
    //    myCharacter.vel.addSelf(dx*0.01, dy*0.01);
    myCharacter.moveTo(mouseX-myCharacter.w/2, mouseY- myCharacter.h/2);
  }

  srcTex = offscreen.getTexture();

  offscreen.beginDraw();
  offscreen.background(0);       


  flock.run(offscreen);

  // update position and draw
  for (DrawableNode node : nodesToDraw) 
  {
    //update ball position
    node.update();
    //node.draw(offscreen);
  }

  if (keyPressed)
  {
    fill(255,120);
    ellipse(mouseX,mouseY,20,20);
  }

  //cam.circle(radians(noise(millis()*2)*noise(millis())*50));    
  //cam.circle(radians(mouseX / 800.) * PI);
  //cam.feed();

  //offscreen.glDisable( GL.GL_DEPTH_TEST );
  //offscreen.glEnable( GL.GL_BLEND );
  //offscreen.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);

  offscreen.endDraw();

  // Extracting the bright regions from input texture.
  extractBloom.setParameterValue("bright_threshold", fx);
  extractBloom.apply(srcTex, tex0);

  // Downsampling with blur
  tex0.filter(blur, tex2);
  tex2.filter(blur, tmp2);        
  tmp2.filter(blur, tex2);

  tex2.filter(blur, tex4);        
  tex4.filter(blur, tmp4);
  tmp4.filter(blur, tex4);            
  tex4.filter(blur, tmp4);
  tmp4.filter(blur, tex4);            

  tex4.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);        
  tex8.filter(blur, tmp8);
  tmp8.filter(blur, tex8);

  tex8.filter(blur, tex16);     
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);        
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);        
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);
  tex16.filter(blur, tmp16);
  tmp16.filter(blur, tex16);  

  // Blending downsampled textures.
  blend4.apply(new GLTexture[] {
    tex2, tex4, tex8, tex16
  }
  , new GLTexture[] {
    bloomMask
  }
  );

  // Final tone mapping into destination texture.
  toneMap.setParameterValue("exposure", fy);
  toneMap.setParameterValue("bright", fx);
  toneMap.apply(new GLTexture[] {
    srcTex, bloomMask
  }
  , new GLTexture[] {
    destTex
  }
  );


  PGraphicsOpenGL gpgl = (PGraphicsOpenGL) g;  // g may change
  GL ggl = gpgl.beginGL();  // always use the GL object returned by beginGL
  ggl.glDepthMask(false);  
  ggl.glDisable( GL.GL_DEPTH_TEST );
  ggl.glEnable( GL.GL_BLEND );
  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //  ggl.glAlphaFunc(GL.GL_GREATER,0.0);

  image(bgImage, 0, 0, width*2, height*2);

  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_SRC_COLOR);

  image(destTex, 0, 0, destTex.width*2, destTex.height*2);
  gpgl.endGL();
}




// Update the paddle position when we move the mouse:

void keyPressed()
{
  
  if (key == CODED) 
  {
    if (keyCode == UP) {
      myCharacter.accel.y -= 1;
    } 
    else if (keyCode == DOWN) {
      myCharacter.accel.y += 1;
    } 
    else if (keyCode == LEFT) {
      myCharacter.accel.x -= 1;
    } 
    else if (keyCode == RIGHT) {
      myCharacter.accel.x += 1;
    }
  }
  else
    switch(key) {

      case('s'):
      gui.getProperties().setSnapshot(presetName.getText());
      break;

      case('g'):
      gui.getProperties().getSnapshot(presetName.getText());
      break;

      case('r'):
      gui.getProperties().removeSnapshot(presetName.getText());
      break;

      case('S'):
      gui.getProperties().saveSnapshot("data/" + presetName.getText());
      println("Saved preset:" + "data/" + presetName.getText());
      break;

      case('L'):
      loadingGUIPreset = true;
      gui.getProperties().load("data/" + presetName.getText()+".ser");
      println("Loaded preset:" + "data/" + presetName.getText()+".ser");
      loadingGUIPreset = false;
    }
    
    println(gui.getProperties().getSnapshotIndices());
    
}



void mousePressed()
{
}

