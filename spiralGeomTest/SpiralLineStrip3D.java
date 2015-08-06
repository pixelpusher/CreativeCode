/*    
 * This file is by Evan Raskob <info@pixelist.info>, loosely based on other classes
 * from toxiclibs core by Karsten Schmidt.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 */


// Direction and axis are handled only when getting a point or list of points


import java.util.ArrayList;
import java.util.List;

import toxi.geom.ReadonlyVec3D;
import toxi.geom.Vec3D;
import toxi.math.MathUtils;



public class SpiralLineStrip3D extends LineStrip3D2 {

  public Vec3D dir;
  public Vec3D pos;


  private float radius;
  private int   numPoints;
  private float turns;
  private float distanceBetweenTurns;
  private float edgeThickness; // thickness of the line
  private float length;


  /**
   * Constructs a new 3D spiral instance.
   * 
   * @param pos
   *            start position
   * @param dir
   *            direction
   */
  public SpiralLineStrip3D(ReadonlyVec3D pos, ReadonlyVec3D dir) 
  {
    this.pos = new Vec3D(pos);
    this.dir = dir.getNormalized();
  }

  public SpiralLineStrip3D() 
  {
    // defaults to not much of a spiral
    this.pos = new Vec3D(0, 0, 0);
    this.radius = 0;
    this.numPoints = 0;
    this.turns = 0;
    this.distanceBetweenTurns = 0;
    this.edgeThickness = 0;
    this.dir = new Vec3D(Vec3D.Z_AXIS);
    this.recalculate();
  }

  /*
     * Boring get/set stuff
   */
  public SpiralLineStrip3D setRadius(float radius, boolean recalculate)
  {
    this.radius = radius;
    if (recalculate)
      this.recalculate();
    return this;
  }
  public SpiralLineStrip3D setRadius(float radius)
  {     
    return this.setRadius(radius, true);
  }

  public SpiralLineStrip3D setTurns(float turns)
  {     
    return this.setTurns(turns, true);
  }
  public SpiralLineStrip3D setTurns(float turns, boolean recalculate)
  {
    this.turns = turns;
    if (recalculate)
      this.recalculate();
    return this;
  }

  public SpiralLineStrip3D setDistanceBetweenTurns(float distanceBetweenTurns)
  {     
    return this.setDistanceBetweenTurns(distanceBetweenTurns, true);
  }
  public SpiralLineStrip3D setDistanceBetweenTurns(float distanceBetweenTurns, boolean recalculate)
  {
    this.distanceBetweenTurns = distanceBetweenTurns;
    if (recalculate)
      this.recalculate();
    return this;
  }


  public SpiralLineStrip3D setEdgeThickness(float edgeThickness)
  {     
    return this.setEdgeThickness(edgeThickness, true);
  }
  public SpiralLineStrip3D setEdgeThickness(float edgeThickness, boolean recalculate)
  {
    this.edgeThickness = edgeThickness;
    if (recalculate)
      this.recalculate();
    return this;
  }  

  public SpiralLineStrip3D setNumPoints(int numPoints)
  {     
    return this.setNumPoints(numPoints, true);
  }
  public SpiralLineStrip3D setNumPoints(int numPoints, boolean recalculate)
  {
    this.numPoints = numPoints;
    if (recalculate)
      this.recalculate();
    return this;
  }  

  public List<Vec3D> getVertices() 
  {
    return super.getVertices();
  }

  // TODO - handle rotation based on this.dir??
  // TODO - fix this, it's not following convention but quicker right now...

  public List<Vec3D> getVertices(boolean useOffset) 
  {
    if (useOffset)
    {
      final ArrayList<Vec3D> truePoints = new ArrayList<Vec3D>(this.vertices.size());
      for (Vec3D pt : this.vertices)
      {
        truePoints.add(pt.add(this.pos));
      }

      return truePoints;
    } else
      return super.getVertices();
  }


  public float getRadius() { 
    return radius;
  }
  public int   getNumPoints() { 
    return numPoints;
  }
  public float getTurns() { 
    return turns;
  }
  public float getDistanceBetweenTurns() { 
    return distanceBetweenTurns;
  }
  public float getEdgeThickness() { 
    return edgeThickness;
  }
  public float getLength() { 
    return length;
  }


