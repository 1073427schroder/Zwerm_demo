class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector obstacle_vector;
  float r;
  float maxspeed;
  float maxforce;
  float d;
  PVector[] prev_rotation;
  int id;
  //boolean crowded;
  static final int numberOfNeighborsWhenCrowded = 3;
  //float crowdedSpace = desired_s;
  float crowdedSpace = 8 * boid_scl;
  int lastFrameTurnedAround = frameCount;
  boolean talkedThisFrame = false;
  int turnAroundAnimationCounter = 0;
  PVector tmp_heading = new PVector(0, 0);
  static final int TURN_AROUND_LENGTH = 20;
  static final int TURN_AROUND_RESET_TIME = 60;
  float stepDown;

  //constructor
  Boid(float x, float y) {
    obstacle_vector = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    velocity = new PVector(random(-2, 2), random(-2, 2));
    //velocity.setMag(random(3,4));
    velocity.setMag(0.1);
    location = new PVector(x, y);
    r = 2.0;
    maxspeed = 2.5;
    maxforce = 0.1;
    //maxforce = 0.075;
    d = 150;
    id = getID();
    //this.crowded = false;

    //set up for averaging heading
    prev_rotation = new PVector[5];
    for (int i = 0; i < prev_rotation.length; i++) {
      PVector tmp_vel = new PVector(0, 0);
      tmp_vel.set(velocity);
      tmp_vel.normalize();
      prev_rotation[i] = tmp_vel;
    }
  }

  //do all the things required to run
  void run(ArrayList<Boid> boids) {
    if (turnAroundAnimationCounter <= 0) {
      flock(boids);
      //test
      avoidCornerCollisions();
    } else if ( turnAroundAnimationCounter > floor(TURN_AROUND_LENGTH * 0.5)) {
      slow_down();
      turnAroundAnimationCounter--;
    } else if (turnAroundAnimationCounter == floor(TURN_AROUND_LENGTH*0.5)) {
      change_heading();      
      turnAroundAnimationCounter--;
    } else if (turnAroundAnimationCounter > 0) {
      speed_up();      
      turnAroundAnimationCounter--;
      if (turnAroundAnimationCounter == 1) lastFrameTurnedAround = frameCount;
    }
    update(boids);
    borders();
    render();
    //checkIfCrowded();
    //if (checkIfCrowded()) {
    //  //println("Druk hier!");
    //  collisionDanger = true;
    //}

    //talkedThisFrame = false;
  }

  //update location with velocity
  void update(ArrayList<Boid> boids) {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    //slow down, bunching prevention
    //slow_down(boids);
    location.add(velocity);
    //wrap();
    acceleration.mult(0);
  }

  /*
  void applyBehaviors() {
   if (seeking) {
   PVector seek = seek(target);
   seek.mult(1);
   applyForce(seek);
   }
   //boid.arrive(target);
   if (avoiding) {
   PVector avoid = avoid();
   avoid.mult(2);
   applyForce(avoid);
   }
   if (separating) {
   PVector separate = separate(boids);
   separate.mult(1);
   applyForce(separate);
   }
   }
   */
  //applies force
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  //applies behaviors
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    PVector see = cursor_seeking();
    PVector avo = cursor_avoiding();
    PVector obs = avoidObstacle();


    sep.mult(s_power*0.02);
    ali.mult(a_power*0.01);
    coh.mult(c_power*0.01);
    see.mult(1.0);
    avo.mult(1.0);
    obs.mult(4.0);

    //sep.mult(4);
    //applyForce(sep);
    //applyForce(ali);
    //applyForce(coh);
    //applyForce(see);
    //applyForce(avo);

    //applyForce(obs);

    //println(obs.mag());
    if ( obs.mag() == 0) {
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
      applyForce(see);
      applyForce(avo);
      //testing
      sep.mult(0.5);
      applyForce(sep);
      ali.mult(0.5);
      applyForce(ali);
    } else {
      applyForce(obs);
      sep.mult(0.5);
      applyForce(sep);
      ali.mult(0.5);
      applyForce(ali);
      //applyForce(see);
    }
  }

  boolean checkIfCrowded() { 
    boolean crowded = false;
    int counter = 0;
    for (Boid other : flock.getBoids()) {
      float d = PVector.dist(location, other.location);
      if ((this.id != other.id) && (d < this.crowdedSpace)) {
        counter++;
        //println("counter: " + counter);
      }
    }
    if (counter > numberOfNeighborsWhenCrowded) {
      crowded = true;
    } else crowded = false;
    return crowded;
  }

  boolean hasTalkedRecently() {
    return this.talkedThisFrame;
  }

  void tellNeighborsToTurnAround() {
    //talkedThisFrame = true;
    float maximumDistance = neighbor_d * boid_scl*2.5;
    for (Boid other : flock.getBoids()) {
      float distance = PVector.dist(location, other.location);
      if (this.id != other.id && distance < maximumDistance) other.turnAround();

      //float d = PVector.dist(location, other.location);
      //if ((this.id != other.id) && (d < maximumDistance)) {
      //  other.turnAround();
      //}
    }
  }

  boolean hasTurnedRecently() {
    boolean turnedRecently;
    if (frameCount - lastFrameTurnedAround < 60) turnedRecently = true;
    else turnedRecently = false;
    return turnedRecently;
  }

  void turnAround() {
    turnAroundAnimationCounter = TURN_AROUND_LENGTH;
    projected_heading();
    calculateStepDown();
    //this.velocity.mult(-1);    
    //lastFrameTurnedAround = frameCount;
  }

  ////without animation
  //void turnAround() {
  //  this.velocity.mult(-1);    
  //  lastFrameTurnedAround = frameCount;
  //}

  void avoidCornerCollisions() {
    if (checkIfCrowded()) {
      if (!hasTurnedRecently()) {
        turnAround();
        if (!talkedThisFrame) {
          tellNeighborsToTurnAround();
          talkedThisFrame = true;
        }
      }
    }
  }

  void calculateStepDown() {
    this.stepDown = this.velocity.mag() / (floor(TURN_AROUND_LENGTH/2));
    println("Stepdown = " + this.stepDown);
  }

  void slow_down() {
    this.velocity.limit(maxspeed);
    //this.velocity.mult(0.95);    
    this.velocity.setMag(this.velocity.mag()-this.stepDown);
    println("Slowing down, velocity: " + this.velocity.mag());
  }

  void projected_heading() {
    //println("Velocity before: " + this.velocity);
    tmp_heading.set(this.velocity);
    tmp_heading.mult(-1);
    //println("Velocity after: " + this.velocity);
    //println("Heading after: " + this.tmp_heading);
  }

  void change_heading() {
    tmp_heading.setMag(this.velocity.mag());
    this.velocity.set(tmp_heading);
  }

  void speed_up() {    
    this.velocity.setMag(this.velocity.mag()+this.stepDown);
    println("Speeding up, velocity: " + this.velocity.mag());

    //this.velocity.mult(1.05);
    this.velocity.limit(maxspeed);
  }

  ////prevent bunching up
  ////slow down when boids are to close
  //void slow_down () {
  //  ArrayList<Boid> boids = flock.getBoids();
  //  //int counter = 0;
  //  float maximumDistance = desired_s * boid_scl * 0.25;
  //  for (Boid other : boids) {
  //    float d = PVector.dist(location, other.location);
  //    if ((this.id != other.id) && (d < maximumDistance)) {
  //      //prevent below 0 distance (no dividing by 0)
  //      if (d < 1) d = 1;
  //      float limiter = d / maximumDistance;
  //      println("limiter: " + limiter);
  //      this.velocity.limit(maxspeed*limiter);
  //      //counter++;
  //      //println("counter: " + counter);
  //      //break;
  //    }
  //  }
  //  //if (counter > 1)  println("times: " + counter);
  //}

  //separation rule
  PVector separate(ArrayList<Boid> boids) {
    if (separation) {
      PVector sum = new PVector(0, 0, 0);
      int count = 0;

      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);

        if ((this.id != other.id) && (d < desired_s * boid_scl * 0.5)) {
          PVector diff = PVector.sub(location, other.location);
          diff.normalize();
          diff.div(d);
          sum.add(diff);
          count++;
        }
      }

      if (count > 0) {
        sum.div(count);
      }

      if (sum.mag() > 0) {
        sum.setMag(maxspeed);
        PVector steer = PVector.sub(sum, velocity);
        steer.limit(maxforce);
        //applyForce(steer);
        return steer;
      }
      return(new PVector(0, 0));
    } else     return(new PVector(0, 0));
  }

  //seek a target
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    //applyForce(steer);
    return steer;
  }

  //seek the cursor
  PVector cursor_seeking() {
    if (seeking) {
      PVector target = new PVector(mouseX, mouseY);
      PVector desired = PVector.sub(target, location);
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      //applyForce(steer);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }


  //avoid the cursor, flee from cursor
  PVector cursor_avoiding() {
    if (avoiding) {
      PVector target = new PVector(mouseX, mouseY);
      PVector desired = PVector.sub(target, location);
      desired.normalize();
      desired.mult(maxspeed);
      desired.mult(-1);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      //applyForce(steer);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  //arrive, decrease speed closer to the target
  //stop at the target
  void arrive(PVector target) {
    PVector desired = PVector.sub(target, location);

    float d = desired.mag();    
    desired.normalize();

    if (d < 100) {
      float m = map(d, 0, 100, 0, maxspeed);
      desired.mult(m);
    } else {
      desired.mult(maxspeed);
    }

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    applyForce(steer);
  }

  //avoid
  PVector avoid() {
    PVector desired = null;

    if (location.x < d) {
      desired = new PVector(maxspeed, velocity.y);
    } else if (location.x > width -d) {
      desired = new PVector(-maxspeed, velocity.y);
    } 

    if (location.y < d) {
      desired = new PVector(velocity.x, maxspeed);
    } else if (location.y > height-d) {
      desired = new PVector(velocity.x, -maxspeed);
    } 

    if (desired != null) {
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce * 1.5);
      //applyForce(steer);
      return(steer);
    }
    return(new PVector(0, 0));
  }

  //alignment rule
  PVector align (ArrayList<Boid> boids) {
    if (alignment) {
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);
        if ((this.id != other.id) && (d < neighbor_d  * boid_scl * 0.5)) {
          sum.add(other.velocity);
          count++;
        }
      }
      if (count > 0) {
        sum.div(count);
        sum.normalize();
        sum.mult(maxspeed);
        PVector steer = PVector.sub(sum, velocity);
        steer.limit(maxforce);
        return steer;
      } else {
        return new PVector (0, 0);
      }
    } else return new PVector(0, 0);
  }

  //cohesion rule
  PVector cohesion (ArrayList<Boid> boids) {
    if (cohesion) {
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);
        if ((this.id != other.id) && (d<neighbor_d  * boid_scl * 0.5)) {
          sum.add(other.location);
          count++;
        }
      }
      if (count > 0) {
        sum.div(count);
        return seek(sum);
      } else {
        return new PVector(0, 0);
      }
    } else return new PVector(0, 0);
  }

  //************************************************************************************************//
  // obstacle avoidance way
  // Force field way to be converted to obstacle avoidance
  // take two, keep heading of group / individual
  // or just future predicting
  // future predicting
  PVector avoidObstacle() {
    float looking_distance = 10*obs_scl+10;
    PVector sum = new PVector(0, 0);
    PVector more_velocity = new PVector(0, 0);
    more_velocity.set(velocity);
    more_velocity.mult(30);
    PVector future_location = new PVector(0, 0);
    future_location.set(PVector.add(location, more_velocity));
    int count = 0;
    //obstacles.checkDistance
    for (Obstacle o : obstacles.obstacles) {
      obstacle_vector.set(0, 0);
      float dist = o.calcDistPointToLine(o.start_position, o.end_position, future_location, obstacle_vector);
      dist = sqrt(dist);
      if (dist < looking_distance) {
        future_location.add(more_velocity.mult(20));
        if (o.start_position.dist(future_location) > o.end_position.dist(future_location)) obstacle_vector.set(o.start_position);
        else obstacle_vector.set(o.end_position);
        //obstacle_vector.set(o.end_position);
        PVector diff = PVector.sub(location, obstacle_vector);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.set(diff);
        //dist_smallest = dist;
        //sum.add(diff);
        //count++;            // Keep track of how many
      }
    }
    //cut corners prevention
    //overide when current loc is to close
    for (Obstacle o : obstacles.obstacles) {
      obstacle_vector.set(0, 0);
      float dist = o.calcDistPointToLine(o.start_position, o.end_position, location, obstacle_vector);
      dist = sqrt(dist);
      if (dist < looking_distance) {
        PVector diff = PVector.sub(location, obstacle_vector);
        diff.normalize();
        sum.set(diff);
        count = 1;
      }
    }

    if (count > 0) {
      sum.div(count);
    }
    if (sum.mag() > 0) {
      sum.setMag(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      //PVector steer = PVector.sub(velocity, sum);
      steer.limit(maxforce);
      //steer.rotate(steer.heading() + PI/2);
      //velocity.heading() + PI/2
      //println(steer.heading());
      //steer.limit(maxforce * 1.5);
      //applyForce(steer);
      return steer;
    } else     return(new PVector(0, 0));
  }

  //************************************************************************************************//

  //// obstacle avoidance way
  //// Force field way to be converted to obstacle avoidance
  ////pseudocode
  //// 
  //PVector avoidObstacle() {
  //  float looking_distance = 80;
  //  PVector sum = new PVector(0, 0);
  //  int count = 0;
  //  //obstacles.checkDistance
  //  for (Obstacle o : obstacles.obstacles) {
  //    obstacle_vector.set(0, 0);
  //    float dist = o.calcDistPointToLine(o.start_position, o.end_position, location, obstacle_vector);
  //    dist = sqrt(dist);
  //    if (dist < looking_distance) {
  //      if (o.start_position.dist(location) > o.end_position.dist(location)) obstacle_vector.set(o.start_position);
  //      else obstacle_vector.set(o.end_position);
  //      PVector diff = PVector.sub(location, obstacle_vector);
  //      diff.normalize();
  //      diff.div(d);        // Weight by distance
  //      sum.add(diff);
  //      count++;            // Keep track of how many
  //    }
  //  }

  //  if (count > 0) {
  //    sum.div(count);
  //  }
  //  if (sum.mag() > 0) {
  //    sum.setMag(maxspeed);
  //    PVector steer = PVector.sub(sum, velocity);
  //    //PVector steer = PVector.sub(velocity, sum);
  //    steer.limit(maxforce*2);
  //    //steer.rotate(steer.heading() + PI/2);
  //    //velocity.heading() + PI/2
  //    //println(steer.heading());
  //    //steer.limit(maxforce * 1.5);
  //    //applyForce(steer);
  //    return steer;
  //  } else     return(new PVector(0, 0));
  //}



  // Force field way
  //PVector avoidObstacle() {
  //  PVector sum = new PVector(0, 0);
  //  int count = 0;
  //  //obstacles.checkDistance
  //  for (Obstacle o : obstacles.obstacles) {
  //    obstacle_vector.set(0, 0);
  //    float dist = o.calcDistPointToLine(o.start_position, o.end_position, location, obstacle_vector);
  //    dist = sqrt(dist);
  //    if (dist < 40) {
  //      PVector diff = PVector.sub(location, obstacle_vector);
  //      diff.normalize();
  //      diff.div(d*d);        // Weight by distance
  //      sum.add(diff);
  //      count++;            // Keep track of how many
  //    }
  //  }

  //if (count > 0) {
  //  sum.div(count);
  //}
  //if (sum.mag() > 0) {
  //  sum.setMag(maxspeed);
  //  PVector steer = PVector.sub(sum, velocity);
  //  steer.limit(maxforce);
  //  //steer.limit(maxforce * 1.5);
  //  //applyForce(steer);
  //  return steer;
  //} else     return(new PVector(0, 0));
  //}
  //

  /*
  void wrap() {
   if (location.x < 0) {
   location.x += width;
   } else if (location.x > width) {
   location.x -= width;
   }
   if (location.y < 0) {
   location.y += height;
   } else if (location.y > height) {
   location.y -= height;
   }
   }
   */

  // Wraparound
  void borders() {
    if (location.x < -r) location.x += width+r-cpanel.cp_width;
    if (location.y < -r) location.y += height+r;
    if (location.x > width+r-cpanel.cp_width) location.x -= width-r-cpanel.cp_width;
    if (location.y > height+r) location.y -= height-r;
  }

  //draw the boid
  void render() {
    noStroke();
    strokeWeight(1);
    float theta = velocity.heading() + PI/2;
    //float theta = ((velocity.heading() + prev_rotation) * 0.5) + PI/2;
    //average rotation
    //shift list 1 down
    for (int i = 0; i < prev_rotation.length - 1; i++) {
      prev_rotation[i] = prev_rotation[i+1];
    }
    //put in current value
    PVector tmp_vel = new PVector(0, 0);
    tmp_vel.set(velocity);
    tmp_vel.normalize();
    prev_rotation[prev_rotation.length - 1] = tmp_vel;
    //add all values
    PVector dir =  new PVector(0, 0);
    for (int i = 0; i < prev_rotation.length; i++) {
      dir.add(prev_rotation[i]);
    }
    //average the values
    dir.div(prev_rotation.length);
    theta =  dir.heading() + PI/2 ;

    //end
    fill(boid_c);
    //stroke(255);
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2*boid_scl);
    vertex(-r*boid_scl, r*2*boid_scl);
    vertex(r*boid_scl, r*2*boid_scl);
    endShape(CLOSE);
    popMatrix();
    //prev_rotation = theta;
  }
}