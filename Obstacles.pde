class Obstacles {
  ArrayList<Obstacle> obstacles;
  PVector startPosition;
  PVector endPosition;
  boolean creatingObstacles;

  Obstacles() {
    this.obstacles = new ArrayList<Obstacle>();
    this.startPosition = new PVector(0, 0);
    this.endPosition = new PVector(0, 0);
    this.creatingObstacles = false;
  }

  void render() {
    for (Obstacle o : this.obstacles) {
      o.drawObstacle();
    }
  }

  void addObstacle() {
    this.obstacles.add(new Obstacle(this.startPosition, this.endPosition));
    this.creatingObstacles = false;
  }

  void startObstacle(int x, int y) {
    this.startPosition.set(x, y);
    this.creatingObstacles = true;
  }

  void endObstacle(int x, int y) {
    this.endPosition.set(x, y);
    this.addObstacle();
  }

  void continueObstacle(int x, int y) {    
    this.endObstacle(x, y);
    this.startObstacle(x, y);
  }

  void eraseObstacle(int x, int y) {
    for (int i = this.obstacles.size() - 1; i >= 0; i--) {
      Obstacle o = this.obstacles.get(i);
      if (o.intersectsPoint(x, y)) {
        this.obstacles.remove(i);
      }
    }
  }

  void empty() {
    this.obstacles.clear();
  }
}