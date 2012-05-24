// COLLISION DETECTION FUNCTIONS   
// -------------------------------------



static class Collider
{

  // Find the closest point (x,y) to a piece of a line, and return it.

  static final Vec2D closestPointToLine(Vec2D l0, Vec2D l1, Vec2D p)
  {
    Vec2D direction = l1.sub(l0);
    Vec2D w = p.sub(l0);
    float proj = w.dot(direction);

    if (proj <= 0)
      return l0;
    else
    {
      float vsq = direction.dot(direction);
      if (proj >= vsq)
        return l0.add(direction);
      else
        return l0.add( direction.scaleSelf(proj/vsq));
    }
  }


  // Find the shortest possible distance between a point and a line.

  static final float distancePointToLine(Vec2D l0, Vec2D l1, Vec2D p)
  {
    Vec2D direction = l1.sub(l0);
    Vec2D w = p.sub(l0);
    float proj = w.dot(direction);

    if (proj <= 0)
      return w.dot(w);
    else
    {
      float vsq = direction.dot(direction);
      if (proj >= vsq)
        return w.dot(w) - 2.0f*proj+vsq;
      else
        return w.dot(w) - proj*proj/vsq;
    }
  }


  // collide two rectangles

  static void collide(DrawableNode n0, DrawableNode n1)
  {
 
    n0.accel.set(0, 0);    
    n1.accel.set(0, 0);

    // impart some acceleration
    if (n0.movable)
    {
      n0.accelerate(n1.vel.scale(n1.hardness));
      // fixme!
      if (n0 instanceof AnimatedImageNode) ((AnimatedImageNode)n0).start();
    }
    if (n1.movable)
    {
      n1.accelerate(n0.vel.scale(n0.hardness));
      // fixme!
      if (n1 instanceof AnimatedImageNode) ((AnimatedImageNode)n0).start();
    }


    int collisionSide = 0;  
    // left = 0
    // right = 1
    // top = 2
    // bottom = 3

    float min_dist = MAX_FLOAT;  // something really small   

    // handle collisions in X axis
    if (!(n0.minY > n1.maxY || n1.minY > n0.maxY))
    {
      // top      
      if (n0.maxY > n1.minY)
      {
        float top_min_dist = n0.maxY - n1.minY;
        if (top_min_dist < min_dist)
        {
          collisionSide = 2;
          min_dist = top_min_dist;
        }
      }
      if (n0.maxY > n1.maxY)
      {
        float bot_min_dist = n1.maxY - n0.minY;
        if (bot_min_dist < min_dist)
        {
          collisionSide = 3;
          min_dist = bot_min_dist;
        }
      }
    }

    // handle collisions in y axis
    if (!(n0.minX > n1.maxX || n1.minX > n0.maxX))
    {
      // left

      if (n0.maxX > n1.minX)
      {
        float d = n0.maxX - n1.minX;

        if (d < min_dist)
        {
          min_dist = d;
          collisionSide = 0;
        }
      }
      if (n0.maxX > n1.maxX)
      {
        float right_min_dist = n1.maxX - n0.minX;
        if (right_min_dist < min_dist)
        {
          collisionSide = 1;
          min_dist = right_min_dist;
        }
      }
    }

    min_dist += 2f; // for rounding errors...

    switch (collisionSide)
    {
    case 0: // left
      if (verbose)  println("LEFT");
      float amountToMove = min_dist;

      if (n0.movable && n1.movable) amountToMove /= 2f;

      if (n0.movable)
      {
        n0.move(-amountToMove, 0);
        n0.vel.x = -n0.vel.x;
      }
      if (n1.movable)
      {
        n1.move(amountToMove, 0);
        n1.vel.x = -n1.vel.x;
      }
      break;

    case 1: // right
      if (verbose) println("RIGHT");
      amountToMove = min_dist;

      if (n0.movable && n1.movable)  amountToMove /= 2f;

      if (n0.movable)
      {
        n0.move(amountToMove, 0);
        n0.vel.x = -n0.vel.x;
      }
      if (n1.movable)
      {
        n1.move(-amountToMove, 0);             
        n1.vel.x = -n1.vel.x;
      }
      break;

    case 2: // top
      if (verbose)  println("TOP");
      amountToMove = min_dist;
      if (n0.movable)
      {
        if (n1.movable)
          amountToMove /= 2f;
        n0.move(0, -amountToMove);
        n0.vel.y = -n0.vel.y;
      }
      if (n1.movable)
      {
        n1.move(0, amountToMove);
        n1.vel.y = -n1.vel.y;
      }
      break;

    case 3: // bottom
      if (verbose) println("BOTTOM");

      amountToMove = min_dist;
      if (n0.movable)
      {
        if (n1.movable)
          amountToMove /= 2f;
        n0.move(0, amountToMove);
        n0.vel.y = -n0.vel.y;
      }
      if (n1.movable)
      {
        n1.move(0, -amountToMove);
        n1.vel.y = -n1.vel.y;
      }
      break;
    }
  }

  // end class Collider
}

