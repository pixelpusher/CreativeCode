class DrawableNode 
{
   //internal variables ///////
      
   // bounding box
   float maxX, minX;
   float maxY, minY;
   
   float w;
   float h;
   
   // movement variables
   Vec2D pos;        // position  
   Vec2D prevPos;    // previous position, for hit testing
   
   Vec2D vel;        // velocity
   Vec2D accel;      // acceleration
   
   // drawing variables
   boolean hasStroke = false;
   color strokeColor = color(0);
   boolean hasFill = true;
   color fillColor = color(255);
   
   boolean wrap = true; // for screen wrap


  /// Constructor //////////////////////////////////////
  //////////////////////////////////////////////////////
  
  // default:
  DrawableNode()
  {
    pos = new Vec2D();
    prevPos = new Vec2D();
    
    w = 20;
    h = 20;

    vel = new Vec2D();
    accel = new Vec2D();
    
    updateBoundingBox();
  }

  
  DrawableNode(float _x, float _y, float _w, float _h)
  {
    pos = new Vec2D(_x,_y);
    prevPos = new Vec2D(_x,_y);

    vel = new Vec2D();
    accel = new Vec2D();
    
    w = _w;
    h = _h;
    
    updateBoundingBox();
  }
    
  
  void setX(float _x)
  {
    pos.x = _x;
    minX = pos.x;
    maxX = pos.x + w;
  }
  
  void setY(float _y)
  {
    pos.y = _y;
    minY = pos.y;
    maxY = pos.y + h;
  }
  
  void setW(float _w)
  {
     w = _w;
     maxX = pos.x + w;
  }
  
  void setH(float _h)
  {
     h = _h;
     maxY = pos.y + h;
  }
  
  
  void updateBoundingBox()
  {
    minX = pos.x;
    maxX = pos.x + w;
    
    minY = pos.y;
    maxY = pos.y + h;
  }
  
  
  /// update  ///////////////////////////////////////////
  //////////////////////////////////////////////////////
  
  void update()
  {
    // apply acceleration
    vel.addSelf(accel);
    pos.addSelf(vel);
    
    if (wrap)
    {
      if(pos.x < 0) setX(width-w-1);
      if(pos.x > width) setX(0);
      if(pos.y < 0) setY(height-h-1);
      if(pos.y > height) setY(0);
    }
    
    updateBoundingBox();
    
    // apply drag
    vel.scaleSelf(0.95);
    // clear acceleration
    accel.set(0,0);
    
  }
  
  
  /// moveTo /////////////////////////////////////////////
  //////////////////////////////////////////////////////
  
  void moveTo(float x, float y)
  {
    pos.set(x,y);
    
    // update minX, maxX, etc
  }
  
  /// draw /////////////////////////////////////////////
  //////////////////////////////////////////////////////
  
  void draw(PGraphics renderer)
  {
    // stroke
    if (hasStroke) 
    {
      renderer.stroke(strokeColor);
    } 
    else 
    {
      renderer.noStroke();
    }
    // fill
    if (hasFill) 
    {
      renderer.fill(fillColor);
    } 
    else {
      renderer.noFill();
    }

    // you can change this in subclasses to make custom objects
    
    //rectMode(CORNER);
    //rect(pos.x, pos.y, w,h);
    
    renderer.rectMode(CORNERS);
    renderer.rect(minX, minY, maxX, maxY);
  }
  
  
  
  
  // simple rectangluar boundary hit test
  boolean intersects(DrawableNode other)
  {

    if (minX > other.maxX || other.minX > maxX)
      return false;
     
    if (minY > other.maxY || other.minY > maxY)
      return false;

    return true;
  }
  
  
// end class DrawableNode 
}
