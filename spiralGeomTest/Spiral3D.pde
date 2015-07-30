/*
 * Creates a 3D spiral form internally aligned to the Z axis. 
 * Direction and axis are handled only when getting a point or list of points.
 *
 * Copyright (c) 2015 Evan Raskob <info@pixelist.info>
 * (based in part on other classes from toxiclibs core by Karsten Schmidt.)
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



public class Spiral3D extends Vec3D {

  public Vec3D dir;  
  public boolean VERBOSE = true; // send spiral info to System.out

  protected Vec3D[] points;
  
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
  public Spiral3D(ReadonlyVec3D pos, ReadonlyVec3D dir) 
  {
    super(pos);
    this.dir = dir.getNormalized();
  }

  public Spiral3D() 
  {
    // defaults to not much of a spiral
    super(new Vec3D(0,0,0));
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
  public Spiral3D setRadius(float radius, boolean recalculate)
  {
    this.radius = radius;
    if (recalculate)
      this.recalculate();
    return this;
  }
  public Spiral3D setRadius(float radius)
  {     
    return this.setRadius(radius, true);
  }

  public Spiral3D setTurns(float turns)
  {     
    return this.setTurns(turns, true);
  }
  public Spiral3D setTurns(float turns, boolean recalculate)
  {
    this.turns = turns;
    if (recalculate)
      this.recalculate();
    return this;
  }

  public Spiral3D setDistanceBetweenTurns(float distanceBetweenTurns)
  {     
    return this.setDistanceBetweenTurns(distanceBetweenTurns, true);
  }
  public Spiral3D setDistanceBetweenTurns(float distanceBetweenTurns, boolean recalculate)
  {
    this.distanceBetweenTurns = distanceBetweenTurns;
    if (recalculate)
      this.recalculate();
    return this;
  }


  public Spiral3D setEdgeThickness(float edgeThickness)
  {     
    return this.setEdgeThickness(edgeThickness, true);
  }
  public Spiral3D setEdgeThickness(float edgeThickness, boolean recalculate)
  {
    this.edgeThickness = edgeThickness;
    if (recalculate)
      this.recalculate();
    return this;
  }  

  public Spiral3D setNumPoints(int numPoints)
  {     
    return this.setNumPoints(numPoints, true);
  }
  public Spiral3D setNumPoints(int numPoints, boolean recalculate)
  {
    this.numPoints = numPoints;
    if (recalculate)
      this.recalculate();
    return this;
  }  


  // TODO - handle rotation based on this.dir??

  public Vec3D[] getPoints()
  {
    final Vec3D[] truePoints = new Vec3D[this.points.length];
    for (int i=0; i<truePoints.length; i++)
    {
      truePoints[i] = this.points[i].add(this);
    }
    
    return truePoints;
  }


  public float getRadius() { return radius; }
  public int   getNumPoints() { return numPoints; }
  public float getTurns() { return turns; }
  public float getDistanceBetweenTurns() { return distanceBetweenTurns; }
  public float getEdgeThickness() { return edgeThickness; }
  public float getLength() { return length; }


  //
  // recalculate all the points in this spiral
  //
  public Spiral3D recalculate()
  {

    if (turns < 1)
    {
      turns = 1; // avoid divide by 0
    }

    int pointsPerTurn = int(numPoints/turns);
    int totalPoints   = int(pointsPerTurn*turns); // might have been rounding differences

      points = new Vec3D[totalPoints];

    // nothing to do here - too few points
    if (totalPoints < 2)
    {
      for (int i=0; i< points.length; i++)
        points[i] = new Vec3D(radius, 0, 0);

      return this;
    }

    if (VERBOSE)
    {
      System.out.println("total points: " + totalPoints +  " / " +  numPoints);
      System.out.println("points per turn: " +  pointsPerTurn);
      System.out.println("turns: " + turns);
    }
    
    // NOTE: Direction and axis are handled only when getting a point or list of points

    for (int currentPoint=0; currentPoint < totalPoints; currentPoint++)
    {
      float turnsProgress = float(currentPoint)/totalPoints;
      float turnsInnerProgress = float(currentPoint % pointsPerTurn)/pointsPerTurn;
      float turnsInnerAngle = turnsInnerProgress * TWO_PI;
      float x = cos( turnsInnerAngle ) * radius;
      float y = sin( turnsInnerAngle ) * radius;
      float z = turnsProgress * turns * (edgeThickness+distanceBetweenTurns);
      points[currentPoint] = new Vec3D(x, y, z);
    }

    Vec3D topBottomDiff = points[points.length-1].sub(points[0]);
    this.length = topBottomDiff.z; // aligning to Z axis internally makes this easier...
    
    return this;
  }

/* //TODO-------------------------------

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

