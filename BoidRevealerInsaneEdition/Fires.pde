
LinkedList<DrawableNode> fireNodes;
int numberOfFires = 40;
int firesStartY = 400;
int fireRows = 2; 
float fireRotationSpeed = PI/20f;
float fireOverlap = 0.8f;

void animateFires(PGraphics renderer)
{
  for (DrawableNode fire : fireNodes)
  {
    fire.update();
    fire.draw(renderer);
  }
}


void setupFires(PGraphics renderer)
{
  int firesPerRow = numberOfFires / fireRows;
  int fireWidth = renderer.width/firesPerRow;
  int fireHeight = (renderer.height-firesStartY)/fireRows;
  fireHeight = fireWidth = min(fireWidth, fireHeight);


  // get rid of all previous bricks, if there are any
  if (fireNodes != null) 
  {
    fireNodes.clear();
  }
  else  
  {
    // otherwise make a new ArrayList to hold our game bricks
    fireNodes = new LinkedList<DrawableNode>();
  }

  PImage fireImg = loadImage("fire128.png");

  // loop through and make new brick objects and add to bricks list
  for (int i=0; i<numberOfFires; i++)
  {
    int rowNum = i/firesPerRow;
    // coords
    int x = fireWidth*i;
    x -= rowNum*firesPerRow*fireWidth;
    int y = firesStartY + rowNum*fireHeight;
    // color
    //    int num = min(rowNum, rowsColors.length-1);
    //    color rowColor = rowsColors[num];
    // create brick


    DrawableNode fire = new ImageNode(fireImg, x, y, fireWidth*(1+fireOverlap), fireHeight*(1+fireOverlap));
    fire.hasFill = true;
    fire.fillColor = color(255,100);
    fire.rotation = random(0, TWO_PI); // all random rotations
    fire.rotationSpeed = fireRotationSpeed;
    fire.update();
    println("r:" + fire.rotation + "/" + fire.rotationSpeed);

    // fire.fillColor = rowColor;
    //fire.hasFill = true;
    //brick.hasStroke = true;

    fire.putData ("type", "fire" + nf(i, 3));

    fireNodes.add(fire);
  }
}

