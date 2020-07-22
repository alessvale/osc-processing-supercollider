//// Setup for OscP5;

import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress Supercollider;

//// Setting up the particle systems and the main counter;


ArrayList<Parsys> systems;
ArrayList<Part> circles;
int count = 0;

void setup(){
  size(800, 800);
  background(255);
  oscP5 = new OscP5(this,12000);
  Supercollider = new NetAddress("127.0.0.1", 57120);
 
  systems = new ArrayList<Parsys>();
  circles = new ArrayList<Part>();
 
}

void draw(){
  background(255);
  for (int i = systems.size() - 1; i>=0; i--){
    Parsys sys = systems.get(i);
    sys.update();
    sys.show();
    if (sys.isDead()){
      systems.remove(i);
    }
    for (int j = 0; j < circles.size(); j++){
      Part circ = circles.get(j);
      sys.interact(circ);
    }
  }
 
  for (int i = 0; i < circles.size(); i++){
    Part circ = circles.get(i);
    circ.show();
  }
  if (random(0, 1) < 0.04){
    Parsys p = new Parsys(random(0, width), random(0, height));
    systems.add(p);
  }
}

void mousePressed(){
  Part circ = new Part(mouseX, mouseY, 0, 0, 0, 30);
  circ.stuck = true;
  circ.halflife = 80;
  circles.add(circ);
}

/////Define the class Parsys

class Parsys {
  ArrayList<Part> particles;
 
  Parsys(float x, float y){
    particles = new ArrayList<Part>();
   
    int n = int(random(20, 80));
    for (int i = 0; i < n; i++){
      float theta = random(0, 2 * PI);
      float r = random(0.1, 1.2);
      Part p = new Part(x, y, r * cos(theta), r * sin(theta), int(random(0, 3)));
      p.tag = count;
      count++;
      particles.add(p);
    }
  }
 
  void update(){
    for (int i =  particles.size() - 1; i>=0; i--){
      Part p = particles.get(i);
      p.move();
      if (p.isDead()){
        particles.remove(i);
      }
    }
  }
 
  void show(){
    for (int i =  particles.size() - 1; i>=0; i--){
      Part p = particles.get(i);
      p.show();
    }
  }
 
  boolean isDead(){
    if (particles.size() <=0){
      return true;
    }
    else return false;
  }
 
  void interact(Part other){
    for (int i = 0; i < particles.size(); i++){
      Part p = particles.get(i);
      if (p.interacting(other)){
        float dist = (p.pos.x - other.pos.x)* (p.pos.x - other.pos.x) + (p.pos.y - other.pos.y)*(p.pos.y - other.pos.y);
        if (!p.active){
          float start = other.pos.x/width;
        p.makeSynth(start, dist/(other.rad * other.rad));
        p.active = true;
        }
        else {
          p.sendMessage(dist/(other.rad * other.rad));
        }
      }
      else
      {
        p.active = false;
      }
    }
  }
}
