/*
 * Using classes to create "beats".
 * Exends the simple example to add different beat sequences.
 * This is basically a primitive sequencer, of sorts.
 *
 * By Evan Raskob 2012
 *
 * Licensed under BSD license. No warrantee provided.
 *
 */

final int MAX_BEAT_INTERVAL = 1500;  // max time between beats in ms

int[] intervals = new int[3]; // tap intervals, for tapping out the meat
int medianTime = 500; // the media time between taps - used to calculate current BPM (beats per minute)
int index = 0; // for median time calcuation
int lastTime = 0;
boolean keyDown = false;

Beat[] beats;
final int NUM_SCENES = 3;
int beatsCounted=0, beatsPerScene=8;  // current number of beats in this scene
int currentBeatIndex = 0;  //current Beat scene


LinkedList<IAnimationModifier> animModifiers;


PFont font;

void setup()
{
  size(512, 384);
  noStroke();
  smooth();
  lastTime = millis();

  animModifiers = new  LinkedList<IAnimationModifier>();

  beats = new Beat[4];

  // start beat objects in motions
  for (int b=0; b<beats.length; b++)
  {
    beats[b] = new Beat(4);
    beats[b].beatInterval = medianTime; 


    IBeatListener bl = new IBeatListener() 
    { 
      public void beatChanged(int beat)
      {
        println("Beat changed:" + beat);
        // decide whether to switch beats
        updateBeatScene();
      }

      public void beatUpdated(float beat)
      {
      }  // do nothing

      public void beatReset()
      {
        println("Beat reset");
      }
    };

    //report back for each beat
    beats[b].addListener( bl );
  }

  BeatMatcher matcher = new BeatMatcher( beats[0].getMaxBeats() );
  matcher.addBeatEvent( 3, 
  new IBeatEvent() { 
    public void trigger() { 
      println("Beat 3 MATCHED");
    }
  }
  );

  matcher.addBeatEvent( 0, 
  new IBeatEvent() { 
    public void trigger() 
    { 
      println("start ellipse!");
      
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          colorMode(HSB, 360,100,100,100);
          
          fill (65, 100, map(percentFinished, 0,1,100,0));
          ellipse(width/8, height/4,width/16,width/16);
        }
        public void stop()
        { 
          println("stop ellipse!");
        }
      };

      animod.start(beats[currentBeatIndex].beatInterval);
      animModifiers.add( animod );
    }
  }
  );


matcher.addBeatEvent( 2, 
  new IBeatEvent() { 
    public void trigger() 
    { 
      println("start ellipse 2!");
      
      IAnimationModifier animod = new TimedAnimationModifier()
      {        
        public void update(int t)
        {
          super.update(t);
          colorMode(HSB, 360,100,100,100);
          
          fill (303, 100, map(percentFinished, 0,1,100,0));
          ellipse(2*width/8, height/4,width/16,width/16);
        }
        public void stop()
        { 
          println("stop ellipse 2!");
        }
      };

      animod.start(beats[currentBeatIndex].beatInterval);
      animModifiers.add( animod );
    }
  }
  );

  // add this beat matcher to the list of beat listeners, listening for beat changes
  beats[0].addListener(matcher);
  beats[1].addListener(matcher);


  //initialize beat intervals
  for (int i=0; i<intervals.length; i++)
  {
    intervals[i] = medianTime;
  }

  font = loadFont("SilkscreenExpanded-24.vlw");
  textFont(font, 24); 
  textAlign(CENTER);
  background(0);
  ellipseMode(CENTER);
  frameRate(60);
}





//
// Update for a new beat.
// If necessary, change to a random new beat scene
//

void updateBeatScene()
{
  beatsCounted++;

  println("beatsCounted: " + beatsCounted);
  if (beatsCounted > beatsPerScene)
  {
    int newBeatIndex = int ( random(0, NUM_SCENES) );
    beats[newBeatIndex].reset();
    beatsCounted = 0;
    beatsPerScene = int( random(1, 4)) * 8;
    println("new beats per scene:" + beatsPerScene);
    currentBeatIndex =   newBeatIndex;
    println("Changed beat:" + newBeatIndex);
  }
}




void draw()
{
  
  colorMode(RGB);
  fill(0, 20);
  rect(0, 0, width, height);
  fill(255);
  text("Tap spacebar to \nset the tempo", width/2, 40);

  int ms = millis();

  // update beat objects in motions
  beats[currentBeatIndex].update(ms);

  pushMatrix();
  float eSize = beats[0].getCurrentBeat()*width/12;
  translate(width/6, height/2);
  fill(255, 0, 0, 100);
  ellipse(0, 0, eSize, eSize);
  fill(0, 255, 255, 200);
  text(1+int(beats[0].getPartialBeat() ), 0, 0);


  eSize = beats[1].getPartialBeat()*width/12;
  translate(width/3, 0);
  fill(0, 255, 0, 100);
  ellipse(0, 0, eSize, eSize);
  fill(255, 0, 255, 200);
  text(1+int(beats[1].getPartialBeat()), 0, 0);

  eSize = beats[2].getPartialBeat()*width/12;
  translate(width/3, 0);
  fill(0, 0, 255, 100);
  ellipse(0, 0, eSize, eSize);
  fill(255, 255, 0, 200);
  text(1+int(beats[2].getPartialBeat()), 0, 0);
  popMatrix();

  fill(255);
  text("Median time:" + medianTime, width/2, height-40);

  text("BPM:" + 60000/medianTime, width/2, height-20);
  
  // --------------------------------------------
  // Timed animations ---------------------------
  // --------------------------------------------
  //
  // These are added by BeatListeners when beats are matched

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

    // update all beats:
    for (int b=0; b<beats.length; b++)
      beats[b].setBeatInterval( medianTime );
    println("Median time:" + medianTime);

  }
}


void keyPressed()
{
  if (!keyDown)
  {
    keyDown = true;
    switch(key)
    {
      case(' '):    
      tapTempo();
      break;
    }
  }
}

void keyReleased()
{
  keyDown = false;
}

