// waveform vs RMS power example
//  by evan raskob evanraskob@gmail.com
// wave code uses code from http://code.google.com/p/musicg/
//


import java.io.*;
import java.util.Iterator;
import toxi.geom.*;
import toxi.geom.mesh.TriangleMesh;
import toxi.geom.mesh.Mesh3D;
import toxi.geom.mesh.Face;
import toxi.math.*;
import toxi.volume.*;
import processing.opengl.*;
import peasy.*;
import com.musicg.wave.WaveHeader;
import com.musicg.wave.Wave;
import com.musicg.wave.extension.NormalizedSampleAmplitudes;


boolean fileChosen = false;
boolean useLogScale = false;
PrintWriter output, outputRMS;
float[] soundAmplitudes;
float[] rmsAmplitudes, rmsAmplitudes2;

PShape soundAmpsShape = null, soundRMSShape = null, soundRMSShape2 = null;

boolean drawProfiles = false, drawVecs=false;

String wavFileName = "";
int wavSampleRate; // sample rate of Wave file

//metal 3 sec - 6,0,60,90,120,0.125,44100 *1*1.1/500.0

BezierInterpolation tween=new BezierInterpolation(-0.2, 0.2); // for interpolating between points
final int TWEEN_POINTS = 5; // resolution of tween


float spikiness = 2;
int RMSSize =1; // will be overriden in fileSelected() function


PeasyCam cam;

static final float log10 = log(10);

float ampMin = MAX_INT;
float ampMax = MIN_INT;

// convert number from 0 to 1 into log scale from 0 to 1
float logScale(float val, float minVal, float maxVal)
{
  val = map(val, minVal, maxVal, 1, 10);
  //val *= val;
  return log(val)/log10;
}

// convert number from 0 to 1 into log scale from 0 to 1
float revLogScale(float val, float minVal, float maxVal)
{
  val = map(val, minVal, maxVal, 10, 1);
  //val *= val;
  return log(val)/log10;
}


void setup()
{
  size(1280, 720, P3D);

  cam = new PeasyCam(this, width);
  cam.setMinimumDistance(-width);
  cam.setMaximumDistance(width*200);
  cam.setResetOnDoubleClick(true);

  background(0);
  fill(200);

  text("hit space", 10, 20);

  noLoop(); //turn off loop until needed
}

void createShapes()
{
  soundAmpsShape = createShape();
  soundAmpsShape.beginShape();
  soundAmpsShape.enableStyle();
  soundAmpsShape.strokeWeight(1);
  soundAmpsShape.stroke(220, 220, 0, 80);
  soundAmpsShape.noFill();

  float yPos = -height/2f;
  Vec3D v = new Vec3D((float)-width, yPos, 0f);

  float widthInc = (width*2f)/soundAmplitudes.length;

  for (int i=0; i < soundAmplitudes.length; i++)
  { 
    float data = soundAmplitudes[i];

    if (useLogScale)
    {
      float absData = abs(data);
      float sign = data/absData; // positive or negative

      data = sign*logScale(absData, 0f, 1f);
    }

    v.setY( height-data*height*0.8f+yPos);
    pvertex(soundAmpsShape, v);
    v.addSelf(widthInc, 0, 0);
  }
  soundAmpsShape.endShape();

  soundRMSShape = createShape();
  soundRMSShape.beginShape();
  soundRMSShape.enableStyle();
  soundRMSShape.strokeWeight(3.5);
  soundRMSShape.stroke(0, 0, 255);
  soundRMSShape.noFill();

  //yPos = -yPos;
  v.set(-width, yPos, 0);

  widthInc = (width*2f)/rmsAmplitudes.length;

  for (int i=0; i < rmsAmplitudes.length; i++)
  { 
    float data = rmsAmplitudes[i];

    /* Note: using log scaling here doesn't really make sense because we've already calcuated sums linearly  
     if (useLogScale)
     {
     data = logScale(data, 0f, 1f);
     }
     */
    v.setY( height-data*height*1.6f*spikiness+yPos);
    pvertex(soundRMSShape, v);
    v.addSelf(widthInc, 0, 0);
  }
  soundRMSShape.endShape();


  soundRMSShape2 = createShape();
  soundRMSShape2.beginShape();
  soundRMSShape2.enableStyle();
  soundRMSShape2.strokeWeight(3.5);
  soundRMSShape2.stroke(255, 0, 255);
  soundRMSShape2.noFill();

  //yPos = -yPos;
  v.set(-width, yPos, 0);

  widthInc = (width*2f)/rmsAmplitudes2.length;

  for (int i=0; i < rmsAmplitudes2.length; i++)
  { 
    float data = rmsAmplitudes2[i];

    /* Note: using log scaling here doesn't really make sense because we've already calcuated sums linearly
     if (useLogScale)
     {
     data = logScale(data, 0f, 1f);
     }
     */
    v.setY( height-data*height*1.6f*spikiness+yPos);
    pvertex(soundRMSShape2, v);
    v.addSelf(widthInc, 0, 0);
  }
  soundRMSShape2.endShape();
}


