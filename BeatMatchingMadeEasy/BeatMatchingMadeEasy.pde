/*
 * Using classes to create "beats".
 * This is basically a primitive sequencer, of sorts.
 *
 * By Evan Raskob 2012
 *
 * Licensed under BSD license. No warrantee provided.
 *
 */



int[] intervals = new int[3];
int index = 0;
int lastTime = 0;
boolean keyDown = false;
int medianTime = 500;
Beat[] beats;

PFont font;

void setup()
{
  size(512, 384);
  noStroke();
  smooth();
  lastTime = millis();

  beats = new Beat[4];

  // start beat objects in motions
  for (int b=0; b<beats.length; b++)
  {
    beats[b] = new Beat(4);
  }

  beats[0].addListener( 
    new IBeatListener() 
    { 
      public void beatChanged(int beat)
      {
        println("Beat changed:" + beat);
      }

      public void beatReset()
      {
        println("Beat reset");
      }
    }
    );
  
  BeatMatcher matcher = new BeatMatcher( beats[0].getMaxBeats() );
  matcher.addBeatEvent( 1,
    new IBeatEvent() { 
      public void trigger() { println("Beat 1 MATCHED"); }
    });
  
  beats[0].addListener( matcher );
  
  matcher.addBeatEvent( 1,
    new IBeatEvent() { 
      public void trigger() { println("Beat 1 MATCHED AGAIN!"); }
    });
  
  
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


void draw()
{
  fill(0, 20);
  rect(0, 0, width, height);
  fill(255);
  text("Tap spacebar to \nset the tempo", width/2, 40);


  int ms = millis();

  // update beat objects in motions
  for (int b=0; b<beats.length; b++)
    beats[b].update(ms);

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
}

void keyPressed()
{
  if (!keyDown)
  {
    keyDown = true;
    int currentTime = millis();
    int timeInterval = currentTime - lastTime;
    lastTime = currentTime;

    intervals[index] = timeInterval;
    index = (index + 1) % intervals.length;
    intervals = sort(intervals);
    medianTime = intervals[(intervals.length-1)/2];  /// middle element

    for (int b=0; b<beats.length; b++)
      beats[b].setBeatInterval( (int)pow((b+1), 2) * medianTime );

    //println("Median time:" + medianTime);
  }
}

void keyReleased()
{
  keyDown = false;
}



