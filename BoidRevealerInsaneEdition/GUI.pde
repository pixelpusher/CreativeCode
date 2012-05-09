void setupGUI()
{
   gui = new ControlP5(this);
  cpFill = gui.addColorPicker("boidStroke", 10, 10, 255, 20);
  cpStroke = gui.addColorPicker("boidFill", 10, 80+cpFill.getHeight(), 255, 20);

  int guiX = 10;
  int guiY = 200;

  Slider slider = gui.addSlider("desiredseparation", 2f, 100f, 25f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("avoidWallsFactor", 0f, 1f, 0.8f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("attraction", 0.01f, 2f, 0.08f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("neighbordist", 8f, 80f, 25f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("boidMaxSpeed", 1f, 300f, 120f, guiX, guiY, 100, 20); 
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("boidMaxForce", 0.01f, 3f, 0.8f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("fx", 0.01f, 1f, 0.1f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+2;
  slider = gui.addSlider("fy", 0.01f, 1f, 0.1f, guiX, guiY, 100, 20);
  guiY += slider.getHeight()+4;

  presetName = gui.addTextfield("preset", guiX, guiY, 200, 20);

  guiY += slider.getHeight()+36;

  refreshPresetFilesList(guiX, guiY);
}
