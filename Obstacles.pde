class Obstacles {
  ArrayList<Obstacle> obstacles;
  PVector start_p;
  PVector end_p;

  Obstacles() {
    this.obstacles = new ArrayList<Obstacle>();
    start_p = new PVector(0, 0);
    end_p = new PVector(0, 0);
  }

  void addObstacle() {
    this.obstacles.add(new Obstacle(start_p, end_p));
    creating_obstacles = false;
  }

  void render() {
    for (Obstacle o : this.obstacles) {
      o.drawObstacle();
    }
  }

  void empty() {
    this.obstacles.clear();
  }

  void startObstacle(int x, int y) {
    start_p.set(x, y);
    creating_obstacles = true;
  }

  void endObstacle(int x, int y) {
    end_p.set(x, y);
    this.addObstacle();
  }

  void eraseObstacle(int x, int y) {
    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle o = obstacles.get(i);
      if (o.intersectsPoint(x, y)) {
        obstacles.remove(i);
      }
    }
  }
}