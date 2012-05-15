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

int[] intervals = new int[3];
int index = 0;
int lastTime = 0;
int medianTime = 500;
Beat[] beats;

PFont font;

final int NUM_SCENES = 2;
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
    beatsPerScene = int( random(1, 4)) * 8;
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

      public void beatUpdated(float partialBeat) { 
        /*
       float beat = beats[currentBeatIndex].partialBeat/4f; // 1/4
         // scale on a point
         translate( -(1f-beat)*width/2f, 0);
         scale( ((1f-beat)*3+1) );
         */
      }
    }
    );
  }


BeatMatcher matcher0 = new BeatMatcher( beats[0].getMaxBeats() );
IBeatEvent be1 =  new IBeatEvent() { 
    public void trigger() { 
      println("Beat 0 MATCHED!");
      
      
       DynamicWhitney whitneyDynamicImage  = (DynamicWhitney)(sourceDynamic.get( DynamicWhitney.NAME));

      whitneyDynamicImage.nbrPoints = int(random(50,180));

      /*
      IAnimationModifier animod = new TimedAnimationModifier()
       {        
       public void update(int t)
       {
       super.update(t);
       
       }
       };
       
       animod.start(beats[2].beatInterval*4);
       animModifiers.add( animod );
       }
       */
    }
  };

  matcher0.addBeatEvent( 0, be1 );
  
  beats[0].addListener( matcher0 );
//nbrPoints


  BeatMatcher matcher1 = new BeatMatcher( beats[0].getMaxBeats() );
/*
  matcher1.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() {

      // change colors???
    }
  }
  );
*/

  IBeatEvent be =  new IBeatEvent() { 
    public void trigger() { 
      println("Beat 1 MATCHED!");
      randomiseShapeColors();
      /*
      IAnimationModifier animod = new TimedAnimationModifier()
       {        
       public void update(int t)
       {
       super.update(t);
       
       }
       };
       
       animod.start(beats[2].beatInterval*4);
       animModifiers.add( animod );
       }
       */
    }
  };

  matcher1.addBeatEvent( 0, be );
  matcher1.addBeatEvent( 2, be );

  beats[1].addListener( matcher1 );

  //initialize beat intervals
  for (int i=0; i<intervals.length; i++)
  {
    intervals[i] = medianTime;
  }
}

