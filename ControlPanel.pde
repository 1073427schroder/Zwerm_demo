import controlP5.*;

class ControlPanel {
  Boolean showing;
  int cpWidth;
  ControlP5 cp5;
  int oldWindowWidth;

  ControlPanel (PApplet thePApplet) {
    this.showing = true;
    this.setWidth();  

    this.cp5 = new ControlP5(thePApplet);    
    ControlWindow window = this.cp5.getWindow();
    window.setPositionOfTabs(width - this.cpWidth, 0);
    this.cp5.setFont(createFont("Verdana", 12));    
    this.addControlP5Elements();
    this.setPositionControls();

    oldWindowWidth = width;
  }

  void setWidth() {
    this.cpWidth = 300;
  }

  //draw controlpanel
  void render() {
    if (this.showing) {
      if (oldWindowWidth != width) setPositionControls();
      strokeWeight(1);
      fill(60);
      stroke(60);
      rect(width - this.cpWidth, 0, this.cpWidth, height);

      RadioButton rbtn = this.cp5.get(RadioButton.class, "rbtn_seeking");

      if (seeking) rbtn.activate(0);
      else if (avoiding) rbtn.activate(1);
      else rbtn.activate(2);

      rbtn = this.cp5.get(RadioButton.class, "rbtn_mode");

      if (mode == Mode.BOIDS) rbtn.activate(0);
      else if (mode == Mode.ADD_OBS) rbtn.activate(1);
      else if (mode == Mode.ERASE_OBS) rbtn.activate(2);
      
      drawText();
    }
  }

  void drawText() {
    fill(255);
    stroke(0);
    text("Drag the mouse to generate new boids.", width - this.cpWidth + 10, height - 30);
    text("Number of boids: " + flock.boids.size(), width - this.cpWidth + 10, height - 20);
    text("Framerate: " + round(frameRate), width - this.cpWidth + 10, height - 10);
  }



  //hide and unhide control panel
  void toggleShow() {
    this.showing = !this.showing;
    if (this.showing) {
      this.setWidth();
      this.render();
      this.cp5.show();
    } else {
      this.cpWidth = 0;
      this.cp5.hide();
    }
  }

  //setup controlP5 elements
  void addControlP5Elements() {
    //Default Tab
    this.cp5.addButton("btn_clear")
      .setLabel("Clear")
      ;

    this.cp5.addButton("btn_reset")
      .setLabel("Reset")
      ;

    this.cp5.addRadioButton("rbtn_seeking")
      .setSize(20, 20)
      .setColorForeground(color(120))
      .setColorActive(color(255))
      .setColorLabel(color(255))
      .setItemsPerRow(3)
      .setSpacingColumn(60)
      .addItem("Attract", 0)
      .addItem("Repel", 1)
      .addItem("Neutral", 2)
      ;

    this.cp5.addToggle("toggle_c")
      .setSize(40, 20)
      .setValue(cohesion)
      .setLabel("Cohesion")
      ;
    //reset first toggle
    cohesion = !cohesion;

    this.cp5.addToggle("toggle_s")
      .setSize(40, 20)
      .setValue(separation)
      .setLabel("Separation")
      ;
    //reset first toggle
    separation = !separation;

    this.cp5.addToggle("toggle_a")
      .setSize(40, 20)
      .setValue(alignment)
      .setLabel("Alignment")
      ;
    //reset first toggle
    alignment = !alignment;

    this.cp5.addSlider("c_power")
      .setRange(0, 200)
      .setSize(100, 20)
      .setLabel("Cohesion power")
      ;

    this.cp5.addSlider("s_power")
      .setRange(0, 200)
      .setSize(100, 20)
      .setLabel("Separation power")
      ;

    this.cp5.addSlider("a_power")
      .setRange(0, 200)
      .setSize(100, 20)
      .setLabel("Alignment power")
      ;

    this.cp5.addSlider("desired_s")
      .setRange(0, 80)
      .setSize(100, 20)
      .setLabel("Separation distance")
      ;

    this.cp5.addSlider("neighbor_d")
      .setRange(0, 250)
      .setSize(100, 20)
      .setLabel("Neighbor distance")
      ;

    this.cp5.addRadioButton("rbtn_mode")
      .setSize(20, 20)
      .setColorForeground(color(120))
      .setColorActive(color(255))
      .setColorLabel(color(255))
      .setItemsPerRow(5)
      .setSpacingColumn(80)
      .addItem("Boids", 0)
      .addItem("Obstacles", 1)
      .addItem("Eraser", 2)
      ;

    //Color Tab
    this.cp5.addTab("color");

    cp5.addColorWheel("c", width - this.cpWidth + 20, 20, 200 )
      .moveTo("color")
      .setLabel("Boids Color")
      ;

    cp5.addColorWheel("background_c", width - this.cpWidth + 20, 20 + this.cpWidth - 20, 200  )
      .moveTo("color")
      .setLabel("Background Color")
      ;

    cp5.addColorWheel("obs_c", width - this.cpWidth + 20, 20 + this.cpWidth*2 - 20, 200 )
      .moveTo("color")
      .setLabel("Obstacle Color")
      ;

    //Scaling Tab
    this.cp5.addTab("scaling");

    cp5.addSlider("boid_scl")
      .setRange(0.5, 10)
      .setSize(100, 20)
      .setLabel("Boid Scale")
      .moveTo("scaling")
      ;

    cp5.addSlider("obs_scl")
      .setRange(0.5, 10)
      .setSize(100, 20)
      .setLabel("Obstacle Scale")
      .moveTo("scaling")
      ;

    //Scenaria Tab
    this.cp5.addTab("scenario's");

    cp5.addButton("btnTriangle")
      .setSize(100, 20)
      .setLabel("Triangle")
      .moveTo("scenario's")
      ;

    cp5.addButton("btnWarehouse")
      .setSize(100, 20)
      .setLabel("Warehouse")
      .moveTo("scenario's")
      ;

    cp5.addButton("btnOctagon")
      .setSize(100, 20)
      .setLabel("Octagon")
      .moveTo("scenario's")
      ;

    cp5.addButton("btnTurnAround")
      .setSize(100, 20)
      .setLabel("TurnAround")
      ;
  }

