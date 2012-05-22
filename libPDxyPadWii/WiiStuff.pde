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
      println("Z!!! " + millis());
      pd.sendBang("trigger");
      //
    }
    public void zReleased()
    {
    }
    public void cPressed()
    {
      pd.sendBang("play");
      println("C!!!" + millis());
      //
    }

    public void cReleased()
    {
      println("released");
      pd.sendBang("release");
    }
    public void stateUpdated(WiiChuck chuck) 
    {
      float wiiy = map(chuck1.stickY, -100, 100, 0, 127);
      pd.sendFloat("note", wiiy);
      float wiix = map(chuck1.stickX, -100, 100, 0, 800);  
      pd.sendFloat("freq", wiix);  
      float wiiRoll = map(chuck1.roll, -100, 100, 0, 2500);  
      pd.sendFloat("cutoff", wiiRoll);
      float wiiScale = map(abs(chuck1.pitch), 0, 100, 0, 4000);  
      pd.sendFloat("delay", wiiScale);
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

