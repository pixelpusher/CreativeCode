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

static final String spriteImages[] = { 
  "tv.png", "blue-acrobats.png", "whitetoady.png"
};

final color tintColors[] = {color(100,20), color(0,100,0,20), color(160,0,0,20) };


GLTexture bgImage, spriteTexs[];

Flock[] flocks;
final int FLOCKS = 3;
int BOIDS = 60;


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


//Camera cam;

void setupBR() 
{
  // textures
  spriteTexs = new GLTexture[spriteImages.length];

  for (int i=0; i < spriteImages.length; ++i)
  {
    spriteTexs[i] = new GLTexture(this, spriteImages[i]);
  }



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
//    flocks[i].active = true;
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

}



void drawBR(GLGraphicsOffScreen offscreen)
{
 
  offscreen.beginDraw();
  offscreen.hint(DISABLE_DEPTH_TEST);
  offscreen.gl.glEnable( GL.GL_BLEND );
  offscreen.gl.glDisable( GL.GL_DEPTH );
  //ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  offscreen.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //offscreen.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_DST_ALPHA);
  
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
  
  offscreen.endDraw();
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



