void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding)
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

  renderRect(h, widthPadding);

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


void renderRect(float w, float h)
{

  // now draw rightside up
  beginShape(TRIANGLES);
    vertex(0, 0);
    vertex(w, 0);
    vertex(w, h);

    vertex(w, h);
    vertex(0, h);
    vertex(0, 0);
  endShape(CLOSE);
}


