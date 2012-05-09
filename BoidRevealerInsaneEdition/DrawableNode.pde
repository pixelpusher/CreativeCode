class DrawableNode 
{
  //internal variables ///////

  // bounding box
  float maxX, minX;
  float maxY, minY;

  float w;
  float h;

  float frictionCoeff = 0.95f;
  static final float MIN_VELOCITY = 0.1f;

  // movement variables
  boolean moving;

  Vec2D pos;        // position  
  Vec2D prevPos;    // previous position, for hit testing

  Vec2D vel;        // velocity
  Vec2D accel;      // acceleration

  float rotation;  // z rotation, clockwise in radians
  float rotationSpeed;  // z rotation speed per frame, clockwise in radians

  // drawing variables
  boolean hasStroke = false;
  color strokeColor = color(0);
  boolean hasFill = true;
  color fillColor = color(255);

  boolean wrap = true; // for screen wrap

  HashMap<String, Object> data = null;  // in case you need some custom data storage...

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

    rotationSpeed = 0f;

    updateBoundingBox();
  }


  DrawableNode(float _x, float _y, float _w, float _h)
  {
    pos = new Vec2D(_x, _y);
    prevPos = new Vec2D(_x, _y);

    vel = new Vec2D();
    accel = new Vec2D();

    w = _w;
    h = _h;

    updateBoundingBox();

    data = new HashMap<String, Object>();
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


  void accelerate(Vec2D a)
  {
    accel.addSelf(a);
    moving = true;
  }


  void updateBoundingBox()
  {
    minX = pos.x;
    maxX = pos.x + w;

    minY = pos.y;
    maxY = pos.y + h;
  }


  Vec2D middle()
  {
    return (new Vec2D(pos.x+w/2, pos.y+h/2));
  }



  void putData(String key, Object val)
  {
    data.put(key, val);
  }

  Object getData(String key)
  {
    return data.get(key);
  }


  /// update  ///////////////////////////////////////////
  //////////////////////////////////////////////////////

  void update()
  {

    rotation += rotationSpeed;

    if (moving)
    {

      prevPos.set(pos);
      // apply acceleration
      vel.addSelf(accel);
      pos.addSelf(vel);

      if (wrap)
      {
        if (pos.x < 0) setX(width-w-1);
        if (pos.x > width) setX(0);
        if (pos.y < 0) setY(height-h-1);
        if (pos.y > height) setY(0);
      }

      updateBoundingBox();

      // apply drag
      vel.scaleSelf(frictionCoeff);
      // clear acceleration
      accel.set(0, 0);

      if (vel.magnitude() < MIN_VELOCITY) 
      {
        vel.x = vel.y = 0f;
        moving = false;

        // do something?
        finishedMoving();
      }
    }
  }


  /// moveTo /////////////////////////////////////////////
  //////////////////////////////////////////////////////

  void moveTo(float x, float y)
  {
    prevPos.set(pos);
    pos.set(x, y);

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
    if (rotationSpeed == 0f)
    {
      renderer.rectMode(CORNERS);
      renderer.rect(minX, minY, maxX, maxY);
    }
    else
    {
      Vec2D m = middle();
      renderer.translate(m.x, m.y);
      renderer.rectMode(CENTER);
      renderer.rotate(rotation);
      renderer.rect(0, 0, w, h);
    }
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


  void unload()
  {
  }

  void finishedMoving()
  {
  }


  // end class DrawableNode
}

