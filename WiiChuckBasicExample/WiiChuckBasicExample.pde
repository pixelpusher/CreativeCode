/**
 * wii controlled
 * RGB Cube.
 * 
 * The three primary colors of the additive color model are red, green, and blue.
 * This RGB color cube displays smooth transitions between these colors. 
 * Uses a Wii Nunchuck connected to an Arduino as a controller using a modified
 * version of this: http://arduino.cc/playground/Main/WiiChuckClass
 * which can be found at http://github.com/pixelpusher/CreativeCode/
 *
 * Modified by Evan Raskob 2012
 * http://pixelist.info
 * Licensed under a BSD license but for good karma distribute it far and wide for free
 */


import processing.serial.*;
Serial myPort;                // The serial port

int BAUDRATE = 115200; 
char DELIM = ','; // the delimeter for parsing incoming data

WiiChuck chuck1;



void setup() 
{ 
  size(200, 200, P3D); 
  noStroke(); 
  colorMode(RGB, 1); 
  myPort = new Serial(this, Serial.list()[0], BAUDRATE);
  // clear the serial buffer:
  myPort.clear();

  chuck1 = new WiiChuck();
  
  // this prints out to console
  //chuck1.debug = true;
  
  
  chuck1.addListener( new IWiiChuckListener() {
    public void zPressed()
    {
      println("Z!!!");
    }
    public void cPressed()
    {
      println("C!!!");      
    }
    public void stateUpdated(WiiChuck chuck) { 
    //println("CPRESSED:" + chuck.cPressed);
    
    }
  } );
  
} 




void draw() 
{ 
  background(0.5, 0.5, 0.45);

  pushMatrix(); 

  translate(width/2, height/2, -30); 

  rotateZ(chuck1.roll); 
  rotateX(chuck1.pitch); 
  scale(map(chuck1.stickY, -100,100, 10,60));
  
  beginShape(QUADS);

  float fx = map(chuck1.stickX, -100,100,0,1);

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



void serialEvent(Serial myPort) {
  // read incoming data until you get a newline:
  String serialString = myPort.readStringUntil('\n');

  // if the read data is a real string, parse it:
  if (serialString != null) 
  {
    //println(serialString);
    //println(serialString.charAt(serialString.length()-3));
    // println(serialString.charAt(serialString.length()-2));
    // split it into substrings on the DELIM character:
    String[] numbers = split(serialString, DELIM);

    chuck1.update(numbers);

    // Things we don't handle in particular can get output to the text window
  }
}

