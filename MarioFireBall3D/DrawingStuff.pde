////////////////////////////////////
//
// BASE 2D RENDERER (RECTANGLES AND TEXTURES)
//
//
  PGraphicsOpenGL renderer;
  
  // simple, no texture
  void renderRectFromVectors(PVector p1, PVector p2, int widthPadding)
  {
    renderRectFromVectors(p1, p2, widthPadding, 0, null, false);
  }


  // simple, with texture
  void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, PImage tex )
  {
    renderRectFromVectors(p1, p2, widthPadding, 0, tex, false);
  }

  // simple, with texture
  void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, PImage tex, boolean reversed )
  {
    renderRectFromVectors(p1, p2, widthPadding, 0, tex, reversed);
  }


  // no texture
  void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding)
  {
    renderRectFromVectors(p1, p2, widthPadding, lengthPadding, null, false);
  }

  // no reverse
  void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding, PImage tex)
  {
    renderRectFromVectors(p1, p2, widthPadding, lengthPadding, tex, false);
  }


  //
  // this draws a textured rectangle between two points with an absolute width and height in pixels,
  // optionally reversed in x direction
  //

  void renderRectFromVectors(PVector p1, PVector p2, int widthPadding, int lengthPadding, PImage tex, boolean reversed)
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

    //renderer.ellipse(xCenter, yCenter, 10, 10);  

    renderer.pushMatrix();

    // rotations are at 0,0 by default, but we want to rotate around the center
    // of this shape
    renderer.translate(xCenter, yCenter);
    //ellipse(0, 0, 20, 20);

    // rotate
    renderer.rotate(angle);

    // center screen
    renderer.translate( -h*0.5f, -widthPadding/2);

    renderRect(h, widthPadding, p1.z, p2.z, tex, reversed);

    renderer.popMatrix();

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


  void renderRectFromVectors(PVector p1, PVector p2, float padSidePercent)
  {
    renderRectFromVectors(p1, p2, padSidePercent, 0.0, null, false);
  }

  void renderRectFromVectors(PVector p1, PVector p2, float padSidePercent, boolean reversed)
  {
    renderRectFromVectors(p1, p2, padSidePercent, 0.0, null, reversed);
  }

  // simple, no texture
  void renderRectFromVectors(PVector p1, PVector p2, float padSidePercent, PImage tex)
  {
    renderRectFromVectors(p1, p2, padSidePercent, 0, tex, false);
  }

  void renderRectFromVectors(PVector p1, PVector p2, float padSidePercent, PImage tex, boolean reversed)
  {
    renderRectFromVectors(p1, p2, padSidePercent, 0.0, tex, reversed);
  }


  void renderRectFromVectors(PVector p1, PVector p2, float padSidePercent, float padEndPercent)
  {
    renderRectFromVectors(p1, p2, padSidePercent, padEndPercent, null, false);
  }


  void renderRectFromVectors(PVector p1, PVector p2, float padW, float padH, PImage tex)
  {
    renderRectFromVectors( p1, p2, padW, padW, padH, padH, tex, false);
  }


  void renderRectFromVectors(PVector p1, PVector p2, float padW, float padH, PImage tex, boolean reversed)
  {
    renderRectFromVectors( p1, p2, padW, padW, padH, padH, tex, reversed);
  }


  void renderRectFromVectors(PVector p1, PVector p2, float padLeft, float padRight, float padTop, float padBottom, PImage tex)
  {
    renderRectFromVectors( p1, p2, padLeft, padRight, padTop, padBottom, tex, false);
  }

  void renderRectFromVectors(PVector p1, PVector p2, float padLeft, float padRight, float padTop, float padBottom, PImage tex, boolean reversed)
  {
    // rotate the screen the angle btw the two vectors and then draw it rightside-up
    float angle = atan2(p2.y-p1.y, p2.x-p1.x);

    float w2 =  (p1.x - p2.x)*0.5f;
    float h2 =  (p1.y - p2.y)*0.5f;
    float xCenter = p1.x - w2;
    float yCenter = p1.y - h2;

    // height of the shape
    //float xdiff = p1.x-p2.x;
    //float ydiff = p1.y-p2.y;
    //float h = sqrt( xdiff*xdiff + ydiff*ydiff);
    float h = p1.dist(p2);

    float widthPadding = h*(padLeft+padRight);

    float totalHeight =  h + h*(padTop+padBottom);

    // save drawing state
    renderer.pushMatrix();

    // rotations are at 0,0 by default, but we want to rotate around the center
    // of this shape

    renderer.translate(xCenter, yCenter);
    //renderer.ellipse(0, 0, 20, 20);

    // rotate
    renderer.rotate(angle);

    // center screen
    renderer.translate(-h*padTop-h*0.5f, -padLeft*h);

    renderRect(totalHeight, widthPadding, p1.z, p2.z, tex, reversed);

    renderer.popMatrix();
  }


  void renderRect(float w, float h, PImage tex)
  {
    renderRect(w, h, tex, false);
  }




  void renderRect(float w, float h, PImage tex, boolean reversed)
  {
    renderer.textureMode(NORMALIZED);
    int r = reversed ? 1 : 0;

    // now draw rightside up
    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(0, 0, 1-r, 0);
      renderer.vertex(w, 0, 1-r, 1);
      renderer.vertex(w, h, r-0, 1);

      renderer.vertex(w, h, r-0, 1);
      renderer.vertex(0, h, r-0, 0);
      renderer.vertex(0, 0, 1-r, 0);
    }
    else
    {
      renderer.vertex(0, 0);
      renderer.vertex(w, 0);
      renderer.vertex(w, h);

      renderer.vertex(w, h);
      renderer.vertex(0, h);
      renderer.vertex(0, 0);
    }
    renderer.endShape(CLOSE);
  }



  void renderRect(float w, float h, float d1, float d2, PImage tex, boolean reversed)
  {
    int r = reversed ? 1 : 0;

    renderer.textureMode(NORMALIZED);

    // now draw rightside up
    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(0, 0, d1, 1-r, 0);
      renderer.vertex(w, 0, d1, 1-r, 1);
      renderer.vertex(w, h, d2, r-0, 1);

      renderer.vertex(w, h, d2, r-0, 1);
      renderer.vertex(0, h, d2, r-0, 0);
      renderer.vertex(0, 0, d1, 1-r, 0);
    }
    else
    {
      renderer.vertex(0, 0);
      renderer.vertex(w, 0);
      renderer.vertex(w, h);

      renderer.vertex(w, h);
      renderer.vertex(0, h);
      renderer.vertex(0, 0);
    }
    renderer.endShape(CLOSE);
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
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, float padX, float padY, PImage tex, boolean reversed)
  {
    float pX1 = padX*(p2.x-p1.x);
    float pX2 = padX*(p3.x-p4.x);

    float pY1 = padY*(p4.y-p1.y);
    float pY2 = padY*(p3.y-p2.y);

    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(p1.x-pX1, p1.y-pY1, 0, 0);
      renderer.vertex(p2.x+pX1, p2.y-pY2, 100, 0);
      renderer.vertex(p3.x+pX2, p3.y+pY1, 100, 100);

      renderer.vertex(p3.x+pX2, p3.y+pY1, 100, 100);
      renderer.vertex(p4.x-pX2, p4.y+pY2, 0, 100);
      renderer.vertex(p1.x-pX1, p1.y-pY1, 0, 0);
    }
    else
    {
      renderer.vertex(p1.x-pX1, p1.y-pY1);
      renderer.vertex(p2.x+pX1, p2.y-pY2);
      renderer.vertex(p3.x+pX2, p3.y+pY1);

      renderer.vertex(p3.x+pX2, p3.y+pY1);
      renderer.vertex(p4.x-pX2, p4.y+pY2);
      renderer.vertex(p1.x-pX1, p1.y-pY1);
    }
    renderer.endShape();
  }


  //
  // Render a clockwise list of vectors as a (optionally) textured rectangle with padding  
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, float padL, float padR, float padT, float padB, PImage tex, boolean reversed)
  {
    float WT = p2.x-p1.x;
    float WB = p3.x-p4.x;

    float padWidthLT = padL*WT;
    float padWidthLB = padL*WB;

    float padWidthRT = padR*WT;
    float padWidthRB = padR*WB;


    float HL = p4.y-p1.y;
    float HR = p3.y-p2.y;

    float padHeightTL = padT*HL;
    float padHeightTR = padT*HR;

    float padHeightBL = padB*HL;
    float padHeightBR = padB*HR;

    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL, p1.z, 0, 0);
      renderer.vertex(p2.x+padWidthRT, p2.y-padHeightTR, p2.z, 100, 0);
      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR, p3.z, 100, 100);

      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR, p3.z, 100, 100);
      renderer.vertex(p4.x-padWidthLB, p4.y+padHeightBL, p4.z, 0, 100);
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL, p1.z, 0, 0);
    }
    else
    {
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL);
      renderer.vertex(p2.x+padWidthRT, p2.y-padHeightTR);
      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR);

      renderer.vertex(p3.x+padWidthRB, p3.y+padHeightBR);
      renderer.vertex(p4.x-padWidthLB, p4.y+padHeightBL);
      renderer.vertex(p1.x-padWidthLT, p1.y-padHeightTL);
    }
    renderer.endShape();
  }


  //
  // Render a clockwise list of vectors as a rectangle with padding
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padX, int padY)
  {
    renderRectFromVectors( p1, p2, p3, p4, padX, padY, null);
  }

  //
  // Render a clockwise list of vectors as an (optionally) textured rectangle with padding
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padX, int padY, PImage tex)
  {
    renderRectFromVectors( p1, p2, p3, p4, padX, padX, padY, padY, tex, false);
  }

  //
  // ignores reversed for now
  //
  void renderRectFromVectors(PVector p1, PVector p2, PVector p3, PVector p4, int padXLeft, int padXRight, int padYTop, int padYBottom, PImage tex, boolean reversed)
  {

    float pX1 = padXLeft;
    float pX2 = padXRight;

    float pY1 = padYTop;
    float pY2 = padYBottom;

    renderer.beginShape(TRIANGLES);
    if (tex != null)
    {
      renderer.noStroke();
      renderer.texture(tex);    
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z, 0, 0);
      renderer.vertex(p2.x+pX1, p2.y-pY1, p2.z, 100, 0);
      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z, 100, 100);

      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z, 100, 100);
      renderer.vertex(p4.x-pX2, p4.y+pY2, p4.z, 0, 100);
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z, 0, 0);
    }
    else
    {
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z);
      renderer.vertex(p2.x+pX1, p2.y-pY1, p2.z);
      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z);

      renderer.vertex(p3.x+pX2, p3.y+pY2, p3.z);
      renderer.vertex(p4.x-pX2, p4.y+pY2, p4.z);
      renderer.vertex(p1.x-pX1, p1.y-pY1, p1.z);
    }
    renderer.endShape();
  }

  // end class BodyPartRenderer


