//
// This is where all the beat stuff kicks off.
// The tempo is determined from the median time between taps (either on wii or keyboard) here.
// Beat timelines (AKA Scenes) are created and initialised here.
// Beat matchers which trigger animations are also created here, and
// updated each frame.
//
// Beat animations might do things like change the boids speed, attraction, and anything else that can 
// globally affect the animation


GLTexture kitPart, grumpyKitPart; // kitten particles

final int MAX_BEAT_INTERVAL = 2000;  // max time between beats in ms

int[] intervals = new int[3];
int index = 0;
int lastTime = 0;
int medianTime = 500;
Beat[] beats;

ProjectedShape beatShape;

PFont font;

final int NUM_SCENES = 4; // number of different beat matching sections

int totalBeatsCounted, beatsCounted, beatsPerScene;  // current number of beats in this scene
int currentBeatIndex = 0;  //current Beat scene

LinkedList<IAnimationModifier> animModifiers;

int timeScale = 1;

void updateBeatStuff()
{  
  // update beat objects in motions
  //for (int b=0; b<beats.length; b++)
  int ms = millis();
  beats[currentBeatIndex].update(ms*timeScale);

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
  totalBeatsCounted++;

    // swap config change events
  if (totalBeatsCounted % 256  == 0)
  {
    ConfigFileChangeEvent temp = configFileChangeEvent;
    configFileChangeEvent = laterConfigFileChangeEvent;
    laterConfigFileChangeEvent = temp;
    println("CONFIG CHANGE");
  }


  if (beatsCounted > beatsPerScene)
  {
    int newBeatIndex = int ( random(0, NUM_SCENES) );
    beats[newBeatIndex].reset();
    beatsCounted = 0;
    beatsPerScene = int( random(1, 3)) * 8;
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

  if (timeInterval < MAX_BEAT_INTERVAL)
  {

    intervals[index] = timeInterval;
    index = (index + 1) % intervals.length;
    intervals = sort(intervals);
    medianTime = intervals[(intervals.length-1)/2];  /// middle element

    for (int b=0; b<beats.length; b++)
      beats[b].setBeatInterval( medianTime );

    PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
    for (int i=0; i<pw.intervalTime.length; i++)
    {
      pw.intervalTime[i] = medianTime*int(random(32, 128));
      pw.setParticleColors();
      pw.updateModelColors();
    }

    println("Median time:" + medianTime);
  }
}


//
// SETUP BEAT STUFF
//
////////////////////

void setupBeatStuff()
{
  configFileChangeEvent = new ConfigFileChangeEvent();

  configFileChangeEvent.add( "data/config.xml", 0.4);
  configFileChangeEvent.add( "data/config1.xml", 0.4);
  configFileChangeEvent.add( "data/config2.xml", 0.4);
  configFileChangeEvent.add( "data/config3.xml", 0.3);
  configFileChangeEvent.add( "data/config4.xml", 0.2);

  secondConfigFileChangeEvent= new ConfigFileChangeEvent();
  secondConfigFileChangeEvent.add( "data/config5.xml", 0.8);

  laterConfigFileChangeEvent = new ConfigFileChangeEvent();

  laterConfigFileChangeEvent.add( "data/config6.xml", 0.2);
  laterConfigFileChangeEvent.add( "data/config7.xml", 0.8);
  laterConfigFileChangeEvent.add( "data/config2.xml", 0.2);
  laterConfigFileChangeEvent.add( "data/config3.xml", 0.2);
  laterConfigFileChangeEvent.add( "data/config4.xml", 0.1);


  kitPart = new GLTexture(this, "kittpart.png");
  grumpyKitPart = new GLTexture(this, "tard2headx64.png");

  lastTime = millis();

  beats = new Beat[NUM_SCENES];
  beatsPerScene = 4;

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
        //println("Beat changed:" + beat);
      }

      public void beatUpdated(float partialBeat) { 

        //float beat = beats[currentBeatIndex].partialBeat/4f; // 1/4
        // scale on a point
        //translate( -(1f-beat)*width/2f, 0);
        //scale( ((1f-beat)*3+1) );
      }
    }
    );
  }


  BeatMatcher matcher2 = new BeatMatcher( beats[2].getMaxBeats() );
  beats[2].addListener( matcher2 );

  matcher2.addBeatEvent(0, ibe);
  matcher2.addBeatEvent(0, triggerBeatFader);  
  matcher2.addBeatEvent(0, scalePoint);
  matcher2.addBeatEvent(0, randomActivateFlockBeatEvent);   
  matcher2.addBeatEvent(0, configFileChangeEvent );
  matcher2.addBeatEvent(1, changeConfigEvent );
  matcher2.addBeatEvent(1, ibe);
  matcher2.addBeatEvent(3, ibe);


  BeatMatcher matcher0 = new BeatMatcher( beats[0].getMaxBeats() );
  beats[0].addListener( matcher0 );



  matcher0.addBeatEvent(3, pointsEvent );
  matcher0.addBeatEvent(0, moveRight);
  matcher0.addBeatEvent(0, triggerGlowFader);
  matcher0.addBeatEvent(2, changeWhitneyPetalsBeatEvent);
  matcher0.addBeatEvent(2, moveLeft);
  matcher0.addBeatEvent(3, configFileChangeEvent );
  matcher0.addBeatEvent(3, changeConfigEvent );
  matcher0.addBeatEvent(3, triggerBeatFader);


  BeatMatcher matcher1 = new BeatMatcher( beats[1].getMaxBeats() );
  beats[1].addListener( matcher1 );

  matcher1.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() { 

      println("dyn img pts");
      timeScale = 1;
      DynamicWhitney whitneyDynamicImage  = (DynamicWhitney)(sourceDynamic.get( DynamicWhitney.NAME));

      //        whitneyDynamicImage.nbrPoints = int(random(30,180));
      whitneyDynamicImage.cycleLength = 320000 * int(random(1, 8));
      whitneyDynamicImage.calcSpeed();
    }
  }
  );

  matcher1.addBeatEvent( 0, blendsEvent );
  matcher1.addBeatEvent( 1, colorsEvent );
  matcher1.addBeatEvent( 2, changeConfigEvent);
  matcher1.addBeatEvent( 2, configFileChangeEvent);
  matcher1.addBeatEvent( 3, colorsEvent );  


  BeatMatcher matcher3 = new BeatMatcher( beats[3].getMaxBeats() );
  beats[3].addListener( matcher3 );

  matcher3.addBeatEvent( 0, secondConfigFileChangeEvent );
  matcher3.addBeatEvent( 1, partFreak );
  matcher3.addBeatEvent( 2, pointsEvent );
  matcher3.addBeatEvent( 3, partFreak );  



  //initialize beat intervals
  for (int i=0; i<intervals.length; i++)
  {
    intervals[i] = medianTime;
  }
}


void nextBeatShape()
{
  // back up 1

  if (beatShape == null)
  {
    // may as well use the 1st
    beatShape = shapes.getFirst();
  }
  else
  {
    ListIterator<ProjectedShape> iter = shapes.listIterator();
    ProjectedShape prev = shapes.getLast();
    ProjectedShape nxt = prev;

    while (iter.hasNext () && beatShape != (nxt = iter.next()) )
    {
      prev = nxt;
    }
    beatShape = prev;
  }
}

