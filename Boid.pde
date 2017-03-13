class Boid {
  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector obstacle_vector;
  float r;
  float maxspeed;
  float maxforce;
  float d;

  Boid(float x, float y) {
    obstacle_vector = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    velocity = new PVector(random(-2, 2), random(-2, 2));
    //velocity.setMag(random(3,4));
    velocity.setMag(0.1);
    location = new PVector(x, y);
    r = 2.0;
    maxspeed = 3;
    maxforce = 0.1;
    d = 150;
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }


  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
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

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);
    PVector ali = align(boids);
    PVector coh = cohesion(boids);
    PVector see = cursor_seeking();
    PVector avo = cursor_avoiding();
    PVector obs = avoidObstacle();


    sep.mult(s_power*0.015);
    ali.mult(a_power*0.01);
    coh.mult(c_power*0.01);
    see.mult(1.0);
    avo.mult(1.0);
    obs.mult(2.0);

    //println(obs.mag());
    if ( obs.mag() == 0) {
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
      applyForce(see);
      applyForce(avo);
    }
    applyForce(obs);
  }

  PVector separate(ArrayList<Boid> boids) {
    if (separation) {
      PVector sum = new PVector(0, 0, 0);
      int count = 0;

      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);

        if ((d >0) && (d < desired_s)) {
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

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);
    //applyForce(steer);
    return steer;
  }


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


  //avoiding
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

  PVector align (ArrayList<Boid> boids) {
    if (alignment) {
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);
        if ((d > 0) && (d < neighbor_d)) {
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

  PVector cohesion (ArrayList<Boid> boids) {
    if (cohesion) {
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (Boid other : boids) {
        float d = PVector.dist(location, other.location);
        if ((d>0) && (d<neighbor_d)) {
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

  PVector avoidObstacle() {
    PVector sum = new PVector(0, 0);
    int count = 0;
    //obstacles.checkDistance
    for (Obstacle o : obstacles.obstacles) {
      obstacle_vector.set(0, 0);
      float dist = o.calcDistPointToLine(o.start_position, o.end_position, location, obstacle_vector);
      dist = sqrt(dist);
      if (dist < 40) {
        PVector diff = PVector.sub(location, obstacle_vector);
        diff.normalize();
        diff.div(d*d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }

    if (count > 0) {
      sum.div(count);
    }
    if (sum.mag() > 0) {
      sum.setMag(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce * 1.5);
      //applyForce(steer);
      return steer;
    } else     return(new PVector(0, 0));
  }


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

  void render() {
    noStroke();
    strokeWeight(1);
    float theta = velocity.heading() + PI/2;
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
  }
}