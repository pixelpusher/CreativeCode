

// COLLISION DETECTION FUNCTIONS   
// -------------------------------------


// Find the closest point (x,y) to a piece of a line, and return it.

Vec2D closestPointToLine(Vec2D l0, Vec2D l1, Vec2D p)
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

float distancePointToLine(Vec2D l0, Vec2D l1, Vec2D p)
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




// "Bounces" a Ball object off of a rectangle, and returns the closest point.
// This could easily be generalised for a "MovingRectangle" class instead of
// a "Ball" class to get a simple rigid body dynamics system.

Vec2D bounceBallOffRectangle(DrawableNode ball, DrawableNode r)
{
  // First, find the boundary points for our rectangle.

  Vec2D pTopL = new Vec2D(r.minX,r.minY);
  Vec2D pTopR = new Vec2D(r.maxX,r.minY);
  Vec2D pBotL = new Vec2D(r.minX,r.maxY);
  Vec2D pBotR = new Vec2D(r.maxX, r.maxY);
  
  // The previous position of the ball.  At this point in time 
  // the ball is possibly intersecting the rectangle, so we look at
  // the previous position to find out the direction in which it 
  // was traveling as it hit the rectangle.
  Vec2D ballPrevPos =  new Vec2D(ball.prevPos.x,ball.prevPos.y);

  // For each border (line segment) of the rectangle, find the point that 
  // falls directly on the border that is closest to the previous ball
  // position: 
  Vec2D closestTopPoint = closestPointToLine(pTopL,pTopR,ballPrevPos);
  Vec2D closestBotPoint = closestPointToLine(pBotL,pBotR,ballPrevPos);
  Vec2D closestLeftPoint = closestPointToLine(pTopL,pBotL,ballPrevPos);
  Vec2D closestRightPoint = closestPointToLine(pTopR,pBotR,ballPrevPos);
  
  float dt, db, dl, dr;  // Distance to the points from prev ball pos

  // Find the distance between the previous ball position and the 
  // closest point on each border:
  dt = closestTopPoint.distanceToSquared(ballPrevPos);
  db = closestBotPoint.distanceToSquared(ballPrevPos);
  dl = closestLeftPoint.distanceToSquared(ballPrevPos);
  dr = closestRightPoint.distanceToSquared(ballPrevPos);

  // Go through all the closest points and find the closest of them,
  // which will tell us which side the ball (most likely) hit.
  // Then, based on which side the ball hit, change the ball's velocity
  // so it appears to have bounced (reflected) off that side.

  // There are better ways to do this, generally (such as calculating
  // the slope of the line that represents the rectangle's border
  // and then geometrically reflecting the velocity vector off it),
  // but this way works fine (and is a bit more straightforward).

  float bestDistance = dt;
  float newBallVx, newBallVy;

  Vec2D closestPoint =  closestTopPoint;
  ball.moveTo(closestPoint.x, closestPoint.y-ball.h-1);
  newBallVx = ball.vel.x;
  newBallVy = -ball.vel.y;
  //println("TOP");

  if (db < bestDistance)
  {
    closestPoint =  closestBotPoint;
    ball.moveTo(closestPoint.x,closestPoint.y+1);
    newBallVx = ball.vel.x;
    newBallVy = -ball.vel.y;
    //println("BOT");
  }
  else if (dl < bestDistance)
  {
    bestDistance = db;
    closestPoint =  closestLeftPoint;
    ball.moveTo(closestPoint.x-ball.w-1,closestPoint.y);
    newBallVx = -ball.vel.x;
    newBallVy = ball.vel.y;
    //println("LEFT");
  }
  else if (dr < bestDistance)
  {
    bestDistance = dr;
    closestPoint =  closestRightPoint;
    ball.moveTo(closestPoint.x,closestPoint.y+1);
    newBallVx = -ball.vel.x;
    newBallVy = ball.vel.y;
    //        println("RIGHT");
  }

  // now, finally, update the ball's velocity:
  ball.vel.x = newBallVx;
  ball.vel.y = newBallVy;

  return closestPoint;
}

