/////Define the class Part

class Part {
  PVector pos;
  PVector vel;
  int halflife = 200;
  int col;
  float rad = 2;
  boolean stuck = false;
  boolean active = false;
  int tag;

  Part(float x, float y, int _col) {
    pos = new PVector(x, y);
    col = _col;
  }

  Part(float x, float y, float vx, float vy, int _col) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    col = _col;
  }

  Part(float x, float y, float vx, float vy, int _col, float _rad) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    rad = _rad;
  }

  void move() {
    if (!stuck) {
      pos.add(vel);
      halflife--;
    }
  }

  void show() {
    noStroke();
    fill(255 / 2 * col, 255, 100, halflife);
    ellipse(pos.x, pos.y, rad * 2, rad * 2);
  }

  boolean isDead() {
    if (halflife < 0) {
      active = false;
      return true;
    } else return false;
  }

  boolean interacting(Part other) {
    if (dist(pos.x, pos.y, other.pos.x, other.pos.y) < rad + other.rad) {
      return true;
    } else return false;
  }

  void makeSynth(float start, float dist) {
      OscMessage message = new OscMessage("/makesynth");
      message.add(col);
      message.add(vel.x);
      message.add(vel.y);
      message.add(start);
      message.add(dist);
      message.add(tag);
      oscP5.send(message, Supercollider);
    }
   
    void sendMessage(float dist){
    OscMessage control = new OscMessage("/control");
    control.add(tag);
    control.add(dist);
    oscP5.send(control, Supercollider);
  }
}
