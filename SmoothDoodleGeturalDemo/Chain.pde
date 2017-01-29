// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Toxiclibs example

// A soft pendulum (series of connected springs)

class Chain 
{
  float radius=8;       // Radius of ball at tail
  int lifetime = 10000;
  int maxlifetime = 10000;
  boolean alive;

  // Let's keep an extra reference to the tail particle
  
  // This is just the last particle in the ArrayList
  private VerletParticle2D tail;

  private float strength;     // Strength of springs

  private ArrayList<VerletParticle2D> particles; // keep track of just ours, if we need them
  private ArrayList<VerletSpring2D> springs; // keep track of just ours, if we need them

  // Some variables for mouse dragging
  private PVector offset = new PVector();
  private boolean dragged = false;


  // make sure we do both steps when adding a spring 
  private void addSpring(VerletSpring2D s)
  {
    physics.addSpring(s);
    springs.add(s);
  }

  // make sure we do both steps when adding a particle 
  private void addParticle(VerletParticle2D p)
  {
    // Redundancy, we put the particles both in physics and in our own ArrayList

    physics.addParticle(p);
    particles.add(p);
  }


  // Chain constructor
  Chain(List<Vec2D> points, float s)
  {
    alive = true;
    strength = s;
    particles = new ArrayList<VerletParticle2D>();
    springs = new ArrayList<VerletSpring2D>();

    // Here is the real work, go through and add particles to the chain itself

    VerletParticle2D prevParticle = null;

    for (Vec2D p : points) {
      // Make a new particle with an initial starting location
      VerletParticle2D particle=new VerletParticle2D(p);

      addParticle(particle);

      // Connect the particles with a Spring (except for the head)
      if (prevParticle != null)
      {
        VerletSpring2D spring=new VerletSpring2D(particle, prevParticle, particle.distanceTo(prevParticle), strength);
        // Add the spring to the physics world
        addSpring(spring);
      }
      prevParticle = particle;
    }

    int startI=0;
    final int offset = 4;
    final int endI = particles.size() - offset;
    final int skip = 1; // indices to skip, to save memory

    while (startI < endI) 
    {
      for (int i=offset; i>offset/2; i -= skip)
      {
        // pair 1
        VerletParticle2D particle1=particles.get(startI);
        VerletParticle2D particle2=particles.get(startI+i);

        // just make sure, could be rounding errors
        if (particle1 != particle2)
        {
          VerletSpring2D spring=new VerletSpring2D(particle1, particle2, particle1.distanceTo(particle2), strength);

          // Add the spring to the physics world
          addSpring(spring);
        }

        // pair 2:
        int index2 = startI+i-offset/2;

        if (index2 > 0) // careful not to put this in twice
        {
          particle1=particles.get(startI+offset);
          particle2=particles.get(index2);

          // just make sure, could be rounding errors
          if (particle1 != particle2)
          {
            VerletSpring2D spring=new VerletSpring2D(particle1, particle2, particle1.distanceTo(particle2), strength);

            // Add the spring to the physics world
            addSpring(spring);
          }
        }

        // Make a new particle with an initial starting location
        particle1=particles.get(i);
        particle2=particles.get(i+offset);

        VerletSpring2D spring=new VerletMinDistanceSpring2D(particle1, particle2, particle1.distanceTo(particle2), strength);

        // Add the spring to the physics world
        addSpring(spring);
      }
      startI += offset;
    }


    // Keep the top fixed
    //VerletParticle2D head=particles.get(0);
    //head.lock();

    // Store reference to the tail
    tail = particles.get(particles.size()-1);
    tail.lock();
  }

  // Check if a point is within the ball at the end of the chain
  // If so, set dragged = true;
  void contains(int x, int y) {
    float d = dist(x, y, tail.x, tail.y);
    if (d < radius) {
      offset.x = tail.x - x;
      offset.y = tail.y - y;
      tail.lock();
      dragged = true;
    }
  }

  // Release the ball
  void release() {
    tail.unlock();
    dragged = false;
  }

  // Update tail location if being dragged
  void updateTail(int x, int y) {
    if (dragged) {
      tail.set(x+offset.x, y+offset.y);
    }
  }

  // Draw the chain
  void display() {
    if (lifetime > 0)
    {
      // Draw line connecting all points
      for (int i=0; i < particles.size()-1; i++) {
        VerletParticle2D p1 = particles.get(i);
        VerletParticle2D p2 = particles.get(i+1);
        int lifecolor = (int)map(lifetime, 0, 300, 0, 200);
        stroke(lifecolor, lifecolor, 100);
        strokeWeight(2);
        line(p1.x, p1.y, p2.x, p2.y);
        lifetime--;

        if (lifetime < 1)
        {
          lifetime = 0;
          boolean result = destroy();
          if (!result) println("destroy failed!");
        }
      }

      // Draw a ball at the tail
      stroke(0);
      fill(175);
      ellipse(tail.x, tail.y, radius*2, radius*2);

      stroke(128, 100);
      fill(200, 100);
      for (VerletSpring2D spring : springs)
      {
        gfx.line(spring.a, spring.b);
        ellipse(spring.a.x, spring.a.y, 5, 5);
      }
    }
  }

  boolean destroy()
  {
    alive = false;
    // remove and return true if success

    boolean result = false;
    for (VerletSpring2D s : springs)
    {
      result = result && physics.removeSpring(s);
    }

    for (VerletParticle2D p : particles)
    {
      result = result && physics.removeParticle(p);
    }

    springs.clear();
    particles.clear();

    return result;
  }
}