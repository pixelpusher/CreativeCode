//
// NOTE - YOU MUST HAVE AT LEAST A 1px BUFFER BETWEEN FRAMES OTHERWISE IT
// PICKS UP AN EXTRA FRAME


class AnimatedImageNode extends DrawableNode
{
  // This is the sprite sheet
  PImage img = null;

  private PImage currentSprite = null; // current frame to be drawn

  // rows and columns in the sprite sheet
  int rows = 1;
  int cols = 1;

  //current index in the sprite sheet (from 0 to Max # sprites - 1)
  int spriteIndex = 0;

  int msPerFrame = 1000 / 10;  // at 10 fps, in 1000ms (1 sec) we've shown 10 frames 
  int lastFrameTime = 0;  // last time we drew a frame, in ms 

  boolean forwards = true;  // forwards or backwards?
  boolean flipped = false; // reverse drawing this in the x direction

  boolean animating = true;

  // these are animation variables
  private int imgW;
  private int imgH;
  private int imgX;
  private int imgY;

  //////////////////////////////////////////////////////  
  /// Constructors /////////////////////////////////////
  //////////////////////////////////////////////////////

  AnimatedImageNode()  // default
  {
    super();
    hasFill = hasStroke = false;
  }

  AnimatedImageNode(float _x, float _y, float _w, float _h)
  {
    super( _x, _y, _w, _h);
    hasFill = hasStroke = false;
  }

  AnimatedImageNode(PImage newImg, float _x, float _y)
  {
    super( _x, _y, newImg.width, newImg.height);
    setImage(newImg);
    hasFill = hasStroke = false;
  }

  AnimatedImageNode(PImage newImg, float _x, float _y, float _w, float _h)
  {
    super( _x, _y, _w, _h);
    setImage(newImg);
    hasFill = hasStroke = false;
  }

  AnimatedImageNode(PImage newImg, float _x, float _y, float _w, float _h, int _cols, int _rows)
  {
    super( _x, _y, _w, _h);
    rows = _rows;
    cols = _cols;
    setImage(newImg);
    hasFill = hasStroke = false;
  }
  //////////////////////////////////////////////////////  
  /// End Constructors /////////////////////////////////
  //////////////////////////////////////////////////////


  void setImage(PImage newImg)
  {
    img = newImg;

    spriteIndex = 0;
    lastFrameTime = millis();  // update current time

    imgW = img.width/cols ;
    imgH = img.height/rows;

    // update the image of the current sprite
    updateCurrentSprite();
  }

  void setImage(PImage newImg, int _w, int _h)
  { 
    setW(_w);
    setH(_h);

    setImage(newImg);
  }


  void setImage(PImage newImg, int _w, int _h, int _rows, int _cols)
  {
    rows = _rows;
    cols = _cols;

    setImage(newImg, _w/_rows, _h/_cols);
  }


  void setRowsCols(int _rows, int _cols)
  {
    rows = _rows;
    cols = _cols;

    updateCurrentSprite();
  }


  void stop()
  {
    animating  = false;
  }

  void start()
  {
    animating  = true;
  }


  void animate()
  {
    if (!animating)
      lastFrameTime = millis();  // update current time
    animating  = true;
  }

  // ovverides DrawableNode's version
  void finishedMoving()
  {
    //println("stopped!");
    stop();
  }


  /// updateCurrentSprite  /////////////////////////////
  //////////////////////////////////////////////////////

  // get the next sprite image in the series

  void updateCurrentSprite()
  {
    int currentCol = spriteIndex % cols;
    int currentRow = spriteIndex/cols;
    
    imgX = currentCol*imgW; 
      //println("x=" +imgX);
    imgY = currentRow*imgH;
  }


  /// update  ///////////////////////////////////////////
  //////////////////////////////////////////////////////

  void update()
  {

    if (animating)
    {
      // animate - update currentFrameTime
      // move to next index

      // has enough time elapsed that we need to go to the next frame?
      int currentTime = millis();
      int timeDiff = currentTime-lastFrameTime;  // difference in time

        // how many frames do we jump?
      int framesToJump = timeDiff/msPerFrame;


      if (framesToJump > 0)
      {
        // println("frame to jump: " +       framesToJump);

        // for smooth animation, should also account for extra time elapsed...
        lastFrameTime = lastFrameTime + framesToJump*msPerFrame;

        // println("last frame time: " + lastFrameTime);


        if (forwards)
        {
          // increase current frame index by 1
          spriteIndex = (spriteIndex+framesToJump) % (rows*cols);
        } 
        else 
        {
          spriteIndex = spriteIndex-framesToJump;

          if (spriteIndex < 0) 
          {
            spriteIndex = (-spriteIndex) % (rows*cols);

            spriteIndex = rows*cols - spriteIndex;
          }
        }

        // println("sprite index: " + spriteIndex + " / " + rows*cols);

        // update the image of the current sprite
        updateCurrentSprite();
      }
    }

    // call normal DrawableNode update() to handle movement
    super.update();  

    ////////////////////////////////////////////
    // handle accelerating in opposite direction
    if (vel.x > 0) flipped = true;
    else if (vel.x < 0) flipped = false;
  }


  //////////////////////////////////////////////////////  
  /// draw /////////////////////////////////////////////
  //////////////////////////////////////////////////////


  void draw(PGraphics renderer)
  {
    // fill, or tint in this case
    if (hasFill) 
    {
      renderer.tint(fillColor);
    } 

    else {
      renderer.noTint();
      renderer.noFill();
    }

    // stroke
    if (hasStroke) 
    {
      renderer.stroke(strokeColor);
    } 
    else 
    {
      renderer.noStroke();
    }


    //imgX, imgY, imgW, imgH

    //  1 *---* 2
    //    |   |
    //  4 *---* 3 
    renderer.textureMode(IMAGE);
    renderer.beginShape();
    renderer.texture( img );
    renderer.vertex(pos.x, pos.y, imgX, imgY);
    
    // subtract 1px from width because of Processing bug?
    renderer.vertex(pos.x+w, pos.y, imgX+imgW-1, imgY);
    renderer.vertex(pos.x+w, pos.y+h, imgX+imgW-1, imgY+imgH);
    renderer.vertex(pos.x, pos.y+h, imgX, imgY+imgH);
    renderer.endShape();
  }


  void unload()
  {
    img = null;
    currentSprite = null;
  }

  // end class
}

