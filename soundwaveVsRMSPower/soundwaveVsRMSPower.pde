// 3d sound spiral generator
//  by evan raskob evanraskob@gmail.com
// wave code uses code from http://code.google.com/p/musicg/
//
// Draw a base spiral and offset it by the sound volume (RMS)
//
// TODO
// - fix bounding box pshape display - not showing due to some PShape thing?
// - bounding box check - model size display too!! How bug are these??
// - how about a REPL for commands instead of stupid key presses
// - need flat base for stand and for printing properly...
// - how about filling it to the max spikiness in between shapes, so it is recessed rather 
// than filled?
// - or inner removal of material rather than exterior extrusion


import java.io.*;
import java.util.Iterator;
import toxi.math.*;
import processing.opengl.*;



boolean fileChosen = false;
PrintWriter output, outputRMS;
float[] soundAmplitudes;
float[] rmsAmplitudes;

PShape soundwaveShape = null;
PShape RMSPowerShape = null;
int RMSSize = 1; // will be overriden in fileSelected() function

String wavFileName = "";
int wavSampleRate; // sample rate of Wave file


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

  background(0);
  fill(200);

  text("hit space", 10, 20);
  noLoop(); //turn off loop until needed
}


void draw()
{  
  background(0);
  fill(200, 0, 200, 100);
  stroke(255);
  
  hint(DISABLE_DEPTH_TEST);
  // TODO: draw shapes soundwaveShape and RMSPowerShape 
  if (soundwaveShape != null)
    shape(soundwaveShape);

  pushMatrix();
  translate(0,height/2);
  if (soundwaveShape != null)
    shape(soundwaveShape);
  popMatrix();


  if (true)
  {  
    // draw info overlay

    int fontsize = 18;
    int startX = fontsize;
    int startY = 2*fontsize;

    textSize(fontsize);
    textAlign(LEFT, BOTTOM);

    fill(255);
    text("file: " + wavFileName, startX, startY );
    startY += fontsize;
    text("wavSampleRate: " + wavSampleRate, startX, startY );
    startY += fontsize;
    text("RMSSize: " + RMSSize, startX, startY );
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

        // initialize to 1 chunk per pixel, to start
        RMSSize = int(amps.length / width); 

        for (int i=0; i<amps.length; i++)
          soundAmplitudes[i] = (float) amps[i];

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
  // println("RMS Size: " + RMSSize);

  ampMin = MAX_FLOAT;
  ampMax = MIN_FLOAT;

  rmsAmplitudes = new float[soundAmplitudes.length/RMSSize];

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
    float RMSSum = 0;

    while (RMSIndex < RMSSize)
    {
      
      float data = soundAmplitudes[currentIndex];

      // debug
      /*if (rmsArrayIndex == rmsAmplitudes.length-1)
       {
       // println("data[" + currentIndex + "]=" + data);
       }*/
      RMSSum += data*data; // add square of data to sum
      currentIndex++; 
      RMSIndex++;
    }

    // find average value - could also scale logarithmically
    float RMSAve = RMSSum / float(RMSSize);
    ampMin = min(ampMin, RMSAve);
    ampMax = max(ampMax, RMSAve);

    rmsAmplitudes[rmsArrayIndex++] = RMSAve;

    //println("stored " + (rmsArrayIndex-1) + ":" + RMSAve);
  }
  println("building shapes");
  buildShapes();
}



void buildShapes()
{
  soundwaveShape = createShape();
  soundwaveShape.enableStyle();
  soundwaveShape.beginShape(LINES);
  soundwaveShape.noFill();
  soundwaveShape.strokeWeight(3);
  soundwaveShape.stroke( color(255,255,0) );
  
  // map to 1:1 pixel ratio
  for (int y=0, inc = soundAmplitudes.length/width; y < soundAmplitudes.length; y+=inc)
  {
    float x = 4*soundAmplitudes[y]*height/10.0; // 4/5 of 1/2 the height of the screen (40%)
    soundwaveShape.vertex(x,y,0);
  }
  soundwaveShape.endShape();
  
  //RMSPowerShape = null;
}
