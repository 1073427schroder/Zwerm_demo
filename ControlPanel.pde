import controlP5.*;

class ControlPanel {
  Boolean show;
  int cp_width;
  ControlP5 cp5;
  int old_width;

  //constructor
  ControlPanel (PApplet thePApplet) {
    this.show = true;
    this.setWidth();  

    this.cp5 = new ControlP5(thePApplet);
    ControlWindow tmp = this.cp5.getWindow();
    tmp.setPositionOfTabs(width - this.cp_width, 0);

    this.cp5.setFont(createFont("Verdana", 12));

    this.addControlP5Elements();


    old_width = width;
  }

  //draw controlpanel
  void render() {
    if (this.show) {
      if (old_width != width) resetPositionControls();
      strokeWeight(1);
      fill(60);
      stroke(60);
      rect(width - this.cp_width, 0, this.cp_width, height);

      RadioButton tmp = this.cp5.get(RadioButton.class, "rbtn_seeking");

      if (seeking) tmp.activate(0);
      else if (avoiding) tmp.activate(1);
      else tmp.activate(2);


      tmp = this.cp5.get(RadioButton.class, "rbtn_mode");

      if (mode == Mode.BOIDS) tmp.activate(0);
      else if (mode == Mode.ADD_OBS) tmp.activate(1);
      else if (mode == Mode.ERASE_OBS) tmp.activate(2);




      fill(255);
      stroke(0);
      text("Drag the mouse to generate new boids.", width - this.cp_width + 10, height-30);
      text("Number of boids: " + flock.boids.size(), width - this.cp_width + 10, height - 20);
      text("Framerate: " + round(frameRate), width - this.cp_width + 10, height - 10);
    }
  }

  //set width of control panel
  void setWidth() {
    this.cp_width = floor(300 * ui_scl);
  }

  //hide unhide control panel
  void toggleShow() {
    this.show = !this.show;
    if (this.show) {
      this.setWidth();
      this.render();
      this.cp5.show();
    } else {
      this.cp_width = 0;
      this.cp5.hide();
    }
  }

  //setup controlP5 elements
  //RF--RF//
  //Move the positioning to other function, call other function at the end
  void addControlP5Elements() {

    this.cp5.addButton("btn_clear")
      .setPosition(width - this.cp_width + 20, 20)
      .setLabel("Clear")
      ;

    this.cp5.addButton("btn_reset")
      .setPosition(width - this.cp_width + 60, 20)
      .setLabel("Reset")
      ;

    this.cp5.addRadioButton("rbtn_seeking")
      .setPosition(width - this.cp_width + 20, 60)
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
      .setPosition(width - this.cp_width + 20, 100)
      .setSize(40, 20)
      .setValue(cohesion)
      .setLabel("Cohesion")
      ;
    //reset first toggle
    cohesion = !cohesion;

    this.cp5.addToggle("toggle_s")
      .setPosition(width - this.cp_width + 100, 100)
      .setSize(40, 20)
      .setValue(separation)
      .setLabel("Separation")
      ;
    //reset first toggle
    separation = !separation;


    this.cp5.addToggle("toggle_a")
      .setPosition(width - this.cp_width + 180, 100)
      .setSize(40, 20)
      .setValue(alignment)
      .setLabel("Alignment")
      ;
    //reset first toggle
    alignment = !alignment;

    this.cp5.addSlider("c_power")
      .setPosition(width - this.cp_width + 20, 140)
      .setRange(0, 200)
      .setSize(100, 20)
      .setLabel("Cohesion power")
      ;

    this.cp5.addSlider("s_power")
      .setPosition(width - this.cp_width + 20, 180)
      .setRange(0, 200)
      .setSize(100, 20)
      .setLabel("Separation power");
    ;

    this.cp5.addSlider("a_power")
      .setPosition(width - this.cp_width + 20, 220)
      .setRange(0, 200)
      .setSize(100, 20)
      .setLabel("Alignment power")
      ;

    this.cp5.addSlider("desired_s")
      .setPosition(width - this.cp_width + 20, 260)
      .setRange(0, 80)
      .setSize(100, 20)
      .setLabel("Separation distance")
      ;
    this.cp5.addSlider("neighbor_d")
      .setPosition(width - this.cp_width + 20, 300)
      .setRange(0, 250)
      .setSize(100, 20)
      .setLabel("Neighbor distance")
      ;

    this.cp5.addRadioButton("rbtn_mode")
      .setPosition(width - this.cp_width + 20, 340)
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

    this.cp5.addTab("color")
      //.setPosition(width - this.cp_width, 0)
      ;


    cp5.addColorWheel("c", width - this.cp_width + 20, 20, 200 )
      .moveTo("color")
      .setLabel("Boids Color")
      ;
    //cp5.addColorWheel("c", width - this.cp_width + 20, 380, this.cp_width - 40 ).setRGB(color(255, 255, 255));
    cp5.addColorWheel("background_c", width - this.cp_width + 20, 20 + this.cp_width - 20, 200  )
      .moveTo("color")
      .setLabel("Background Color");
    ;
    cp5.addColorWheel("obs_c", width - this.cp_width + 20, 20 + this.cp_width*2 - 20, 200 )
      .moveTo("color")
      .setLabel("Obstacle Color")
      ;

    this.cp5.addTab("scaling");

    cp5.addSlider("boid_scl")
      .setPosition(width - this.cp_width + 20, 20)
      .setRange(0.5, 10)
      .setSize(100, 20)
      .setLabel("Boid Scale")
      .moveTo("scaling")
      ;

    cp5.addSlider("obs_scl")
      .setPosition(width - this.cp_width + 20, 60)
      .setRange(0.5, 10)
      .setSize(100, 20)
      .setLabel("Obstacle Scale")
      .moveTo("scaling")
      ;

    //cp5.addSlider("ui_scl_sl")
    //  .setPosition(width - this.cp_width + 20, 100)
    //  .setValue(ui_scl)
    //  .setRange(0.5, 3)
    //  .setSize(100, 20)
    //  .setLabel("UI Scale")
    //  .moveTo("scaling")
    //  ;


    //.activate(2);
    //;

    /*
    this.cp5.addCheckBox("checkBox")
     .setPosition(width - this.cp_width + 20, 60)
     .setSize(40, 40)
     .setItemsPerRow(3)
     .setSpacingColumn(40)
     .setSpacingRow(20)
     .addItem("Attract", 0)
     .addItem("Repel", 50)
     .addItem("Neutral", 100)
     ;
     */
  }



