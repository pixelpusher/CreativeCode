//
// Don't close the shapes!
//

// The trick is to draw the ring using a skip (samples in the file)
// and some light linear interpolation between successive samples,
// then double the skip on the inner ring, and double the soothing 
//
// can also make ones with segments...

import processing.pdf.*;

float spacing=1, diam=200, smoothing=0.9, bumpiness=2;
// for bracelet
//float innerDiam = diam*0.25;

// for ring
float innerDiam = diam*0.8;
float innerRatio = 0.95;

int MAX_DIAMETER; // pixels
int MIN_DIAMETER; // pixels

int maxFrames = 30; 
final int cols = 9;

final static int skip = 60;
final static int SAMPLE_RATE = 48000; // not a great place to put it, but...
final static int BUFFER_SIZE = int(1.257*SAMPLE_RATE/4)/skip;


float radii[][];
float centerX, centerY;

PVector a, b;

final float step = TWO_PI/(BUFFER_SIZE);

float minV, maxV;

void setup()
{
  size(3600, 2400, PDF, "crickets_rings_" + BUFFER_SIZE + "-" + skip + "." + smoothing + "." + innerDiam + ".pdf");

  centerX = width/2;
  centerY = height/2;

  a = new PVector();
  b = new PVector();

  int totalFramesRead = 0;

  println("Buffer size: " + BUFFER_SIZE);


  try
  {
    // Open the wav file specified as the first argument
    //WavFile wavFile = WavFile.openWavFile(new File(dataPath("alicia.wav")));
    WavFile wavFile = WavFile.openWavFile(new File(dataPath("crickets-long-for-spiral.wav")));

    // Display information about the wav file
    wavFile.display();

    // Get the number of audio channels in the wav file
    int numChannels = wavFile.getNumChannels();

    // Create a buffer of 100 frames
    double[] buffer = new double[BUFFER_SIZE * numChannels * skip];

    maxFrames = int(wavFile.getNumFrames()/buffer.length);
    println("maxFrames: " + maxFrames);
    println("extra samples to read: " + (wavFile.getNumFrames() % maxFrames));

    radii = new float[maxFrames][BUFFER_SIZE];

    int framesRead;
    int loops = 0;
    double dminV = Double.MAX_VALUE;
    double dmaxV = Double.MIN_VALUE;

    do
    {
      // Read frames into buffer
      framesRead = wavFile.readFrames(buffer, buffer.length);
      println("Read " + framesRead + " frames");
      totalFramesRead += framesRead;

      if ( framesRead == buffer.length) //only care about complete frames
      {
        float b = 0.0f;
        int bufferIndex = 0;

        // Loop through frames and look for minimum and maximum value
        for (int s=0; s < framesRead * numChannels; s+= (numChannels*skip))
        {   
          //b = lerp( (float)buffer[s], b, 0.7);
          b = (float)buffer[s];

          radii[loops][bufferIndex++] = b;

          if (buffer[s] > dmaxV) dmaxV = buffer[s];
          if (buffer[s] < dminV) dminV = buffer[s];
        }
      }
      loops++;
      println("Finished loop " + loops + "----------------");
    }
    while (framesRead != 0);

    // Close the wavFile
    wavFile.close();

    minV = (float)dminV;
    maxV = (float)dmaxV;

    // Output the minimum and maximum value
    System.out.printf("Min: %f, Max: %f\n", minV, maxV);
  }
  catch (Exception e)
  {
    System.err.println(e);
  }
}



void draw()
{
  float transAmt = spacing * (diam + bumpiness*diam);
  float radiiRange = maxV-minV;

  smooth();
  background(255);
  //hint(DISABLE_DEPTH_TEST);

  stroke(0, 0, 0, 180);
  noFill();
  strokeWeight(1);

  int fIndex = 0;
  int colCount = 0;

  pushMatrix();
  translate(transAmt, transAmt);

  // do row/cols

  noFill();

  final float log2 = log(2); 

  while (fIndex < radii.length)
  {
    // DRAW OUTER RING
    //
    beginShape();
    for (int v = 0; v < BUFFER_SIZE; v++)
    {
      float currentRadiusScaled = log( (radii[fIndex][v]-minV)/radiiRange + 1) / log2;
      float angle = step * v;
      float r = diam*0.5 + currentRadiusScaled*diam*bumpiness*0.5;
      float dx = cos(angle)*r;
      float dy = sin(angle)*r;
      float pdx = dx;
      float pdy = dy;

      vertex(lerp(pdx, dx, smoothing), lerp(pdy, dy, smoothing));
    }
    endShape(CLOSE);

    // DRAW INNER RING
    //

    beginShape();
    for (int v = 0; v < BUFFER_SIZE; v++)
    {
      float innerSmoothing = 0.75;
      float currentRadiusScaled = log( (radii[fIndex][v]-minV)/radiiRange + 1) / log2;
      //float currentRadiusScaled = (radii[fIndex][v]-minV)/radiiRange;
      float angle = step * v;
      // opposite..
      //float r = diam*0.5*innerRatio - currentRadiusScaled*(innerDiam*0.5);
      // same direction
      float r = innerDiam*0.5 + currentRadiusScaled*(diam-innerDiam)*bumpiness*0.5;
      float dx = cos(angle)*r;
      float dy = sin(angle)*r;
      float pdx = dx;
      float pdy = dy;

      vertex(lerp(pdx, dx, smoothing*innerSmoothing), lerp(pdy, dy, smoothing*innerSmoothing));
    }
    endShape(CLOSE);


    translate(transAmt, 0);
    colCount++;

    if (colCount == cols)
    {
      colCount = 0;
      translate(-cols*(transAmt), transAmt);
    }

    ++fIndex;
  }
  popMatrix();

  exit();
}

