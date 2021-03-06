//
// This is where all the beat stuff kicks off.
// The tempo is determined from the median time between taps (either on wii or keyboard) here.
// Beat timelines (AKA Scenes) are created and initialised here.
// Beat matchers which trigger animations are also created here, and
// updated each frame.
//
// Beat animations might do things like change the boids speed, attraction, and anything else that can 
// globally affect the animation


final int MAX_BEAT_INTERVAL = 2000;  // max time between beats in ms
final int MIN_BEAT_INTERVAL = 50;

int[] intervals = new int[3];
int index = 0;
int lastTime = 0;
int medianTime = 500;
Beat[] beats;

PFont font;

final int NUM_SCENES = 4;
int beatsCounted, beatsPerScene;  // current number of beats in this scene
int currentBeatIndex = 0;  //current Beat scene

LinkedList<IAnimationModifier> animModifiers;


void updateBeatStuff()
{  
  int ms = millis();

  Iterator<IAnimationModifier> iter = animModifiers.iterator();

  while (iter.hasNext ())
  {
    IAnimationModifier animod  = iter.next();
    if (animod.isFinished())
    {
      animod.stop();
      iter.remove();
      animod = null;
    }
    else animod.update(ms);
  }

  // update beat objects in motions
  //for (int b=0; b<beats.length; b++)

  beats[currentBeatIndex].update(ms);

  //float f1 = map(chuck1.stickY, -100, 100, 0, 255);
  //float f2 = map(chuck1.stickX, -100, 100, 0, 255);
}



//
// Update for a new beat.
// If necessary, change to a random new beat scene
//

void updateBeatScene()
{
  beatsCounted++;

  if (beatsCounted > beatsPerScene)
  {

    int newBeatIndex = int ( random(0, NUM_SCENES) );
    beats[newBeatIndex].reset();
    beatsCounted = 0;
    beatsPerScene = int( random(1, 4)) * 4;
    currentBeatIndex =   newBeatIndex;
    //println("Changed beat:" + newBeatIndex);
  }
}



//
// TAP TEMPO
//
//////////////////

void tapTempo()
{
  int currentTime = millis();
  int timeInterval = currentTime - lastTime;
  lastTime = currentTime;

  if (timeInterval < MAX_BEAT_INTERVAL && timeInterval > MIN_BEAT_INTERVAL)
  {
    intervals[index] = timeInterval;
    index = (index + 1) % intervals.length;
    intervals = sort(intervals);
    medianTime = intervals[(intervals.length-1)/2];  /// middle element

    for (int b=0; b<beats.length; b++)
      beats[b].setBeatInterval( medianTime );
    //println("Median time:" + medianTime);

    for (DrawableNode fire : fireNodes)
    {
      fire.rotationSpeed = 30f*TWO_PI/(medianTime); // sort of based on framerate
    }
  }
}


//
// SETUP BEAT STUFF
//
////////////////////

