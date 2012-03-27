
boolean drawBG = true;


// -----------------------------------------------------------------
// SimpleOpenNI event handlers -- these add and remove skeletons from our list

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  context.startPoseDetection("Psi", userId);


  // add to list of skeletons if this id doesn't already exist
  ListIterator<Skeleton> iterator = skeletons.listIterator();

  boolean found = false;

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      // we're already tracking this skeleton
      found = true;
      s.calibrated = false;
      break;
    }
  }

  // start tracking this one if not found in our list
  if (!found)
  {
    iterator.add(new Skeleton(context, userId) );

    // reset iterator
    currentSkeletonIter = skeletons.listIterator();
    if ( currentSkeletonIter.hasNext() )
        currentSkeleton =    currentSkeletonIter.next();
      else
        currentSkeleton = null;
  }
}


void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);


  context.getUsers(userList);

  if ( userList.size() < 1)
    drawBG = true;

  // add to list of skeletons if this id doesn't already exist
  ListIterator<Skeleton> iterator = skeletons.listIterator();

  boolean found = false;

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      iterator.remove();

      // reset iterator
      currentSkeletonIter = skeletons.listIterator();  
      
      if ( currentSkeletonIter.hasNext() )
        currentSkeleton =    currentSkeletonIter.next();
      else
        currentSkeleton = null;

      break;
    }
  }
}



void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);

  boolean found = false;

  ListIterator<Skeleton> iterator = skeletons.listIterator();

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      s.calibrated = false;
      found = true;
      break;
    }
  }
}


void onEndCalibration(int userId, boolean successful)
{
  println("onEndCalibration - userId: " + userId + ", successful: " + successful);

  if (successful) 
  {
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);

    // stop drawing depth image
    drawDepthImage = false;
    drawBG = false;
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }

  boolean found = false;

  ListIterator<Skeleton> iterator = skeletons.listIterator();

  while ( !found && iterator.hasNext () )
  {
    Skeleton s = iterator.next();
    if (s.id == userId)
    {
      s.calibrated = successful;
      found = true;

      // set as current skeleton    
      if (successful)
      {
        currentSkeleton = s;
        buildSkeleton(currentSkeleton);
      }

      break;
    }
  }
}


void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

