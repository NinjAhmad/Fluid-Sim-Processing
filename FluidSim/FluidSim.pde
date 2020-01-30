import java.util.*;
import controlP5.*;
ControlP5 cp5;
// 128 is a safe value for grid
final int grid = int(128 * 1.5);
final int iter = 16;
final int SCALE = 5;
float t = 0;
// Fluid RGB Color Sliders
int myColor1 = color(0, 0, 0);
Slider s1;
int myColor2 = color(0, 0, 0);
Slider s2;
int myColor3 = color(0, 0, 0);
Slider s3;
// Background RGB Color Sliders
int myColor4 = color(0, 0, 0);
Slider s4;
int myColor5 = color(0, 0, 0);
Slider s5;
int myColor6 = color(0, 0, 0);
Slider s6;
// Dye Density Slider
int dyeDensity = 500;
Slider dyeSlider;

// Viscosity slider
Slider viscSlider;

List<Slider> allSliders = new ArrayList<Slider>();
boolean fluidColorOptionsActive = true;

Fluid fluid;

void settings() {
  size(grid * SCALE, grid * SCALE);
}

// Density of sea water: 1.02813
// Last tried value for visc: 0.0000001

// Use this for Visc of fluid: 0.00001 to 0.0000001

void setup() {
  fluid = new Fluid(.2, 0, 0.000001);
  cp5 = new ControlP5(this);
  s1 = cp5.addSlider("FluidColor R").setPosition(0, 10).setRange(0, 255);
  allSliders.add(s1);
  s2 = cp5.addSlider("FluidColor G").setPosition(0, 60).setRange(0, 255);
  allSliders.add(s2);
  s3 = cp5.addSlider("FluidColor B").setPosition(0, 110).setRange(0, 255);
  allSliders.add(s3);
  s4 = cp5.addSlider("BackgroundColor R").setPosition(0, 10).setRange(0, 255);
  s4.setVisible(false);
  allSliders.add(s4);
  s5 = cp5.addSlider("BackgroundColor G").setPosition(0, 60).setRange(0, 255);
  s5.setVisible(false);
  allSliders.add(s5);
  s6 = cp5.addSlider("BackgroundColor B").setPosition(0, 110).setRange(0, 255);
  s6.setVisible(false);
  allSliders.add(s6);

  cp5.addButton("Swap").setPosition(0, 140).setSize(50, 19);

  dyeSlider = cp5.addSlider("DyeSlider").setPosition((width / 2) - 50, height - 50).setRange(0, 500);
  viscSlider = cp5.addSlider("ViscSlider").setPosition((width / 2) - 50, height - 100).setRange(0.0001f, 0.0000001f);
}

void mouseDragged() {
  if (key == 'd') {
    fluid.AddDensity(mouseX/SCALE, mouseY/SCALE, dyeDensity);
  }
  if (key == 'w') {
    float amtX = mouseX - pmouseX;
    float amtY = mouseY - pmouseY;
    fluid.AddVelocity(mouseX/SCALE, mouseY/SCALE, amtX, amtY);
  }
  if (mouseButton == RIGHT) {
    fluid.AddDensity(mouseX/SCALE, mouseY/SCALE, 300);
    float amtX = mouseX - pmouseX;
    float amtY = mouseY - pmouseY;
    fluid.AddVelocity(mouseX/SCALE, mouseY/SCALE, amtX, amtY);
  }
}

void draw() {
  //println("dye density: " + dyeDensity);
  if (keyPressed) {
    if (key == ' ') {
      int cx = int(0.5 * width/SCALE);
      int cy = int(3);
      for (int i = -1; i <= 1; i++)
        for (int j = -1; j <= 1; j++)
          fluid.AddDensity(cx+i, cy+j, random(50, 150));
      //fluid.AddDensity(int(0.5 * mouseX/SCALE), int(0.5 * mouseY/SCALE), 500);
      float angle = noise(t) * PI;
      PVector v = PVector.fromAngle(angle);
      v.mult(0.2);
      t += 0.01;
      fluid.AddVelocity(cx, cy, v.x, v.y);
    }
  }
  if (!fluidColorOptionsActive) {
    for (int i = 0; i < 3; i++) allSliders.get(i).setVisible(false);
    for (int i = 3; i < 6; i++) allSliders.get(i).setVisible(true);
  } else {
    for (int i = 0; i < 3; i++) allSliders.get(i).setVisible(true);
    for (int i = 3; i < 6; i++) allSliders.get(i).setVisible(false);
  }

  myColor1 = (int)s1.getValue();
  myColor2 = (int)s2.getValue();
  myColor3 = (int)s3.getValue();
  myColor4 = (int)s4.getValue();
  myColor5 = (int)s5.getValue();
  myColor6 = (int)s6.getValue();

  dyeDensity = (int)dyeSlider.getValue();

  background(myColor4, myColor5, myColor6);
  //// This block of code will generate fluids automatically without you having to click. Currently it rotates 180 degrees. PI * 1 = 180 degrees / PI * 2 = 360 degrees
  //int cx = int(0.5*width/SCALE);
  //int cy = int(3);
  //for (int i = -1; i <= 1; i++)
  //  for (int j = -1; j <= 1; j++)
  //    fluid.AddDensity(cx+i, cy+j, random(50, 150));
  ////fluid.AddDensity(int(0.5 * mouseX/SCALE), int(0.5 * mouseY/SCALE), 500);
  //float angle = noise(t) * PI;
  //PVector v = PVector.fromAngle(angle);
  //v.mult(0.2);
  //t += 0.01;
  //fluid.AddVelocity(cx, cy, v.x, v.y); 

  fluid.Step();
  // Render fluid
  fluid.RenderD();
  // Render 'Velocity Fields'
  //fluid.RenderV();
  // Fade fluid
  fluid.FadeDye();
}

void FluidColorR(float theColor) {
  myColor1 = color(theColor);
  println("a slider event. setting colors to " + theColor);
}

void FluidColorG(float theColor) {
  myColor2 = color(theColor);
  println("a slider event. setting colors to " + theColor);
}

void FluidColorB(float theColor) {
  myColor3 = color(theColor);
  println("a slider event. setting colors to " + theColor);
}

void BackgroundColorR(float theColor) {
  myColor4 = color(theColor);
  println("a slider event. setting colors to " + theColor);
}

void BackgroundColorG(float theColor) {
  myColor5 = color(theColor);
  println("a slider event. setting colors to " + theColor);
}

void BackgroundColorB(float theColor) {
  myColor6 = color(theColor);
  println("a slider event. setting colors to " + theColor);
}

void Swap() {
  fluidColorOptionsActive = !fluidColorOptionsActive;
  println("a button event. swapping between slider options");
}

void DyeSlider(int _dyeDensity) {
  dyeDensity = _dyeDensity;
  println("a slider event. setting dye value to " + _dyeDensity);
}

void ViscSlider(float _visc) {
  fluid = new Fluid(.2, 0, _visc);
  println("a slider event. changing viscosity value to " + _visc);
}
