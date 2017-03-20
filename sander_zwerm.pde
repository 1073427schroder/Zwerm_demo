//Zwerm demo
//Start of code based of Daniel Shiffman's Nature of Code Chapter 6

//Modes
enum Mode {
  BOIDS, ADD_OBS, ERASE_OBS
}
Mode mode = Mode.BOIDS;

//values for scaling en colors
float obs_scl = 1.0f;
float boid_scl = 2.0f;
float ui_scl = 1.0f;
int background_c = 255; //70
int obs_c = #D12A2A; //175
int boid_c = #532AD1; //255
int eraser_c = #E000FF; //255



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

//List of all boids
Flock flock;

//List of all obstacles
Obstacles obstacles;

//Setup code
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

  //Window resizable
  surface.setResizable(true);
  //Set size to max size, otherwise the 
  //ControlP5 buttons stop working
  size(displayWidth, displayHeight);
  //Check for highresolution screens
  pixelDensity(displayDensity());
  //Set frame rate
  frameRate(60);

  flock = new Flock();
  seeking = false;
  avoiding = false;
  for (int i = 0; i < 0; i++) {
    Boid b = new Boid(width/2, height/2);
    flock.addBoid(b);
  }
  cpanel = new ControlPanel(this);

  //Set windows size to a more manageable size
  surface.setSize(800, 600);
}

//Draw code, keeps looping
void draw() {
  //Draw background
  background(background_c);

  //Simulate flock
  flock.run();
  //Render obstacles
  obstacles.render();

  //Add blobs to cursor in certain modes
  //RF--RF//
  //Separate function?
  if (mode == Mode.ADD_OBS) {
    stroke(obs_c);
    strokeWeight(20*obs_scl);
    point(mouseX, mouseY);
  } else if (mode == Mode.ERASE_OBS) {
    stroke(eraser_c);
    strokeWeight(20*obs_scl);
    point(mouseX, mouseY);
  }
  if (creating_obstacles) {
    stroke(obs_c);
    strokeWeight(20*obs_scl);
    line(obstacles.start_p.x, obstacles.start_p.y, mouseX, mouseY);
  }
  //END--RF//

  //Draw the control panel
  cpanel.render();
}


void mouseDragged() {
  if (mode == Mode.BOIDS && mouseButton == RIGHT && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    //Add boids
    flock.addBoid(new Boid(mouseX, mouseY));
  } else if (mode == Mode.ERASE_OBS && mouseButton == LEFT && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    //Erase obstacles
    obstacles.eraseObstacle(mouseX, mouseY);
  }
}

void mousePressed() {
  if (mode == Mode.ADD_OBS && !creating_obstacles && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    //Start obstacle
    obstacles.startObstacle(mouseX, mouseY);
  } else  if (mode == Mode.ADD_OBS && mouseButton == LEFT && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    //End obstacle
    obstacles.endObstacle(mouseX, mouseY);
  } else  if (mode == Mode.ADD_OBS && creating_obstacles && mouseButton == RIGHT && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    //Continue obstacle
    obstacles.endObstacle(mouseX, mouseY);
    obstacles.startObstacle(mouseX, mouseY);
  }
  if (mode == Mode.ERASE_OBS) {
    //Erase obstacle
    obstacles.eraseObstacle(mouseX, mouseY);
  }

  if (mode == Mode.BOIDS && mouseX >= 0 && mouseX <= width - cpanel.cp_width && mouseY >= 0 && mouseY <= height) {
    //Add boid
    flock.addBoid(new Boid(mouseX, mouseY));
  }
}

//Keyboard shortcuts
void keyPressed() {
  //RF--RF//
  //change key to lower (case independent)
  switch (key) {
  case ESC:
  //println("esc pushed");
  creating_obstacles = false;
  key = 0;
    break;
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
    rbtn_mode(2);
    //if (mode != Mode.ERASE_OBS) mode = Mode.ERASE_OBS;
    //eraser_mode = !eraser_mode;
    break;
  case 'o':
    rbtn_mode(1);
    //if (mode != Mode.ADD_OBS) mode = Mode.ADD_OBS;
    //eraser_mode = !eraser_mode;
    break;
  case 'b':
    rbtn_mode(0);
    //  mode = Mode.BOIDS;
    break;
  default:
    break;
  }
}