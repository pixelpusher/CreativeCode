import com.noisepages.nettoyeur.processing.*;

/*
 * Using libpd and a Wii nunchuck connected via an Arduino to make a nice breakbeat synth thing
 *
 * by Evan Raskob, copyright 2012
 * computational Designer in Residence at Ravensbourne http://rave.ac.uk
 * libPDxyPadWii by Evan Raskob is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.
 * http://creativecommons.org/licenses/by-sa/3.0/
 * (other included code has differing licenses) 
 * Based on a work from the libPd library for Processing: https://github.com/libpd/puredatap5
 *
 */



PureDataP5Jack pd;
boolean freqy = true;
boolean rez = false;

void setup() {
  size(800, 600);
  smooth();
  colorMode(HSB, 100, 100, 100);

  pd = new PureDataP5Jack(this, 1, 2, "system", "system");
  pd.openPatch(dataFile("sawdrone5.pd"));
  //pd.subscribe("timeSymbol");
  pd.start();
  
  // if you don't use the wii nunchuck and arduino, comment this next line out:
  setupWiiChuck();  
}

void draw() {
  float h = map(mouseX+mouseY, 0, width+height, 0, 100);
  background(h, 100, 20);
  noStroke();
  if (mousePressed) {
    fill(100, 50);
    ellipse(mouseX, mouseY, width/6, width/6);
  }
}

void mousePressed() {
  pd.sendBang("play");
  dispatchPad();
}

void mouseReleased() {
  pd.sendBang("release");
}

void mouseDragged() {
 dispatchPad();
}

void receiveFloat(String s, float x) {
  println(s + ": " + x);
}

void dispatchPad() {
   float mY = constrain(mouseY,0,height);
  float mX = constrain(mouseX,0,width);
  if (freqy) {
    float frequency = map(mY, height, 0, 0, 800);
    pd.sendFloat("freq", frequency);
  } 
  else {
    float note = round(map(mY, height, 0, 0, 127));
    pd.sendFloat("note", note);
  }
  float cutoff = map(mX,0,width,0,2500);
  pd.sendFloat("cutoff", cutoff);
}

void keyPressed() {
  if (key == 'f') {
    freqy = true;
  }

  if (key == 'n') {
    freqy = false;
  }
  
  if(key == 'r') {
    if(rez) {
      rez = false;
      pd.sendFloat("rez", 1);
    } else {
      rez = true;
      pd.sendFloat("rez", 10);
    }
  }
}


