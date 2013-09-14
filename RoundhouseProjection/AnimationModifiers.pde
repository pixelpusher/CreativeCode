class FadeWhitneyOnBeat implements IAnimationModifier 
{
  int maxBeats = 8;
  int beatCount = 0;
  int startId;
  ProjectedShape ps;

  FadeWhitneyOnBeat()
  {
    startId = int(random(0, 999999));
  }

  public void stop() {
    //int r = (ps.dstColor >> 16) & 0xFF;
    //int g = (ps.dstColor >> 8) & 0xFF;
    //int b = ps.dstColor & 0xFF;
    //ps.dstColor = 0x85000000 | (r << 16) | (g << 8) | b;
    ps = null;
  }
  public void pause() {
  }
  public void start(int t) 
  {
    maxBeats = t;
  }
  public void update(int t) 
  {
    float beat = beats[currentBeatIndex].getPartialBeat() % 1f; // 1/4
    int balpha = int(beat*80) <<  24;

    int r = (ps.dstColor >> 16) & 0xFF;
    int g = (ps.dstColor >> 8) & 0xFF;
    int b = ps.dstColor & 0xFF;
    ps.dstColor = balpha | (r << 16) | (g << 8) | b;

    if (beats[currentBeatIndex].getBeatChanged()) 
    {
      //println("beat["+"]" + startId +" " + this.beatCount + " :: " + millis());
      this.beatCount++;
    }
  }
  public boolean isFinished()
  {
    if (this.beatCount >= this.maxBeats)
      return true;

    return false;
  }
}



class FadeGlowOnBeat implements IAnimationModifier 
{
  int maxBeats = 4;
  int beatCount = 0;
  int startId;

  FadeGlowOnBeat()
  {
    startId = int(random(0, 999999));
  }

  public void stop() {
    fy = 0.85;
  }
  public void pause() {
  }
  public void start(int t) {
    maxBeats = t;
  }
  public void update(int t) 
  {
    float beat = beats[currentBeatIndex].getPartialBeat() % 1f; // 1/4

    fy = sqrt(beat)*0.8f;

    if (beats[currentBeatIndex].getBeatChanged()) 
    {
      this.beatCount++;
    }
  }
  public boolean isFinished()
  {
    if (this.beatCount >= this.maxBeats)
      return true;

    return false;
  }
}



// Scale/pan camera movement
class ScaleAnimationModifier implements IAnimationModifier 
{ 
  int maxBeats = 4;
  int beatCount = 0;
  int startId;
  float d;

  ScaleAnimationModifier()
  {
    d = (random(0,1) >= 0.5) ? -1 : 1;
  }

  public void stop() {
  }
  public void pause() {
  }
  public void start(int t) 
  {
    maxBeats = t;
    beatCount = 0;
  }
  public void update(int t) 
  {
    float beat = beats[currentBeatIndex].getPartialBeat()/maxBeats; // 1/4

    if (beats[currentBeatIndex].getBeatChanged()) 
    {
      this.beatCount++;
    }

    translate( d*beat*width/2, 0);
    scale( ((1f-beat)+1.5) );
  }
  public boolean isFinished()
  {
    if (this.beatCount >= this.maxBeats)
      return true;

    return false;
  }
}




// Scale/pan camera movement
class PanAnimationModifier implements IAnimationModifier 
{ 
  int maxBeats = 4;
  int beatCount = 0;
  int startId;
  float direction, zoomScale;

  PanAnimationModifier(float _direction, float _zoomScale)
  {
    direction = _direction; 
    zoomScale = _zoomScale;
  }

  public void stop() {
  }
  public void pause() {
  }
  public void start(int t) {
    maxBeats = t;
    beatCount = 0;
  }
  public void update(int t) 
  {
    float beat = beats[currentBeatIndex].getPartialBeat()/maxBeats;

    if (beats[currentBeatIndex].getBeatChanged()) 
    {
      this.beatCount++;
    }

    //move right
    translate( -width/2 + direction*width/2 + (-direction)*beat*width/zoomScale , -height/2);
    scale(zoomScale);
  }
  public boolean isFinished()
  {
    if (this.beatCount >= this.maxBeats)
      return true;

    return false;
  }
}


