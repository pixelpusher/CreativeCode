/*
 * Represents a projection-mapped shape using a source image
 * and set of source points in that image (forming a polygon)
 * and a destination set of points (forming a polgon) that
 * the image should be mapped to.
 *
 *
 */

class ProjectedShape
{
  PImage srcImage = null;

  // for tinting:
  int r;
  int g;
  int b;
  int a;
  int blendMode = BLEND;

  // for outlining:
  color srcColor = color(255, 255);
  color dstColor = color(255, 255);

  String name = null;

  LinkedList<ProjectedShapeVertex> verts = null; // list of points in the image (PVectors)

  ProjectedShape(PImage img)
  {
    if (img != null)
      srcImage = img;
    else
      println("ERROR::::IMAGE FOR PROJECTED SHAPE CANNOT BE NULL!!");
    verts    = new LinkedList<ProjectedShapeVertex>();

    // give it a random name
    name = "shape" + random(0, MAX_INT);
  }


  // deep copy ProjectedShape

  ProjectedShape(ProjectedShape srcShape)
  {
    if (srcShape.srcImage != null)
      srcImage = srcShape.srcImage;
    else
      println("ERROR::::IMAGE FOR PROJECTED SHAPE CANNOT BE NULL!!");

    // deep copy verts
    verts    = new LinkedList<ProjectedShapeVertex>();

    for (ProjectedShapeVertex psvert : srcShape.verts )
    {
      verts.add(new ProjectedShapeVertex(psvert) );
    }

    // give it a random name
    name = "shape" + random(0, MAX_INT);
  }



  // Add a new source and destination vertex
  ProjectedShapeVertex addVert(float srcX, float srcY, float destX, float destY)
  {
    PVector srcVert  =  new PVector(srcX, srcY);
    PVector destVert = new PVector(destX, destY);

    ProjectedShapeVertex newVert = new ProjectedShapeVertex( srcVert, destVert); 

    verts.add( newVert );

    return newVert;
  }


  void removeVert( ProjectedShapeVertex v)
  {
    verts.remove( v );
  }


  void clear()
  {
    srcImage = null;

    clearVerts();
  }

  void clearVerts()
  {    
    for (ProjectedShapeVertex v : verts)
      v.clear();

    verts.clear();
  }

  // sync all the projected vertices to the source verts
  void syncVertsToSource()
  {
    for (ProjectedShapeVertex v : verts)
      v.dest.set(v.src);
  }

  // sync all the projected vertices to the source verts
  void syncVertsToDest()
  {
    for (ProjectedShapeVertex v : verts)
      v.src.set(v.dest);
  }


  // Find the closest vertex - return null if none is within the distance
  ProjectedShapeVertex getClosestVertexToSource( float x, float y, float distanceSquared)
  {
    // this represents the one we've found
    ProjectedShapeVertex result = null;

    for (int i=0; i < verts.size(); ++i)
    {
      ProjectedShapeVertex vert = verts.get(i);

      float xdiff =  vert.src.x - x;
      float ydiff =  vert.src.y - y;
      float dsquared = xdiff*xdiff+ydiff*ydiff;

      if ( dsquared <= distanceSquared)
      {
        result = vert;
      }
    }

    return result;
  }



  // Find the closest vertex - return null if none is within the distance
  ProjectedShapeVertex getClosestVertexToDest( float x, float y, float distanceSquared)
  {
    // this represents the one we've found
    ProjectedShapeVertex result = null;

    for (int i=0; i < verts.size(); ++i)
    {
      ProjectedShapeVertex vert = verts.get(i);

      float xdiff =  vert.dest.x - x;
      float ydiff =  vert.dest.y - y;
      float dsquared = xdiff*xdiff+ydiff*ydiff;

      if ( dsquared <= distanceSquared)
      {
        result = vert;
      }
    }
    return result;
  }



  PVector createNewShapeVertexFromSourcePoint( PVector vert1src, PVector vert2src, PVector vert1dest, PVector vert2dest, PVector newPoint)
  {
    // add a new point between the current and previous vertices
    // make it proportional to the destination shape based on the distance between verts
    // in the source shape

    // calc standardized distance between new point and previous point 
    // could get direction from currentVert & prevVert, normalize, and then use magnitude of x,y - currentVert?

    // total distance between src points            
    float diffSrcMag = PVector.sub(vert1src, vert2src).mag();

    // how far along are we?
    PVector diffNewSrc = PVector.sub(newPoint, vert1src);
    float diffNewSrcMag = diffNewSrc.mag() / diffSrcMag;
    // DEBUG
    //println("percent diff:" + diffNewSrcMag);

    // in what direction?
    // source direction: PVector dirNewSrc = new PVector(diffNewSrc.x, diffNewSrc.y, diffNewSrc.z);
    // dest direction:
    PVector dirNewSrc = PVector.sub(vert2dest, vert1dest);
    dirNewSrc.normalize();

    float diffDest = PVector.sub(vert2dest, vert1dest).mag();

    PVector pvecDest = PVector.mult(dirNewSrc, diffNewSrcMag);
    pvecDest.mult(diffDest);
    pvecDest.add( vert1dest );
    /* DEBUG       
     println("adding point at:");
     println(pvecSource);
     println(pvecDest);
     */
    return pvecDest;
  }


