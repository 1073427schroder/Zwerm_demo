class Obstacle {
  PVector start_position;
  PVector end_position;

  Obstacle(PVector start, PVector end) {
    start_position = new PVector(start.x, start.y);
    end_position = new PVector(end.x, end.y);
  }

  void drawObstacle() {
    stroke(obs_c);
    strokeWeight(20);
    line(start_position.x, start_position.y, end_position.x, end_position.y);
    //println("sx: " + start_position.x +" sy: "+start_position.y +" ex: "+end_position.x +" ey: "+ end_position.y);
  }

  boolean intersectsPoint(int m_x, int m_y) {
    float distance = calcDistPointToLine(start_position, end_position, new PVector(m_x,m_y), new PVector());
    distance = sqrt(distance);
    //println(distance);
    if (distance < 20) return true;
    else return false;
    //return false;
  }

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