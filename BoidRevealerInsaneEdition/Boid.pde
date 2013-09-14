// The Boid class

int boidLifetime = 100;

class Boid {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  GLTexture tex;
//  float maxforce;
  int life;
  boolean alive;
  boolean immortal;

  Boid(PVector l, GLTexture _tex) 
  {
    acc = new PVector(0, 0);
    vel = new PVector(random(-2, 2), random(-2, 2));
    loc = l.get();
    r = 2.0 + random(-1, 1);

    tex = _tex;
    life = boidLifetime-int(random(boidLifetime*0.25));
    alive = true;
    immortal = false;
    
  }


  void seek(PVector target, float maxspeed, float maxforce) {
    accelerate(steer(target, maxspeed, maxforce));
  }

  void arrive(PVector target, float maxspeed, float maxforce) {
    accelerate(steer(target, maxspeed, maxforce));
  }


  PVector steer(PVector target, float maxspeed)
  {
    return steer( target, maxspeed, 0f);
  } 

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, float maxspeed, float slowdown) 
  {
    PVector steer;  // The steering vector
    PVector desired = target.sub(target, loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > EPSILON) 
    {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if (d < slowdown) desired.mult(maxspeed*(d/slowdown)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired, vel);
    } 
    else {
      steer = new PVector(0, 0);
    }
    return steer;
  }

  void render(PGraphics renderer) {
    renderer.imageMode(CENTER);

    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + PI/2;
    renderer.fill(boidFill);
    renderer.stroke(boidStroke);
    renderer.pushMatrix();
    renderer.translate(loc.x, loc.y);
    renderer.rotate(theta);
    renderer.image(tex, 0, 0);
/*
    renderer.noFill();
    renderer.stroke(255);
    renderer.ellipse(0,0,desiredseparation*2,desiredseparation*2);
    renderer.stroke(255,0,0);    
    renderer.ellipse(0,0,neighbordist*2,neighbordist*2);
    */
    renderer.popMatrix();
  }

  // Wraparound
  void wrapBorders() 
  {
    if (loc.x < -r) loc.x = width+r;
    if (loc.y < -r) loc.y = height+r;
    if (loc.x > width+r) loc.x = -r;
    if (loc.y > height+r) loc.y = -r;
  }


  Boid accelerate(PVector a)
  {
    return accelerate(a.x,a.y,a.z);
  }

  Boid accelerate(float ax, float ay, float maxforce)
  {
    acc.add( ax, ay, 0f );
    acc.limit(maxforce);
    return this;
  }

  Boid applyAcceleration(float maxforce, float maxspeed)
  {
    //acc.limit(maxforce);
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);

    // Reset accelertion to 0 each cycle
    acc.set(0f, 0f, 0f);

    return this;
  }
}

