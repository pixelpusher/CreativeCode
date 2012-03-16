
class MoveDetect
{
  float prev_x, prev_y, prev_z;
  public static final int numPlotSamples = 256;
  float[] mFunction;
  float thresh = 80;
  float SMOOTHING = 0.2f;
  float cursample;
  
  int onsetState,swipeStart,swipeEnd;
  int lastStateChange;
  int stateChangeInterval = 1000; // in ms
  
  
  
  MoveDetect()
  {
     mFunction = new float[numPlotSamples]; 
     
     onsetState = 0;
     swipeStart = 0;
     swipeEnd = 0;
     lastStateChange = 0;
  }
  
  
  
  
  // plots the movement function as a signal on the screen
  void plotMovementFunction()
  {
    int xpixel1, xpixel2;

    for (int i = 0;i < (numPlotSamples-1);i++)
    {
      xpixel1 = (int) round((((float) i) / ((float) numPlotSamples))*((float)context.depthWidth()));
      xpixel2 = (int) round((((float) i+1) / ((float) numPlotSamples))*((float)context.depthWidth()));
      stroke(255);
      line(xpixel1, context.depthHeight()-mFunction[i], xpixel2, context.depthHeight()-mFunction[i+1]);
    }
  }

  // returns a movement function sample for a given limb
  void jointMovementFunction(int userId, int joint)
  {
    float d_x, d_y, d_z;  // to hold current differences
    float diff;        // to hold overall difference

    // PVector to hold joint position
    PVector jointPos = new PVector();

    // get joint position for the given limb
    context.getJointPositionSkeleton(userId, joint, jointPos);

    // calculate the difference between current and previous position
    d_x = abs(jointPos.x - prev_x);
    d_y = abs(jointPos.y - prev_y);
    d_z = abs(jointPos.z - prev_z);    

    // sum x, y and z differences to get overall movement function sample
    diff = d_x + d_y + d_z;

    // store current position for next sample point
    prev_x = lerp(jointPos.x, prev_x, SMOOTHING);
    prev_y = lerp(jointPos.y, prev_y, SMOOTHING);
    prev_z = lerp(jointPos.z, prev_z, SMOOTHING);

    if (diff > thresh)
    {
      onsetStateVerify(1);
      // generate swipe events for each limb...
     // onSwipe(joint);
    }
    
    if (diff < 20)
    {
      onsetStateVerify(0); 
    }

    // store movement function sample
    cursample = diff;
    
    // prepare movement function for plotting by shifting everything back one
    for (int i = 0;i < (numPlotSamples-1);i++)
    {
      mFunction[i] = mFunction[i+1];
    }
    mFunction[numPlotSamples-1] = cursample; // add new function to the end
  }



  void onSwipe(int joint)
  {
     println("ONSET!!!!!!!!!!!!"); 
  }  
  
  
  
  // see if an swipe start has started or ended
  void onsetStateVerify(int cur_state)
  {
     swipeStart = 0;
     swipeEnd = 0;
     
     if ( (onsetState == 0) && (cur_state == 1) && ((millis()-lastStateChange) > stateChangeInterval) )
     {
        lastStateChange = millis();
        swipeStart = 1;
        onsetState = 1;
     }
     
     if ((onsetState == 1) && (cur_state == 0) && ((millis()-lastStateChange) > stateChangeInterval))
     {
        lastStateChange = millis();
        swipeEnd = 1;
        onsetState = 0;
     }
  }
   
}
