int speed = 2; // how fast it scrolls across the screen (0 is not moving)
float periods = 4; // how many humps the sine wave has
float waveHeight;  // the height of the wave

// these store the previous x,y points
float x,y;


void setup()
{
  size(512,256);
  background(0);
  
  // the height of our wave
  waveHeight = height/4;
}


void draw()
{
  //periods = map(mouseX, 0,width, 1, 20);
  
  //waveHeight = height/2 * sin(frameCount/20);
  
  background(0);
  fill(255);
  stroke(255);
  
  periods += PI/1000.0;
  
  colorMode(HSB, 1,1,1,1); // all from 0-1 for RGBA
  
  
  for (int index=0; index < width; index++)
  {
    
    int movedIndex = index + (frameCount*speed);
    
    movedIndex = movedIndex % width; // wrap around width
    
    // height goes from 0 to waveHeight
    // remember: sin( ) goes from -1 to 1
    float heightValue = waveHeight * 
      (1+sin( map(movedIndex, 0,width, 0, periods*TWO_PI) ))*0.5;
      
    
    float newx = movedIndex;
    float newy = heightValue;
    
    // convert the horizontal position to an angle
    float angle = map(index, 0,width, 0, TWO_PI); 

    // radius of our circle 
    float r = newy;
    
    float h = r/waveHeight; // hue from 0-1
    
    stroke(h, 1,0.8,1);
    
    newx = r * cos(angle)+  width/2;
    newy = r * sin(angle) + height/2;
    
    // draw a line between the current x,y and the previous ones
    line(x,y,newx,newy);
    
    x = newx;
    y = newy;
    
    //point(x, y);
  }
}




