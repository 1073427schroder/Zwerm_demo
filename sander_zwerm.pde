//Zwerm demo
//Start of code based of Daniel Shiffman's Nature of Code Chapter 6

//Modes
enum Mode {
  BOIDS, ADD_OBS, ERASE_OBS, SPECIAL_BOIDS
}
Mode mode = Mode.BOIDS;

boolean disableTurnAround = true;
boolean collisionDanger = false;
int timestampCollisionDanger = millis();
int numberOfTurns = 0;

//values for scaling en colors
float obs_scl = 1.0f;
float boid_scl = 2.0f;
float ui_scl = 1.0f;
int background_c = 255; //70
int obs_c = #D12A2A; //175
int boid_c = #532AD1; //255
int eraser_c = #E000FF; //255

int id_counter = 0;

//Boolean creatingObstacles = false;
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

//Keeps track of the boids
Flock flock;

//Keeps track of the obstacles
Obstacles obstacles;

//Setup code, ran only once
void setup() {
  //Set size to max size, otherwise the 
  //ControlP5 buttons stop working
  size(displayWidth, displayHeight);

  createObjects();
  setStartValues();

  //Create panel with max size, otherwise the
  //ControlP5 buttons stop working
  cpanel = new ControlPanel(this);

  //Setup rest of window
  setupWindow();
}

void createObjects() {  
  obstacles = new Obstacles();
  flock = new Flock();
}

void setStartValues() {
  alignment = true;
  cohesion = true;
  separation = true;

  seeking = false;
  avoiding = false;

  c_power = 100;
  s_power = 100;
  a_power = 100;

  desired_s = 20.0f;
  neighbor_d = 50.0f;
}

void setupWindow() {
  //Window resizable
  surface.setResizable(true);
  //Check for highresolution screens
  pixelDensity(displayDensity());
  //Set frame rate
  frameRate(60);
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

  //Add blobs and line to cursor in certain modes
  drawCursorBlobAndLine();

  //Draw the control panel
  cpanel.render();
}

//Add blobs and line to cursor in certain modes
void drawCursorBlobAndLine() {
  if (mode == Mode.ADD_OBS) {           //draw obstacle blob at cursor
    stroke(obs_c);
    strokeWeight(20*obs_scl);
    point(mouseX, mouseY);
  } else if (mode == Mode.ERASE_OBS) {  //draw eraser blob at cursor
    stroke(eraser_c);
    strokeWeight(20*obs_scl);
    point(mouseX, mouseY);
  }
  if (obstacles.creatingObstacles) {             //draw line from obstacle to cursor
    stroke(obs_c);
    strokeWeight(20*obs_scl);
    line(obstacles.startPosition.x, obstacles.startPosition.y, mouseX, mouseY);
  }
}

void mouseDragged() {
  if (canAddBoids() && mouseButton == RIGHT) {
    flock.addBoid(new Boid(mouseX, mouseY));
  } else if (canAddSpecialBoids() && mouseButton == RIGHT) {
    flock.addSpecialBoid(new Boid(mouseX, mouseY));
  } else if (canErase()) {
    obstacles.eraseObstacle(mouseX, mouseY);
  }
}

void mousePressed() {
  if (canAddObstacles() && !obstacles.creatingObstacles) {
    obstacles.startObstacle(mouseX, mouseY);
  } else  if (canAddObstacles() && mouseButton == LEFT) {
    obstacles.endObstacle(mouseX, mouseY);
  } else  if (canAddObstacles() && obstacles.creatingObstacles && mouseButton == RIGHT) {
    obstacles.continueObstacle(mouseX, mouseY);
  }

  if (canErase()) {
    obstacles.eraseObstacle(mouseX, mouseY);
  }

  if (canAddBoids()) {
    flock.addBoid(new Boid(mouseX, mouseY));
  }

  if (canAddSpecialBoids()) {
    flock.addSpecialBoid(new Boid(mouseX, mouseY));
  }
}

boolean canAddBoids() {
  return (mode == Mode.BOIDS && mouseX >= 0 && mouseX <= width - cpanel.cpWidth && mouseY >= 0 && mouseY <= height);
}

boolean canAddSpecialBoids() {
  return (mode == Mode.SPECIAL_BOIDS && mouseX >= 0 && mouseX <= width - cpanel.cpWidth && mouseY >= 0 && mouseY <= height);
}

boolean canErase() {
  return (mode == Mode.ERASE_OBS && mouseButton == LEFT && mouseX >= 0 && mouseX <= width - cpanel.cpWidth && mouseY >= 0 && mouseY <= height);
}

boolean canAddObstacles() {
  return (mode == Mode.ADD_OBS && mouseX >= 0 && mouseX <= width - cpanel.cpWidth && mouseY >= 0 && mouseY <= height);
}

//Keyboard shortcuts
void keyPressed() {
  key = Character.toLowerCase(key);  //keyboard shortcuts case insensitive
  switch (key) {
  case ESC:
    obstacles.creatingObstacles = false;
    //escape the escape key, prevent close down
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
    obstacles.creatingObstacles = false;
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