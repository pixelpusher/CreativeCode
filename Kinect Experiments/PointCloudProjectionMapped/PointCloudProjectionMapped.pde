import controlP5.*;
import processing.opengl.*;
import org.openkinect.*;
import org.openkinect.processing.*;


// Kinect Library object
Kinect kinect;

ControlP5 gui;


// Size of kinect image
int w = 640;
int h = 480;

  int deg = 15;

float xdist, ydist, zdist, xRotation, yRotation, zRotation;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void setup() {
  size(800,600,OPENGL);
  
  gui = new ControlP5(this);
  
  int guiX=20;
  int guiY=20;
  int guiYPadding = 4;
  int sliderHeight = 16;
  int sliderWidth = 200;
  
  //addSlider(String theName, float theMin, float theMax, float theDefaultValue, int theX, int theY, int theW, int theH) 
  gui.addSlider("xdist",-w,w,0,guiX,guiY,sliderWidth,sliderHeight)
      .setColorBackground(color(255,255,0,255));
  guiY += sliderHeight+guiYPadding;
  
  gui.addSlider("ydist",-h,h,0,guiX,guiY,sliderWidth,sliderHeight)
    .setColorBackground(color(255,255,0,255));
  guiY += sliderHeight+guiYPadding;
  
  gui.addSlider("zdist",-h,h,h/2,guiX,guiY,sliderWidth,sliderHeight)
      .setColorBackground(color(255,255,0,255));
  guiY += sliderHeight+guiYPadding;

  zdist = w/2;

  gui.addSlider("xRotation",-PI,PI,0f,guiX,guiY,sliderWidth,sliderHeight);
  guiY += sliderHeight+guiYPadding;
  
  gui.addSlider("yRotation",-PI,PI,0f,guiX,guiY,sliderWidth,sliderHeight);
  guiY += sliderHeight+guiYPadding;

  gui.addSlider("zRotation",-PI,PI,0f,guiX,guiY,sliderWidth,sliderHeight);
  guiY += sliderHeight+guiYPadding;


  //addNumberbox(String theIndex, String theName, float theDefaultValue, int theX, int theY, int theWidth, int theHeight) 
//  gui.addNumberbox(
  kinect = new Kinect(this);
  kinect.start();
  kinect.tilt(deg);
  kinect.enableDepth(true);
  // We don't need the grayscale image in this example
  // so this makes it more efficient
  kinect.processDepthImage(false);

  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}

void draw() {

  background(0);
  fill(255);
  stroke(255);
  strokeWeight(2);
  
  //textMode(SCREEN);
  text("Kinect FR: " + (int)kinect.getDepthFPS() + "\nProcessing FR: " + (int)frameRate,10,height-16);

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 4;

  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  scale(width/640f);
  // Translate and rotate
  translate(xdist+w/2,ydist+h/2,zdist);
  rotateX(xRotation);
  rotateY(yRotation);
  rotateZ(zRotation);

  beginShape(POINTS);
  for(int x=0; x<w; x+=skip) {
    for(int y=0; y<h; y+=skip) {
      int offset = x+y*w;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      stroke( map(rawDepth,0,2047,255,80));
      PVector v = depthToWorld(x,y,rawDepth);
      // Scale up by 200
      float factor = 200;
      
      // add a point
      vertex(v.x*factor,v.y*factor,factor-v.z*factor);
    }
  }
  endShape();
  popMatrix();
  hint(DISABLE_DEPTH_TEST);
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}




void keyPressed() {

 if (key == CODED) {
    if (keyCode == UP) {
      deg++;
    } 
    else if (keyCode == DOWN) {
      deg--;
    }
    deg = constrain(deg,0,30);
    kinect.tilt(deg);
  }
}

void stop() {
  kinect.quit();
  super.stop();
}

