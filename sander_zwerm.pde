//Test code zwerm
//Code based of Daniel Shiffman's Nature of Code Chapter 6


/*
ArrayList<Boid> boids;
 PVector target;
 Boolean avoiding;
 Boolean separating;
 */

Boolean separation;
Boolean cohesion;
Boolean alignment;

int c_power;
int s_power;
int a_power;

Boolean seeking;
Boolean avoiding;
ControlPanel cpanel;

Flock flock;


void setup() {
  alignment = true;
  cohesion = true;
  separation = true;
  
  
  c_power = 100;
  s_power = 100;
  a_power = 100;
  
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
   
  surface.setSize(800,600);
}

void draw() {
  background(70);

  flock.run();
  /*
  for (Boid boid : boids) {
   boid.applyBehaviors();
   boid.update();
   boid.display();
   }
   */
  fill(255);
  stroke(0);
  text("Drag the mouse to generate new boids.", 10, height-30);
  text("Number of boids: " + flock.boids.size(), 10, height - 20);
  text("Framerate: " + round(frameRate), 10, height - 10);
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
  if (mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
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