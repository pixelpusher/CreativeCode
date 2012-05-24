//////////////////////////////////////////////////////////////////////
//////// HERE IS WHERE YOU SET GAME OBJECTS PROPERTIES ///////////////
//////////////////////////////////////////////////////////////////////

// number of bricks left to break
int breakableBricks = 0;

///////// bricks properties  ///////////////////////////////
int numberOfBricks = 90;
int bricksPerRow = 20;
int brickScale = 15;  // relative to size of screen
int brickWidth = SCREEN_WIDTH/bricksPerRow;
int brickHeight = SCREEN_HEIGHT/brickScale;
int bricksStartY = 20;

boolean brickHasStroke = true;
color brickStroke = color(255);
boolean brickHasFill = true;

// alternating colors for rows of bricks
color[] rowsColors = {
  color(255,0,255), color(255,255,0), color(255,200,0), color(0,200,255), color(0,255,255), color(0,255,0)
};


////// balls properties /////////////////
int ballMinDiameter = SCREEN_WIDTH/80;
int ballMaxDiameter = SCREEN_WIDTH/40;
int numberOfBalls = 2;


int paddleHeight = SCREEN_HEIGHT/12;
int paddlesY     = SCREEN_HEIGHT-paddleHeight;

int numberOfPaddles = 4;
int paddleWidth  = min(SCREEN_WIDTH/numberOfPaddles, SCREEN_WIDTH/10);


////////////////////////////////////////////////////////////////
// Create ball objects and add to game balls list //////////////
////////////////////////////////////////////////////////////////
void createBalls()
{
  // TODO: remove all balls from allGameObjects first if necessary

  // get rid of all previous bricks, if there are any
  if (balls != null) 
  {
    balls.clear();
  }
  else
  {
    // otherwise make a new ArrayList to hold our game bricks
    balls = new ArrayList<DrawableNode>();
  }

  // figure out how much of the screen is taken up by bricks...
  int brickRows        = numberOfBricks/bricksPerRow;
  int brickBlockHeight = brickRows*brickHeight;

  int ballsStartY      = bricksStartY + brickBlockHeight + ballMaxDiameter;
  int ballsEndY        = SCREEN_HEIGHT - ballMaxDiameter;

  // check if we have space for balls!!!
  if (ballsEndY-ballsStartY < ballMaxDiameter) 
  {
    println("NO SPACE FOR BALLS!! Try less bricks (or smaller ones)");
  }

  int ballXInterval = SCREEN_WIDTH/((ballMaxDiameter+20)*numberOfBalls);

  for (int i=0; i<numberOfBalls; i++) 
  {
    int ballDiameter     = int(random(ballMinDiameter, ballMaxDiameter));
    float x = ballDiameter + i*(ballDiameter+5);
    float y = random(ballsStartY, ballsEndY);
    DrawableNode ball = new DrawableNode(x,y,ballDiameter,ballDiameter);
    ball.putData("type", "ball" + nf(i,2));
    ball.frictionCoeff = 1f;  // balls never stop...
    ball.accelerate(Vec2D.randomVector().scaleSelf(10));
    balls.add(ball);
    ball.hasFill = true;
    ball.hasStroke = true;
   //ball.wrap = true;

    allGameObjects.add(ball);
  }
}


////////////////////////////////////////////////////////////////
// Create paddle objects and add to  list //////////////////////
////////////////////////////////////////////////////////////////

void createPaddles()
{

  // get rid of all previous bricks, if there are any
  if (paddles != null) 
  {
    paddles.clear();
  }
  else  
  {
    // otherwise make a new ArrayList to hold our game paddles
    paddles = new ArrayList<DrawableNode>();
  }

  int paddleXInterval = paddleWidth*2;

  // loop through and make new brick objects and add to bricks list
  for (int i=0; i < numberOfPaddles; i++)
  {
    float x = paddleWidth + i*paddleXInterval;

    DrawableNode p = new DrawableNode(x, paddlesY, paddleWidth, paddleHeight);
    if (i==0) paddleHeight /= 3;
    p.putData("type", "paddle" + nf(i,2));
    paddles.add(p);
    p.hasFill = true;
    p.hardness = 0.9f; // how hard it bounces off
    p.hasStroke = true;
    p.movable = false; // if true, will bounce back when it hits a ball
    
    p.fillColor = color(220,(i/float(numberOfPaddles-1)) * 128,10);
    
    p.frictionCoeff = 0.9f;  // paddles are a bit heavy...
    allGameObjects.add(p);
  }  
  
  // paddle 1  
  mainPaddleIndex = 0;
}



