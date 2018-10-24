import processing.svg.*;


import toxi.math.*;


void setup() 
{
  size(1080, 720, SVG, "circle01.svg");
  
}

void draw() {
  background(0);

  double radius = 200;
  int segments = 16;
  float segAngle = TWO_PI/segments;

  strokeWeight(4);

  ellipseMode(CENTER);

  translate(width/2, height/2);
  fill(180);
  noStroke();
  ellipse(0, 0, 4, 4);

  stroke(255, 80);
  noFill();
  double t = Math.tan(segAngle);
  
  

  stroke(0, 255, 0);
  for (int i=0; i<segments; i++)
  {
    float x = (float)(radius*Math.sin(segAngle*i));
    float y = (float)(radius*Math.cos(segAngle*i));
    line(0, 0, x, y);
    ellipse(x,y,4,4);
  }
  exit();
}
