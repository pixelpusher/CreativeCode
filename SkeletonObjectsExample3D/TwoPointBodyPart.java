import SimpleOpenNI.*;
import processing.core.PImage;
import processing.core.PVector;


public class TwoPointBodyPart extends BodyPart
{
  public PVector worldPoint1, screenPoint1, pworldPoint1, pscreenPoint1;
  public PVector worldPoint2, screenPoint2, pworldPoint2, pscreenPoint2;


  private int joint1ID, joint2ID;

  //
  // Basic contructor
  //
  public TwoPointBodyPart(int _joint1ID, int _joint2ID, int type )
  {
    setType(type);

    worldPoint1 = new PVector();
    screenPoint1 = new PVector();

    pworldPoint1 = new PVector();
    pscreenPoint1 = new PVector();

    worldPoint2 = new PVector();
    screenPoint2 = new PVector();

    pworldPoint2 = new PVector();
    pscreenPoint2 = new PVector();

    offsetPercent = new PVector();
    offsetCalculated = new PVector();

    joint1ID = _joint1ID;
    joint2ID = _joint2ID;

    tex = null;
    context = null;

    padR = padL = padT = padB = 0f;
  }


  public PVector getJoint(int type)
  {
    if (joint1ID == type)
      return screenPoint1;
    else
      return screenPoint2;
  }

  public PVector getPrevJoint(int type)
  {
    if (joint1ID == type)
      return pscreenPoint1;
    else
      return pscreenPoint2;
  }


  public BodyPart update()
  {
    pscreenPoint1.set(screenPoint1);
    pscreenPoint2.set(screenPoint2);

    // get joint positions in 3D world for the tracked limbs
    context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);
    context.getJointPositionSkeleton(skeletonId, joint2ID, worldPoint2);

    context.convertRealWorldToProjective(worldPoint1, screenPoint1);
    screenPoint1.z = worldDepthToScreen(screenPoint1.z);

    context.convertRealWorldToProjective(worldPoint2, screenPoint2);
    screenPoint2.z = worldDepthToScreen(screenPoint2.z);

    // now calculate offsets in screen coords
    offsetCalculated.x = offsetPercent.x*(screenPoint1.x+screenPoint2.x)*0.5f;
    offsetCalculated.y = offsetPercent.y*(screenPoint1.y+screenPoint2.y)*0.5f;
    offsetCalculated.z = offsetPercent.z*(screenPoint1.z+screenPoint2.z)*0.5f;

    return this;
  }

  //
  // TODO: make this real
  //
  public BodyPart update(float[] lag)
  {
    // get joint positions in 3D world for the tracked limbs
    context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);
    context.getJointPositionSkeleton(skeletonId, joint2ID, worldPoint2);

    context.convertRealWorldToProjective(worldPoint1, screenPoint1);
    screenPoint1.z = worldDepthToScreen(screenPoint1.z);

    context.convertRealWorldToProjective(worldPoint2, screenPoint2);
    screenPoint2.z = worldDepthToScreen(screenPoint2.z);

    // now calculate offsets in screen coords
    offsetCalculated.x = offsetPercent.x*(screenPoint1.x+screenPoint2.x)*0.5f;
    offsetCalculated.y = offsetPercent.y*(screenPoint1.y+screenPoint2.y)*0.5f;
    offsetCalculated.z = offsetPercent.z*(screenPoint1.z+screenPoint2.z)*0.5f;

    return this;
  }
}

