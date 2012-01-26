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
    
    // this is the moving index, from left to right. 
    int movedIndex = index + (frameCount*speed);
    movedIndex = movedIndex % width; // wrap around width
    
    // draw sin wave 1 (point by point)

    // this is the damped height (fades out from left to right
    float dampedHeight = map(index, 0, width, 1, 0) * waveHeight;

    // the y value (height) of the sine wave for this hrizontal screen position
    float heightValue = dampedHeight * 
      sin( map(movedIndex, 0, width, 0, periods*2*TWO_PI) ) 
      + dampedHeight;

    // invert the height (so it grows from the bottom up instead of top down)
    heightValue = height-heightValue;
    
    stroke(255, 0, 255);
    point(index, heightValue);


    // draw sine wave 2 (point-by-point)
    dampedHeight = map(index, 0, width, 1, 0) * waveHeight * 0.5;

    float sinVal1 = sin( map(movedIndex, 0, width, 0, periods*TWO_PI) );
    float sinVal2 = sin( map(movedIndex, 0, width, 0, periods*4*TWO_PI));

    //
    // Add the two sin waves together, but mix them in different amounts.
    // We try to keep the sum of the coefficients (0.8 and 0.2, respectively)
    // equal to 1.0 (e.g., 0.2 + 0.8 = 1.0) because otherwise the height of the 
    // additive sin wave will be too large (greater than 1.0)
    // 
    heightValue = dampedHeight * ( 0.8*sinVal1 + 0.2*sinVal2) + dampedHeight;

     
    // invert the height (so it grows from the bottom up instead of top down)
    heightValue = height-heightValue;

    stroke(255, 255, 0);
    point(index, heightValue);
  }
}

