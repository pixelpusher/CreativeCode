import processing.opengl.*;

/** 
  *  Character Mover
  *  Copyright (C) 2010 Evan Raskob <evan@flkr.com>
  *
  *  This program is free software: you can redistribute it and/or modify
  *  it under the terms of the GNU Affero General Public License as
  *  published by the Free Software Foundation, either version 3 of the
  *  License, or (at your option) any later version.

  *  This program is distributed in the hope that it will be useful,
  *  but WITHOUT ANY WARRANTY; without even the implied warranty of
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *  GNU Affero General Public License for more details.

  *  You should have received a copy of the GNU Affero General Public License
  *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
  
// using toxiclibs for vectors, better than Processing's built-in ones
import toxi.geom.Vec2D;

// list of things to draw
LinkedList<DrawableNode> nodesToDraw = null;

// list of things to collide with
LinkedList<DrawableNode> nodesToCollide = null;

// our character
DrawableNode myCharacter = null;


Flock flock;


float desiredseparation = 25.0;
float avoidWallsFactor = 0.8;
float charAttract = 3.8;
float attraction = 0.08;
float neighbordist = 25.0;


void setup() 
{
  size(720,480, OPENGL);
  background(0);
  frameRate(60);

  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(new PVector(width/2,height/2), 3.0, 0.1));
  }

  // create some random nodes
  
  nodesToDraw = new LinkedList<DrawableNode>();
  
  /*
  for (int i=0; i < 10; i++)
  {
    // x,y,w,h
    DrawableNode node = new DrawableNode(random(0,width), random(0,height), random(10,40), random(10,40));
    nodesToDraw.add(node);
  }
  */
  
  // create our "character"
  myCharacter = new DrawableNode(random(0,width), random(0,height), random(10,40), random(10,40));
  myCharacter.fillColor= color(0,255,0);
  
  nodesToDraw.add(myCharacter);
  
  // nothing yet
  nodesToCollide = new LinkedList<DrawableNode>();
  
  // create our character
  
}


//-----------------------------------------------
// DRAW
//-----------------------------------------------
void draw() 
{  
  background(0);
  smooth();

  flock.run();

  // update position and draw
  for (DrawableNode node : nodesToDraw) 
  {
    //update ball position
    node.update();
    node.draw();
  }
  
  
  // handle collisions

    LinkedList<DrawableNode[]> collisions = new LinkedList<DrawableNode[]>();
    
    for (int i=0; i < nodesToDraw.size(); i++) 
    {
      DrawableNode n0 = nodesToDraw.get(i);
      
      n0.fillColor = color(255);
      
       for (int j=i+1; j < nodesToDraw.size(); j++)
       {
         
         DrawableNode n1 = nodesToDraw.get(j);
         
        if (n0.intersects(n1)) 
        {
          // keep track of collided pair
          collisions.add(new DrawableNode[] {n0,n1} );
          //println("COLLISION");
        }
      }
    }
    
    
    for (DrawableNode[] nodes : collisions)
    {
        nodes[0].fillColor = color(255,255,0);
        nodes[1].fillColor = color(255,255,0);
      
        Vec2D closestPoint = bounceBallOffRectangle(nodes[0],nodes[1]);
        fill(0,255,0,200);
        ellipse(closestPoint.x, closestPoint.y, 20, 20);
    }
    
    
// end draw()
}



// Update the paddle position when we move the mouse:

void keyPressed()
{
  if (key == CODED) 
  {
      if (keyCode == UP) {
        myCharacter.accel.y -= 1;
        
      } else if (keyCode == DOWN) {
        myCharacter.accel.y += 1;
      
      } else if (keyCode == LEFT) {
        myCharacter.accel.x -= 1;
  
      } else if (keyCode == RIGHT) {
        myCharacter.accel.x += 1;
      } 
  }
}
