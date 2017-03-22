class Flock {
  ArrayList<Boid> boids;
  
  //constructor
  Flock() {
    this.boids = new ArrayList<Boid>();
  }
  
  //simulate all boids in list
  void run() {
    for (Boid b : this.boids) {
      b.run(this.boids);
    }
  }
  
  //add a boid
  void addBoid(Boid b) {
    this.boids.add(b);
  }
  
  //clear all boids
  void clearBoids() {
    this.boids.clear();
    reset_ids();
  }
  
  ArrayList<Boid> getBoids(){
    return this.boids;
  }
  
  void turnFlockAround (){
    for (Boid boid : this.boids){
      boid.velocity.mult(-1);
    }
  }

  void changeColor(int c) {

//    for (Boid b : this.boids) {
//      //b.color_b = c;
//    }
  };
}