import processing.svg.*; //<>// //<>// //<>//


import toxi.math.*;


void setup() 
{
  //size(1080, 720, SVG, "circle01.svg");
  size(1080, 720, P2D);
}

void draw() {
  background(0);

  float radius = 200;
  int segments = 16;
  float segAngle = TWO_PI/segments;

  strokeWeight(2);

  ellipseMode(CENTER);

  translate(width/2, height/2);
  fill(180);
  noStroke();
  ellipse(0, 0, 4, 4);

  strokeWeight(3);
  stroke(255,0,255, 140);
  noFill();
  
  // b^2 = 2r^2-2r^2*cos angle
  
  ellipse(0, 0, (float)radius*2, (float)radius*2);
  
  float r2x2 = radius*radius*2; 
  float x = sqrt(r2x2 - r2x2*cos(segAngle) );

  stroke(0, 255, 0);
  translate((float)radius, 0);
  rotate(PI/2);
  rotate(-segAngle/2);

  stroke(0, 0, 255,180);
  for (int i=0; i<segments; i++)
  {
    rotate((float)segAngle);
    
    line(0, 0, x, 0);
    translate(x, 0);
    line(-8, -8, 0, 0);
    line(-8, 8, 0, 0);
  }
  fill(0,255,0);
  noStroke();
  ellipse(0, 0, 4, 4);
  //exit();
  noLoop();
}