void draw()
{  
  background(0);
  fill(200, 0, 200, 100);
  stroke(255);

  hint(DISABLE_DEPTH_TEST);

  if (soundAmpsShape != null)  
    shape(soundAmpsShape);

  if (soundRMSShape != null)
    shape(soundRMSShape);

  if (soundRMSShape2 != null)
    shape(soundRMSShape2);


  if (true)
  {  
    // draw info overlay




    int fontsize = 18;
    int startX = fontsize;
    int startY = 2*fontsize;


    cam.beginHUD();

    textSize(fontsize);
    textAlign(LEFT, BOTTOM);

    fill(255);
    text("file: " + wavFileName, startX, startY );
    startY += fontsize;
    text("wavSampleRate: " + wavSampleRate, startX, startY );
    startY += fontsize;
    text("RMSSize: " + RMSSize, startX, startY );

    cam.endHUD();
  }
} // end draw


void keyReleased()
{
  if (key == '+')
  {
    noLoop();
    if (RMSSize < 10) ++RMSSize;
    else
      RMSSize *=1.1;
    //println("RMSSize:" + RMSSize);
    computeRMS();
    loop();
  } else if (key == '-')
  {
    noLoop();
    if (RMSSize < 10)
    {
      if (RMSSize > 1) --RMSSize;
    } else
      RMSSize /= 1.1;

    computeRMS();
    //println("RMSSize:" + RMSSize);
    loop();
  } else if (key == 'z')
  {
    drawProfiles = !drawProfiles;
  } else if (key == 'P')
  {
    noLoop();
    spikiness *= 1.10;
    computeRMS();
    println("spikiness:" + spikiness);
    loop();
  } else if (key == 'p')
  {
    noLoop();
    spikiness /= 1.10;
    computeRMS();
    println("spikiness:" + spikiness);
    loop();
  } else if (key == 'F')
  {
    // get first part of filename, ignore extension
    String[] wavname = split(wavFileName, '.');

    String fileName = wavname[0] +
      "--" + nf(hour(), 2) + "." + nf(minute(), 2) + "." + nf(second(), 2) + 
      "-" +
      RMSSize + "-" +
      wavSampleRate +
      ".png" ;
    saveFrame(fileName);
  } else if (key==' ')
  { 
    if (!fileChosen) 
    {
      fileChosen = true;
      background(0, 200, 0);
      selectInput("Select a file to process:", "fileSelected");
    }
  } else if (key=='l')
  { 
    useLogScale = !useLogScale;
    computeRMS();
  }
}




void fileSelected(File selection) 
{
  if (selection == null) 
  {
    println("Window was closed or the user hit cancel.");
  } else 
  {
    println("file selected " + selection.getAbsolutePath());
    wavFileName = selection.getName();

    InputStream inputStream = null;
    WaveHeader waveHeader = null;

    try {
      inputStream = new FileInputStream(selection.getAbsolutePath());
      waveHeader = new WaveHeader(inputStream);
    } 
    catch (FileNotFoundException e) {
      e.printStackTrace();
    } 


    if (waveHeader != null && waveHeader.isValid()) 
    {
      try
      {
        wavSampleRate = waveHeader.getSampleRate();   
        println("sample rate:" + wavSampleRate);
        // load data

        byte[] data = new byte[inputStream.available()];
        inputStream.read(data);
        Wave wavFile = new Wave(waveHeader, data);
        //short[] amplitudes = wavFile.getSampleAmplitudes();
        NormalizedSampleAmplitudes nsa = new NormalizedSampleAmplitudes(wavFile);
        double[] amps = nsa.getNormalizedAmplitudes();
        soundAmplitudes = new float[amps.length];

        // initialize to 20 points per turn, to start
        RMSSize = max(1, int(amps.length / (100.0f))); 

        for (int i=0; i<amps.length; i++)
        {
          soundAmplitudes[i] = (float) amps[i];
        }
        println("found " + soundAmplitudes.length + " samples");
      } 
      catch (Exception e) 
      {
        println(e.getMessage());
        e.printStackTrace();
      }

      computeRMS();
      loop();
      // end load data
    } else {
      println("Invalid Wave Header");
    }

    if (inputStream != null)
    {
      try {
        inputStream.close();
      }
      catch (IOException e) {
        e.printStackTrace();
      }
    }

    // short version:
    // Open the wav file specified as the first argument
    //Wave wavFile = new Wave(selection.getAbsolutePath());
  }
  fileChosen = false; // reset for next time
}


