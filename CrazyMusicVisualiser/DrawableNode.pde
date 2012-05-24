class DrawableNode 
{
  //internal variables ///////

  // a very small numnber
  final float epsilon = 1E-4;
  float minVelocity = 0.2f;

  // has this been hit?

  boolean hasCollided = false;
  boolean moving = false;
  boolean movable = true;

  // bounding box
  float maxX, minX;
  float maxY, minY;

  float w;
  float h;

  float frictionCoeff = 0.95;

  // movement variables
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

  boolean wrap;

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

    data = new HashMap<String, Object>();

    updateBoundingBox();
  }


  DrawableNode(float _x, float _y, float _w, float _h)
  {
    pos = new Vec2D(_x, _y);
    prevPos = new Vec2D(_x, _y);

    vel = new Vec2D();
    accel = new Vec2D();

    rotationSpeed = 0f;

    data = new HashMap<String, Object>();

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

  void accelerate(Vec2D a)
  {
    accel.addSelf(a);
    moving = true;
  }

  Vec2D middle()
  {
    return (new Vec2D(pos.x+w/2, pos.y+h/2));
  }

  void finishedMoving()
  {
    // not much!
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

    if (abs(rotationSpeed) > EPSILON)
    {
      rotation += rotationSpeed;
    }
    else
      rotationSpeed = 0f;

    if (moving)
    {
      // apply acceleration
      vel.addSelf(accel);

      pos.addSelf(vel);
      prevPos.set(pos);
      updateBoundingBox();

      // apply drag
      vel.scaleSelf(frictionCoeff);
      // clear acceleration
      accel.set(0, 0);

      if (vel.magnitude() < minVelocity) 
      {
        vel.x = vel.y = 0f;
        moving = false;

        // do something?
        finishedMoving();
      }

      if (wrap)
      {
        if (pos.x < 0) setX(width-w-1);
        if (pos.x > width) setX(0);
        if (pos.y < 0) setY(height-h-1);
        if (pos.y > height) setY(0);
      }
    }
  }


  /// moveTo /////////////////////////////////////////////
  //////////////////////////////////////////////////////

  void moveTo(float x, float y)
  {
    pos.set(x, y);
    prevPos.set(pos);
    updateBoundingBox();
  }


  void move(float x, float y)
  {
    pos.addSelf(x, y);
    prevPos.set(pos);

    updateBoundingBox();
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


  boolean pointInside(float x, float y)
  {
    if (x < minX || x > maxX) return false;
    if (y < minY || y > maxY) return false;

    return true;
  }


  void unload()
  {
    data.clear();
  }

  // end class DrawableNode
}

