ConfigFileChangeEvent configFileChangeEvent, secondConfigFileChangeEvent, laterConfigFileChangeEvent;

class FilenameProbability
{
  String name;
  float  prob;

  FilenameProbability(String s, float p)
  {
    name = s;
    prob = p;
  }
}

class ConfigFileChangeEvent implements IBeatEvent
{
  private ArrayList<FilenameProbability> configFileNames;
  private float totalProbability; // prob of all files

  ConfigFileChangeEvent()
  {
    configFileNames = new ArrayList<FilenameProbability>();
    totalProbability = 0f;
  }

  // should be like "data/config5.xml"
  ConfigFileChangeEvent add(String f, float p)
  {
    configFileNames.add(new FilenameProbability(f, p));
    totalProbability += p;
    return this;
  }
  ConfigFileChangeEvent clear()
  {
    configFileNames.clear();
    totalProbability = 0f;
    return this;
  }

  public void trigger() 
  { 
    String newFileName = null;
    float r = random(0, totalProbability);
    float currentProb=0f;

    //println("CONFIG CHANGE CHECK");

    for ( FilenameProbability f : configFileNames)
    {
      currentProb += f.prob;
      //println("r:" + r + " currentp " + currentProb);
      if (currentProb > r)
      {
        //println(f.name);
        if (!(CONFIG_FILE_NAME.equals( f.name )) )
        {
          CONFIG_FILE_NAME = f.name;        
          readConfigXML();
          nextBeatShape();
        }
        break;
      }
    }
  }
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
    //println("moveright");
    PanAnimationModifier animod = new PanAnimationModifier(-1, 2); // direction, scale
    animod.start( 2 *(1 + (int)random(0, 3) ) );
    cameraAnimations.clear();
    cameraAnimations.add( animod );
  }
};



IBeatEvent moveLeft = new IBeatEvent() 
{ 
  public void trigger() 
  { 
    //println("moveleft");
    PanAnimationModifier animod = new PanAnimationModifier(1, 2); // direction, beats
    animod.start( 2 *(1 + (int)random(0, 3) ) );      
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


IBeatEvent ibe =   new IBeatEvent() { 
  public void trigger() { 
    //println("next shape");
    nextBeatShape();
    beatShape.blendMode = BlendModes[int(random(0, BlendModes.length))];
    PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
    pw.setParticleColors();
    pw.updateModelColors();
  }
};


IBeatEvent randomActivateFlockBeatEvent =  new IBeatEvent() { 
  public void trigger() { 
    for (int i=0; i<flocks.length; i++)
      flocks[i].active = false;

    flocks[(int)(random(0, flocks.length))].active = true;
  }
};



IBeatEvent changeWhitneyPetalsBeatEvent = new IBeatEvent() { 
  public void trigger() { 
    //println("dyn 1 petals");
    DynamicWhitneyTwo whitneyDynTwo  = (DynamicWhitneyTwo)(sourceDynamic.get( DynamicWhitneyTwo.NAME));

    whitneyDynTwo.numPetals = max(2, ++whitneyDynTwo.numPetals % 6);
  }
};


IBeatEvent changeConfigEvent = new IBeatEvent() { 
  public void trigger() 
  { 
    if (CONFIG_FILE_NAME.equals("data/config1.xml"))
    {
      PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
      pw.setTexture(kitPart);
      for (int i=0; i<flocks.length; i++)
        flocks[i].active = false;
    }
    else if (CONFIG_FILE_NAME.equals("data/config2.xml"))
    {
      PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
      pw.setTexture(kitPart);
    }
    else if (CONFIG_FILE_NAME.equals("data/config3.xml"))
    {
      for (int i=0; i<flocks.length; i++)
        if (random(0, 1) >= 0.5)
          flocks[i].active = true;
    }
    else if (CONFIG_FILE_NAME.equals("data/config4.xml"))
    {
      for (int i=0; i<flocks.length; i++)
        flocks[i].active = false;

      PsychedelicWhitney pw  = (PsychedelicWhitney)(sourceDynamic.get( PsychedelicWhitney.NAME));
      pw.setTexture(grumpyKitPart);
    } 
    else 
    {
      for (int i=0; i<flocks.length; i++)
        flocks[i].active = false;
    }
  }
};


IBeatEvent pointsEvent =  new IBeatEvent() { 
  public void trigger() { 
    //println("dyn 1 pts");
    //          timeScale = 4;
    DynamicWhitneyTwo whitneyDynTwo  = (DynamicWhitneyTwo)(sourceDynamic.get( DynamicWhitneyTwo.NAME));

    whitneyDynTwo.usePoints = (random(0, 1) > 0.499);
  }
};


IBeatEvent colorsEvent =  new IBeatEvent() { 
  public void trigger() { 
    //println("colours!");
    timeScale = 1;
    randomiseShapeColors();
  }
};


IBeatEvent blendsEvent =  new IBeatEvent() { 
  public void trigger() { 
    //println("blends!");
    setShapeBlends(BlendModes[int(random(0, BlendModes.length))]);
  }
};


IBeatEvent partFreak = new IBeatEvent() 
{ 
  public void trigger() 
  { 
    //   println("particles");
    //            timeScale = 1;     
    for (int i=0; i<flocks.length; i++)
    {
      if (random(0, 1) < 0.25)
        flocks[i].setTexture(spriteTexs[ (int)random(0, spriteTexs.length) ]);
      flocks[i].active = (random(0, 1) < 0.75);
      flocks[i].maxspeed = random(5, 80*500f/medianTime);
      flocks[i].attraction = random(0.08, 100f/medianTime);
      flocks[i].maxforce = random(0.05, flocks[i].maxspeed);
    }
  }
};


IBeatEvent partHide = new IBeatEvent() 
{ 
  public void trigger() 
  { 
    for (int i=0; i<flocks.length; i++)
    {
      flocks[i].active = false;
    }
  }
};


IBeatEvent partShow = new IBeatEvent() 
{ 
  public void trigger() 
  { 
    flocks[(int)random(0, flocks.length)].active = true;
  }
};

