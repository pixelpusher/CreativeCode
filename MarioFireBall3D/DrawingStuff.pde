/*
// no texture, draw rectangle EXACTLY between vectors at a certain width
 void renderRectFromVectors(PVector p1, PVector p2, int widthPadding);
 
 // simple, with texture
 void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, PImage tex )
 
 // no texture, with some padding in each direction
 void renderRectFromVectors(PVector p1, PVector p2, int lengthPadding, int widthPadding);
 
 // no reverse
 void renderRectFromVectors(PVector p1, PVector p2,  int widthPadding, int lengthPadding, PImage tex);
 
 // this draws a textured rectangle between two points with an absolute width and height in pixels,
 // optionally reversed in x direction
 void renderRectFromVectors(PVector p1, PVector p2,  int widthPadding, int lengthPadding, PImage tex, int reversed);
 
 
 // this draws a textured rectangle between two points with an *relative* width and height in pixels   
 void renderRectFromVectors(PVector p1, PVector p2, float padEndPercent, float padSidePercent, PImage tex);
 
 // untextured rectagle between 4 points 
 void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4);
 
 // textured rectangle between 4 points
 void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, PImage tex);
 
 // Render a clockwise list of vectors as a (optionally) textured rectangle with padding
 void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padX, int padY, PImage tex);
 */




// simple, no texture
void renderRectFromVectors(PVector p1, PVector p2, int widthPadding)
{
  renderRectFromVectors(p1, p2, widthPadding, 0, null, 0);
}

// simple, with texture
void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, PImage tex )
{
  renderRectFromVectors(p1, p2, widthPadding, 0, tex, 0);
}


// no texture
void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding)
{
  renderRectFromVectors(p1, p2, widthPadding, lengthPadding, null, 0);
}

// no reverse
void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding, PImage tex)
{
  renderRectFromVectors(p1, p2, widthPadding, lengthPadding, tex, 0);
}


//
// this draws a textured rectangle between two points with an absolute width and height in pixels,
// optionally reversed in x direction
//

void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding, PImage tex, int reversed)
{
  // rotate the screen the angle btw the two vectors and then draw it rightside-up
  float angle = atan2(p2.y-p1.y, p2.x-p1.x);
  float xdiff = p1.x-p2.x;
  float ydiff = p1.y-p2.y;

  float w2 =  (p1.x - p2.x)*0.5f;
  float h2 =  (p1.y - p2.y)*0.5f;
  float xCenter = p1.x - w2;
  float yCenter = p1.y - h2;

  // height of the shape
  float h = sqrt( xdiff*xdiff + ydiff*ydiff) + lengthPadding*2.0f;

  //ellipse(xCenter, yCenter, 10, 10);  

  pushMatrix();

  // rotations are at 0,0 by default, but we want to rotate around the center
  // of this shape
  translate(xCenter, yCenter);
  //ellipse(0, 0, 20, 20);

  // rotate
  rotate(angle);

  // center screen
  translate( -h*0.5f, -widthPadding/2);

  renderRect(h, widthPadding, tex, reversed);

  popMatrix();

  // another way to do it...  
  // center screen
  //  translate( -h*0.5f, widthPadding);
  //
  //  rotate(-HALF_PI);
  //  tex.render(0,0,widthPadding*2.0f,h);
  //  popMatrix();


  // for debugging...
  //  stroke(0);
  //  strokeWeight(1.0);  
  //  fill(0, 60);
  //  ellipse(p1.x, p1.y, 10, 10);
  //  ellipse(p2.x, p2.y, 10, 10);
}


//
// this draws a textured rectangle between two points with an *relative* width and height in pixels   
//

void renderRectFromVectors(PVector p1, PVector p2, float padEndPercent, float padSidePercent, PImage tex)
{
  renderRectFromVectors(p1, p2, padEndPercent, padSidePercent, tex, 0);
}


