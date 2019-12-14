import controlP5.*;
ControlP5 cp5;
final int N = 128;
final int iter = 16;
final int SCALE = 5;
 int r = 0;
final int g = 0;
final int b = 0;
float t = 0;

Fluid fluid;

void settings() {
  size(N *SCALE, N*SCALE);
  cp5 = new ControlP5(this);
  cp5.addSlider("r").setPosition(400,400).setRange(0,255);
  //cp5.addSlider("g").setPosition(200,300).setRange(0, 255);
  //cp5.addSlider("b").setPosition(200,400).setRange(0, 255);
}

// Density of sea water: 1.02813
// Last tried value for visc: 0.0000001

void setup() {
  fluid = new Fluid(0.25, 0, 0.0000001);
}

void mouseDragged(){
 fluid.AddDensity(mouseX/SCALE, mouseY/SCALE, 200); 
 float amtX = mouseX - pmouseX;
 float amtY = mouseY - pmouseY;
 fluid.AddVelocity(mouseX/SCALE, mouseY/SCALE, amtX, amtY); 
}

void draw() {
  background(r, g, b);
  int cx = int(0.5*width/SCALE);
  int cy = int(0.5*height/SCALE);
  for (int i = -1; i <= 1; i++)
    for (int j = -1; j <= 1; j++)
      fluid.AddDensity(cx+i, cy+j, random(50, 150));
  //fluid.AddDensity(int(0.5 * mouseX/SCALE), int(0.5 * mouseY/SCALE), 500); 
  float angle = noise(t) * TWO_PI * 2;
  PVector v = PVector.fromAngle(angle);
  v.mult(0.2);
  t += 0.01;
  fluid.AddVelocity(cx, cy, v.x, v.y); 

  fluid.Step();
  // Render fluid
  fluid.renderD();
  // Fade fluid
  fluid.fadeD();
  //fluid.renderV();
}
