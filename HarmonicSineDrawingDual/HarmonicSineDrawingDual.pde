// All code is licensed under GNU AGPL 3.0+ http://www.gnu.org/licenses/agpl.html
//
// By Evan Raskob 2012
// info@pixelist.info
//
// for a project with Ravensbourne http://rave.ac.uk


float speed = 0.01; // how fast it gains harmonics
float periods = 0; // how many humps the sine wave has
float waveHeight;  // the height of the wave
int numPoints = 120;

void setup()
{
  size(512,512);
  background(0);
  
  waveHeight = height/4;
}


void draw()
{
  periods += speed;
  //periods = map(mouseX, 0,width, 1, 20);  
  //waveHeight = height/2 * sin(frameCount/20);
  
  background(0);
  fill(255);
  stroke(255);
  
  for (int index = 0; index < numPoints; index++)
  {
      {
        float majorAngle = map(index, 0, numPoints, 0, TWO_PI);

        float angle = map(index, 0, numPoints, -periods*TWO_PI, periods*TWO_PI);

        float heightValue = waveHeight+waveHeight * 
          sin(majorAngle);

        float widthValue = waveHeight+waveHeight * 
          cos(majorAngle);

        float angleMesserUpper = frameCount * 0.001;

        float x = widthValue + (sin(angle*angleMesserUpper)+1)*0.5*waveHeight;
        float y = heightValue + (cos(angle*angleMesserUpper)+1)*0.5*60;

        ellipse(x,y, 10,10);
      }
  }
}
