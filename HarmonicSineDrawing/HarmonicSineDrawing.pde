// All code is licensed under GNU AGPL 3.0+ http://www.gnu.org/licenses/agpl.html
//
// By Evan Raskob 2012
// info@pixelist.info
//
// for a project with Ravensbourne http://rave.ac.uk


float speed = 0.01; // how fast it gains harmonics
float periods = 0; // how many humps the sine wave has
float waveHeight;  // the height of the wave

void setup()
{
  size(512,256);
  background(0);
  
  waveHeight = height/2;
}


void draw()
{
  periods += speed;
  //periods = map(mouseX, 0,width, 1, 20);  
  //waveHeight = height/2 * sin(frameCount/20);
  
  background(0);
  fill(255);
  stroke(255);
  
  for (int index = 0; index < width; index++)
  {
    
    
    float heightValue = waveHeight * 
      sin( map(index, 0,width, -periods*TWO_PI, periods*TWO_PI) ) 
      + waveHeight;
    
    point(index, heightValue);
  }
}
