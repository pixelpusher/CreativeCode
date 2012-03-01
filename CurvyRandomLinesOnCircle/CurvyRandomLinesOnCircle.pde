
float maxLength=100;
float minLength=20;
float curvy = 80;


void setup()
{
  size(640, 480);
  background(0);
  noFill();
}


void draw()
{
  
  float colorChance = random(0,1);
  
  
  if (colorChance < 0.33)
  {
    stroke( 255,0,0 );
  }
  else if (colorChance < 0.66)
  {
    stroke( 0,0,255 );
  }
  else if (colorChance < 1)
  {
    stroke( 0,255,0 );
  }
  

  if (mousePressed)
  {
    float angle = random(0, TWO_PI);
    float r = random(minLength, maxLength);

    float x = mouseX + r*cos(angle);
    float y = mouseY + r*sin(angle);

    //line(mouseX, mouseY, x, y);
    bezier(mouseX, mouseY, mouseX+random(-curvy,curvy), mouseY+random(-curvy,curvy),
      x+random(-curvy,curvy), y+random(-curvy,curvy), x, y);
  }
}

