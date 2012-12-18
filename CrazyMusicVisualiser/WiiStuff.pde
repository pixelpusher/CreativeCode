/**
 * wii controlled
 * RGB Cube.
 * 
 * The three primary colors of the additive color model are red, green, and blue.
 * This RGB color cube displays smooth transitions between these colors. 
 */


import processing.serial.*;
Serial myPort;                // The serial port

final int BAUDRATE = 115200; 
final char DELIM = ','; // the delimeter for parsing incoming data

WiiChuck chuck1;



void randomiseShapeColors()
{
  try {

    if ( shapes != null)
    {
      Iterator<ProjectedShape> iter = shapes.iterator();

      while (iter.hasNext ())
      {
        ProjectedShape ps = iter.next();

        ps.srcColor = color(random(0, 255), random(0, 255), random(0, 255), 180);
        //    currentShape.srcColor = color(255,255);
        ps.dstColor = ps.srcColor;
      }
    }
  }
  catch (Exception e)
  {
    e.printStackTrace();
  }
}



void setShapeBlends(int bm)
{
  try 
  {
    if ( shapes != null)
    {
      Iterator<ProjectedShape> iter = shapes.iterator();

      while (iter.hasNext ())
      {
        ProjectedShape ps = iter.next();        
        ps.blendMode = bm;
      }
    }
  }
  catch (Exception e)
  {
    e.printStackTrace();
  }
}


void setupWiiChuck() 
{ 
  chuck1 = new WiiChuck();

  myPort = new Serial(this, Serial.list()[0], BAUDRATE);
  // clear the serial buffer:
  myPort.clear();

  // this prints out to console
  //chuck1.debug = true;

  chuck1.addListener( new IWiiChuckListener() {
    public void zPressed()
    {
      //println("Z!!! " + millis());
      tapTempo();
    }
    public void cPressed()
    {
      println("C!!!" + millis());
      PsychedelicWhitney psychoWhitney  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
      //psychoWhitney.intervalTime[psychoWhitney.currentInterval] = psychoWhitney.currentTime;
      psychoWhitney.nextInterval();
    }
    public void stateUpdated(WiiChuck chuck) 
    {
      DynamicWhitney whitneyDynamicImage  = (DynamicWhitney)(sourceDynamic.get( DynamicWhitney.NAME));

      //whitneyDynamicImage.crad = lerp(whitneyDynamicImage.crad, whitneyDynamicImage.crad+map(chuck.ay, -100, 100, -8, 8f), 0.2);
      //whitneyDynamicImage.numPetals = int(map(abs(chuck.ax), 0, 100, 1, 4));
      if (chuck1.cPressed == 1)
      {
        PsychedelicWhitney psychoWhitney  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
        psychoWhitney.waveHeight = lerp(psychoWhitney.waveHeight, psychoWhitney.height/6f * map(chuck.stickY, -100, 100, 0.2, 1.5f), 0.3);
      }
      //psychoWhitney.speed = lerp(psychoWhitney.speed, 0.001f * map(chuck.stickX, -100, 100, -50, 50f), 0.2);
    }
  } 
  );
} 




void drawChuck() 
{ 

  rotateZ(chuck1.roll); 
  rotateX(chuck1.pitch); 
  scale(map(chuck1.stickY, -100, 100, 10, 60));

  float fx = map(chuck1.stickX, -100, 100, 0, 1);

  pushMatrix();
  beginShape(QUADS);

  fill(0, fx, fx); 
  vertex(-1, 1, 1);
  fill(fx, fx, fx); 
  vertex( 1, 1, 1);
  fill(fx, 0, fx); 
  vertex( 1, -1, 1);
  fill(0, 0, fx); 
  vertex(-1, -1, 1);

  fill(1, 1, 1); 
  vertex( 1, 1, 1);
  fill(1, 1, 0); 
  vertex( 1, 1, -1);
  fill(1, 0, 0); 
  vertex( 1, -1, -1);
  fill(1, 0, 1); 
  vertex( 1, -1, 1);

  fill(1, 1, 0); 
  vertex( 1, 1, -1);
  fill(0, 1, 0); 
  vertex(-1, 1, -1);
  fill(0, 0, 0); 
  vertex(-1, -1, -1);
  fill(1, 0, 0); 
  vertex( 1, -1, -1);

  fill(0, 1, 0); 
  vertex(-1, 1, -1);
  fill(0, 1, 1); 
  vertex(-1, 1, 1);
  fill(0, 0, 1); 
  vertex(-1, -1, 1);
  fill(0, 0, 0); 
  vertex(-1, -1, -1);

  fill(0, 1, 0); 
  vertex(-1, 1, -1);
  fill(1, 1, 0); 
  vertex( 1, 1, -1);
  fill(1, 1, 1); 
  vertex( 1, 1, 1);
  fill(0, 1, 1); 
  vertex(-1, 1, 1);

  fill(0, 0, 0); 
  vertex(-1, -1, -1);
  fill(1, 0, 0); 
  vertex( 1, -1, -1);
  fill(1, 0, 1); 
  vertex( 1, -1, 1);
  fill(0, 0, 1); 
  vertex(-1, -1, 1);

  endShape();

  popMatrix();
} 



void serialEvent(Serial myPort) 
{
  // read incoming data until you get a newline:
  String serialString = myPort.readStringUntil('\n');

  // if the read data is a real string, parse it:
  if (serialString != null) 
  {
    // split it into substrings on the DELIM character:
    String[] numbers = split(serialString, DELIM);
    chuck1.update(numbers);
  }
}

