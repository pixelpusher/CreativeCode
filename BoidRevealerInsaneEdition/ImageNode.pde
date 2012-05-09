class ImageNode extends DrawableNode
{
  PImage img = null;

  ImageNode()
  {
    super();
  }
  
  ImageNode(float _x, float _y, float _w, float _h)
  {
    super( _x,  _y,  _w,  _h);
  }
  

  ImageNode(PImage newImg, float _x, float _y, float _w, float _h)
  {
    super( _x,  _y,  _w,  _h);
    setImage(newImg);
  }
  
  ImageNode(PImage newImg, float _x, float _y)
  {
    super( _x,  _y,  newImg.width,  newImg.height);
    setImage(newImg);
  }


  void setImage(PImage newImg)
  {
    img = newImg;
  }


  void setImage(PImage newImg, boolean alterDims)
  {
    img = newImg;
    
    if (alterDims)
    {
      setW(img.width);
      setH(img.height);
    }
  }



  void draw(PGraphics renderer)
  {
    // fill, or tint in this case
    if (hasFill) 
    {
      renderer.tint(fillColor);
    } 
    else {
      renderer.noTint();
    }

 if (rotationSpeed == 0f)
    {
      renderer.imageMode(CORNERS);
      renderer.image(img,minX, minY, maxX, maxY);
    }
    else
    {
      renderer.pushMatrix();
      Vec2D m = middle();
      renderer.translate(m.x, m.y);
      renderer.imageMode(CENTER);
      renderer.rotate(rotation);
      renderer.image(img,0, 0, w, h);
      renderer.popMatrix();
    }
  }
  
  
  void unload()
  {
    img = null;
    super.unload();
  }
  
// end class
}