void computeRMS()
{
  println("RMS Size: " + RMSSize);

  ampMin = MAX_FLOAT;
  ampMax = MIN_FLOAT;

  rmsAmplitudes = new float[soundAmplitudes.length/RMSSize];
  rmsAmplitudes2 = new float[soundAmplitudes.length/RMSSize];

  // println("calculating " + rmsAmplitudes.length + " samples");

  int currentIndex = 0;
  int rmsArrayIndex = 0;

  while (rmsArrayIndex < rmsAmplitudes.length)
  {
    int samplesLeft = soundAmplitudes.length - currentIndex;
    if (samplesLeft < RMSSize)
    {
      // println("RMS calc done:" + samplesLeft);
      break; // stop loop!
    }

    int RMSIndex = 0;
    float RMSSum = 0, RMSSum2=0;
    float prevData = 0f;

    while (RMSIndex < RMSSize)
    {
      // convert data to float
      float data = soundAmplitudes[currentIndex];

      if (useLogScale)
      {
        float absData = abs(data);
        float sign = data/absData; // positive or negative

        data = sign*logScale(absData, 0f, 1f);
      }

      float diffData = data - prevData;
      // debug
      /*if (rmsArrayIndex == rmsAmplitudes.length-1)
       {
       // println("data[" + currentIndex + "]=" + data);
       }*/
      RMSSum2 += diffData*diffData; // add square of data to sum
      RMSSum += data*data; // add square of data to sum
      currentIndex++; 
      RMSIndex++;
      prevData = data;
    }

    // find average value - could also scale logarithmically
    float RMSAve = RMSSum / float(RMSSize);
    ampMin = min(ampMin, RMSAve);
    ampMax = max(ampMax, RMSAve);

    rmsAmplitudes[rmsArrayIndex] = sqrt(RMSAve);
    rmsAmplitudes2[rmsArrayIndex] = sqrt(RMSSum2/float(RMSSize));
    rmsArrayIndex++;
    //println("stored " + (rmsArrayIndex-1) + ":" + RMSAve);
  }

  /*
  float[] rmsAmplitudesExtended = new float[rmsAmplitudes.length*TWEEN_POINTS];  //leave room for end->start
   
   for (int i=0; i<rmsAmplitudes.length-1; i++)
   {
   for (int ii=0; ii < TWEEN_POINTS; ii++)
   {
   // calculate linear mix of two vectors 
   float progress = (float)ii/(TWEEN_POINTS-1); // make sure it goes to 100%
   float tweenVal = tween.interpolate(rmsAmplitudes[i], rmsAmplitudes[i+1], progress); // get values btw 0 and 1
   rmsAmplitudesExtended[i*TWEEN_POINTS+ii] = tweenVal;
   }
   }
   // now start to finish
   float first = rmsAmplitudes[0];
   float last = rmsAmplitudes[rmsAmplitudes.length-1];
   
   for (int ii=0; ii < TWEEN_POINTS; ii++)
   {
   // calculate linear mix of two vectors 
   float progress = (float)ii/(TWEEN_POINTS-1); // make sure it goes to 100%
   float tweenVal = tween.interpolate(last, first, progress); // get values btw 0 and 1
   rmsAmplitudesExtended[(rmsAmplitudes.length-1)*TWEEN_POINTS+ii] = tweenVal;
   }
   
   rmsAmplitudes = rmsAmplitudesExtended;
   */
  createShapes();
}


void pvertex(PShape p, Vec3D v)
{
  p.vertex(v.x(), v.y(), v.z());
}

void vertex(Vec3D v)
{
  vertex(v.x(), v.y(), v.z());
}

void vertex(float[] v)
{
  vertex(v[0], v[1], v[2]);
}