  /*
   * Attempt to add a new projected shape vertex to this shape, if the point (x,y) given
   * is less than the maximum distance, e.g. "distanceSquared"
   *
   */
  ProjectedShapeVertex addClosestSourcePointToLine( float x, float y, float distanceSquared)
  {
    // this represents the one we're going to add (if any)
    ProjectedShapeVertex result = null;

    // sanity check, are there are currently any vertices stored in this shape?
    if (verts != null && verts.size() > 1)
    {
      PVector pvecSource = new PVector (x, y);
      PVector pvecDest = new PVector (x, y);

      ListIterator<ProjectedShapeVertex> iter = verts.listIterator();
      ProjectedShapeVertex currentVert = iter.next();
      ProjectedShapeVertex prevVert = currentVert;

      // go through the list of vertices one by one and see if the distance between the point x,y, and line
      // made by successive vertices is less than the maximum distance distanceSquared
      while (iter.hasNext () && result == null)
      {
        // make sure we're not at the last element
        if (iter.hasNext() )
        {
          prevVert = currentVert;
          currentVert = iter.next();

          float d = distancePointToLine(currentVert.src, prevVert.src, pvecSource);

          if ( d < distanceSquared)
          {
            iter.previous();         
            PVector newVert = createNewShapeVertexFromSourcePoint(prevVert.src, currentVert.src, prevVert.dest, currentVert.dest, pvecSource);
            result = new ProjectedShapeVertex(pvecSource, newVert);
            iter.add( result );
          }
        }
      }

      if (result == null)
      {
        // now check last and 1st
        currentVert = verts.peekLast();
        prevVert = verts.peekFirst();

        float d = distancePointToLine(currentVert.src, prevVert.src, pvecSource);

        //println("d:" + d);

        if ( d < distanceSquared)
        {
          // add a new point!
          PVector newVert = createNewShapeVertexFromSourcePoint(prevVert.src, currentVert.src, prevVert.dest, currentVert.dest, pvecSource);
          result = new ProjectedShapeVertex(pvecSource, newVert);
          verts.addLast( result );
        }
      }
    }

    return result;
  }




  ProjectedShapeVertex addClosestDestPointToLine( float x, float y, float distance)
  {
    // this represents the one we're going to add (if any)
    ProjectedShapeVertex result = null;

    // sanity check, are there are currently any vertices stored in this shape?
    if (verts != null && verts.size() > 1)
    {
      PVector pvecSource = new PVector (x, y);
      PVector pvecDest = new PVector (x, y);

      ListIterator<ProjectedShapeVertex> iter = verts.listIterator();
      ProjectedShapeVertex currentVert = iter.next();
      ProjectedShapeVertex prevVert = currentVert;

      // go through the list of vertices one by one and see if the distance between the point x,y, and line
      // made by successive vertices is less than the maximum distance distanceSquared
      while (iter.hasNext () && result == null)
      {
        // make sure we're not at the last element
        if (iter.hasNext() )
        {
          prevVert = currentVert;
          currentVert = iter.next();

          float d = distancePointToLine(currentVert.dest, prevVert.dest, pvecDest);

          if ( d < distanceSquared)
          {
            iter.previous();         
            PVector newVert = createNewShapeVertexFromSourcePoint(prevVert.dest, currentVert.dest, prevVert.src, currentVert.src, pvecDest);
            result = new ProjectedShapeVertex(newVert, pvecDest);

            iter.add( result );
          }
        }
      }

      if (result == null)
      {
        // now check last and 1st
        currentVert = verts.peekLast();
        prevVert = verts.peekFirst();

        float d = distancePointToLine(currentVert.dest, prevVert.dest, pvecDest);

        //println("d:" + d);

        if ( d < distanceSquared)
        {
          // add a new point!
          PVector newVert = createNewShapeVertexFromSourcePoint(prevVert.dest, currentVert.dest, prevVert.src, currentVert.src, pvecDest);
          result = new ProjectedShapeVertex(newVert, pvecDest);
          verts.addLast( result );
        }
      }
    }

    return result;
  }




  void move(float x, float y, boolean useSource)
  {
    // draw the shape using source and destination vertices
    if (verts != null && verts.size() > 1)
    {      
      ListIterator<ProjectedShapeVertex> iter = verts.listIterator();

      while (iter.hasNext ())
      {
        PVector v1 = useSource ? iter.next().src : iter.next().dest;


        v1.x += x;
        v1.y += y;
      }
    }
  }



  // end class ProjectedShape
}