void setupBeatStuff()
{

  lastTime = millis();

  beats = new Beat[NUM_SCENES];
  beatsPerScene = int( random(1, 4)) * 4;

  animModifiers = new LinkedList<IAnimationModifier>();


  // start beat objects in motion
  for (int b=0; b<beats.length; b++)
  {
    beats[b] = new Beat(4);
 /*
 // possibly add global listeners to each, for global events
 
    beats[b].addListener( 
    new IBeatListener() 
    { 
      public void beatChanged(int beat)
      {
        updateBeatScene();
        //println("Beat changed:" + beat);
      }

      public void beatUpdated(float partialBeat) 
      { 
      }
    }
    );
   */
  }


  IBeatEvent scalePoint = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      //println("scalepoint");
      IAnimationModifier animod = new IAnimationModifier()
      { 
        int r = int(random(1, 3000000));

        public void stop() {
        }
        public void pause() {
        }
        public void start(int t) {
        }
        public void update(int t) 
        {
          float beat = beats[currentBeatIndex].getPartialBeat()/4f; // 1/4
          // println(r+ " " +beat);
          // scale on a point

          translate( -(1f-beat)*width/3f, 0);
          scale( ((1f-beat)*0.5+1) );
        }

        //animod.start(beats[0].beatInterval*4);
        public boolean isFinished()
        {
          return false;
        }
      };
      cameraAnimations.clear();
      cameraAnimations.add( animod );
    }
  };



  IBeatEvent moveRight = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      println("moveright");

      IAnimationModifier animod = new IAnimationModifier()
      { 
        int r = int(random(1, 3000000));

        public void stop() {
        }
        public void pause() {
        }
        public void start(int t) {
        }
        public void update(int t) 
        {
          float beat = beats[currentBeatIndex].getPartialBeat()/4f; // 1/4
          // println(r+ " " +beat);

          //move right
          translate( -width+3f*(1f-beat)*width/3f, -height/2);
          scale(3);
        }

        //animod.start(beats[0].beatInterval*4);
        public boolean isFinished()
        {
          return false;
        }
      };
      cameraAnimations.clear();
      cameraAnimations.add( animod );
    }
  };


  // float p = map (millis() % 5000, 0, 4999, 0, 1 );

  // scale on a point
  //  translate( -p*width/2f ,0);
  //  scale( (p*3+1) );

  //move right
  //translate( -width+p*width/2f, -height/2);
  //scale(2);

  // move left
  //translate( -p*width/2f ,0);
  //scale(2);




  BeatMatcher matcher1 = new BeatMatcher( beats[0].getMaxBeats() );

  matcher1.addBeatEvent( 0, scalePoint);

  matcher1.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 
      //println("Beat 1 MATCHED!");
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          attraction = 4f*(1f-percentFinished);
          //println("attract:" + attraction);
        }
      };

      animod.start(beats[0].beatInterval*2);
      animModifiers.add( animod );
    }
  }
  );

  beats[0].addListener( matcher1 );




  BeatMatcher matcher2 = new BeatMatcher( beats[1].getMaxBeats() );

  matcher2.addBeatEvent( 0, moveRight);

  matcher2.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 
      //println("Beat2 MATCHED!");
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          desiredseparation = 120f*(1f-percentFinished);
          //println("attract:" + attraction);
        }
        public void stop()
        {
          desiredseparation = 16f;
        }
      };

      neighbordist = 100f;
//      boidMaxSpeed = random(8, 16);
      animod.start(beats[1].beatInterval*2);
      animModifiers.add( animod );
    }
  }
  );


  beats[1].addListener( matcher2 );

  BeatMatcher matcher3 = new BeatMatcher( beats[1].getMaxBeats() );



  matcher3.addBeatEvent( 2, 
  new IBeatEvent() { 
    public void trigger() {
      currentBGTex = bgImages[int(random(0, bgImages.length))];
    }
  }
  );

  matcher3.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 
      //println("Beat2 MATCHED!");
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          //boidMaxSpeed = 8f+30f*sin(PI*(1f-percentFinished));
        }
      };

      neighbordist = 100f;
//      boidMaxSpeed = random(8, 16);
      animod.start(beats[2].beatInterval*4);
      animModifiers.add( animod );
    }
  }
  );


  beats[2].addListener( matcher3 );


  BeatMatcher matcher4 = new BeatMatcher( beats[3].getMaxBeats() );


  matcher4.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 

      fx = 0.5;
      fy = 1.0;
    }
  }
  );

  matcher4.addBeatEvent( 2, 
  new IBeatEvent() { 
    public void trigger() { 

      fx = 0.08;
      fy = 0.7;
      /*
      tintColors[0]=color(0, random(100, 255), random(100, 255));
       tintColors[1]= color(0, random(80, 255), 0);
       tintColors[2]= color(random(80, 200), 0, 0);
       tintColors[3]= color(255, 0, 255);
       */
    }
  }
  );


  matcher4.addBeatEvent( 3, 
  new IBeatEvent() { 
    public void trigger() { 
      //println("Beat2 MATCHED!");
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          fy =  0.1f+0.6f*(1f-percentFinished);
          //println("attract:" + attraction);
        }
        public void stop()
        {
          fy = 0.5f;
          fx = 0.2f;
        }
      };

      animod.start(beats[1].beatInterval);
      animModifiers.add( animod );
    }
  }
  );

  beats[3].addListener( matcher4 );
  beats[2].addListener( matcher4 );
  beats[0].addListener( matcher4 );

  //initialize beat intervals
  for (int i=0; i<intervals.length; i++)
  {
    intervals[i] = medianTime;
  }
}

