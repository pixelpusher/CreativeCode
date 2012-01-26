int speed = 2; // how fast it scrolls across the screen (0 is not moving)
float periods = 3; // how many humps the sine wave has
float waveHeight;  // the height of the wave

void setup()
{
  size(512, 256);
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

      float newHeight = map(index, 0, width, 1, 0) * waveHeight;

    float heightValue = newHeight * 
      sin( map(movedIndex, 0, width, 0, periods*2*TWO_PI) ) 
      + newHeight;

    stroke(255, 0, 255);
    point(index, heightValue);


    // draw sine wave 2
    newHeight = map(index, 0, width, 1, 0) * waveHeight * 0.5;

    heightValue = newHeight * 
      sin( map(movedIndex, 0, width, 0, periods*TWO_PI) ) 
      + newHeight;

    stroke(255, 255, 0);
    point(index, heightValue);
  }
}

