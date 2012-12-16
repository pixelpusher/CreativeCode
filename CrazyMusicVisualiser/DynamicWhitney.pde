//------------------------------------------------------------------
// This draws a "Whitney" image
//------------------------------------------------------------------

public class DynamicWhitney extends DynamicGraphic
{
  // Based in part on WhitneyScope by Jim Bumgardner
  // http://www.coverpop.com/p5/whitney_2/applet/whitney_2.pde
  // From ideas by John Whitney -- see his book "Digital Harmony"

  static final String NAME = "whitney";

  float nbrPoints;
  float cx, cy;
  float crad;
  float cycleLength;
  float startTime;
  int   counter;
  int numPetals;
  float speed;
  boolean usePoints;
  float baseSpeed;


  DynamicWhitney(PApplet app, int iwidth, int iheight)
  {
    super( app, iwidth, iheight);
    
    // add ourself to the glboal lists of dynamic images
    // Do we want to do this in the constructor or is that potentially evil?
    // Maybe we want to register copies with different params under different names...
    // Or potentially check for other entries in the HashMap and save to a different name
    sourceDynamic.put( NAME, this );
    addPGraphicsToImagesList( NAME, this );
  }

  void initialize()
  {     
    numPetals = 2;
    usePoints = false;
    nbrPoints = 160;
    counter = 0;
    cx = this.width/2;
    cy = this.height/2;
    crad = (min(this.width, this.height)/2) * 0.95;
    cycleLength = 320000*4;
    calcSpeed();
    startTime = millis();

    this.beginDraw();      
    this.smooth();
    this.colorMode(HSB, 1);
    // this.noStroke();
    this.background(0);
    this.endDraw();
  }


  void calcSpeed()
  {
    speed = (TWO_PI*nbrPoints) / cycleLength;
    baseSpeed = (TWO_PI*nbrPoints) / cycleLength;
  }

  //
  // do the actual drawing (off-screen)
  //
  void pre()
  {
    float my = 20;

    this.beginDraw();
    
    GL gl = this.beginGL();
    gl.glClearColor(0f,0f,0f,0f);
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    this.endGL();
    
    
    //this.smooth();
    this.colorMode(HSB, 1);
    this.strokeWeight(4);

    //startTime = -(cycleLength*20) / (float) this.height;
    float timer = (millis() - startTime) % cycleLength;

    //this.background(0);
    
    //counter = int(timer / cycleLength);

    counter = int(timer);

    if (usePoints)
    {

      //    this.noFill();
      this.noStroke();
    }
    else
    {
      this.beginShape();
      this.noFill();
    }
    for (float i = 0; i < nbrPoints; ++i)
    {
      float r = i/(nbrPoints-1f);
      float len = crad*r;

      //if ((counter & 1) == 0)
      //  r = 1-r;

      float a = timer * speed * r; // pow(i * .001,2);
      float rad = max(2, len*.05);

      if (false)
      {
        float tmps = sin(numPetals*a);
        float tmpc = cos(numPetals*a);

        len *= 2*tmps*tmpc;
      }
      
      if (true)
      {
        float tmps = sin(numPetals*(a+TWO_PI*timer/cycleLength));
        //float tmpc = cos(numPetals*a+timer);

        len *= tmps*tmps;
      }
      
      float x = (cx + cos(a)*len);
      float y = (cy + sin(a)*len);
      float h = map(sin(len*TWO_PI) * sin(PI*timer/cycleLength), -1, 1, 0, 1);
      //h -= int(h);

      if (usePoints)
      {
        this.fill(h, .9, 1-r/2);
        this.ellipse(x, y, rad, rad);
      }
      else
      {
        this.stroke(h, .8, 1-r/2, 0.7);
        this.curveVertex(x, y);
      }
    }

    if (!usePoints)
    {
      this.endShape();
    }
    this.endDraw();
  }

  // end class DynamicWhitney
}

