int speed = 2; // how fast it scrolls across the screen (0 is not moving)
float periods = 3; // how many humps the sine wave has
float waveHeight;  // the height of the wave

void setup()
{
  size(512,256);
  background(0);
  
  waveHeight = height/2;
}


void draw()
{
  //periods = map(mouseX, 0,width, 1, 20);
  
  //waveHeight = height/2 * sin(frameCount/20);
  
  background(0);
  fill(255);
  stroke(255);
  
  for (int index=0; index < width; index++)
  {
    int movedIndex = index + (frameCount*speed);
    movedIndex = movedIndex % width; // wrap around width
    
    float heightValue = waveHeight * 
      sin( map(movedIndex, 0,width, 0, periods*TWO_PI) ) 
      + waveHeight;
    
    point(index, heightValue);
  }
}