  void setPositionControls() {
    //Default Tab
    this.cp5.getController("btn_clear")
      .setPosition(width - this.cpWidth + 20, 20);

    this.cp5.getController("btn_reset")
      .setPosition(width - this.cpWidth + 100, 20);

    this.cp5.getController("toggle_c")
      .setPosition(width - this.cpWidth + 20, 95);

    this.cp5.getController("toggle_s")
      .setPosition(width - this.cpWidth + 100, 95);

    this.cp5.getController("toggle_a")
      .setPosition(width - this.cpWidth + 180, 95);

    RadioButton rbtn = this.cp5.get(RadioButton.class, "rbtn_seeking");
    rbtn.setPosition(width - this.cpWidth + 20, 60);
    rbtn = this.cp5.get(RadioButton.class, "rbtn_mode");
    rbtn.setPosition(width - this.cpWidth + 20, 340);

    this.cp5.getController("c_power")
      .setPosition(width - this.cpWidth + 20, 140);

    this.cp5.getController("s_power")
      .setPosition(width - this.cpWidth + 20, 180);

    this.cp5.getController("a_power")
      .setPosition(width - this.cpWidth + 20, 220);

    this.cp5.getController("desired_s")
      .setPosition(width - this.cpWidth + 20, 260);

    this.cp5.getController("neighbor_d")
      .setPosition(width - this.cpWidth + 20, 300);

    //Color Tab
    this.cp5.getController("c")
      .setPosition(width - this.cpWidth + 20, 20);

    this.cp5.getController("background_c")
      .setPosition(width - this.cpWidth + 20, 20 + this.cpWidth - 40);

    this.cp5.getController("obs_c")
      .setPosition(width - this.cpWidth + 20, 20 + this.cpWidth*2 - 40*2);

    //Scaling Tab
    this.cp5.getController("boid_scl")
      .setPosition(width - this.cpWidth + 20, 20);

    this.cp5.getController("obs_scl")
      .setPosition(width - this.cpWidth + 20, 60);

    //Scenario Tab
    this.cp5.getController("btnTriangle")
      .setPosition(width - this.cpWidth + 20, 20);

    this.cp5.getController("btnWarehouse")
      .setPosition(width - this.cpWidth + 20, 50);

    this.cp5.getController("btnTurnAround")
      .setPosition(width - this.cpWidth + 20, 380);

    this.cp5.getController("btnOctagon")
      .setPosition(width - this.cpWidth + 20, 80);

    //Tab position
    ControlWindow window = this.cp5.getWindow();
    window.setPositionOfTabs(width - this.cpWidth, 0);

    //Set width
    this.oldWindowWidth = width;
  }


