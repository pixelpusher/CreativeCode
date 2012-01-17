// All code is licensed under GNU AGPL 3.0+ http://www.gnu.org/licenses/agpl.html
//
// By Evan Raskob 2012
// info@pixelist.info
//
// for a project with Ravensbourne http://rave.ac.uk
//
// hint - hit ALT + h to hide the ControlP5 GUI
//


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
float speedRatio = 4.0;

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




float speed = 0.01; // how fast it gains harmonics
float periods = 0; // how many humps the sine wave has
float waveHeight;  // the height of the wave
int hueOffset = 56;

// this prevents the loading of GUI presets from looping forever... 
boolean loadingGUIPreset = false;


void setup()
{  
  size(640, 480, GLConstants.GLGRAPHICS);

  waveHeight = height/3;

  //  noCursor();
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
  gl.glClearColor(0.0, 0.0, 0.0, 1.0); 



  // setup GUI
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
  guiY += slider.getHeight()+4;
  slider = gui.addSlider("speedRatio", 0.125, 6, 2, guiX, guiY, 60, 20);
  guiY += slider.getHeight()+4;
  slider = gui.addSlider("hueOffsetSlider", 0, 255, 56, guiX, guiY, 255, 20);
  slider.setNumberOfTickMarks(12).showTickMarks(true).setLabel("hue offset");
  guiY += slider.getHeight()+36;
  
  presetName = gui.addTextfield("preset", guiX, guiY, 200, 20);
  guiY += slider.getHeight()+36;
  
  filesList = gui.addDropdownList("savedFileNames", guiX, guiY, 100, 120);
  
  refreshPresetFilesList();

  frameRate(60);
}


void wavePoints(float val)
{
  numPoints = int(val);
}


void hueOffsetSlider(float val)
{
  hueOffset = int(val);
}


void draw()
{

  float s = sin(frameCount*speed);

  //float positiveSin = (1.0 + s) * 0.5; // from 0 - 1
  //  float varSpeed =  s*s * speed*speed + speed*speed;

  float varSpeed =  s * speed/speedRatio + speed;

  periods += varSpeed;


  //periods = map(mouseX, 0,width, 1, 20);  
  //waveHeight = height/2 * sin(frameCount/20); 



  background(0);
  hint(DISABLE_DEPTH_TEST);

  srcTex = offscreen.getTexture();

  offscreen.beginDraw();
  offscreen.background(0);       

  offscreen.gl.glDisable( GL.GL_DEPTH_TEST );
  offscreen.gl.glEnable( GL.GL_BLEND );
  offscreen.gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);


  offscreen.fill(255);
  offscreen.noStroke();

  for (int index = 0; index < numPoints; index++)
  {
    float majorAngle = map(index, 0, numPoints, 0,TWO_PI);
    
    float angle = map(index, 0, numPoints, -periods*TWO_PI, periods*TWO_PI);

    float heightValue = waveHeight+waveHeight * 
      sin(majorAngle);

    float widthValue = waveHeight+waveHeight * 
      cos(majorAngle);

    float x = widthValue + (sin(angle)+1)*0.5*60;
    float y = heightValue + (cos(angle)+1)*0.5*60;

    offscreen.rect( x,y, 5, 5);
  }

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

  // set image blending mode

  PGraphicsOpenGL gpgl = (PGraphicsOpenGL) g;  // g may change
  GL ggl = gpgl.beginGL();  // always use the GL object returned by beginGL
  ggl.glDepthMask(false);  
  ggl.glDisable( GL.GL_DEPTH_TEST );
  ggl.glEnable( GL.GL_BLEND );
  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);
  //  ggl.glAlphaFunc(GL.GL_GREATER,0.0);

  //  image(bgImage, 0, 0, width*2, height*2);

  //  ggl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_SRC_COLOR);
  gpgl.endGL();


  imageMode(CORNER);
  tint((frameCount+hueOffset) % 256, 255, 210);
  image(destTex, 0, 0, destTex.width, destTex.height);


  // draw another rotated 90 degrees
  if (true)
  {
    pushMatrix();
    translate(width/2, height/2);
    rotate(HALF_PI);
    imageMode(CENTER);
    colorMode(HSB, 255, 255, 255);
    tint(frameCount % 256, 255, 210);
    image(destTex, 0, 0, height, width);

//    translate(width/2, height/2);
    rotate(HALF_PI);
    imageMode(CENTER);
    colorMode(HSB, 255, 255, 255);
    tint(frameCount % 256, 255, 210);
    image(destTex, 0, 0, width, height);

    rotate(HALF_PI);
    imageMode(CENTER);
    colorMode(HSB, 255, 255, 255);
    tint(frameCount % 256, 255, 210);
    image(destTex, 0, 0, height, width);


    popMatrix();
  }
}





// Update the paddle position when we move the mouse:

void keyPressed()
{
  
  if (key == CODED) 
  {
    if (keyCode == UP) {
      
    } 
    else if (keyCode == DOWN) {
      
    } 
    else if (keyCode == LEFT) {
      
    } 
    else if (keyCode == RIGHT) {
      
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
      case(ENTER):
      gui.getProperties().saveSnapshot("data/" + presetName.getText());
      gui.saveProperties("data/" + presetName.getText());

      println("Saved preset:" + "data/" + presetName.getText());
      refreshPresetFilesList();
      break;

      case('L'):
      loadingGUIPreset = true;
      gui.getProperties().load("data/" + presetName.getText()+".ser");
      println("Loaded preset:" + "data/" + presetName.getText()+".ser");
      loadingGUIPreset = false;

      break;
    }
    
    println(gui.getProperties().getSnapshotIndices());
}

