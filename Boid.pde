class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector obstacleVector;
  float radius;
  float maxspeed;
  float maxforce;
  PVector[] previousRotation;
  int id;
  //boolean crowded;
  static final int numberOfNeighborsWhenCrowded = 3;
  //float crowdedSpace = desired_s;
  float crowdedSpace = 8 * boid_scl;
  int lastFrameTurnedAround = frameCount;
  boolean talkedThisFrame = false;
  int turnAroundAnimationCounter = 0;
  PVector projectedHeading = new PVector(0, 0);
  static final int TURN_AROUND_LENGTH = 20;
  static final int TURN_AROUND_RESET_TIME = 300;
  float stepDown;
  boolean special;

  Boid(float x, float y) {
    this.obstacleVector = new PVector(0, 0);
    this.acceleration = new PVector(0, 0);
    this.velocity = new PVector(random(-2, 2), random(-2, 2));
    this.velocity.setMag(0.5);
    this.location = new PVector(x, y);
    this.radius = 2.0;
    this.maxspeed = 2.5;
    this.maxforce = 0.1;
    id = flock.getID();
    special = false;

    setupPreviousRotation();
  }



  //set up for averaging heading
  void setupPreviousRotation() {
    this.previousRotation = new PVector[5];
    for (int i = 0; i < this.previousRotation.length; i++) {
      PVector tmpVelocity = new PVector(0, 0);
      tmpVelocity.set(velocity);
      tmpVelocity.normalize();
      this.previousRotation[i] = tmpVelocity;
    }
  }

  //do all the things required to run
  void run(ArrayList<Boid> boids) {
    if (disableTurnAround) this.turnAroundAnimationCounter = 0;
    if (!currentlyTurningAround()) {
      calculateForces(boids);
      //override flock movement
      avoidCornerCollisions();
    } else {
      animateTurningAround();
    }
    //if close by, fly slower
    //closeBySlowness();
    //bumper
    //bumper();
    update();
    borders();
    render();
  }

  void bumper() {
    float smallestDistance = MAX_FLOAT;
    //check all distances
    for (Boid other : flock.getBoids()) {
      if (this.id != other.id) {
        float localDistance = PVector.dist(location, other.location);
        if (localDistance < smallestDistance) {
          //save smallest one
          smallestDistance = localDistance;
        }
      }
    }

    if (smallestDistance < radius * boid_scl * 3) {
      this.velocity.limit(0);
    }
  }

  void closeBySlowness() {
    float smallestDistance = MAX_FLOAT;
    //check all distances
    for (Boid other : flock.getBoids()) {
      if (this.id != other.id) {
        float localDistance = PVector.dist(location, other.location);
        if (localDistance < smallestDistance) {
          //save smallest one
          smallestDistance = localDistance;
        }
      }
    }

    //limit speed accordingly
    float personalSpace = desired_s * 0.75;
    float limitingFactor = smallestDistance / personalSpace;
    if (limitingFactor < 1) {
      this.velocity.limit(maxspeed*limitingFactor);
    }
  }

  boolean currentlyTurningAround() {
    return (this.turnAroundAnimationCounter > 0);
  }

  void animateTurningAround() {
    if (this.turnAroundAnimationCounter > floor(TURN_AROUND_LENGTH * 0.5)) {        //first half of turning around
      slowDown();
      this.turnAroundAnimationCounter--;
    } else if (this.turnAroundAnimationCounter == floor(TURN_AROUND_LENGTH*0.5)) {  //at the halfway point of turning around
      changeHeading();      
      this.turnAroundAnimationCounter--;
    } else if (this.turnAroundAnimationCounter > 0) {                               //last part of turning around
      speedUp();      
      this.turnAroundAnimationCounter--;
      if (this.turnAroundAnimationCounter == 1) this.lastFrameTurnedAround = frameCount;
    }
  }

  //update location with velocity
  void update() {
    this.velocity.add(this.acceleration);
    this.velocity.limit(this.maxspeed);
    this.location.add(this.velocity);
    this.acceleration.mult(0);
  }

  //applies force
  void applyForce(PVector force) {
    acceleration.add(force);
  }

  //applies behaviors
  void calculateForces(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    PVector see = cursorAttracting();
    PVector avo = cursorReppeling();
    PVector obs = avoidObstacle();

    //transform multiplier from percentage to value
    float sepMultiplier = s_power * 0.01;
    float aliMultiplier = a_power * 0.01;
    float cohMultiplier = c_power * 0.01;

    obs.mult(4.0);
    if (obs.mag() == 0) { //no obstacle near
      sep.mult(sepMultiplier*1.5);
      ali.mult(aliMultiplier*1);
      coh.mult(cohMultiplier*1);
    } else {
      sep.mult(sepMultiplier*1);
      ali.mult(aliMultiplier*0.5);
      coh.mult(cohMultiplier*0);
    }

    //if (checkIfCrowded()){
    //  obs.mult(-1);
    //  if (this.id == 0) println("Druk hier!");
    //}

    if (this.id == 0 && obs.mag() != 0) {
      println("OBS mag: " + obs.mag());
      println("SEP mag: " + sep.mag());
    }



    see.mult(0.8);
    avo.mult(1.0);

    applyForce(obs);
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);

    applyForce(see);
    applyForce(avo);


    //sep.mult(4);
    //applyForce(sep);
    //applyForce(ali);
    //applyForce(coh);
    //applyForce(see);
    //applyForce(avo);

    //applyForce(obs);

    //println(obs.mag());
    //if ( obs.mag() == 0) {
    //  applyForce(sep);
    //  applyForce(ali);
    //  applyForce(coh);
    //  applyForce(see);
    //  applyForce(avo);
    //  //testing
    //  sep.mult(0.5);
    //  applyForce(sep);
    //  ali.mult(0.5);
    //  applyForce(ali);
    //} else {
    //  applyForce(obs);
    //  sep.mult(0.5);
    //  applyForce(sep);
    //  ali.mult(0.5);
    //  applyForce(ali);
    //  //applyForce(see);
    //}
  }

  boolean checkIfCrowded() { 
    boolean crowded = false;
    int counter = 0;
    for (Boid other : flock.getBoids()) {
      float d = PVector.dist(location, other.location);
      if ((this.id != other.id) && (d < this.crowdedSpace)) {
        counter++;
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
    this.talkedThisFrame = true;
    float maximumDistance = neighbor_d * boid_scl*2.5;
    for (Boid other : flock.getBoids()) {
      float distance = PVector.dist(location, other.location);
      if (this.id != other.id && distance < maximumDistance) other.turnAround();
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
    setProjectedHeading();
    calculateStepDown();
  }

  void setProjectedHeading() {
    this.projectedHeading.set(this.velocity);
    this.projectedHeading.mult(-1);
  }

  void avoidCornerCollisions() {
    if (checkIfCrowded()) {
      if (!hasTurnedRecently()) {
        turnAround();
        if (!this.talkedThisFrame) {
          tellNeighborsToTurnAround();
          this.talkedThisFrame = true;
        }
      }
    }
  }

  void calculateStepDown() {
    this.stepDown = this.velocity.mag() / (floor(TURN_AROUND_LENGTH/2));
  }

  void slowDown() {
    this.velocity.limit(this.maxspeed);
    this.velocity.setMag(this.velocity.mag()-this.stepDown);
  }

  void changeHeading() {
    this.projectedHeading.setMag(this.velocity.mag());
    this.velocity.set(this.projectedHeading);
  }

  void speedUp() {    
    this.velocity.setMag(this.velocity.mag()+this.stepDown);
    this.velocity.limit(this.maxspeed);
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
        float localDistance = PVector.dist(this.location, other.location);
        if ((this.id != other.id) && (localDistance < desired_s * boid_scl * 0.5)) {
          PVector difference = PVector.sub(this.location, other.location);
          difference.normalize();
          difference.div(localDistance);
          sum.add(difference);
          count++;
        }
      }

      if (count > 0) {
        sum.div(count);
      }

      if (sum.mag() > 0) {
        sum.setMag(this.maxspeed);
        PVector steer = PVector.sub(sum, velocity);
        steer.limit(this.maxforce);
        return steer;
      }
      return(new PVector(0, 0));
    } else return(new PVector(0, 0));
  }

  //seek a target
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, this.location);
    desired.normalize();
    desired.mult(this.maxspeed);
    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxforce);
    return steer;
  }

  //seek the cursor
  PVector cursorAttracting() {
    if (seeking) {
      PVector target = new PVector(mouseX, mouseY);
      PVector desired = PVector.sub(target, this.location);
      desired.normalize();
      desired.mult(this.maxspeed);
      PVector steer = PVector.sub(desired, this.velocity);
      steer.limit(this.maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }


  //avoid the cursor, flee from cursor
  PVector cursorReppeling() {
    if (avoiding) {
      PVector target = new PVector(mouseX, mouseY);
      PVector desired = PVector.sub(target, this.location);
      desired.normalize();
      desired.mult(this.maxspeed);
      desired.mult(-1);
      PVector steer = PVector.sub(desired, this.velocity);
      steer.limit(this.maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  //arrive, decrease speed closer to the target
  //stop at the target
  void arrive(PVector target) {
    PVector desired = PVector.sub(target, location);

    float distanceToTarget = desired.mag();    
    desired.normalize();

    if (distanceToTarget < 100) {
      float multitude = map(distanceToTarget, 0, 100, 0, maxspeed);
      desired.mult(multitude);
    } else {
      desired.mult(this.maxspeed);
    }
    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxforce);
    applyForce(steer);
  }

  //alignment rule
  PVector align (ArrayList<Boid> boids) {
    if (alignment) {
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float localDistance = PVector.dist(location, other.location);
        if ((this.id != other.id) && (localDistance < neighbor_d  * boid_scl * 0.5)) {
          sum.add(other.velocity);
          count++;
        }
      }
      if (count > 0) {
        sum.div(count);
        sum.normalize();
        sum.mult(this.maxspeed);
        PVector steer = PVector.sub(sum, this.velocity);
        steer.limit(this.maxforce);
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
        float localDistance = PVector.dist(location, other.location);
        if ((this.id != other.id) && (localDistance < neighbor_d  * boid_scl * 0.5)) {
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
  // Test for corner bunching prevention
  PVector avoidObstacle() {
    float lookingDistance = 10*obs_scl+10;
    PVector sum = new PVector(0, 0);
    PVector biggerVelocity = new PVector(0, 0);
    biggerVelocity.set(this.velocity);
    biggerVelocity.mult(30);
    PVector futureLocation = new PVector(0, 0);
    futureLocation.set(PVector.add(location, biggerVelocity));
    int count = 0;
    //obstacles.checkDistance
    for (Obstacle o : obstacles.obstacles) {
      obstacleVector.set(0, 0);
      float localDistance = o.calcDistPointToLine(o.startPosition, o.endPosition, futureLocation, obstacleVector);
      localDistance = sqrt(localDistance);
      if (localDistance < lookingDistance) {
        futureLocation.add(biggerVelocity.mult(20));
        if (o.startPosition.dist(futureLocation) > o.endPosition.dist(futureLocation)) obstacleVector.set(o.startPosition);
        else obstacleVector.set(o.endPosition);
        PVector difference = PVector.sub(this.location, obstacleVector);
        difference.normalize();
        difference.div(localDistance);        // Weight by distance
        sum.set(difference);
        //dist_smallest = dist;
        //sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    //cut corners prevention
    //overide when current loc is to close
    for (Obstacle o : obstacles.obstacles) {
      obstacleVector.set(0, 0);
      float localDistance = o.calcDistPointToLine(o.startPosition, o.endPosition, this.location, obstacleVector);
      localDistance = sqrt(localDistance);
      if (localDistance < lookingDistance) {
        PVector difference = PVector.sub(this.location, obstacleVector);
        difference.normalize();
        sum.set(difference);
        //count = 1;
      }
    }

    if (count > 1) {
      sum.div(count);
      sum.mult(-1);
    }
    if (sum.mag() > 0) {
      sum.setMag(this.maxspeed);
      PVector steer = PVector.sub(sum, this.velocity);
      //PVector steer = PVector.sub(velocity, sum);
      steer.limit(this.maxforce);
      //steer.rotate(steer.heading() + PI/2);
      //velocity.heading() + PI/2
      //println(steer.heading());
      //steer.limit(maxforce * 1.5);
      //applyForce(steer);
      return steer;
    } else     return(new PVector(0, 0));
  }


//  //************************************************************************************************//
//  // obstacle avoidance way
//  // Force field way to be converted to obstacle avoidance
//  // take two, keep heading of group / individual
//  // or just future predicting
//  // future predicting
//  PVector avoidObstacle() {
//    float lookingDistance = 10*obs_scl+10;
//    PVector sum = new PVector(0, 0);
//    PVector biggerVelocity = new PVector(0, 0);
//    biggerVelocity.set(this.velocity);
//    biggerVelocity.mult(30);
//    PVector futureLocation = new PVector(0, 0);
//    futureLocation.set(PVector.add(location, biggerVelocity));
//    int count = 0;
//    //obstacles.checkDistance
//    for (Obstacle o : obstacles.obstacles) {
//      obstacleVector.set(0, 0);
//      float localDistance = o.calcDistPointToLine(o.startPosition, o.endPosition, futureLocation, obstacleVector);
//      localDistance = sqrt(localDistance);
//      if (localDistance < lookingDistance) {
//        futureLocation.add(biggerVelocity.mult(20));
//        if (o.startPosition.dist(futureLocation) > o.endPosition.dist(futureLocation)) obstacleVector.set(o.startPosition);
//        else obstacleVector.set(o.endPosition);
//        PVector difference = PVector.sub(this.location, obstacleVector);
//        difference.normalize();
//        difference.div(localDistance);        // Weight by distance
//        sum.set(difference);
//        //dist_smallest = dist;
//        //sum.add(diff);
//        //count++;            // Keep track of how many
//      }
//    }
//    //cut corners prevention
//    //overide when current loc is to close
//    for (Obstacle o : obstacles.obstacles) {
//      obstacleVector.set(0, 0);
//      float localDistance = o.calcDistPointToLine(o.startPosition, o.endPosition, this.location, obstacleVector);
//      localDistance = sqrt(localDistance);
//      if (localDistance < lookingDistance) {
//        PVector difference = PVector.sub(this.location, obstacleVector);
//        difference.normalize();
//        sum.set(difference);
//        count = 1;
//      }
//    }

//    if (count > 0) {
//      sum.div(count);
//    }
//    if (sum.mag() > 0) {
//      sum.setMag(this.maxspeed);
//      PVector steer = PVector.sub(sum, this.velocity);
//      //PVector steer = PVector.sub(velocity, sum);
//      steer.limit(this.maxforce);
//      //steer.rotate(steer.heading() + PI/2);
//      //velocity.heading() + PI/2
//      //println(steer.heading());
//      //steer.limit(maxforce * 1.5);
//      //applyForce(steer);
//      return steer;
//    } else     return(new PVector(0, 0));
//  }

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
    if (this.location.x < -this.radius) this.location.x += width+this.radius-cpanel.cpWidth;
    if (this.location.y < -this.radius) this.location.y += height+this.radius;
    if (this.location.x > width+this.radius-cpanel.cpWidth) this.location.x -= width-this.radius-cpanel.cpWidth;
    if (this.location.y > height+this.radius) this.location.y -= height-this.radius;
  }

  //draw the boid
  void render() {
    int tmpColor = boid_c;
    if (this.special || this.id == 0) {
      boid_c = #FF4000;
    }

    noStroke();
    strokeWeight(1);
    float theta = this.velocity.heading() + PI/2;
    ////float theta = ((velocity.heading() + prev_rotation) * 0.5) + PI/2;
    ////average rotation
    ////shift list 1 down
    for (int i = 0; i < this.previousRotation.length - 1; i++) {
      this.previousRotation[i] = this.previousRotation[i+1];
    }
    //put in current value
    PVector tmpVelocity = new PVector(0, 0);
    tmpVelocity.set(this.velocity);
    tmpVelocity.normalize();
    this.previousRotation[this.previousRotation.length - 1] = tmpVelocity;
    //add all values
    PVector direction =  new PVector(0, 0);
    for (int i = 0; i < this.previousRotation.length; i++) {
      direction.add(this.previousRotation[i]);
    }
    //average the values
    direction.div(this.previousRotation.length);
    theta =  direction.heading() + PI/2 ;

    ////end
    fill(boid_c);
    //stroke(255);
    pushMatrix();
    translate(this.location.x, this.location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -this.radius*2*boid_scl);
    vertex(-this.radius*boid_scl, this.radius*2*boid_scl);
    vertex(this.radius*boid_scl, this.radius*2*boid_scl);
    endShape(CLOSE);
    popMatrix();
    //prev_rotation = theta;
    boid_c = tmpColor;
  }
}