//------------------------------------------------------------------
// This draws a Lissajous shapey thing
//------------------------------------------------------------------


public class LissajousDrawing extends DynamicGraphic
{

  static final String NAME = "lissajous";

  float rotation;
  float speed; // how fast it scrolls across the screen (0 is not moving)
  float periods; // how many humps the sine wave has
  float waveHeight;  // the height of the wave

  float radii[];


  LissajousDrawing(PApplet app, int iwidth, int iheight)
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
    waveHeight = this.height/4;
    radii = new float[this.width]; // list of radii

    rotation = 0f;
    speed = 2; // how fast it scrolls across the screen (0 is not moving)
    periods = 1;
    speed = 0f;

    this.beginDraw();      
    this.smooth();
    this.colorMode(HSB, 1);
    // this.noStroke();
    this.background(0);
    this.endDraw();
  }


  //
  // do the actual drawing (off-screen)
  //
  void pre()
  {

/*
    GL gl = this.beginGL();
    gl.glClearColor(0f, 0f, 0f, 0f);
    gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
    this.endGL();
*/

    //this.smooth();
    this.colorMode(HSB, 1);
    this.strokeWeight(4);

    rotation = millis() * speed;
    int numPoints = radii.length;

    for (int index=0; index < numPoints; index++)
    {
      // moving index, so it scrolls across the screen:
      int movedIndex = index + int(frameCount*speed);
      movedIndex = movedIndex % numPoints; // wrap around width

      float angle = map(movedIndex, 0, numPoints, 0, TWO_PI);

      float finalAngle = periods*angle;


      // map the value of the sin function across 1 rotation that spans the width of the screen 
      float sinVal = sin( finalAngle);
      float cosVal = cos( finalAngle);
      //
      //    float sinVal = sin( periods*finalAngle);
      //    float cosVal = cos( periods*finalAngle);


      // The height of the sine wave at the current position across the screen.
      // Will range from 0 to waveHeight
      float heightValue = waveHeight * 
        (1.0 + sinVal)*0.5;

      // this is the radius at this point
      radii[index] = heightValue;


      float waveStartY = height/8;
      float waveStartX = width/64;

      float waveX = waveStartX + map(index, 0, numPoints, 0, width/2);
      float waveY = waveStartY + heightValue;

      float circleCenterX = width/4 + waveStartX;
      float circleCenterY = height/4;

      float circleR = height/2;

      float circleX = circleCenterX + circleR * cosVal;
      float circleY = circleCenterY + circleR * sinVal;

      float roseCenterX = width/2;
      float roseCenterY = height/2;

      //float roseR = circleR;

      float roseR =  circleR * sin(angle*periods+rotation);

      //    float roseR =  circleR * (sin(angle*periods+rotation/3) + cos(2*angle*periods+rotation/3));

      //float roseR =  circleR * pow(sin(angle*periods+rotation/3),2);

      float vol = in.mix.get(index);


      //float roseR =  circleR * (1.5+sin(angle*periods));
      //    roseR /= 2.5;

      float br = 0.2;

      //
      // Only uncomment out *one* of these that uses periods to alter the sin/cos angle, not both! 
      //


      //float roseX = roseCenterX + (br+vol)*roseR * cos(angle + rotation);
      //float roseX = roseCenterX + (br+vol)*roseR * cos(angle*periods*2 + rotation);

      //float roseX = roseCenterX + (br+vol)*roseR * cos(angle*periods + rotation)*sin(angle);

      //float roseX = roseCenterX + (br+vol)*roseR * cos(angle + rotation);

      //float roseX = roseCenterX + (br+vol)*roseR * (cos(angle + rotation)*sin(angle + rotation));

      float roseX = roseCenterX + (br+vol)*roseR *2* (cos(angle*periods + rotation)*sin(angle*periods + rotation));

      //
      // PLAY WITH THESE FOR FUN!!
      //

      // float roseY = roseCenterY + (br+vol)*roseR * (sin(angle)); 
      //float roseY = roseCenterY + (br+vol)*roseR* sin(angle + rotation/2); 
      //    float roseY = roseCenterY + (br+vol)*roseR * sin(angle*periods + rotation/2); 
      float roseY = roseCenterY + roseR * (sin(2*angle + rotation));

      //float roseY = roseCenterY + roseR * (br+vol)*(sin(frameCount*0.005f*angle + rotation));

      //float roseY = roseCenterY + roseR * (br+vol)*(sin(2*angle + rotation));
      // float roseY = roseCenterY + roseR * sin(angle);


      // highlight the middle dot, for effect  
      if (index == numPoints/2) 
      {
        this.fill(0, 255, 0, 200);      
        // ellipse(waveX, waveY, 12, 12);
        // ellipse(circleX, circleY, 12, 12);

        //stroke(0, 255, 0, 200);
        //line(waveX, waveStartY, waveX, waveStartY+waveHeight);
        //line(circleCenterX, circleCenterY, circleX, circleY);
        this.ellipse(roseX, roseY, 8, 8);
        this.noStroke();
      }
      else 
      {
        //      fill(100, 255);
        this.noStroke();
        //      ellipse(waveX, waveY, 4, 4);
        this.fill(0, 255, 0, map(abs(angle-PI), 0, PI, 80, 255));
        //    ellipse(circleX, circleY, 4, 4);
        this.ellipse(roseX, roseY, 4, 4);
      }
    }

  }
  // end class LissajousDrawing
}

