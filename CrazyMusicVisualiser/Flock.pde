// The Flock (a list of Boid objects)

class Flock 
{
  LinkedList<Boid> boids; // An arraylist for all the boids
  boolean active;
  PGraphics renderer;
  /*
  float desiredseparation = 25.0;
   float avoidWallsFactor = 0.8;
   float charAttract = 3.8;
   float attraction = 0.08;
   float neighbordist = 25.0;
   color boidFill = color(255, 30, 0);
   color boidStroke = color(255, 0, 0);
   float boidMaxSpeed = 8, boidMaxForce=0.8;
   */
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed


  Flock() 
  {
    boids = new LinkedList<Boid>(); // Initialize the arraylist
    active = false;
    maxspeed = 6;
    maxforce = 10;
  }



  // We accumulate a new acceleration each time based on three rules
  void flock() 
  {
    maxspeed = boidMaxSpeed;
    maxforce = boidMaxForce;


    for (Boid b : boids)
    {
      b.maxforce = maxforce;
      PVector sep = separate(b, boids);   // Separation
      PVector ali = align(b, boids);      // Alignment
      //PVector coh = cohesion(b, boids);   // Cohesion
      // Arbitrarily weight these forces
      sep.mult(1.0);
      ali.mult(0.6);
      //coh.mult(0.2);

      // Add the force vectors to acceleration
      b.accelerate( sep );
      //b.applyAcceleration(maxforce, maxspeed);
      b.accelerate( ali);
      //b.accelerate( coh );
      update(b);
      b.render(renderer);
    }
  }


  void run(PGraphics _renderer) 
  {
    renderer = _renderer;

    if (active)
    {
      flock();
      /*
      ListIterator<Boid> li = boids.listIterator();
       
       while (li.hasNext ())
       {
       Boid b = li.next();
       
       b.render(renderer);
       if (hit) li.remove();
       }
       */
    }
    // end run
  }

  void addBoid(Boid b) 
  {
    boids.add(b);
  }

  void setTexture(GLTexture tex)
  {
    for (Boid b : boids)
      b.tex = tex;
  }



  // Method to update location
  // true if hit character
  boolean update(Boid b) 
  {
    boolean hit = false;

    //    Avoid walls
    float dLeft = b.loc.x;
    float dRight = width-b.loc.x;
    float dTop = b.loc.y;
    float dBot = height-b.loc.y;

    float sumAccelX = 0;

    if (dLeft > EPSILON)
      sumAccelX += (1f/dLeft)*avoidWallsFactor;
    if (dRight > EPSILON)
      sumAccelX -= (1f/dRight)*avoidWallsFactor;

    float sumAccelY = 0;

    if (dTop > EPSILON)
      sumAccelY += (1f/dTop)*avoidWallsFactor;
    if (dBot > EPSILON)
      sumAccelY -= (1f/dBot)*avoidWallsFactor;

    b.accelerate(sumAccelX, sumAccelY);

    // attraction towards "characters"

    for (DrawableNode node : nodesToCollide )
    {

      float charDiffX = node.pos.x - b.loc.x;
      float charDiffY = node.pos.y - b.loc.y;

      float d = charDiffX*charDiffX + charDiffY*charDiffY;

      if (d > MinNodeDistanceSquared && d < MaxNodeDistanceSquared)
      {
        float dInv = attraction-constrain(1/d, 0, attraction);

        float m = max(abs(charDiffX), abs(charDiffY));
        float dirX = charDiffX/m;
        float dirY = charDiffY/m;

        float cX = dirX*dInv;
        float cY = dirY*dInv;

        b.accelerate(cX, cY);
      }
    }

    b.applyAcceleration(maxforce, maxspeed);
    b.wrapBorders();

    return hit;
  }



  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (Boid b, LinkedList<Boid> boids)
  {

    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) 
    {
      if (other != b)
      {
        float d = PVector.dist(b.loc, other.loc);
        // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
        if (d < desiredseparation) 
        {
          d = constrain(d, 0.1, desiredseparation);
          // Calculate vector pointing away from neighbor
          PVector diff = PVector.sub(b.loc, other.loc);
          //diff.normalize();
          diff.div(d/desiredseparation);        // Weight by distance
          //diff.mult(1f/d);
          sum.add(diff);
          count++;            // Keep track of how many
        }
      }
    }
    /*
    if (count > 0) 
    {
      sum.div((float)count);
    }
    */
    // As long as the vector is greater than 0
    if (sum.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      //sum.normalize();
      //sum.mult(maxspeed);
      sum.sub(b.vel);
      sum.limit(maxforce);
    }
    return sum;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (Boid b, LinkedList<Boid> boids) {
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(b.loc, other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
      }
    }

    if (count > 0) {
      sum.div((float)count);
    }
    // As long as the vector is greater than 0
    if (sum.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      sum.sub(b.vel);
      sum.limit(maxforce);
    }
    return sum;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (Boid b, LinkedList<Boid> boids) {

    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) 
    {
      if (b != other)
      {
        float d = b.loc.dist(other.loc);
        if (d < neighbordist) 
        {
          sum.add(other.loc); // Add location
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div((float)count);
    }
    return b.steer(sum, maxspeed);
  }
}

