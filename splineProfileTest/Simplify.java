// Java port adapted from https://github.com/mourner/simplify-js/blob/master/simplify.js
// "Simplify.js is a high-performance JavaScript polyline simplification library by Vladimir Agafonkin"

/**
 * LICENSE
 *
 *
 * Copyright (c) 2015, Vladimir Agafonkin
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * 
 *    1. Redistributions of source code must retain the above copyright notice, this list of
 *       conditions and the following disclaimer.
 * 
 *    2. Redistributions in binary form must reproduce the above copyright notice, this list
 *       of conditions and the following disclaimer in the documentation and/or other materials
 *       provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 **/

import java.util.List;
import java.util.ArrayList;
import java.util.ListIterator;
import toxi.geom.Vec2D;
import processing.core.PApplet;


public class Simplify
{ 

  // square distance from a point to a segment
  static public float getSqSegDist(Vec2D p, Vec2D p1, Vec2D p2) {

    float    x = p1.x;
    float    y = p1.y;
    float    dx = p2.x - x;
    float    dy = p2.y - y;

    if (PApplet.abs(dx) > PApplet.EPSILON || PApplet.abs(dy) > PApplet.EPSILON) {

      float t = ((p.x - x) * dx + (p.y - y) * dy) / (dx * dx + dy * dy);

      if (t > 1) {
        x = p2.x;
        y = p2.y;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }

    dx = p.x - x;
    dy = p.y - y;

    return dx * dx + dy * dy;
  }

  /*
   * used internally by simplifyDouglasPeucker
   */
  static private void simplifyDPStep(List<Vec2D> pointsList, float sqTolerance, List<Vec2D> simplifiedPoints) {
    float maxSqDist = sqTolerance;
    int endIndex = pointsList.size()-1;

    ListIterator<Vec2D> iterator = pointsList.listIterator();

    Vec2D firstPoint = iterator.next();
    Vec2D lastPoint = pointsList.get(endIndex);
    Vec2D maxDistPoint = firstPoint; 
    int currentIndex  = 0;
    int maxPointIndex = 0;

    while (iterator.hasNext ()) 
    {
      ++currentIndex;

      Vec2D currentPoint = iterator.next();

      float sqDist = getSqSegDist(currentPoint, firstPoint, lastPoint);

      if (sqDist > maxSqDist) 
      {
        maxDistPoint = currentPoint;
        maxPointIndex = currentIndex;
        maxSqDist = sqDist;
      }
    }

    if (maxSqDist > sqTolerance) 
    {
      if (maxPointIndex > 1) simplifyDPStep(pointsList.subList(0, maxPointIndex), sqTolerance, simplifiedPoints);
      simplifiedPoints.add(maxDistPoint);
      if (endIndex - maxPointIndex > 1) simplifyDPStep(pointsList.subList(maxPointIndex, pointsList.size()), sqTolerance, simplifiedPoints);
    }
  }

  // simplification using Ramer-Douglas-Peucker algorithm
  public static List<Vec2D> simplifyDouglasPeucker(List<Vec2D> points, float sqTolerance) 
  {
    ArrayList<Vec2D> simplifiedPoints = new ArrayList<Vec2D>();

    int endIndex = points.size()-1;

    if (endIndex > 3)
    {
      simplifiedPoints.add(points.get(0));
      simplifyDPStep(points.subList(0, endIndex), sqTolerance, simplifiedPoints);
      simplifiedPoints.add(points.get(endIndex));
    } else
    {
      for (Vec2D v : points)
      {
        simplifiedPoints.add(v);
      }
    }

    return simplifiedPoints;
  }
}

