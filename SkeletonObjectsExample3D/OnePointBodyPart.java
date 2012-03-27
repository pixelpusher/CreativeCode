import SimpleOpenNI.*;
import processing.core.PImage;
import processing.core.PVector;


public class OnePointBodyPart extends BodyPart
{
  public PVector worldPoint1, screenPoint1, pworldPoint1, pscreenPoint1;  

  private int joint1ID;

  //
  // Basic contructor
  //
  public OnePointBodyPart(int _joint1ID, int type )
  {
    setType(type);

    worldPoint1 = new PVector();
    screenPoint1 = new PVector();

    pworldPoint1 = new PVector();
    pscreenPoint1 = new PVector();

    offsetPercent = new PVector();
    offsetCalculated = new PVector();

    joint1ID = _joint1ID;

    tex = null;
    context = null;

    padR = padL = padT = padB = 0f;
  }


  public PVector getJoint(int type)
  {
    return screenPoint1;
  }

  public PVector getPrevJoint(int type)
  {
    return pscreenPoint1;
  }


  public BodyPart update()
  {
    pscreenPoint1.set(screenPoint1);

    // get joint positions in 3D world for the tracked limbs
    context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);

    context.convertRealWorldToProjective(worldPoint1, screenPoint1);
    screenPoint1.z = worldDepthToScreen(screenPoint1.z);

    // now calculate offsets in screen coords
    offsetCalculated.x = offsetPercent.x*screenPoint1.x;
    offsetCalculated.y = offsetPercent.y*screenPoint1.y;
    offsetCalculated.z = offsetPercent.z*screenPoint1.z;

    return this;
  }

  public BodyPart update(float[] lag)
  {
    // get joint positions in 3D world for the tracked limbs
    context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);

    context.convertRealWorldToProjective(worldPoint1, screenPoint1);
    screenPoint1.z = worldDepthToScreen(screenPoint1.z);

    // now calculate offsets in screen coords
    offsetCalculated.x = lag[0]*offsetCalculated.x + (1f-lag[0])*offsetPercent.x*screenPoint1.x;
    offsetCalculated.y = lag[0]*offsetCalculated.y + (1f-lag[0])*offsetPercent.y*screenPoint1.y;
    offsetCalculated.z = lag[0]*offsetCalculated.z + (1f-lag[0])*offsetPercent.z*screenPoint1.z;

    return this;
  }
}

