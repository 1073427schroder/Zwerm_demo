class Obstacle {
  PVector startPosition;
  PVector endPosition;

  Obstacle(PVector start, PVector end) {
    this.startPosition = new PVector(start.x, start.y);
    this.endPosition = new PVector(end.x, end.y);
  }

  void drawObstacle() {
    stroke(obs_c);
    strokeWeight(20*obs_scl);
    line(this.startPosition.x, this.startPosition.y, this.endPosition.x, this.endPosition.y);
  }

  boolean intersectsPoint(int pointX, int pointY) {
    float distance = calcDistPointToLine(this.startPosition, this.endPosition, new PVector(pointX, pointY), new PVector());
    distance = sqrt(distance);
    if (distance < 20*obs_scl) return true;
    else return false;
  }

  //RF probably rewrite function
  // calculate the squared distance of a point P to a line segment A-B
  // and return the nearest line point S
  float calcDistPointToLine(PVector A, PVector B, PVector P, PVector S)
  {
    float vx = P.x-A.x, vy = P.y-A.y;   // v = A->P
    float ux = B.x-A.x, uy = B.y-A.y;   // u = A->B
    float det = vx*ux + vy*uy; 

    if (det <= 0)
    { // its outside the line segment near A
      S.set(A);
      return vx*vx + vy*vy;
    }
    float len = ux*ux + uy*uy;    // len = u^2
    if (det >= len)
    { // its outside the line segment near B
      S.set(B);
      return sq(B.x-P.x) + sq(B.y-P.y);
    }
    // its near line segment between A and B
    float ex = ux / sqrt(len);    // e = u / |u^2|
    float ey = uy / sqrt(len);
    float f = ex * vx + ey * vy;  // f = e . v
    S.x = A.x + f * ex;           // S = A + f * e
    S.y = A.y + f * ey;

    return sq(ux*vy-uy*vx) / len;    // (u X v)^2 / len
  }
}