import processing.opengl.*;

// gradient
// make a Cornsweet illusion!
// by Evan Raskob 2012

color baseColor = color(128, 255); //med gray
color darkColor = color(80, 255);
color lightColor = color(200, 255);

void setup()
{
  size(540, 360, OPENGL);
  //noLoop();
}


void draw()
{
  float padding = 0.1;
//  float endPercent = 0.1;

  float endPercent = map(mouseX,0,width,0,1);

  float yPadding = height*2*padding;

  float shapeWidth = (width-2*padding*width)/2;
  float baseColorWidth = shapeWidth*(1f-endPercent);
  float shapeHeight = height-yPadding;

  background(255); 
  
  pushMatrix();
  
  // apply padding
  translate(width*padding, height*padding);
  noStroke();
  beginShape();

  fill( baseColor );
  vertex(0, 0);

  fill(baseColor);
  vertex(baseColorWidth, 0);

  fill(darkColor);
  vertex(shapeWidth, 0);

  fill(darkColor);
  vertex(shapeWidth, shapeHeight);

  fill(baseColor);
  vertex(baseColorWidth, shapeHeight);

  fill( baseColor );
  vertex(0, shapeHeight);

  endShape(CLOSE);
  

  // now draw right side
  
    // apply padding
  translate(shapeWidth, 0);
  noStroke();
  beginShape();

  fill( lightColor );
  vertex(0, 0);

  fill(baseColor);
  vertex(shapeWidth-baseColorWidth, 0);

  fill(baseColor);
  vertex(shapeWidth, 0);

  fill(baseColor);
  vertex(shapeWidth, shapeHeight);

  fill(baseColor);
  vertex(shapeWidth-baseColorWidth, shapeHeight);

  fill( lightColor );
  vertex(0, shapeHeight);

  endShape(CLOSE);
  popMatrix();

  float[] brights = calculateBrightness();
  
  stroke(0);
  strokeWeight(1);
  for (int i=0; i < width; i++)
  {
    float h = height - yPadding*0.25*brights[i];
    //println(h);
    point( i, h);
  } 
    

  if (keyPressed)
  {
    saveFrame("Cornsweet-"+endPercent+".png");
  }
}


float[] calculateBrightness()
{
  loadPixels();
  // use the middle of the screen
  float[] pixelBrights = new float[width];
  for (int i=0; i<width; ++i)
  {
    pixelBrights[i] = brightness( pixels[height/2*width+i]) / 255f ;
  }
  return pixelBrights;
}

