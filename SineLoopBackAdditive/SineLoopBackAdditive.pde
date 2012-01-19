int speed = 2; // how fast it scrolls across the screen (0 is not moving)
float periods = 2; // how many humps the sine wave has
float waveHeight;  // the height of the wave

// these store the previous x,y points
float x,y;


void setup()
{
  size(512,256);
  background(0);
  
  // the height of our wave
  waveHeight = height/2;
}


void draw()
{
  //periods = map(mouseX, 0,width, 1, 20);
  
  //waveHeight = height/2 * sin(frameCount/20);
  
  background(0);
  
  //periods += PI/800.0;
  periods *= 1.001;
  
  colorMode(HSB, 1,1,1,1); // all from 0-1 for RGBA
  
  
  for (int index=0; index < width; index++)
  {
    
    int movedIndex = index + (frameCount*speed);
    
    movedIndex = movedIndex % width; // wrap around width
    
    // angle calculated from our moving index:
    float movingAngle = map(movedIndex, 0,width, 0, periods*TWO_PI);  
    
    // height goes from 0 to waveHeight
    // remember: sin( ) goes from -1 to 1
  //  float heightValue = waveHeight * ( 1 + sin(movingAngle) )*0.5;
    
    // convert the horizontal position to an angle
    float angle = map(index, 0,width, 0, TWO_PI); 
      
    float heightValue = (2+cos(periods*angle))*0.5* waveHeight * (1 + 0.8*sin(movingAngle) + 0.2*cos(periods*0.1*movingAngle))/2;

    
    float newx = movedIndex;
    float newy = heightValue;
    
    // radius of our circle 
    float r = newy;
    
    float h = r/waveHeight; // hue from 0-1
 
    newx = r * cos(angle)+  width/2;
    newy = r * sin(angle) + height/2;
    
    // draw a line between the current x,y and the previous ones
    //line(x,y,newx,newy);
    
    stroke(h, 1,0.8,1);
    point(newx,newy);
    
    x = newx;
    y = newy;
    
    //point(x, y);
  }
}




