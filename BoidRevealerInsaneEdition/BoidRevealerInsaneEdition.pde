// Using flocking and effects to reveal a map underneath.
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

//
// TODO: flocks can die, push button to grown new ones
// left/right to change scenes / speed
// array of explosions? with lifetimes? placed at boids...


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

LinkedList<IAnimationModifier> cameraAnimations;

boolean playing = true;
boolean saveScreen = false;

ColorPicker cpFill, cpStroke;


color tintColors[] = {
  color(0, 0, 250,180), color(0, 200, 0), color(200, 0, 0,180), color(255, 0, 255),
};


final String bgImageSrcs[] = { "carstiled.png", "rose.png", "roseBW.png", "BOOMBOXbg.png" };
final String spriteImages[] = { 
  "blue-acrobats.png", "tv.png", "boombox1_64.png", "adidasGold.png", 
};
//"boombox128x64.png"
//
//"whitetoady.png"

GLTexture bgImages[], spriteTexs[];
GLTexture currentBGTex;

Flock[] flocks;
final int FLOCKS = 4;
int BOIDS = 100;


// for attraction to objects:
float MinNodeDistanceSquared = 8*8;
float MaxNodeDistanceSquared = 200*200;


// this prevents the loading of GUI presets from looping forever... 
boolean loadingGUIPreset = false;

boolean keyDown = false;  // for checking for keys held down

// boids variables:

float desiredseparation = 25.0;
float avoidWallsFactor = 0.8;
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

void setup() 
{
  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);
  noStroke();
  hint( ENABLE_OPENGL_4X_SMOOTH );  
  //noCursor();
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


  // textures
  spriteTexs = new GLTexture[spriteImages.length];
  bgImages = new GLTexture[bgImageSrcs.length];

  for (int i=0; i < spriteImages.length; ++i)
  {
    spriteTexs[i] = new GLTexture(this, spriteImages[i]);
  }

  for (int i=0; i < bgImages.length; ++i)
  {
    bgImages[i] = new GLTexture(this, bgImageSrcs[i]);
  }

  currentBGTex = bgImages[0];

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

  // create our "character"
  myCharacter = new DrawableNode(random(0, width), random(0, height), random(10, 40), random(10, 40));
  myCharacter.fillColor= color(0, 255, 0);

  nodesToDraw.add(myCharacter);

  myCharacter = new DrawableNode(random(0, width), random(0, height), random(10, 40), random(10, 40));
  myCharacter.fillColor= color(0, 255, 0);

  // 
  nodesToCollide = new LinkedList<DrawableNode>();

  // nodes to be attracted towards
  nodesToCollide.add(myCharacter);

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
  setupGUI();

  cameraAnimations = new LinkedList<IAnimationModifier>();
  setupBeatStuff();

  setupFires(offscreen);
  setupWiiChuck();

  frameRate(60);
}



void draw() 
{
  if (playing)
    updateBeatStuff();

  background(0);
  hint(DISABLE_DEPTH_TEST);

  boolean b = gui.window(this).isMouseOver(); // returns true or false
  if (b)
  {
    boidStroke = cpStroke.getColorValue();
    boidFill = cpFill.getColorValue();
  }

  // BLOOM EFFECT SETUP STUFF
  srcTex = offscreen.getTexture();
  offscreen.hint(DISABLE_DEPTH_TEST);
  offscreen.beginDraw();
  offscreen.background(0);
  offscreen.gl.glEnable( GL.GL_BLEND );
  offscreen.gl.glDisable( GL.GL_DEPTH );
  //  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //ggl.glBlendFunc(GL.GL_SRC_COLOR, GL.GL_ONE);


  offscreen.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
  // draw fires first
  animateFires(offscreen);


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

  // 
  // CAMERA STUFF
  // 

  pushMatrix();

  //
  // --------------------------------------------
  // Timed animations ---------------------------
  // --------------------------------------------
  //
  // These are added by beat timelines (See BeatStuff.pde)

  Iterator<IAnimationModifier> iter = cameraAnimations.iterator();

  int ms = millis();

  while (iter.hasNext ())
  {
    IAnimationModifier animod  = iter.next();
    if (animod.isFinished())
    {
      animod.stop();
      iter.remove();
      animod = null;
    }
    else animod.update(ms);
  }
  // float p = map (millis() % 5000, 0, 4999, 0, 1 );

  // scale on a point
  //  translate( -p*width/2f ,0);
  //  scale( (p*3+1) );

  //move right
  //translate( -width+p*width/2f, -height/2);
  //scale(2);

  // move left
  //translate( -p*width/2f ,0);
  //scale(2);



  // DRAW BACKGROUND IMAGE

  textureMode(NORMALIZED);
  beginShape(QUADS);
  texture(currentBGTex);

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

  popMatrix();

  if (saveScreen)
  {
    saveScreen = false;
    saveFrame("surreally_"+year()+"-"+hour()+"-"+minute()+"-"+second()+".png");
  }
  else
  {
    fill(255);
    text("fps:"+frameRate, 12, 20);
  }
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
    if (!keyDown)
    {
      keyDown = true;

      switch(key) 
      {
      case 'p': 
        playing = !playing;
        break;
      case 's': saveScreen = true;
    break;  
        
/*
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
        break;
*/
        case(' '):    
        tapTempo();
        break;
      }
    }

  //println(gui.getProperties().getSnapshotIndices());
}


void keyReleased()
{
  keyDown = false;
}


void mousePressed()
{
  for (int i=0; i < FLOCKS; ++i)
    flocks[i].toReanimate++;
}

