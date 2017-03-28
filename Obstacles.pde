class Obstacles {
  ArrayList<Obstacle> obstacles;
  PVector start_p;
  PVector end_p;
  
  //constructor
  Obstacles() {
    this.obstacles = new ArrayList<Obstacle>();
    start_p = new PVector(0, 0);
    end_p = new PVector(0, 0);
  }
   
  //add obstactle
  void addObstacle() {
    this.obstacles.add(new Obstacle(start_p, end_p));
    creating_obstacles = false;
  }

  //draw all obstacles
  void render() {
    for (Obstacle o : this.obstacles) {
      o.drawObstacle();
    }
  }

  //clear all obstacles
  void empty() {
    this.obstacles.clear();
  }

  //start obstacle
  void startObstacle(int x, int y) {
    start_p.set(x, y);
    creating_obstacles = true;
  }
  
  //end obstacle
  void endObstacle(int x, int y) {
    end_p.set(x, y);
    this.addObstacle();
  }
  
  void continueObstacle(int x, int y){    
    this.endObstacle(x, y);
    this.startObstacle(x, y);
  }
  
  //delete obstacle
  void eraseObstacle(int x, int y) {
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle o = obstacles.get(i);
      if (o.intersectsPoint(x, y)) {
        obstacles.remove(i);
      }
    }
  }
}