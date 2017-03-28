class Flock {
  ArrayList<Boid> boids;

  Flock() {
    this.boids = new ArrayList<Boid>();
  }

  //simulate all boids in list
  void run() {
    for (Boid b : this.boids) {
      b.run(this.boids);
    }
    //setTalkedToFalse
    for (Boid o : this.boids) {
      o.talkedThisFrame=false;
    }
  }

  void addBoid(Boid b) {
    this.boids.add(b);
  }

  void clearBoids() {
    this.boids.clear();
  }

  ArrayList<Boid> getBoids() {
    return this.boids;
  }

  void turnFlockAround () {
    for (Boid boid : this.boids) {
      boid.turnAround();
    }
  }

  void changeColor(int c) {

    //    for (Boid b : this.boids) {
    //      //b.color_b = c;
    //    }
  }

  int getID() {
    //no need for -1, the boid isn't added yet
    return (this.boids.size());
  }
}