void renderRectFromVectors(PVector p1, PVector p2, float padEndPercent, float padSidePercent, PImage tex, int reversed)
{
  // rotate the screen the angle btw the two vectors and then draw it rightside-up
  float angle = atan2(p2.y-p1.y, p2.x-p1.x);

  float xdiff = p1.x-p2.x;
  float ydiff = p1.y-p2.y;

  float w2 =  (p1.x - p2.x)*0.5f;
  float h2 =  (p1.y - p2.y)*0.5f;
  float xCenter = p1.x - w2;
  float yCenter = p1.y - h2;

  // height of the shape
  float h = sqrt( xdiff*xdiff + ydiff*ydiff);
  float widthPadding = h*padSidePercent;

  h +=  h*padEndPercent*2.0f;

  // save drawing state
  pushMatrix();

  // rotations are at 0,0 by default, but we want to rotate around the center
  // of this shape
  translate(xCenter, yCenter);
  //ellipse(0, 0, 20, 20);

  // rotate
  rotate(angle);

  // center screen
  translate( -h*0.5f, -widthPadding/2);

  renderRect(h, widthPadding, tex, reversed);

  popMatrix();
}



void renderRect(float w, float h, PImage tex)
{
  renderRect(w, h, tex, 0);
}




void renderRect(float w, float h, PImage tex, int reversed)
{
  textureMode(NORMALIZED);

  // now draw rightside up
  beginShape(TRIANGLES);
  if (tex != null)
  {
    texture(tex);
    vertex(0, 0, 1-reversed, 0);
    vertex(w, 0, 1-reversed, 1);
    vertex(w, h, reversed-0, 1);

    vertex(w, h, reversed-0, 1);
    vertex(0, h, reversed-0, 0);
    vertex(0, 0, 1-reversed, 0);
  }
  else
  {
    vertex(0, 0);
    vertex(w, 0);
    vertex(w, h);

    vertex(w, h);
    vertex(0, h);
    vertex(0, 0);
  }
  endShape(CLOSE);
}



// untextured rectagle between 4 points 
void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4)
{
  renderRectFromVectors( p1, p2, p3, p4, 0, 0, null);
}


// textured rectangle between 4 points
void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, PImage tex)
{
  renderRectFromVectors( p1, p2, p3, p4, 0, 0, tex);
}


//
// Render a clockwise list of vectors as a (optionally) textured rectangle with padding  
//
void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, float padX, float padY, PImage tex)
{
  float pX1 = padX*(p2.x-p1.x);
  float pX2 = padX*(p3.x-p4.x);

  float pY1 = padY*(p4.y-p1.y);
  float pY2 = padY*(p3.y-p2.y);

  beginShape(TRIANGLES);
  if (tex != null)
  {
    texture(tex);
    vertex(p1.x-pX1, p1.y-pY1, 0, 0);
    vertex(p2.x+pX1, p2.y-pY2, 100, 0);
    vertex(p3.x+pX2, p3.y+pY1, 100, 100);

    vertex(p3.x+pX2, p3.y+pY1, 100, 100);
    vertex(p4.x-pX2, p4.y+pY2, 0, 100);
    vertex(p1.x-pX1, p1.y-pY1, 0, 0);
  }
  else
  {
    vertex(p1.x-pX1, p1.y-pY1);
    vertex(p2.x+pX1, p2.y-pY2);
    vertex(p3.x+pX2, p3.y+pY1);

    vertex(p3.x+pX2, p3.y+pY1);
    vertex(p4.x-pX2, p4.y+pY2);
    vertex(p1.x-pX1, p1.y-pY1);
  }
  endShape();
}

//
// Render a clockwise list of vectors as a (optionally) textured rectangle with padding
//
void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padX, int padY, PImage tex)
{
  float pX1 = padX;
  float pX2 = padX;

  float pY1 = padY;
  float pY2 = padY;

  beginShape(TRIANGLES);
  if (tex != null)
  {
    texture(tex);    
    vertex(p1.x-pX1, p1.y-pY1, 0, 0);
    vertex(p2.x+pX1, p2.y-pY1, 100, 0);
    vertex(p3.x+pX2, p3.y+pY2, 100, 100);

    vertex(p3.x+pX2, p3.y+pY2, 100, 100);
    vertex(p4.x-pX2, p4.y+pY2, 0, 100);
    vertex(p1.x-pX1, p1.y-pY1, 0, 0);
  }
  else
  {
    vertex(p1.x-pX1, p1.y-pY1);
    vertex(p2.x+pX1, p2.y-pY1);
    vertex(p3.x+pX2, p3.y+pY2);

    vertex(p3.x+pX2, p3.y+pY2);
    vertex(p4.x-pX2, p4.y+pY2);
    vertex(p1.x-pX1, p1.y-pY1);
  }
  endShape();
}