  //Sync controlpanel with values
  public void sync_panel() {
    Toggle toggle = this.cp5.get(Toggle.class, "toggle_c");
    toggle.setValue(cohesion);
    toggle = this.cp5.get(Toggle.class, "toggle_s");
    toggle.setValue(separation);
    toggle = this.cp5.get(Toggle.class, "toggle_a");
    toggle.setValue(alignment);
    //toggle for the flip
    cohesion = !cohesion;
    separation = !separation;
    alignment = !alignment;

    this.cp5.getController("c_power")
      .setValue(c_power);

    this.cp5.getController("s_power")
      .setValue(s_power);

    this.cp5.getController("a_power")
      .setValue(a_power);


    this.cp5.getController("desired_s")
      .setValue(desired_s);

    this.cp5.getController("neighbor_d")
      .setValue(neighbor_d);

    this.cp5.getController("boid_scl")
      .setValue(boid_scl);

    this.cp5.getController("obs_scl")
      .setValue(obs_scl);
  }
}

//ControlP5 events

//Clear all boids
public void btn_clear() {
  flock.clearBoids();
  clearConsole();
}

//Reset everything
public void btn_reset() {
  flock.clearBoids();
  obstacles.empty();
  obs_scl = 1.0f;
  boid_scl = 2.0f;
  ui_scl = 1.0f;
  background_c = 255; //70
  obs_c = #D12A2A; //175
  boid_c = #532AD1; //255
  eraser_c = #E000FF; //255
  obstacles.creatingObstacles = false;
  eraser_mode = false;

  alignment = true;
  cohesion = true;
  separation = true;


  c_power = 100;
  s_power = 100;
  a_power = 100;

  desired_s = 20.0f;
  neighbor_d = 50.0f;


  seeking = false;
  avoiding = false;

  mode = Mode.BOIDS;

  cpanel.sync_panel();

  clearConsole();
}

void clearConsole() {
  for (int i = 0; i < 20; i++) println("");
}


//RF Could be changed out with the right values, maybe yes maybe no
public void rbtn_seeking(int mode) {
  seeking = false;
  avoiding = false;
  switch (mode) {
  case 0: 
    seeking = true;
    break;
  case 1:
    avoiding = true;
    break;
  case 2:
    break;
  default:
    break;
  }
}

public void rbtn_mode(int state) {
  switch (state) {
  case 0: 
    obstacles.creatingObstacles = false;
    mode = Mode.BOIDS;
    break;
  case 1:
    mode = Mode.ADD_OBS;
    break;
  case 2:  
    obstacles.creatingObstacles = false;
    mode = Mode.ERASE_OBS;
    break;
  default:
    break;
  }
}

void toggle_c() {
  cohesion = !cohesion;
}
void toggle_s() {
  separation = !separation;
}
void toggle_a() {
  alignment = !alignment;
}

void c(int c) {
  //flock.changeColor(c);
  boid_c = c;
}

void btnTriangle() {
  btn_reset();
  obstacles.startPosition.set((width-cpanel.cpWidth)*0.5, height*0.1);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.9, height*0.9);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.9);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.5, height*0.1);
  obstacles.addObstacle();
}

void btnWarehouse() {
  btn_reset(); 
  //house
  obstacles.startPosition.set((width-cpanel.cpWidth)*0.6, height*0.2);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.9, height*0.2);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.9, height*0.5);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.82, height*0.5);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.82, height*0.3);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.6, height*0.3);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.6, height*0.2);
  obstacles.addObstacle();

  //rack 1
  obstacles.startPosition.set((width-cpanel.cpWidth)*0.1, height*0.2);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.4, height*0.2);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.4, height*0.3);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.3);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.2);
  obstacles.addObstacle();  

  //rack 2
  obstacles.startPosition.set((width-cpanel.cpWidth)*0.1, height*0.5);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.4, height*0.5);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.4, height*0.6);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.6);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.5);
  obstacles.addObstacle();  

  //rack 3
  obstacles.startPosition.set((width-cpanel.cpWidth)*0.1, height*0.8);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.4, height*0.8);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.4, height*0.9);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.9);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.1, height*0.8);
  obstacles.addObstacle();
}

void btnOctagon() {
  btn_reset();

  //octagan  
  obstacles.startPosition.set((width-cpanel.cpWidth)*0.35, height*0.05);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.65, height*0.05);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.95, height*0.35);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.95, height*0.65);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.65, height*0.95);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.35, height*0.95);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.05, height*0.65);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.05, height*0.35);
  obstacles.addObstacle();
  obstacles.startPosition.set(obstacles.endPosition);
  obstacles.endPosition.set((width-cpanel.cpWidth)*0.35, height*0.05);
  obstacles.addObstacle();
}

void btnTurnAround() {
  flock.turnFlockAround();
}