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
      pw.intervalTime[i] = medianTime*int(random(32,128));
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
      ScaleAnimationModifier animod = new ScaleAnimationModifier();
      cameraAnimations.clear();
      cameraAnimations.add( animod );
    }
  };


  IBeatEvent moveRight = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      println("moveright");
      PanAnimationModifier animod = new PanAnimationModifier(-1, 2); // direction, scale
      animod.start( 2 *(1 + (int)random(0,3) ) );
      cameraAnimations.clear();
      cameraAnimations.add( animod );
    }
  };



IBeatEvent moveLeft = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      println("moveleft");
      PanAnimationModifier animod = new PanAnimationModifier(1, 2); // direction, beats
      animod.start( 2 *(1 + (int)random(0,3) ) );      
      cameraAnimations.clear();
      cameraAnimations.add( animod );
    }
  };
  

IBeatEvent triggerBeatFader =   new IBeatEvent() { 
        public void trigger() { 
          FadeWhitneyOnBeat fb = new FadeWhitneyOnBeat();
          fb.start(8);
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
          PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
          pw.setParticleColors();
          pw.updateModelColors();

        }
   };
  
  
  
  
  
  
  matcher2.addBeatEvent(0, ibe);
  matcher2.addBeatEvent(0, triggerBeatFader);  
  matcher2.addBeatEvent(0, scalePoint);
  
  matcher2.addBeatEvent(1, ibe);
  matcher2.addBeatEvent(2, ibe);
  matcher2.addBeatEvent(3, ibe);
       
  beats[2].addListener( matcher2 );
      
      
  matcher2.addBeatEvent( 2, 
  new IBeatEvent() 
  { 
        public void trigger() 
        { 
          String newConfigFile = null;
          
          float r = random(0,1);
          if (r < 0.15f)
          {
            newConfigFile = "data/config7.xml";
          }
          else
            newConfigFile = "data/config1.xml";
          
          if (!(CONFIG_FILE_NAME.equals( newConfigFile )) )
          {
            CONFIG_FILE_NAME = newConfigFile;        
            readConfigXML();
            nextBeatShape();
          }
        }
  });
      
      
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
  
  IBeatEvent changeConfigEvent = new IBeatEvent() { 
        public void trigger() { 
          //println("next shape");
          String newConfigFile = null;
          
          float r = random(0,1);
          if (r < 0.3f)
          {
            PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
            pw.setTexture(kitPart);
            for (int i=0; i<flocks.length; i++)
              flocks[i].active = false;
              
            newConfigFile = "data/config1.xml";
          }
          else if (r < 0.5f)
          {
            PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
            pw.setTexture(kitPart);
            newConfigFile = "data/config2.xml";
          }
          else if (r < 0.7f)
          {
          for (int i=0; i<flocks.length; i++)
            if (random(0,1) >= 0.5)
              flocks[i].active = true;

            newConfigFile = "data/config3.xml";
          }
          else if (r < 0.9f)
          {
            newConfigFile = "data/config4.xml";
            for (int i=0; i<flocks.length; i++)
              flocks[i].active = false;

            PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
            pw.setTexture(grumpyKitPart);
          } 
          else 
          {
            newConfigFile = "data/config7.xml";
            for (int i=0; i<flocks.length; i++)
              flocks[i].active = false;
          } 
          if (!(CONFIG_FILE_NAME.equals( newConfigFile )) )
          {
            CONFIG_FILE_NAME = newConfigFile;
            readConfigXML();
            nextBeatShape();
          }
          
        }
   };
  
  
  matcher0.addBeatEvent( 3, changeConfigEvent );
  
  
 IBeatEvent pointsEvent =  new IBeatEvent() { 
        public void trigger() { 
          println("dyn 1 pts");
//          timeScale = 4;
          DynamicWhitneyTwo whitneyDynTwo  = (DynamicWhitneyTwo)(sourceDynamic.get( DynamicWhitneyTwo.NAME));
          
          whitneyDynTwo.usePoints = (random(0,1) > 0.499);     
        }
  };
  
  matcher0.addBeatEvent( 0, pointsEvent );


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
  matcher1.addBeatEvent( 1, bc );
  matcher1.addBeatEvent( 2,changeConfigEvent);
  matcher1.addBeatEvent( 3, bc );  


  BeatMatcher matcher3 = new BeatMatcher( beats[3].getMaxBeats() );
  beats[3].addListener( matcher3 );
  
  IBeatEvent partFreak = new IBeatEvent() 
  { 
    public void trigger() 
    { 
      println("particles");
  //            timeScale = 1;     
      for (int i=0; i<flocks.length; i++)
      {
        if (random(0,1) < 0.25)
          flocks[i].setTexture(spriteTexs[ (int)random(0,spriteTexs.length) ]);
        flocks[i].active = (random(0,1) < 0.75);
        flocks[i].maxspeed = random(10,80*500f/medianTime);
        flocks[i].attraction = random(0.08,100f/medianTime);
        flocks[i].maxforce = random(0.2,flocks[i].maxspeed);
      }
    }
  };
  
  matcher3.addBeatEvent( 2, pointsEvent );
  matcher3.addBeatEvent( 1, partFreak );
  matcher3.addBeatEvent( 3, partFreak );

  matcher3.addBeatEvent( 0, 
  new IBeatEvent() 
  { 
        public void trigger() 
        { 
          if (!(CONFIG_FILE_NAME.equals( "data/config5.xml" )) )
          {
            CONFIG_FILE_NAME = "data/config5.xml";        
            readConfigXML();
            nextBeatShape();
          }
        }
  });  
          

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

