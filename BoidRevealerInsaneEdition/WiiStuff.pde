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
      //println("Z!!! " + millis());
      tapTempo();
    }
    public void cPressed()
    {
       currentBGTex = bgImages[floor(random(0,bgImages.length))];
       colorMode(HSB);
       tintColors[floor(random(0,tintColors.length))] = color(random(0,256), 255, 220, 180);
    }
    public void stateUpdated(WiiChuck chuck) {
//      println("roll:"+chuck.roll);
      int val = (int)constrain(map(abs(chuck.roll), 0, 1.3, 0, FLOCKS+1),0,FLOCKS); 
      if (val > 0)
      {
        //println("animating:"+val);
        flocks[val-1].toReanimate++;
      }
      //println("x:"+chuck.stickX);
      final float maxh = 2*83*83;
      float h2 = chuck.stickY*chuck.stickY + chuck.stickX*chuck.stickX;
      //println(h2/maxh);
      if (h2 > maxh/6f)
      {
        float speed  = map(h2, maxh/6f, maxh, 2,280);
        //speed *= speed; 
        //println("speed:"+speed);
        boidMaxSpeed = speed;
        boidMaxForce = speed/5f;
        
        for (Flock f : flocks)
        {
          
          f.maxspeed = speed;
          fx = speed/100f;
        }
      }
    }
  } 
  );
} 




void drawChuck() 
{ 
  pushMatrix();
  rotateZ(chuck1.roll); 
  rotateX(chuck1.pitch); 
  scale(map(chuck1.stickY, -100, 100, 10, 60));

  float fx = map(chuck1.stickX, -100, 100, 0, 1);

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
