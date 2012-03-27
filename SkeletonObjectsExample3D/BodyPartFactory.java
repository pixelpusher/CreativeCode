/*
 * Singleton factory for creating BodyParts
 */

import SimpleOpenNI.*;
import processing.core.PImage;
import processing.core.PVector;



public class BodyPartFactory
{
  // Private constructor prevents instantiation from other classes
  private BodyPartFactory() {
  }

  /**
   * SingletonHolder is loaded on the first execution of Singleton.getInstance() 
   * or the first access to SingletonHolder.INSTANCE, not before.
   */
  private static class SingletonHolder 
  { 
    public static final BodyPartFactory instance = new BodyPartFactory();
  }

  public static BodyPartFactory getInstance() 
  {
    return SingletonHolder.instance;
  }


  public static BodyPart makeBodyPart(int part1ID, int type)
  {
    return (BodyPart)(new OnePointBodyPart(part1ID, type));
  }

  public static BodyPart makeBodyPart(int part1ID, int part2ID, int type)
  {
    return (BodyPart)(new TwoPointBodyPart(part1ID, part2ID, type));
  }


  public static BodyPart makeBodyPart(int part1ID, int part2ID, int part3ID, int part4ID, int type)
  {
    return (BodyPart)(new FourPointBodyPart(part1ID, part2ID, part3ID, part4ID, type));
  }

  
  public static BodyPart createPartForSkeleton(Skeleton skeleton, int part1ID, int type)
  {
    BodyPart bp = makeBodyPart(part1ID, type).setSkeletonId(skeleton.id).setContext(skeleton.context);
    skeleton.addBodyPart(bp);

    return bp;
  }

  public static BodyPart createPartForSkeleton(Skeleton skeleton, int part1ID, int part2ID, int type)
  {
    BodyPart bp = makeBodyPart(part1ID, part2ID, type).setSkeletonId(skeleton.id).setContext(skeleton.context);
    skeleton.addBodyPart(bp);

    return bp;
  }


  public static BodyPart createPartForSkeleton(Skeleton skeleton, int part1ID, int part2ID, int part3ID, int part4ID, int type)
  {
    BodyPart bp = makeBodyPart(part1ID, part2ID, part3ID, part4ID, type).setSkeletonId(skeleton.id).setContext(skeleton.context);
    skeleton.addBodyPart(bp);

    return bp;
  }


  // end class BodyPartFactory
}

