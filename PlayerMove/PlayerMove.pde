ArrayList<Line> lines;
Line line;
Ray ray;
Player player;

final float MAX_LINE_LENGTH = 500;

/* 
 * Tests whether a point (x, y) 
 * falls within a rectangular bounding box around a Line l.
 * Use this to decide whether a point lies on a line-segment
 */
boolean between(float x, float y, Line l) {
  float lowx = min(l.a.x, l.b.x);
  float lowy = min(l.a.y, l.b.y);
  float highx = max(l.a.x, l.b.x);
  float highy = max(l.a.y, l.b.y);
  // round to help fix errors in floating point numbers
  x = round(1000*x)/1000;
  y = round(1000*y)/1000;
  
  //print("checking x: ", lowx, " < " , x , " < " , highx, "\n");
  //print("and also y: ", lowy, " < " , y , " < " , highy, "\n");
  return (lowx <= x && x <= highx && lowy <= y && y <= highy);
}

/* 2D Determinant */
/* | a11, a12 | */
/* | a21, a22 | */
float det(float a11, float a12, float a21, float a22) {
  return (a11 * a22) - (a12 * a21);
}

/* returns the point where two lines (not line segments) intersect */
/* please check for paralell lines first */
PVector intersection(Line l1, Line l2) {
  PVector p = new PVector();
  float x1 = l1.a.x;
  float x2 = l1.b.x;
  float x3 = l2.a.x;
  float x4 = l2.b.x;
  float y1 = l1.a.y;
  float y2 = l1.b.y;
  float y3 = l2.a.y;
  float y4 = l2.b.y;
  // I got this formula from wikipedia
  float d1 = det(det(x1, y1, x2, y2), det(x1, 1, x2, 1), det(x3, y3, x4, y4), det(x3, 1, x4, 1));
  float d2 = det(det(x1, 1, x2, 1), det(y1, 1, y2, 1), det(x3, 1, x4, 1), det(y3, 1, y4, 1));
  p.x = d1 / d2;
  float d3 = det(det(x1, y1, x2, y2), det(y1, 1, y2, 1), det(x3, y3, x4, y4), det(y3, 1, y4, 1));
  float d4 = det(det(x1, 1, x2, 1), det(y1, 1, y2, 1), det(x3, 1, x4, 1), det(y3, 1, y4, 1));
  p.y = d3 / d4;
  
  return p;
}

/* Checks if the slopes of lines is equal */
boolean paralell(Line l1, Line l2) {
  // prevent divide by zero by just checking this case manually
  if (l1.a.x == l1.b.x || l2.a.x == l2.b.x) {
      return (l1.a.x == l1.b.x && l2.a.x == l2.b.x);
  }
  
  float m1 = (l1.a.y - l1.b.y)/(l1.a.x - l1.b.x);
  float m2 = (l2.a.y - l2.b.y)/(l2.a.x - l2.b.x);
  return m1 == m2;
}

class Line {
  PVector a, b;
  Line(PVector a, PVector b) {
    this.a = a;
    this.b = b;
  }
  
  Line(float ax, float ay, float bx, float by) {
    this.a = new PVector(ax, ay);
    this.b = new PVector(bx, by);
  }
  
  void show() {
    line(a.x, a.y, b.x, b.y);
  }
  
  float length() {
    return sqrt(pow(b.y - a.y, 2) + pow(b.x - a.x, 2));
  }
}

class Ray {
  float x, y, theta;
  Ray(float x, float y, float theta) {
    this.x = x;
    this.y = y;
    this.theta = theta;
  }
  
  /* Returns the ray as a line with unit length */
  Line toLine() {
    Line l = new Line(x, y, x + cos(theta), y + sin(theta));
    return l;
  }
  
  /* Returns the ray as a line with len length */
  Line toLine(float len) {
    Line l = new Line(x, y, x + len * cos(theta), y + len *sin(theta));
    return l;
  }
  
