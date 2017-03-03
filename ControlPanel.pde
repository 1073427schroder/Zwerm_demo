import controlP5.*;

class ControlPanel {
  Boolean show;
  int cp_width;
  ControlP5 cp5;

  //constructor
  ControlPanel (PApplet thePApplet) {
    this.show = true;
    this.setWidth();

    this.cp5 = new ControlP5(thePApplet);

    this.addControlP5Elements();
  }

  void render() {
    if (this.show) {
      fill(60);
      stroke(60);
      rect(width - this.cp_width, 0, this.cp_width, height);

      RadioButton tmp = cp5.get(RadioButton.class, "rbtn_seeking");

      if (seeking) tmp.activate(0);
      else if (avoiding) tmp.activate(1);
      else tmp.activate(2);
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
      .setLabel("Clear");

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
      .addItem("Neutral", 2);
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

/*
public void checkBox(){
 println("testing checkbox"); 
 }
 */