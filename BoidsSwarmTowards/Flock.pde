// The Flock (a list of Boid objects)

class Flock {
  LinkedList<Boid> boids; // An arraylist for all the boids

  Flock() {
    boids = new LinkedList<Boid>(); // Initialize the arraylist
  }

  void run() {
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      boolean hit = b.run(boids);  // Passing the entire list of boids to each boid individually
      if (hit) boids.remove(i);
      b=null;
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}