  //this is the other function
  void resetPositionControls() {

    //println("resetting...");
    //String[] controllers = { "btn_clear", "rbtn_seeking"};

    //println(controllers.length);
    //for (int i = 0; i < controllers.length; i++) {
    //  println("i= " + i);
    //  Controller c = cp5.getController(controllers[i]);
    //  println(c.getPosition());
    //}



    this.cp5.getController("btn_clear")
      .setPosition(width - this.cp_width + 20, 20);


    this.cp5.getController("btn_reset")
      .setPosition(width - this.cp_width + 100, 20);


    this.cp5.getController("toggle_c")
      .setPosition(width - this.cp_width + 20, 95);

    this.cp5.getController("toggle_s")
      .setPosition(width - this.cp_width + 100, 95);

    this.cp5.getController("toggle_a")
      .setPosition(width - this.cp_width + 180, 95);

    RadioButton tmp = this.cp5.get(RadioButton.class, "rbtn_seeking");
    tmp.setPosition(width - this.cp_width + 20, 60);
    tmp = this.cp5.get(RadioButton.class, "rbtn_mode");
    tmp.setPosition(width - this.cp_width + 20, 340);

    this.cp5.getController("c_power")
      .setPosition(width - this.cp_width + 20, 140);

    this.cp5.getController("s_power")
      .setPosition(width - this.cp_width + 20, 180);

    this.cp5.getController("a_power")
      .setPosition(width - this.cp_width + 20, 220);


    this.cp5.getController("desired_s")
      .setPosition(width - this.cp_width + 20, 260);


    this.cp5.getController("neighbor_d")
      .setPosition(width - this.cp_width + 20, 300);



    this.cp5.getController("c")
      .setPosition(width - this.cp_width + 20, 20)
      ;
    this.cp5.getController("background_c")
      .setPosition(width - this.cp_width + 20, 20 + this.cp_width - 40);
    ;
    this.cp5.getController("obs_c")
      .setPosition(width - this.cp_width + 20, 20 + this.cp_width*2 - 40*2);
    ;


    ControlWindow wind = this.cp5.getWindow();
    wind.setPositionOfTabs(width - this.cp_width, 0);


    cp5.getController("boid_scl")
      .setPosition(width - this.cp_width + 20, 20);

    cp5.getController("obs_scl")
      .setPosition(width - this.cp_width + 20, 60);


    //cp5.getController("ui_scl_sl")
    //.setPosition(width - this.cp_width + 20, 100);

    //Tab test = this.cp5.get(Tab.class, "color");
    //println(test.isMoveable());

    //this.cp5.getTab("color")
    ////.setPosition(50,50)
    //.setMoveable(true)
    //;






    //.setSize(40, 20)
    //.setColorForeground(color(120))
    //.setColorActive(color(255))
    //.setColorLabel(color(255))
    //.setItemsPerRow(3)
    //.setSpacingColumn(40)
    //.addItem("Attract", 0)
    //.addItem("Repel", 1)
    //.addItem("Neutral", 2);


    //this.cp5.addToggle("toggle_c")
    //.setPosition(width - this.cp_width + 20, 100)
    //.setSize(40, 20)
    //.setValue(cohesion)
    //.setLabel("Cohesion");
    ////reset first toggle
    //cohesion = !cohesion;

    //this.cp5.addToggle("toggle_s")
    //.setPosition(width - this.cp_width + 100, 100)
    //.setSize(40, 20)
    //.setValue(separation)
    //.setLabel("Separation");
    ////reset first toggle
    //separation = !separation;


    //this.cp5.addToggle("toggle_a")
    //.setPosition(width - this.cp_width + 180, 100)
    //.setSize(40, 20)
    //.setValue(alignment)
    //.setLabel("Alignment");
    ////reset first toggle
    //alignment = !alignment;
    this.old_width = width;
  }


