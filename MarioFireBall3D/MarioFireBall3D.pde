// Mario fireballer puppet, using GLModel and fireball sprite textures.
// By Evan Raskob


import processing.opengl.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.*; 
import codeanticode.glgraphics.*;
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.math.*;
import java.nio.FloatBuffer;
import SimpleOpenNI.*;
import toxi.processing.*;
import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;

boolean go = true;
ToxiclibsSupport gfx;
Vec3D p1, p2, p3;
TriangleMesh origMesh, mesh;
AxisAlignedCylinder cyl;
PeasyCam cam;

float MESH_X_SCALE = 10.0;
float MESH_Y_SCALE = 10.0;
GLGraphicsOffScreen leftBuffer, rightBuffer;
float panAmt = -4.6;
float panAngle = -0.04;



void init() {
  frame.dispose();  
  frame.setUndecorated(true);
  super.init();
}

ImageParticleSwarm swarm;
ParticleExpander particleExpander;


TriangleMesh triMesh;  // for drawing flame trails
Vec2D rotation=new Vec2D();


ArrayList<Vec3D> handPositions;  // a list of previous hand positions

Vec3D prev=new Vec3D();
Vec3D p=new Vec3D();
Vec3D q=new Vec3D();


boolean mouseWasDown = false;

float MIN_DIST = 2.0f;
float weight=0;

LinkedList<ImageParticleSwarm> swarms;
GLTexture fireballTex;

// images for body parts and background:
GLTexture bodyTex, headTex, armTex, legTex, bgTex;

String bodyTexFile = "FieryMarioBody.png";
String headTexFile = "FieryMarioHead.png";
String armTexFile  = "FieryMarioLeftArm.png";
String legTexFile  = "FieryMarioLeftLeg.png";
String bgTexFile   = "mario_bg.png";


boolean drawLimbs = false;
boolean drawMovement = false;
boolean drawBG = true;



// relevant skeleton positions from our Kinect
PVector rightShoulderPos = new PVector();
PVector leftShoulderPos = new PVector();
PVector rightHipPos = new PVector();
PVector leftHipPos = new PVector();
PVector facePos = new PVector();
PVector neckPos = new PVector();
PVector leftHandPos = new PVector();
PVector rightHandPos = new PVector();
PVector leftFootPos = new PVector();
PVector rightFootPos = new PVector();


// Kinect-specific variables
SimpleOpenNI  context;
MoveDetect md;



///////////////////////////////////////////
// SETUP
//

void setup() 
{
  size(1920, 1080, GLConstants.GLGRAPHICS);
  frame.setLocation(1280, 0);

  leftBuffer = new GLGraphicsOffScreen(this, width/2, height/2);
  rightBuffer = new GLGraphicsOffScreen(this, width/2, height/2);

  cam = new PeasyCam(this, height);
  //cam.setMinimumDistance(50);
  //cam.setMaximumDistance(500);
  //cam.pan(-panAmt, 0);

  context = new SimpleOpenNI(this);
  md = new MoveDetect();

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  context.setMirror(true);

  // this next bit of code disables "screen tearing"
  GL gl;
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
  gl = pgl.beginGL();  // always use the GL object returned by beginGL
  gl.setSwapInterval( 1 ); // use value 0 to disable v-sync 
  pgl.endGL();


  // create fireball particle "swarm"
  swarms = new LinkedList<ImageParticleSwarm>();
  particleExpander = new ParticleExpander();

  // fire trail
  triMesh =new TriangleMesh("mesh1");

  handPositions = new ArrayList<Vec3D>();

  //
  // Load our textures from image files - 
  //

  // any particle texture... small is better
  fireballTex = new GLTexture(this, "mario_fireball.png");

  bodyTex = new GLTexture(this, bodyTexFile);
  headTex = new GLTexture(this, headTexFile);
  armTex = new GLTexture(this, armTexFile);
  legTex = new GLTexture(this, legTexFile);
  bgTex = new GLTexture(this, bgTexFile);
}



void drawIntoBuffer(GLGraphicsOffScreen buffer)
{
  
  buffer.beginDraw();
  buffer.camera();
  //buffer.lights();
  buffer.pushMatrix();
  buffer.background(0);
  cam.getState().apply(buffer);
  
  //buffer.translate(buffer.width/2, buffer.height/2, 0);
  //buffer.rotateX(rotation.x);
  //buffer.rotateY(rotation.y);  

  drawMeshUniqueVerts(buffer);
  drawMesh(buffer);

  buffer.beginGL();  
  buffer.setDepthMask(false);

  // now models

  int currentTime = millis();

  for (ImageParticleSwarm swarm : swarms)
  {
    if (go)
      swarm.update(particleExpander, currentTime);
    swarm.render(buffer);
  }

  buffer.setDepthMask(true);
  buffer.endGL();

  //buffer.scale(0.5,0.5,0.5);
  //  gfx.setGraphics(buffer);
  // draw axes
  //  gfx.origin(p1, 200);
  //  drawMeshBetween(p1, p2, origMesh, buffer);
  //  drawMeshBetween(p1, p3, origMesh, buffer);
  buffer.popMatrix();
  buffer.endDraw();
}


/////////////////////////////////////////////
//  DRAW
//