//-----------------------------------------------
// Create brick objects and add to game bricks list
//-----------------------------------------------
void createBricks()
{
  brickWidth = SCREEN_WIDTH/bricksPerRow;
  brickHeight = SCREEN_HEIGHT/brickScale;

  // get rid of all previous bricks, if there are any
  if (bricks != null) 
  {
    bricks.clear();
  }
  else  
  {
    // otherwise make a new ArrayList to hold our game bricks
    bricks = new ArrayList<DrawableNode>();
  }


   PImage charImg = loadImage("kidicarus_walkleft.png");

  // loop through and make new brick objects and add to bricks list
  for (int i=0; i<numberOfBricks; i++)
  {
    int rowNum = i/bricksPerRow;
    // coords
    int x = brickWidth*i;
    x -= rowNum*bricksPerRow*brickWidth;
    int y = bricksStartY + rowNum*brickHeight;
    // color
    int num = min(rowNum, rowsColors.length-1);
    color rowColor = rowsColors[num];
    // create brick
    //DrawableNode brick = new DrawableNode(x, y, brickWidth-1, brickHeight-1);
    
    AnimatedImageNode brick = new AnimatedImageNode(charImg, x, y, brickWidth-1, brickHeight-1, 4, 1);
    
    brick.fillColor = rowColor;
    brick.hasFill = true;
    //brick.hasStroke = true;

    brick.putData ("type", "brick" + nf(i,3));


    boolean breakability = (random(0,1) >= 0.1);
    if (!breakability) brick.fillColor = color(100,100,100);
    else breakableBricks++;
    
    brick.putData("breakable", new Boolean( breakability ) );
    brick.spriteIndex = int(random(0,4));
    brick.msPerFrame = 30+int(random(0,100));
    brick.wrap = true;
    bricks.add(brick);
    allGameObjects.add(brick);
  }
  println("created " + bricks.size() + "bricks");

  int boundaryThickness = 1000;

  // add boundaries
  DrawableNode node = new DrawableNode(0,-boundaryThickness, width, boundaryThickness);
  node.putData("breakable", new Boolean(false) );
  node.fillColor = color(0);
  node.putData ("type", "brickwall");
  node.movable = false;
  allGameObjects.add(node);

  node = new DrawableNode(-boundaryThickness,0, boundaryThickness,height);
  node.putData("breakable", new Boolean(false) );
  node.fillColor = color(0);
  node.putData ("type", "brickwall");
  node.movable = false;
  allGameObjects.add(node);

  node = new DrawableNode(width,0, boundaryThickness, height);
  node.putData("breakable", new Boolean(false) );
  node.fillColor = color(0);
  node.putData ("type", "brickwall");
  node.movable = false;
  allGameObjects.add(node);

  node = new DrawableNode(0,height, width, boundaryThickness);
  node.putData("breakable", new Boolean(false) );
  node.fillColor = color(0);
  node.movable = false;
  node.putData ("type", "brickwall");
  allGameObjects.add(node);
}


//-----------------------------------------------
// Create a single random brick and add it to the list of bricks in the game
//-----------------------------------------------

DrawableNode createRandomBrick()
{
  //
  // CREATE BRICKS --
  int i= int( random(0, numberOfBricks));

  int rowNum = i/bricksPerRow;
  // coords
  int x = brickWidth*i;
  x -= rowNum*bricksPerRow*brickWidth;
  int y = bricksStartY+i/bricksPerRow*brickHeight;
  // color
  int num = min(rowNum, rowsColors.length-1);
  color rowColor = rowsColors[num];
  // create brick
  DrawableNode brick = new DrawableNode(x, y, brickWidth, brickHeight);
  brick.fillColor = rowColor;
  brick.hasFill = true;
  brick.hasStroke = true;


  return brick;
}

