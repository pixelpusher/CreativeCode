final int MAX_BEAT_INTERVAL = 1500;  // max time between beats in ms

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
    animod.update(ms);
    if (animod.isFinished())
    {
      animod.stop();
      iter.remove();
      animod = null;
    }
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

  if (beatsCounted >= beatsPerScene)
  {
    int newBeatIndex = int ( random(0, NUM_SCENES) );
    beats[newBeatIndex].reset();
    beatsCounted = 0;
    beatsPerScene = int( random(1, 4)) * 4;
    currentBeatIndex =   newBeatIndex;
    println("Changed beat:" + newBeatIndex);
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

  if (timeInterval < MAX_BEAT_INTERVAL)
  {

    intervals[index] = timeInterval;
    index = (index + 1) % intervals.length;
    intervals = sort(intervals);
    medianTime = intervals[(intervals.length-1)/2];  /// middle element

    for (int b=0; b<beats.length; b++)
      beats[b].setBeatInterval( medianTime );
    println("Median time:" + medianTime);

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

  animModifiers = new LinkedList<IAnimationModifier>();


  // start beat objects in motions
  for (int b=0; b<beats.length; b++)
  {
    beats[b] = new Beat(4);

    beats[b].addListener( 
    new IBeatListener() 
    { 
      public void beatChanged(int beat)
      {
        updateBeatScene();
        println("Beat changed:" + beat);
      }

      public void beatReset()
      {
        println("Beat reset");
      }
    }
    );
  }



  BeatMatcher matcher1 = new BeatMatcher( beats[0].getMaxBeats() );

  matcher1.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 
      println("Beat 1 MATCHED!");
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

  matcher2.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 
      println("Beat2 MATCHED!");
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
      boidMaxSpeed = random(8, 16);
      animod.start(beats[1].beatInterval*2);
      animModifiers.add( animod );
    }
  }
  );


  beats[1].addListener( matcher2 );

  BeatMatcher matcher3 = new BeatMatcher( beats[1].getMaxBeats() );

  matcher3.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 
      println("Beat2 MATCHED!");
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          boidMaxSpeed = 8f+30f*sin(PI*(1f-percentFinished));
        }
      };

      neighbordist = 100f;
      boidMaxSpeed = random(8, 16);
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
      fy = 0.6;

      tintColors[0]=color(0, random(100, 255), random(100, 255));
      tintColors[1]= color(0, random(80, 255), 0);
      tintColors[2]= color(random(80, 200), 0, 0);
      tintColors[3]= color(255, 0, 255);
    }
  }
  );

  beats[3].addListener( matcher4 );
  beats[0].addListener( matcher4 );

  //initialize beat intervals
  for (int i=0; i<intervals.length; i++)
  {
    intervals[i] = medianTime;
  }
}