void draw()
{
  // update the Kinect cam
  context.update();

  for (int i=1; i<3; i++)
  {
    // draw the skeleton if it's available
    if (context.isTrackingSkeleton(i))
    {  
      // get joint positions in 3D world for the tracked limbs
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulderPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulderPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HIP, leftHipPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HIP, rightHipPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_HEAD, facePos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_NECK, neckPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);

      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_LEFT_FOOT, leftFootPos);
      context.getJointPositionSkeleton(i, SimpleOpenNI.SKEL_RIGHT_FOOT, rightFootPos);

      // convert to screen coordinates
      context.convertRealWorldToProjective(leftShoulderPos, leftShoulderPos);
      context.convertRealWorldToProjective(rightShoulderPos, rightShoulderPos);

      context.convertRealWorldToProjective(rightHipPos, rightHipPos);
      context.convertRealWorldToProjective(leftHipPos, leftHipPos);

      context.convertRealWorldToProjective(neckPos, neckPos);
      context.convertRealWorldToProjective(facePos, facePos);      

      context.convertRealWorldToProjective(rightHandPos, rightHandPos);
      context.convertRealWorldToProjective(leftHandPos, leftHandPos);

      leftHandPos.z = height/4 + -height/4*((abs(leftHandPos.z)<EPSILON) ? 0f : 525f/leftHandPos.z);

      context.convertRealWorldToProjective(leftFootPos, leftFootPos);
      context.convertRealWorldToProjective(rightFootPos, rightFootPos);


      if (go)
      {
        // calculate new joint movement function sample
        md.jointMovementFunction(i, SimpleOpenNI.SKEL_LEFT_HAND);

        if (md.swipeStart == 1)
        {
          handJerked();

          //println("ONSET START:::::" + millis());
        }
        else if (md.onsetState == 1)
        {
          handMoved();
        }
        else
          if (md.swipeEnd == 1)
          {
            newSwarm(fireballTex, triMesh);
            //println("ONSET END:::::" + millis());
          }
      }

      // note: vectors must be clockwise!


      /*
    noStroke();
       
       // draw based on percentages...
       //
       renderRectFromVectors(leftShoulderPos, rightShoulderPos, rightHipPos, leftHipPos, 0.15f, 0.05f, bodyTex);
       
       renderRectFromVectors(facePos, neckPos, 0f, 1f, headTex);
       
       renderRectFromVectors(leftHipPos, leftFootPos, 0f, 0.12f, legTex);      
       renderRectFromVectors(rightHipPos, rightFootPos, 0f, 0.12f, legTex, 1);      
       
       renderRectFromVectors(leftShoulderPos, leftHandPos, 0f, 0.12f, armTex);      
       renderRectFromVectors(rightShoulderPos, rightHandPos, 0f, 0.12f, armTex, 1);
       
       
       
       if (drawLimbs)
       {
       drawSkeleton(i);
       }
       */
      // end of drawing skeleton stuff
    }

    // end for each user detected
  }



  // draw particle systems
  // rotate around center of screen (accounted for in mouseDragged() function)

  /*
  drawHandPositions();
   
   
   // draw mesh as polygon (in white)
   drawMesh();
   
   // draw mesh unique points only (in green)
   drawMeshUniqueVerts();
   */

  // udpate rotation
  //  rotation.addSelf(0.014, 0.0237);
  if (go)
    rotation.set(map(md.prev_x, 0, 640, -0.05, 0.05), 0.0237);
  // popMatrix();

  CameraState camState = cam.getState();

  cam.rotateX(-rotation.x);
  cam.rotateY(-rotation.y);

  // NOTE!!!
  // there is a bug... if you pan the camera, the state never resets.
  // you must apply back the original cam state at the end or it keeps rotating ad infinitum. 

  //cam.lookAt(0, 0, 0);
  cam.rotateY(panAngle);
  cam.pan(panAmt*2, 0);
  drawIntoBuffer(leftBuffer);
  camState.apply(leftBuffer);

  //cam.lookAt(0, 0, 0);
  cam.rotateY(-panAngle);
  cam.pan(-panAmt*2, 0);
  drawIntoBuffer(rightBuffer);
  camState.apply(rightBuffer);

  //  hint(DISABLE_DEPTH_TEST);
  //  bgTex.render(0,0,width,height);

  //cam.rotateY(-rotation.y);
  //cam.rotateX(-rotation.x);


  cam.beginHUD();
  image(leftBuffer.getTexture(), 0, 0, width/2, height);
  image(rightBuffer.getTexture(), width/2, 0, width/2, height);
  if (drawBG)
  {
    // draw depthImageMap
    image(context.depthImage(), 0, 0, width/2, height);
    image(context.depthImage(), width/2, 0, width/2, height);
  }
  cam.endHUD();
}


void vertex(Vec3D v) {
  vertex(v.x, v.y, v.z);
}





// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  stroke(255);
  strokeWeight(2);

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
    drawBG = false;
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}


void keyReleased()
{
  switch(key)
  {
    case '1': 
    panAmt += 0.1;
    break;

  case '2': 
    panAmt -= 0.1;
    break;

  case '[': 
    panAngle += 0.01;
    break;

  case ']': 
    panAngle -= 0.01;
    break;


  case 'm':
    context.setMirror(!context.mirror());
    break;
  case ' ':
    go = !go;
    // now models
    //  for (ImageParticleSwarm swarm : swarms)
    //   swarm.destroy();
    //swarms.clear();
    break;

  case 's': 
    drawLimbs = !drawLimbs;
    break;

  case 'v': 
    drawMovement = !drawMovement;
    break;

  case 'b': 
    drawBG = !drawBG;
    break;
  }
  println("pan amount:" + panAmt);
  println("pan angle:" + panAngle);

  if (key == CODED)
  {
    switch(keyCode)
    {
    case UP: 
      md.SMOOTHING += 0.05;
      break;

    case DOWN: 
      md.SMOOTHING -= 0.05;
      break;
    }

    md.SMOOTHING = constrain(md.SMOOTHING, 0.0f, 1.0f);
    println("SMOOTHING: " + md.SMOOTHING);
  }
}

