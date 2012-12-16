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

ProjectedShape beatShape;

PFont font;

final int NUM_SCENES = 3; // number of different beat matching sections

int beatsCounted, beatsPerScene;  // current number of beats in this scene
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
    
    while (iter.hasNext())
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
      pw.intervalTime[i] = medianTime*int(random(8,32));
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


IBeatEvent scalePoint = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      //println("scalepoint");
      IAnimationModifier animod = new IAnimationModifier()
      { 
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
          translate( -width+(1f-beat)*width, -height/2);
          scale(2);
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



IBeatEvent moveLeft = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      println("moveleft");

      IAnimationModifier animod = new IAnimationModifier()
      { 
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
          translate( (beat-1f)*width-width/2, -height/2);
          scale(2);
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
  



IBeatEvent triggerBeatFader =   new IBeatEvent() { 
        public void trigger() { 
          FadeWhitneyOnBeat fb = new FadeWhitneyOnBeat();
          fb.start(millis());
          animModifiers.add( fb );
        }
   };

IBeatEvent triggerGlowFader =   new IBeatEvent() { 
        public void trigger() { 
          FadeGlowOnBeat fg = new FadeGlowOnBeat();
          animModifiers.add( fg );
        }
   };   
   
   

BeatMatcher matcher2 = new BeatMatcher( beats[2].getMaxBeats() );
  
  IBeatEvent ibe =   new IBeatEvent() { 
        public void trigger() { 
          //println("next shape");
          nextBeatShape();
          beatShape.blendMode = BlendModes[int(random(0,BlendModes.length))];
        }
   };
  
  
  
  
  
  
  matcher2.addBeatEvent(0, ibe);
  matcher2.addBeatEvent(0, triggerBeatFader);  
  matcher2.addBeatEvent(0, scalePoint);
  
  matcher2.addBeatEvent(1, ibe);
  matcher2.addBeatEvent(2, ibe);
  matcher2.addBeatEvent(3, ibe);
       
  beats[2].addListener( matcher2 );
      
      
    matcher2.addBeatEvent( 0, 

     new IBeatEvent() { 
        public void trigger() { 
          for (int i=0; i<flocks.length; i++)
            flocks[i].active = false;
          
          flocks[(int)(random(0,flocks.length))].active = true;
          
        }
  });   
      


BeatMatcher matcher0 = new BeatMatcher( beats[0].getMaxBeats() );
beats[0].addListener( matcher0 );
  
  matcher0.addBeatEvent( 2, 

     new IBeatEvent() { 
        public void trigger() { 
          println("dyn 1 petals");
          DynamicWhitneyTwo whitneyDynTwo  = (DynamicWhitneyTwo)(sourceDynamic.get( DynamicWhitneyTwo.NAME));
          
          whitneyDynTwo.numPetals = max(2, ++whitneyDynTwo.numPetals % 6);
        }
  });
  
  // TEST
  //
  //
  matcher0.addBeatEvent( 3, 
  new IBeatEvent() { 
        public void trigger() { 
          //println("next shape");
          float r = random(0,1);
          if (r < 0.25f)
            CONFIG_FILE_NAME = "data/config1.xml";
          else if (r < 0.5f)
            CONFIG_FILE_NAME = "data/config2.xml";
          else if (r < 0.8f)
            CONFIG_FILE_NAME = "data/config3.xml";
          else 
            CONFIG_FILE_NAME = "data/config4.xml";
            
          readConfigXML();
          nextBeatShape();
        }
   });
  
  matcher0.addBeatEvent( 0, 

     new IBeatEvent() { 
        public void trigger() { 
          println("dyn 1 pts");
//          timeScale = 4;
          DynamicWhitneyTwo whitneyDynTwo  = (DynamicWhitneyTwo)(sourceDynamic.get( DynamicWhitneyTwo.NAME));
          
          whitneyDynTwo.usePoints = (random(0,1) > 0.499);     
        }
  });


  matcher0.addBeatEvent(0, moveRight);
  matcher0.addBeatEvent(0, triggerGlowFader);
  
  matcher0.addBeatEvent(3, triggerBeatFader);
  
  matcher0.addBeatEvent(2, moveLeft);

  BeatMatcher matcher1 = new BeatMatcher( beats[1].getMaxBeats() );
  beats[1].addListener( matcher1 );
  
  IBeatEvent be =  new IBeatEvent() { 
    public void trigger() { 
      println("colours!");
      timeScale = 1;
      randomiseShapeColors();
    }
  };


  IBeatEvent bc =  new IBeatEvent() { 
    public void trigger() { 
      println("blends!");
      setShapeBlends(BlendModes[int(random(0,BlendModes.length))]);
    }
  };



  matcher1.addBeatEvent( 0,
    new IBeatEvent() { 
      public void trigger() { 
        
        println("dyn img pts");
                  timeScale = 1;
         DynamicWhitney whitneyDynamicImage  = (DynamicWhitney)(sourceDynamic.get( DynamicWhitney.NAME));
  
//        whitneyDynamicImage.nbrPoints = int(random(30,180));
        whitneyDynamicImage.cycleLength = 320000 * int(random(1,8));
        whitneyDynamicImage.calcSpeed();
      }
    });

  matcher1.addBeatEvent( 0, be );
  matcher1.addBeatEvent( 2, bc );


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

