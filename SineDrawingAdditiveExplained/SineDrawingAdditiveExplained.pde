import controlP5.*;

float speed = 2; // how fast it scrolls across the screen (0 is not moving)
float periods = 1; // how many humps the sine wave has
float waveHeight;  // the height of the wave

float radii[];

ControlP5 gui;



void setup()
{
  size(960, 480);
  gui = new ControlP5(this);

  int guiX = width/64;
  int guiY = height/32;  

  Slider slider = gui.addSlider("periods", 1f, 20f, 1f, guiX, guiY, 100, 16);
  slider = gui.addSlider("speed", -20f, 20f, 1f, guiX, guiY+20, 100, 16);

  waveHeight = height/2;
  radii = new float[width]; // list of radii
  background(0);
}


void draw()
{
  smooth();
  background(0);
  fill(255);
  stroke(255);

  // Step 1: calculate & draw moving sine wave representing changing radius

  int numPoints = width/2;

  for (int index=0; index < numPoints; index++)
  {
    // moving index, so it scrolls across the screen:
    int movedIndex = index + int(frameCount*speed);
    movedIndex = movedIndex % numPoints; // wrap around width

    float angle = map(movedIndex, 0, numPoints, 0, TWO_PI);

    float finalAngle = int(periods)*angle;


    // map the value of the sin function across 1 rotation that spans the width of the screen 
    float sinVal = sin( finalAngle );
    float sinVal2 = sin( 2*finalAngle );
    float sinVal3 = sin( 6*finalAngle );
    float cosVal = cos( finalAngle );
    float cosVal2 = cos( 2*finalAngle );
    float cosVal3 = cos( 3*finalAngle );

    // The height of the sine wave at the current position across the screen.
    // Will range from 0 to waveHeight
    float heightValue = waveHeight * 
      (1.0 + 0.6*sinVal + 0.3*sinVal2+0.1*sinVal3)*0.5;

    float heightValue1 = waveHeight * 
      (1.0 + 0.6*sinVal)*0.5;

    float heightValue2 = waveHeight * 
      (1.0 + 0.3*sinVal2)*0.5;

    float heightValue3 = waveHeight * 
      (1.0 + 0.1*sinVal3)*0.5;

    // this is the radius at this point
    radii[index] = heightValue;


    float waveStartY = height/4;
    float waveStartX = width/64;

    float waveX = waveStartX + map(index, 0, numPoints, 0, width/2);
    float waveY = waveStartY + heightValue;

    float circleCenterX = width/4 + waveStartX;
    float circleCenterY = height/2;

    float circleR = height/4;

    float circleX = circleCenterX + circleR * cosVal;
    float circleY = circleCenterY + circleR * sinVal;

    float roseCenterX = 3*width/4;
    float roseCenterY = height/2;

    float roseR =  circleR * (0.6*sin(angle*int(periods)+ 0.3*sin(angle*2*int(periods)) + 0.1*sin(6*angle*int(periods))));

    float roseX = roseCenterX + roseR * cos(angle);
    float roseY = roseCenterY + roseR * sin(angle);

    strokeWeight(1);

    // highlight the middle dot, for effect  
    if (index == numPoints/2) 
    {
      fill(0, 255, 0, 200);      
      ellipse(waveX, waveY, 12, 12);
      ellipse(circleX, circleY, 12, 12);

      stroke(0, 255, 0, 200);
      line(waveX, waveStartY, waveX, waveStartY+waveHeight);
      line(circleCenterX, circleCenterY, circleX, circleY);
      ellipse(roseX, roseY, 16, 16);

//      stroke(0, 255, 0, 200);      
      noStroke();
      fill(255,0,0, 200);
      ellipse(waveX, waveStartY+heightValue1, 8, 8);
      fill(0,255,0, 200);
      ellipse(waveX, waveStartY+heightValue2, 8, 8);
      fill(0,0,255, 200);
      ellipse(waveX, waveStartY+heightValue3, 8, 8);
      noStroke();
    }
    else 
    {
      fill(100, 255);
      noStroke();
      ellipse(waveX, waveY, 4, 4);
      
      fill(255,0,0, 80);
      ellipse(waveX, waveStartY+heightValue1, 2, 2);
      fill(0,255,0, 80);
      ellipse(waveX, waveStartY+heightValue2, 2, 2);
      fill(0,0,255, 80);
      ellipse(waveX, waveStartY+heightValue3, 2, 2);
      
      fill(255);
      ellipse(circleX, circleY, 4, 4);
      ellipse(roseX, roseY, 4, 4);
    }
  }
}