  //
  // recalculate all the points in this spiral
  //
  public SpiralLineStrip3D recalculate()
  {

    if (turns < 1)
    {
      turns = 1; // avoid divide by 0
    }

    int pointsPerTurn = (int)(this.numPoints/this.turns);
    int totalPoints   = (int)(pointsPerTurn*this.turns); // might have been rounding differences

      this.vertices = new ArrayList<Vec3D>( totalPoints);

    // nothing to do here - too few points
    if (totalPoints < 2)
    {
      for (int i=0; i< totalPoints; i++)
        this.vertices.add(new Vec3D(this.radius, 0, 0));

      return this;
    }

    System.out.println("total points: " + totalPoints +  " / " +  this.numPoints);
    if (totalPoints != this.numPoints) System.out.println("SpiralLineStrip3D WARNING:: total points and numPoints not the same due to turns. Updating them.");
    System.out.println("points per turn: " +  pointsPerTurn);
    System.out.println("turns: " + this.turns);

    this.numPoints = totalPoints;

    // NOTE: Direction and axis are handled only when getting a point or list of points

      // note - here we're calculating all points requested, even though the number of turns might not match exactly.. 
    // have to choose one or the other.
    for (int currentPoint=0; currentPoint < this.numPoints; currentPoint++)
    {
      float turnsProgress = (float)(currentPoint)/totalPoints;
      float turnsInnerProgress = (float)(currentPoint % pointsPerTurn)/pointsPerTurn;
      float turnsInnerAngle = turnsInnerProgress * MathUtils.TWO_PI;
      float x = MathUtils.cos( turnsInnerAngle ) * this.radius;
      float y = MathUtils.sin( turnsInnerAngle ) * this.radius;
      float z = turnsProgress * this.turns * (this.edgeThickness+this.distanceBetweenTurns);
      this.vertices.add(new Vec3D(x, y, z));
    }

    Vec3D topBottomDiff = this.vertices.get( this.vertices.size() - 1).sub(this.vertices.get(0));

    this.length = topBottomDiff.z; // aligning to Z axis internally makes this easier...

    return this;
  }

  // TODO - implement this??

  /*
  public Mesh3D toMesh(int steps) {
   return toMesh(steps, 0);
   }
   
   public Mesh3D toMesh(int steps, float thetaOffset) {
   return toMesh(null, steps, thetaOffset, true, true);
   }
   
   public Mesh3D toMesh(Mesh3D mesh, int steps, float thetaOffset, 
   boolean topClosed, boolean bottomClosed) {
   
   ReadonlyVec3D c = this.add(0.01f, 0.01f, 0.01f);
   ReadonlyVec3D n = c.cross(dir.getNormalized()).normalize();
   Vec3D halfAxis = dir.scale(length * 0.5f);
   Vec3D p = sub(halfAxis);
   Vec3D q = add(halfAxis);
   Vec3D[] south = new Vec3D[steps];
   Vec3D[] north = new Vec3D[steps];
   float phi = MathUtils.TWO_PI / steps;
   for (int i = 0; i < steps; i++) {
   float theta = i * phi + thetaOffset;
   ReadonlyVec3D nr = n.getRotatedAroundAxis(dir, theta);
   south[i] = nr.scale(radiusSouth).addSelf(p);
   north[i] = nr.scale(radiusNorth).addSelf(q);
   }
   int numV = steps * 2 + 2;
   int numF = steps * 2 + (topClosed ? steps : 0)
   + (bottomClosed ? steps : 0);
   if (mesh == null) {
   mesh = new TriangleMesh("cone", numV, numF);
   }
   for (int i = 0, j = 1; i < steps; i++, j++) {
   if (j == steps) {
   j = 0;
   }
   mesh.addFace(south[i], north[i], south[j], null, null, null, null);
   mesh.addFace(south[j], north[i], north[j], null, null, null, null);
   if (bottomClosed) {
   mesh.addFace(p, south[i], south[j], null, null, null, null);
   }
   if (topClosed) {
   mesh.addFace(north[i], q, north[j], null, null, null, null);
   }
   }
   return mesh;
   }
   */
}

