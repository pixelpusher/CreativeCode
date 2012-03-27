import SimpleOpenNI.*;
import processing.core.PImage;
import processing.core.PVector;


public class FourPointBodyPart extends BodyPart
{
  public PVector worldPoint1, screenPoint1;
  public PVector worldPoint2, screenPoint2;
  public PVector worldPoint3, screenPoint3;
  public PVector worldPoint4, screenPoint4;
  
  public PVector pworldPoint1, pscreenPoint1;
  public PVector pworldPoint2, pscreenPoint2;
  public PVector pworldPoint3, pscreenPoint3;
  public PVector pworldPoint4, pscreenPoint4;
  
  private int joint1ID, joint2ID, joint3ID, joint4ID;
  
  //
  // Basic contructor
  //
  public FourPointBodyPart(int _joint1ID, int _joint2ID, int _joint3ID, int _joint4ID, int type )
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

    worldPoint3 = new PVector();
    screenPoint3 = new PVector();

    pworldPoint3 = new PVector();
    pscreenPoint3 = new PVector();

    worldPoint4 = new PVector();
    screenPoint4 = new PVector();
    
    pworldPoint4 = new PVector();
    pscreenPoint4 = new PVector();

    offsetPercent = new PVector();
    offsetCalculated = new PVector();
    
    joint1ID = _joint1ID;
    joint2ID = _joint2ID;
    joint3ID = _joint3ID;
    joint4ID = _joint4ID;

    tex = null;
    context = null;
    
    padR = padL = padT = padB = 0f;
  }
  
  
  public PVector getJoint(int type)
  {
    if (joint1ID == type)
      return screenPoint1;
    else if (joint2ID == type)
      return screenPoint2;
    else if (joint3ID == type)
      return screenPoint3;
    else return screenPoint4;
  }

  public PVector getPrevJoint(int type)
  {
    if (joint1ID == type)
      return pscreenPoint1;
    else if (joint2ID == type)
      return pscreenPoint2;
    else if (joint3ID == type)
      return pscreenPoint3;
    else return pscreenPoint4;
  }
  
  public BodyPart update()
  {
      pscreenPoint1.set(screenPoint1);
      pscreenPoint2.set(screenPoint2);
      pscreenPoint3.set(screenPoint3);
      pscreenPoint4.set(screenPoint4);
      
    // get joint positions in 3D world for the tracked limbs
      context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);
      context.getJointPositionSkeleton(skeletonId, joint2ID, worldPoint2);
      context.getJointPositionSkeleton(skeletonId, joint3ID, worldPoint3);      
      context.getJointPositionSkeleton(skeletonId, joint4ID, worldPoint4);

      context.convertRealWorldToProjective(worldPoint1, screenPoint1);
      screenPoint1.z = worldDepthToScreen(screenPoint1.z);
      
      context.convertRealWorldToProjective(worldPoint2, screenPoint2);
      screenPoint2.z = worldDepthToScreen(screenPoint2.z);

      context.convertRealWorldToProjective(worldPoint3, screenPoint3);
      screenPoint3.z = worldDepthToScreen(screenPoint3.z);

      context.convertRealWorldToProjective(worldPoint4, screenPoint4);
      screenPoint4.z = worldDepthToScreen(screenPoint4.z);
      
      // now calculate offsets in screen coords
      offsetCalculated.x = offsetPercent.x*(screenPoint1.x+screenPoint2.x)*0.5f;
      offsetCalculated.y = offsetPercent.y*(screenPoint1.y+screenPoint4.y)*0.5f;
      offsetCalculated.z = offsetPercent.z*(screenPoint1.z+screenPoint4.z)*0.5f;
      
      return this;
  }
  
  //
  // TODO: make this real
  //
  public BodyPart update(float[] lag)
  {
      pscreenPoint1.set(screenPoint1);
      pscreenPoint2.set(screenPoint2);
      pscreenPoint3.set(screenPoint3);
      pscreenPoint4.set(screenPoint4);

    // get joint positions in 3D world for the tracked limbs
      context.getJointPositionSkeleton(skeletonId, joint1ID, worldPoint1);
      context.getJointPositionSkeleton(skeletonId, joint2ID, worldPoint2);
      context.getJointPositionSkeleton(skeletonId, joint3ID, worldPoint3);      
      context.getJointPositionSkeleton(skeletonId, joint4ID, worldPoint4);

      context.convertRealWorldToProjective(worldPoint1, screenPoint1);
      screenPoint1.z = worldDepthToScreen(screenPoint1.z);
      
      context.convertRealWorldToProjective(worldPoint2, screenPoint2);
      screenPoint2.z = worldDepthToScreen(screenPoint2.z);

      context.convertRealWorldToProjective(worldPoint3, screenPoint3);
      screenPoint3.z = worldDepthToScreen(screenPoint3.z);

      context.convertRealWorldToProjective(worldPoint4, screenPoint4);
      screenPoint4.z = worldDepthToScreen(screenPoint4.z);
      
      // now calculate offsets in screen coords
      offsetCalculated.x = offsetPercent.x*(screenPoint1.x+screenPoint2.x)*0.5f;
      offsetCalculated.y = offsetPercent.y*(screenPoint1.y+screenPoint4.y)*0.5f;
      offsetCalculated.z = offsetPercent.z*(screenPoint1.z+screenPoint4.z)*0.5f;
      
      return this;
  }
}

