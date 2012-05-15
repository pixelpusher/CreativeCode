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



// list of things to draw
LinkedList<DrawableNode> nodesToDraw = null;

// list of things to collide with
LinkedList<DrawableNode> nodesToCollide = null;

ColorPicker cpFill, cpStroke;

String bgImageSrc = "carstiled.png";
static final String spriteImages[] = { 
  "tv.png", "blue-acrobats.png", "whitetoady.png"
};

final color tintColors[] = {color(255), color(0,128,0), color(255,0,0,128) };


GLTexture bgImage, spriteTexs[];

Flock[] flocks;
final int FLOCKS = 3;
int BOIDS = 150;


// for attraction to objects:
float MinNodeDistanceSquared = 8*8;
float MaxNodeDistanceSquared = 200*200;


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


Textfield presetName; // for saving gui presets
DropdownList filesList = null;
String[] savedFiles = null;

GLGraphics pgl;
GLGraphicsOffScreen offscreen;


//Camera cam;

void setupBR() {
  
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
  offscreen.gl.glClearColor(0.0, 0.0, 0.0, 0.0); 


  // textures
  spriteTexs = new GLTexture[spriteImages.length];

  for (int i=0; i < spriteImages.length; ++i)
  {
    spriteTexs[i] = new GLTexture(this, spriteImages[i]);
  }

  bgImage = new GLTexture(this, bgImageSrc);

  //
  // setup flocks
  //

  flocks = new Flock[FLOCKS];

  for (int i=0; i < FLOCKS; ++i)
  {
    flocks[i] = new Flock();

    // Add an initial set of boids into the system
    for (int ii = 0; ii < BOIDS; ++ii) 
    {
      flocks[i].addBoid(new Boid(new PVector(width/2, height/2), boidMaxSpeed, boidMaxForce, spriteTexs[i]));
    }
    flocks[i].active = true;
  }



  // create some random nodes to attract to
  nodesToDraw = new LinkedList<DrawableNode>();

  // 
  nodesToCollide = new LinkedList<DrawableNode>();

  // nodes to be attracted towards


  for (int i=0; i < 10; i++)
  {
    // x,y,w,h
    DrawableNode node = new DrawableNode(random(0, width), random(0, height), random(10, 40), random(10, 40));
    node.fillColor= color(random(255), 255, random(255));
    nodesToCollide.add(node);
    nodesToDraw.add(node);
  }

  //
  // setup the GUI
  //
  //setupGUI();

  frameRate(60);
}



void drawBR() {

  background(0);
  hint(DISABLE_DEPTH_TEST);

  boolean b = gui.window(this).isMouseOver(); // returns true or false
  if (b)
  {
    boidStroke = cpStroke.getColorValue();
    boidFill = cpFill.getColorValue();
  }


  srcTex = offscreen.getTexture();
  offscreen.hint(DISABLE_DEPTH_TEST);
  offscreen.beginDraw();
  offscreen.background(0);
  offscreen.gl.glEnable( GL.GL_BLEND );
  offscreen.gl.glDisable( GL.GL_DEPTH );
  //  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //ggl.glBlendFunc(GL.GL_SRC_COLOR, GL.GL_ONE);
  offscreen.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  
  int f=0;
  for (Flock flock : flocks)
  {
    offscreen.tint(tintColors[f++]);
    flock.run(offscreen);
  }
  
  // update position and draw
  if (false)
  for (DrawableNode node : nodesToDraw) 
  {
    //update ball position
    node.update();
    offscreen.fill(255, 255, 0, 40);
    Vec2D p = node.middle();
    float d = sqrt(MaxNodeDistanceSquared);
    offscreen.ellipse(p.x, p.y, d, d);
    node.draw(offscreen);
  }

  if (keyPressed)
  {
    fill(255, 120);
    ellipse(mouseX, mouseY, 20, 20);
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
  //  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //ggl.glBlendFunc(GL.GL_SRC_COLOR, GL.GL_ONE);
  ggl.glBlendFunc(GL.GL_ONE, GL.GL_ONE);
  //  ggl.glAlphaFunc(GL.GL_GREATER,0.0);
  gpgl.endGL();
  
  textureMode(NORMALIZED);
  beginShape(QUADS);
  texture(bgImage);
  
  vertex(0, 0, 0, 0);
  vertex(width/2, 0, 1, 0);
  vertex(width/2, height, 1, 1);
  vertex(0, height, 0, 1);
  
  vertex(width/2, 0, 0, 0);
  vertex(width, 0, 1, 0);
  vertex(width, height, 1, 1);
  vertex(width/2, height, 0, 1);
  endShape();

  ggl = gpgl.beginGL();

  //this is nice and ghostly, revealing the image below
  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_SRC_COLOR);

  //this is more ghostly, only revealing it by color, like a multiply effect
  //  ggl.glBlendFunc(GL.GL_SRC_COLOR, GL.GL_SRC_COLOR);

  image(destTex, 0, 0, destTex.width*2, destTex.height*2);
  ggl.glAlphaFunc(GL.GL_ONE, GL.GL_SRC_ALPHA);
  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  // ggl.glDisable( GL.GL_BLEND );
  gpgl.endGL();
}




// Update the paddle position when we move the mouse:

void keyPressedBR(char key)
{

 
//  else
//    switch(key) {
//
//      case('s'):
//      gui.getProperties().setSnapshot(presetName.getText());
//      break;
//
//      case('g'):
//      gui.getProperties().getSnapshot(presetName.getText());
//      break;
//
//      case('r'):
//      gui.getProperties().removeSnapshot(presetName.getText());
//      break;
//
//      case('S'):
//      gui.getProperties().saveSnapshot("data/" + presetName.getText());
//      println("Saved preset:" + "data/" + presetName.getText());
//      break;
//
//      case('L'):
//      loadingGUIPreset = true;
//      gui.getProperties().load("data/" + presetName.getText()+".ser");
//      println("Loaded preset:" + "data/" + presetName.getText()+".ser");
//      loadingGUIPreset = false;
//    }

 // println(gui.getProperties().getSnapshotIndices());
}



