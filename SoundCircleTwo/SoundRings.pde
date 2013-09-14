int MAX_DIAMETER; // pixels
int MIN_DIAMETER;       // pixels

final int maxFrames = 40; 

float radii[][];
int rIndex = 0;

int lastTime = 0;
int msPerFrame = 20;

final int skip = 4;

final int STEP = BUFFER_SIZE/skip;

float step = TWO_PI / (STEP);

boolean reversed = false;

void initRings(AudioSource audioSource)
{
  radii = new float[maxFrames][STEP];

  for (int i=0; i<maxFrames; ++i)
    for (int ii=0; ii<STEP/skip; ++ii)
      radii[i][ii] = 0.0f;
}




void drawRings(float x, float y)
{
  pushMatrix();
  translate(x,y);
  rotateY(rotation);
  
  int buffers = STEP;

  //stroke(255, 0, 255, 180);
  //noFill();
  //strokeWeight(3);

  // draw old radii
  int rcount = 1;
  noStroke();

  float spacingVal = width*spacing.value()/maxFrames;
  
  while (rcount < maxFrames)
  { 
    int index = (rIndex + rcount) % maxFrames;
    colorMode(HSB, 255, 255, 255, 255);
    float bval = 180.0f*float(rcount)/maxFrames;
    if (reversed)
    {
      bval = 255-bval;
    }
    
    fill(180, 255-bval, bval+100, 255);
    beginShape(TRIANGLE_STRIP);
    
  
    float r0 = (radii[index][0] + radii[index][buffers-1])/2f;
    vertex(0, r0, -rcount*spacingVal);
    vertex(0, thickness.value()*r0, -rcount*spacingVal);


    for (int v = 1; v < buffers; v++)
    {
      float angle = step * v;

      float r = radii[index][v];
      float dx = sin(angle)*r;
      float dy = cos(angle)*r;

      vertex(dx,dy, -rcount*spacingVal);
      vertex(thickness.value()*dx, thickness.value()*dy, -rcount*spacingVal);
    }
    // close the shape
    vertex(0, r0, -rcount*spacingVal);
    vertex(0,thickness.value()*r0, -rcount*spacingVal);


    endShape();
    ++rcount;
  }
  popMatrix();
}



void updateRings(AudioSource audioSource)
{
  int timeDiff = millis()-lastTime;
  if (timeDiff > msPerFrame)
  {
    for (int vv = 0; vv < STEP; vv++)
    {
      float angle = step * vv;

      float r = diam.value() * width * (0.2f*(audioSource.mix.get(vv)-0.5f) + 0.4f);

      if (vv == (STEP-1)) r = (r+radii[rIndex][0])*0.5f;

      float dx = sin(angle)*r;
      float dy = cos(angle)*r;

      int pr = rIndex-1;
      if (pr < 0) pr = maxFrames-1;

      radii[rIndex][vv] = lerp(r, radii[pr][vv], smoothing.value());
    }
    rIndex = (rIndex + 1) % maxFrames;
  }
}

