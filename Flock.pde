class Flock {
  ArrayList<Boid> boids;

  Flock() {
    this.boids = new ArrayList<Boid>();
  }

  void run() {
    for (Boid b : this.boids) {
      b.run(this.boids);
    }
  }

  void addBoid(Boid b) {
    this.boids.add(b);
  }

  void clearBoids() {
    this.boids.clear();
  }

  void changeColor(int c) {

//    for (Boid b : this.boids) {
//      //b.color_b = c;
//    }
  };
}