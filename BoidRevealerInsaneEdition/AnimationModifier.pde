public interface IAnimationModifier
{
  public void start(int _timelength);
  public void pause();
  public void stop();
  public void update(int _currentTime);
  public boolean isFinished(); // true if this is done and can be removed
}


public class TimedAnimationModifier implements IAnimationModifier
{
  int startTime = -1;
  int currentTime = -1;
  boolean paused = false;
  int pauseStartTime = -1;
  int timelength;  // in ms
  float percentFinished=0f;

  private float timelengthInv = 1f; // inverse of timelnegth, for efficiency

  public void start(int _timelength)
  {
    startTime = millis();

    timelength = _timelength;
    timelengthInv = 1f/timelength;
  }

  public void pause()  
  {
    if (startTime > -1) // handle if pause before start?
    {
      if (paused)
      {
        paused = false;
        startTime += (millis()-pauseStartTime);
        pauseStartTime = -1;
      }
      else
      {
        paused = true;
        pauseStartTime = millis();
      }
    }
  }

  public void stop()
  {
  }

  public void update(int _currentTime)
  {
    if (startTime > -1)
    {
      currentTime = _currentTime;
      int timeDiff = currentTime-startTime;
      percentFinished = timeDiff * timelengthInv;
    }
  }
  public boolean isFinished() // true if this is done and can be removed
  {
    return (currentTime-startTime) >= timelength;
  }
}

