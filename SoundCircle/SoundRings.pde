int MAX_DIAMETER; // pixels
int MIN_DIAMETER;       // pixels

final int maxFrames = 30; 

float radii[][];
int rIndex = 0;

int lastTime = 0;
int msPerFrame = 10;

float step = TWO_PI / BUFFER_SIZE;


void initRings(AudioSource audioSource)
{
  radii = new float[maxFrames][BUFFER_SIZE];

  for (int i=0; i<maxFrames; ++i)
    for (int ii=0; ii<BUFFER_SIZE; ++ii)
      radii[i][ii] = 0.0f;
}




void drawRings(float x, float y)
{
  int buffers = BUFFER_SIZE;

  stroke(255, 0, 255, 180);
  noFill();
  strokeWeight(3);

  // draw old radii
  int rcount = 1;

  while (rcount < maxFrames)
  {

    int index = (rIndex + rcount) % maxFrames;
    stroke(255, 0, 255, 100.0f-100.0f*float(rcount)/maxFrames);

    beginShape();
    for (int v = 0; v < buffers; v++)
    {
      float angle = step * v;

      float r = radii[index][v];
      float dx = sin(angle)*r;
      float dy = cos(angle)*r;

      vertex(x + dx, y + dy, rcount*spacing.value());
      vertex(x + thickness.value()*dx, y + thickness.value()*dy, rcount*spacing.value());
    }
    endShape(CLOSE);
    ++rcount;
  }
}



void updateRings(AudioSource audioSource)
{
  int timeDiff = millis()-lastTime;
  if (timeDiff > msPerFrame)
  {
    for (int vv = 0; vv < BUFFER_SIZE; vv++)
    {
      float angle = step * vv;

      float r = diam.value() + audioSource.mix.get(vv) * diam.value()*0.35f;

      if (vv == (BUFFER_SIZE-1)) r = (r+radii[rIndex][0])*0.5f;

      float dx = sin(angle)*r;
      float dy = cos(angle)*r;

      int pr = rIndex-1;
      if (pr < 0) pr = maxFrames-1;

      radii[rIndex][vv] = lerp(r, radii[pr][vv], smoothing.value());
    }
    rIndex = (rIndex + 1) % maxFrames;
  }
}

