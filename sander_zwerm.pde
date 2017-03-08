//Test code zwerm
//Code based of Daniel Shiffman's Nature of Code Chapter 6

 
/*
ArrayList<Boid> boids;
 PVector target;
 Boolean avoiding;
 Boolean separating;
 */

Obstacles obstacles;
Boolean creating_obstacles = false;
Boolean eraser_mode = false;

Boolean separation;
Boolean cohesion;
Boolean alignment;

int c_power;
int s_power;
int a_power;

float desired_s;
float neighbor_d;

Boolean seeking;
Boolean avoiding;
ControlPanel cpanel;

Flock flock;


void setup() {
  obstacles = new Obstacles();
  alignment = true;
  cohesion = true;
  separation = true;


  c_power = 100;
  s_power = 100;
  a_power = 100;

  desired_s = 20.0f;
  neighbor_d = 50.0f;

  //int w;
  //int h;
  //w = floor(displayWidth * 0.9);
  //h = floor(displayHeight * 0.9);
  //surface.setSize(w,h);

  surface.setResizable(true);
  //fullScreen();
  //println("Displaywidth " + displayWidth);
  //println("Displayheight " + displayHeight);

  //println("Displaywidth " + floor(displayWidth * 0.9));
  //println("Displayheight " + floor(displayHeight *0.9));
  //surface.setSize(floor(displayWidth * 0.9), floor(displayHeight *0.9));
  //size(1728, 972);


  size(displayWidth, displayHeight);
  //size(800, 600);
  //size(1280, 800);
  pixelDensity(displayDensity());



  frameRate(60);
  flock = new Flock();
  seeking = false;
  avoiding = false;
  for (int i = 0; i < 30; i++) {
    Boid b = new Boid(width/2, height/2);
    flock.addBoid(b);
  }
  cpanel = new ControlPanel(this);
  /*
  //boids = new ArrayList<Boid>();
   target = new PVector(width / 2, height / 2);
   seeking = false;
   avoiding = true;
   separating = true;
   */
  /*
  for (int i = 0; i<500; i++) {
   boids.add(new Boid(width / 2, height / 2));
   }
   */

  surface.setSize(800, 600);
}

void draw() {
  background(70);

  flock.run();
  obstacles.render();

  if (!eraser_mode) {
    stroke(175);
    strokeWeight(20);
    point(mouseX, mouseY);
  } else {
    stroke(255);
    strokeWeight(20);
    point(mouseX, mouseY);
  }
  if (creating_obstacles) {
    stroke(175);
    strokeWeight(20);
    line(obstacles.start_p.x, obstacles.start_p.y, mouseX, mouseY);
  }

  /*
  for (Boid boid : boids) {
   boid.applyBehaviors();
   boid.update();
   boid.display();
   }
   */
  //fill(255);
  //stroke(0);
  //text("Drag the mouse to generate new boids.", 10, height-30);
  //text("Number of boids: " + flock.boids.size(), 10, height - 20);
  //text("Framerate: " + round(frameRate), 10, height - 10);
  /* 
   if (cpanel.updated) {
   cpanel.render();
   cpanel.updated = false;
   println("Drew the panel!");
   }
   */
  cpanel.render();

  //println(Cohesion);
  //println("-----");
  //println(cohesion);
  //println(separation);
  //println(alignment);
  //println("-----");
}

void mouseDragged() {
  if (keyPressed == true && keyCode == SHIFT && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    flock.addBoid(new Boid(mouseX, mouseY));
  }
}

void mousePressed() {
  if (!eraser_mode && !creating_obstacles) {
    obstacles.startObstacle(mouseX, mouseY);
  } else  if (!eraser_mode) {
    obstacles.endObstacle(mouseX, mouseY);
  }
  if (eraser_mode) {
    obstacles.eraseObstacle(mouseX, mouseY);
  }

  if (eraser_mode && mouseButton == LEFT && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    flock.addBoid(new Boid(mouseX, mouseY));
  }
}

/*
void mousePressed() {
 if (mouseButton == LEFT) {
 boids.add(new Boid(mouseX, mouseY));
 } else if (mouseButton == RIGHT) {
 target = new PVector(mouseX, mouseY);
 }
 }
 
 void mouseDragged() {
 if (mouseButton == RIGHT) {    
 target = new PVector(mouseX, mouseY);
 }
 }
 
 */

void keyPressed() {
  switch (key) {
  case 'a':
    //seeking = !seeking;
    if (!seeking) rbtn_seeking(0);
    else rbtn_seeking(2);
    break;
  case 'r':
    //avoiding = !avoiding;
    if (!avoiding) rbtn_seeking(1);
    else rbtn_seeking(2);
    break;
  case 'n':
    rbtn_seeking(2);
    break;
  case ' ':
    //separating = !separating;
    break;
  case 'c':
    flock.clearBoids();
    break;
  case 'h':
    cpanel.toggleShow();
    break;
  case 'k':
    obstacles.empty();
    break;
  case 'e':
    creating_obstacles = false;
    eraser_mode = !eraser_mode;
    break;
  default:
    break;
  }
}

/*
void mousePressed() {
 if (mouseButton == LEFT) {
 boids.add(new Boid(mouseX, mouseY));
 }
 else if (mouseButton == RIGHT) {
 target = new PVector(mouseX, mouseY);
 }
 }
 */
/*

 void flock(ArrayList<Boid> boids) {
 PVector sep = separate(boids);
 PVector ali = align(boids);
 PVector coh = cohesion(boids);
 
 sep.mult(1.5);
 ali.mult(1.0);
 coh.mult(1.0);
 
 applyForce(sep);
 applyForce(ali);
 applyForce(coh);
 }
 
 */

/*
void killAllBoids() {
 flock.boids.clear();
 }
 */