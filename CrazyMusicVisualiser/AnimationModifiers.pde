class FadeWhitneyOnBeat implements IAnimationModifier 
{
  int maxBeats = 8;
  int beatCount = 0;
  int startId;
  ProjectedShape ps;
  
  FadeWhitneyOnBeat()
  {
    startId = int(random(0,999999));
  }

  public void stop() {
    int r = (ps.dstColor >> 16) & 0xFF;
    int g = (ps.dstColor >> 8) & 0xFF;
    int b = ps.dstColor & 0xFF;
    ps.dstColor = 0xE0000000 | (r << 16) | (g << 8) | b;
    ps = null;
  }
  public void pause() {
  }
  public void start(int t) 
  {
    nextBeatShape();
    ps = beatShape;
  }
  public void update(int t) 
  {
    float beat = beats[currentBeatIndex].getPartialBeat() % 1f; // 1/4
    int balpha = int(beat*180) <<  24;

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
    startId = int(random(0,999999));
  }

  public void stop() {
    fy = 0.8;
  }
  public void pause() {
  }
  public void start(int t) {
  }
  public void update(int t) 
  {
    float beat = beats[currentBeatIndex].getPartialBeat() % 1f; // 1/4

    fy = beat;
    
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

