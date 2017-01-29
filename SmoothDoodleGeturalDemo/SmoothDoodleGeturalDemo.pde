/**
 * A little doodle demo using the Spline class to compress & smooth mouse inputs.
 * Points are recorded at a fixed interval (distance) and used as handles for a
 * continous curve.
 * 
 * Key controls:
 * h - toggle spline handles on/off
 * s - toggle display of smoothed spline
 * l - toggle display of raw linear connection between handles (to compare with curvature)
 * any other key clears the canvas/history
 */

/* 
 * Copyright (c) 2006-2009 Karsten Schmidt
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
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

import toxi.geom.*;
import toxi.processing.*;
import java.util.List;
import java.util.ListIterator;
import java.util.LinkedList;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;


// Reference to physics "world" (2D)
VerletPhysics2D physics;

// Our "Chain" object
LinkedList<Chain> chains = new LinkedList<Chain>();


LineStrip2D points=new LineStrip2D();
Spline2D spline;
LineStrip2D splineVerts;




// desired distance between points/handles
int sampleDistance=50;

int maxPoints = 121;
int currentPoints = 0;

boolean showLine=true;
boolean showSpline=true;
boolean showHandles=true;

ToxiclibsSupport gfx;

void setup() {
  size(600, 600, P3D);
  gfx=new ToxiclibsSupport(this);
  smooth(4);

  // Initialize the physics world
  physics=new VerletPhysics2D();
  physics.addBehavior(new GravityBehavior2D(new Vec2D(0.01, 0.01)));
  physics.setWorldBounds(new Rect(0, 0, width, height));
}

void draw() {
  background(255);
  noFill();

  // Update physics
  physics.update();
  /*
  // Update chain's tail according to mouse location 
   chain.updateTail(mouseX,mouseY);
   // Display chain
   chain.display();
   */

  if (showLine) {
    stroke(255, 0, 0, 50);
    gfx.lineStrip2D(points);
  }

  stroke(0);
  // highlight the positions of the points with circles


  if (splineVerts != null)
  {
    if (showHandles)
      for (Vec2D p : splineVerts.getVertices()) {
        ellipse(p.x, p.y, 5, 5);
      }
    // draw the smoothened curve
    gfx.lineStrip2D(splineVerts);
  }

  stroke(255, 0, 255);
  
  
  
  for (Chain chain : chains)
  {
      chain.display();
  }
  
  
  // TODO remove bad chains 
  
  
  stroke(128,100);
  fill(200,100);
  
  if (false)
  for (VerletSpring2D spring : physics.springs)
  {
    gfx.line(spring.a, spring.b);
    ellipse(spring.a.x, spring.a.y, 5, 5);
  }
}

void keyPressed() {
  if (key=='h') showHandles=!showHandles;
  else if (key=='l') showLine=!showLine;
  else if (key=='s') showSpline=!showSpline;
  else points =new LineStrip2D();
}


boolean altPoint = false; // keep track of alt. points... need better way

void mouseDragged()
{
  if (currentPoints == 0)
  {
    Vec2D currP=new Vec2D(mouseX, mouseY);
    // add first point regardless
    points.add(currP);
    currentPoints++;
  } 
  else
  {
    Vec2D currP=new Vec2D(mouseX, mouseY);
    // check distance to previous point
    Vec2D prevP=(Vec2D)points.get(currentPoints-1);
    if (currP.distanceTo(prevP)>sampleDistance) {

      // point 1/2 in between
      Vec2D centerP = currP.add(prevP).scale(0.5);
      float angle = altPoint ? PI/6f : -PI/6f;
      Vec2D centerPRotated = centerP.sub(prevP).rotate(angle).add(prevP);

      points.add(centerPRotated);
      points.add(currP);
      currentPoints += 2;

      altPoint = !altPoint;

      while (currentPoints > maxPoints)
      {
        points.getVertices().remove(0);
        currentPoints--;
      }

      // need at least 4 vertices for a spline
      if (currentPoints>3) {
        // pass the points into the Spline container class
        spline=new Spline2D(points.getVertices());
        // sample the curve at a higher resolution
        // so that we get extra 8 points between each original pair of points
        splineVerts = spline.setTightness(0.25).toLineStrip2D(2);
      }
    }
  }
}

void mouseReleased()
{
  altPoint = false;
  if (splineVerts != null)
    chains.push(new Chain(splineVerts.getVertices(), 0.2f));
  
  splineVerts = null;
  points.getVertices().clear();
  currentPoints = 0;
}