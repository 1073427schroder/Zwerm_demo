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

    this.addControlP5Elements();
    old_width = width;
  }

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

  void setWidth() {
    this.cp_width = 280;
  }

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

  void addControlP5Elements() {

    this.cp5.addButton("btn_clear")
      .setPosition(width - this.cp_width + 20, 20)
      .setLabel("Clear")
      ;

    this.cp5.addRadioButton("rbtn_seeking")
      .setPosition(width - this.cp_width + 20, 60)
      .setSize(40, 20)
      .setColorForeground(color(120))
      .setColorActive(color(255))
      .setColorLabel(color(255))
      .setItemsPerRow(3)
      .setSpacingColumn(40)
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
      .setSpacingColumn(60)
      .addItem("Boids", 0)
      .addItem("Obstacles", 1)
      .addItem("Eraser", 2)
      ;





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




  void resetPositionControls() {
    //String[] controllers = { "btn_clear", "rbtn_seeking"};

    //println(controllers.length);
    //for (int i = 0; i < controllers.length; i++) {
    //  println("i= " + i);
    //  Controller c = cp5.getController(controllers[i]);
    //  println(c.getPosition());
    //}



    this.cp5.getController("btn_clear")
      .setPosition(width - this.cp_width + 20, 20);


    this.cp5.getController("toggle_c")
      .setPosition(width - this.cp_width + 20, 100);

    this.cp5.getController("toggle_s")
      .setPosition(width - this.cp_width + 100, 100);

    this.cp5.getController("toggle_a")
      .setPosition(width - this.cp_width + 180, 100);

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
  }
}

//ControlP5 events

public void btn_clear() {
  flock.clearBoids();
}

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
    mode = Mode.BOIDS;
    break;
  case 1:
    mode = Mode.ADD_OBS;
    break;
  case 2:
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




/*
public void checkBox(){
 println("testing checkbox"); 
 }
 */