  /* gives distance to line segment if possible, -1 otherwise */
  float distanceTo(Line l) {
    Line r = this.toLine(MAX_LINE_LENGTH); // length larger than screen required
    boolean valid = false;
    if (!paralell(l, r)) {
      PVector intersect = intersection(l, r);
      if (between(intersect.x, intersect.y, l) && between(intersect.x, intersect.y, r)) {
        r.b.x = intersect.x;
        r.b.y = intersect.y;
        valid = true;
      }
    }
    if (valid) {
      return r.length();
    } else {
      return -1;
    }
  }
  void show_toLines(ArrayList<Line> a) {
    float min_distance = MAX_LINE_LENGTH;
    int i=0;
    for (Line l : a) {
      float d = distanceTo(l);
      //print("Distance to ", i++, "was ");
      if (d > 0 && d < min_distance) {
        //print(d, "\n");
        min_distance = d;
      } else {
        //print("n/a\n");
      }
    }
    
    Line r = toLine(min_distance);
    r.show();

  }
  
  void show_toLine(Line l) {
    Line r = this.toLine(MAX_LINE_LENGTH); // length larger than screen required
    if (!paralell(l, r)) {
      PVector intersect = intersection(l, r);
      if (between(intersect.x, intersect.y, l) && between(intersect.x, intersect.y, r)) {
        //print("ray and line intersected\n");
        r.b.x = intersect.x;
        r.b.y = intersect.y;
      } else {
        //print("ray and line do not intersect\n");
      }
    } else {
      //print("ray and line paralell\n");
    }
    r.show();
  }
}

class Player {
  Ray viewL, viewR;
  float x, y, theta;
  float v, dTheta;
  float viewAngle;
  
  Player(float x, float y, float theta, float viewAngle) {
    viewL = new Ray(x, y, theta-viewAngle/2);
    viewR = new Ray(x, y, theta+viewAngle/2);
  }
  Player() {
    x = width/2;
    y = height/2;
    theta = 0;
    viewAngle = PI/3; // radians
    viewL = new Ray(x, y, theta-viewAngle/2);
    viewR = new Ray(x, y, theta+viewAngle/2);
  }
  
  /* Update rays to match player x, y, and theta */
  void update() {
    if (v != 0) {
      step(v);
    }
    theta += dTheta;
    viewL.x = x;
    viewL.y = y;
    viewL.theta = theta-viewAngle/2;
    viewR.x = x;
    viewR.y = y;
    viewR.theta = theta+viewAngle/2;
  }
  
  void show(ArrayList<Line> a) {
    update();
    viewL.show_toLines(a);
    viewR.show_toLines(a);
  }
  
  /* Moves Player some distance in the current theta direction */
  void step(float distance) {
    x += distance * cos(theta);
    y += distance * sin(theta);
  }
  
}

void setup() {  
  size(500,500);
  ray = new Ray(250, 250, 0.5);
  lines = new ArrayList<Line>();
  Line line1 = new Line(200, 400, 400, 400);
  Line line2 = new Line(170, 350, 345, 410);
  line = new Line(50, 85, 200, 70);
  lines.add(line);
  lines.add(line2);
  lines.add(line1);
  for (int i=0; i<3; i++) {
    lines.add(new Line(random(MAX_LINE_LENGTH), random(MAX_LINE_LENGTH), random(MAX_LINE_LENGTH), random(MAX_LINE_LENGTH)));
  }
  player = new Player();
}


void draw() {
  background(255);
  stroke(0);
  for(Line l : lines) {
    l.show();
  }
  
  stroke(255,0,0);
  //ray.show_toLine(line);
  ray.show_toLines(lines);
  ray.theta += 0.01;
  
  stroke(0, 255, 0);
  player.show(lines);
}

void keyPressed() {
  if (keyCode == UP || key == 'w' || key == 'W') {
    player.v = 1;
  } else if (keyCode == DOWN || key == 's' || key == 'S') {
    player.v = -1;
  } else if (keyCode == LEFT || key == 'a' || key == 'A') {
    player.dTheta = -0.02;
  } else if (keyCode == RIGHT || key == 'd' || key == 'D') {
    player.dTheta = 0.02;
  }
}

void keyReleased() {
  if (keyCode == UP || key == 'w' || key == 'W' || keyCode == DOWN || key == 's' || key == 'S') {
    player.v = 0;
  } else if (keyCode == LEFT || key == 'a' || key == 'A' || keyCode == RIGHT || key == 'd' || key == 'D') {
    player.dTheta = 0;
  } 
}
