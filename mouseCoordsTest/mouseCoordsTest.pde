void setup()
{
  background(0);
  size(1280, 720, P3D);
}

void draw() 
{
  background(0);
  stroke(255);
  strokeWeight(2);
  int lines = 100;
  for (int i=0; i<lines; i++)
    line(i*width/lines, 0, i*width/lines, height);
    
  for (int i=0; i<lines; i++)
    line(0, i*height/lines, width, i*height/lines);
    
  fill(0);
  stroke(0);
  ellipse(mouseX,mouseY,8,8);
}