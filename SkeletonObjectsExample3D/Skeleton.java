import SimpleOpenNI.*;
import java.util.ArrayList;

public class Skeleton
{
  // the userid from OpenNI
  public int id = 1;
  public SimpleOpenNI context;
  
  // are we calibrated and ready to draw?
  public boolean calibrated;

  // relevant skeleton positions from our Kinect in screen coordinates:

  public ArrayList<BodyPart> mBodyParts;

  // end class vars

  // 
  // Default constructor
  //
  public Skeleton(SimpleOpenNI _context)
  {
    mBodyParts = new ArrayList<BodyPart>();
    context = _context;
    calibrated = false;
  }

  // 
  // Constructor with id
  //
  public Skeleton(SimpleOpenNI _context, int _id)
  {
    id = _id;
    context = _context;
    mBodyParts = new ArrayList<BodyPart>();
    calibrated = false;
  }

  

  ////////////////////////////////////////
  // update internal vars
  //

  public Skeleton update()
  {
    // draw the skeleton if it's available
    if (calibrated && context.isTrackingSkeleton(id))
    {  
      for (BodyPart bp : mBodyParts)
      {
        bp.update();
      }
    }
    
    // return reference to this object
    return this;
  } 


 /*
 static int HEAD = 0;
  static int NECK = 1;
  static int LEFT_ARM_UPPER = 2;
  static int LEFT_ARM_LOWER = 3;
  static int RIGHT_ARM_UPPER = 4;
  static int RIGHT_ARM_LOWER = 5;
  static int TORSO = 6;
  static int LEFT_LEG_UPPER = 7;
  static int LEFT_LEG_LOWER = 8;
  static int RIGHT_LEG_UPPER = 9;
  static int RIGHT_LEG_LOWER = 10;
  */

  public ArrayList<BodyPart> getPartsByType(int type)
  {
    ArrayList<BodyPart> foundParts = new ArrayList<BodyPart>();
    
    for (BodyPart part : mBodyParts)
    {
      if (part.getType() == type)
        foundParts.add(part);
    }
    return foundParts;
  }


  public Skeleton addBodyPart(BodyPart bp)
  {
    mBodyParts.add(bp);
    
    return this;
  }
  
  // end class Skeleton
}

