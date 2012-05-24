
/** 
 * A minimal block-breaking "game"
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

import processing.opengl.*;
// using toxiclibs for vectors, better than Processing's built-in ones
import toxi.geom.Vec2D;
import java.util.LinkedList;


ArrayList<DrawableNode> bricks = null;
ArrayList<DrawableNode> balls = null;
ArrayList<DrawableNode> paddles = null;
ArrayList<DrawableNode> allGameObjects = null;

int mainPaddleIndex = 0;

static boolean verbose = false;


/////// scoring //////////////////
int score=0;

static int gameTime = 0;


// SCREEN PROPERTIES --
static final int SCREEN_WIDTH = 800;
static final int SCREEN_HEIGHT = 600;

color backgroundColor = color(46, 33, 260, 100);

boolean backgroundRefreshes = true;




///////// SETUP  ///////////////////////////////

void setup() 
{
  size(SCREEN_WIDTH, SCREEN_HEIGHT, OPENGL);
  //size(800,600);

  background(backgroundColor);
  frameRate(60);  

  newGame();
}


///////// INIT  //////////////////////////////////////////////
// in a separate method so it can be called again to re-init
/////////////////////////////////////////////////////////////
void newGame()
{

  gameTime = millis();

  if (allGameObjects != null) allGameObjects.clear();

  allGameObjects = new ArrayList<DrawableNode>();

  // create objects
  createBricks();
  createBalls();
  createPaddles();

  score = 0;
}  




/////////////////////////////////////////////////////////////
/// send a ball hit message to all clients

void sendBallHitOSCMessage(Vec2D v)
{
  if (verbose) println("ball hit! " + millis());
}


void sendPaddleHitOSCMessage(Vec2D v)
{
  if (verbose)   println("paddle hit! " + millis());
}

void sendBrickHitOSCMessage(Vec2D v, boolean breakable)
{
  if (verbose)   println("brick hit! " + millis());
}



////////////////////////////////////////////////////////
// move paddle /////////////////////////////////////////

void movePaddle(int i, float x, float y)
{
  if (i > -1 && i < paddles.size())
  {
    DrawableNode p = paddles.get(i);

    float xCoord = map(x, 0, 1, 0, width); 
    float yCoord = map(y, 0, 1, 0, height); 

    Vec2D a = new Vec2D(x-p.pos.x, y-p.pos.y);
    a.scaleSelf(0.05);

    //println("Moving X: " + xCoord + " Y: " +  yCoord ) ;
    p.accelerate(a);
  }
  else
  {
    println("!!!!ERROR :: Bad Paddle!!!! :::: " + i);
  }
}


/////////////////////////////////////////////////
// draw /////////////////////////////////////////

void draw() 
{ 
  smooth();

  // BACKGROUND
  if (backgroundRefreshes) 
  {
    background(backgroundColor);
  }
  else
  {
    fill(0, 20);
    rect(0, 0, width, height);
  }   
  fill(255);

  //show score
  text("Score:" + score, 40, 20);
  text("Time:" + (millis()-gameTime)/1000, 40, 36);


  // Update the balls - check for collisions with game objects (paddles,
  // bricks) and handle accordingly.

  // update position and draw
  for (DrawableNode node : allGameObjects) 
  {
    //update ball position
    node.update();
    node.hasCollided = false;
    node.draw();
  }


  // handle collisions

  ArrayList<DrawableNode[]> collisions = new ArrayList<DrawableNode[]>();

  for (int i=0; i < allGameObjects.size(); i++) 
  {
    DrawableNode n0 = allGameObjects.get(i);

    for (int j=i+1; j < allGameObjects.size(); j++)
    {

      DrawableNode n1 = allGameObjects.get(j);

      if (n0.intersects(n1)) 
      {
        // keep track of collided pair
        collisions.add(new DrawableNode[] {
          n0, n1
        } 
        );

        n0.hasCollided = true;
        n1.hasCollided = true;

        //println("COLLISION");
      }
    }
  }

  //////////////////////////////////////
  //////// HANDLE COLLISIONS ///////////
  //////////////////////////////////////

  for (DrawableNode[] nodes : collisions)
  {
    // here's where you handle the collision...

    String node0Type = (String) nodes[0].getData("type");
    String node1Type = (String) nodes[1].getData("type");

    boolean hitBrick   = false;
    boolean hitBall    = false;
    boolean hitPaddle  = false;

    boolean node0IsBall   = false;
    boolean node0IsBrick  = false;
    boolean node0IsPaddle = false;
    boolean node0IsBreakable = false;

    boolean node1IsBall   = false;
    boolean node1IsBrick  = false;
    boolean node1IsPaddle = false;
    boolean node1IsBreakable = false;

    // if ball hits brick, it breaks.
    // if paddle hits brick, it doesn't.
    // if paddle hits paddle, ditto.
    // if brick hits brick, they break. (overlap)

    // SO, either 2 balls hit, or 2 paddles hit. then we do nothing but play a sound.
    // or, a ball hit a paddle (make sound), or a ball or brick hit a brick (break it, make sound)

    node0IsBall = node0Type.startsWith("ball");
    node0IsBrick = node0Type.startsWith("brick");
    node0IsPaddle = node0Type.startsWith("paddle");
    Object tmp = nodes[0].getData("breakable");
    if (tmp != null)
      node0IsBreakable = ((Boolean) tmp).booleanValue();

    node1IsBall = node1Type.startsWith("ball");
    node1IsBrick = node1Type.startsWith("brick");
    node1IsPaddle = node1Type.startsWith("paddle");
    tmp = nodes[1].getData("breakable");
    if (tmp != null)
      node1IsBreakable = ((Boolean) tmp).booleanValue();


    if ( node0IsBall && node1IsBall )
    {
      hitBall = true;

      // trigger sounds
      sendBallHitOSCMessage(nodes[0].vel.sub(nodes[1].vel));
    }
    else if ( node0IsPaddle || node1IsPaddle )
    {
      hitPaddle = true;
      --score;
      //println("PADDLE" + millis());
      // trigger sounds
      sendPaddleHitOSCMessage(nodes[0].vel);
    }
    else if (node0IsBrick && node1IsBrick)
    {
    }
    else if (node1IsBrick && node1IsBreakable) 
    {
      breakBrick(nodes[1]);
      hitBrick = true;
      // trigger sounds
      sendBrickHitOSCMessage(nodes[0].vel, node1IsBrick && node1IsBreakable && node0IsBrick && node0IsBreakable);
    }
    else if (node0IsBrick && node0IsBreakable) 
    {
      breakBrick(nodes[0]);
      hitBrick = true;
      // trigger sounds
      sendBrickHitOSCMessage(nodes[0].vel, node1IsBrick && node1IsBreakable && node0IsBrick && node0IsBreakable);
    }

    Collider.collide(nodes[0], nodes[1]);
  }
  // end draw
}


void breakBrick(DrawableNode brick)
{
  score += 5;
  --breakableBricks;
  allGameObjects.remove(brick);
  bricks.remove(brick);
println(breakableBricks);
println(bricks.size() + "left");
  // instant new game!!
  if (breakableBricks < 1) newGame();
}




void keyReleased()
{
  switch(key)
  {
  case 'v': 
    verbose = !verbose;
    break;
  }
}


// Update the paddle position when we move the mouse:

void mouseMoved()
{
  moveToMouse();
}

void mousePressed()
{
  moveToMouse();
}

void mouseReleased()
{
  moveToMouse();
}

void mouseDragged()
{
  moveToMouse();
}


void moveToMouse()
{
  if (paddles != null)
  {
    DrawableNode p = paddles.get(mainPaddleIndex);
    if (p.pos.x < 10 || p.pos.x > width-10 || p.pos.y < 10 || p.pos.y > height-10 )
      p.moveTo(mouseX-p.w/2, mouseY-p.h/2);
    else
    {
      Vec2D a = new Vec2D((mouseX-p.w/2)-p.pos.x, (mouseY-p.h/2)-p.pos.y);
      a.scaleSelf(0.02);

      //println("Moving X: " + xCoord + " Y: " +  yCoord ) ;
      p.accelerate(a);
    }
  }
}