  //sync controlpanel with values
  //Not working yet
  //possible workaround link the toggles to the values
  public void sync_panel() {



    this.cp5.getController("toggle_c");

    this.cp5.getController("toggle_s")
      .setPosition(width - this.cp_width + 100, 95);

    this.cp5.getController("toggle_a")
      .setPosition(width - this.cp_width + 180, 95);

    RadioButton tmp = this.cp5.get(RadioButton.class, "rbtn_seeking");
    tmp.setPosition(width - this.cp_width + 20, 60);
    tmp = this.cp5.get(RadioButton.class, "rbtn_mode");
    tmp.setPosition(width - this.cp_width + 20, 340);

    this.cp5.getController("c_power")
      .setPosition(width - this.cp_width + 20, 140);

    this.cp5.getController("s_power")
      .setPosition(width - this.cp_width + 20, 180);

    this.cp5.getController("a_power")
      .setPosition(width - this.cp_width + 20, 220);


    this.cp5.getController("desired_s")
      .setPosition(width - this.cp_width + 20, 260);


    this.cp5.getController("neighbor_d")
      .setPosition(width - this.cp_width + 20, 300);



    this.cp5.getController("c")
      .setPosition(width - this.cp_width + 20, 20)
      ;
    this.cp5.getController("background_c")
      .setPosition(width - this.cp_width + 20, 20 + this.cp_width - 40);
    ;
    this.cp5.getController("obs_c")
      .setPosition(width - this.cp_width + 20, 20 + this.cp_width*2 - 40*2);
    ;


    ControlWindow wind = this.cp5.getWindow();
    wind.setPositionOfTabs(width - this.cp_width, 0);


    cp5.getController("boid_scl")
      .setPosition(width - this.cp_width + 20, 20);

    cp5.getController("obs_scl")
      .setPosition(width - this.cp_width + 20, 60);
  }
}

//ControlP5 events

//Clear all boids
public void btn_clear() {
  flock.clearBoids();
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
  creating_obstacles = false;
  eraser_mode = false;

  alignment = true;
  cohesion = true;
  separation = true;


  c_power = 100;
  s_power = 100;
  a_power = 100;

  desired_s = 20.0f;
  neighbor_d = 50.0f;

  cpanel.sync_panel();
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
    creating_obstacles = false;
    mode = Mode.BOIDS;
    break;
  case 1:
    mode = Mode.ADD_OBS;
    break;
  case 2:  
    creating_obstacles = false;
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
  flock.changeColor(c);
  boid_c = c;
}

//void ui_scl_sl(float scl) {
//  ui_scl = scl;
//  cpanel.setWidth();
//  cpanel.resetPositionControls();
//}


/*
public void checkBox(){
 println("testing checkbox"); 
 }
 */