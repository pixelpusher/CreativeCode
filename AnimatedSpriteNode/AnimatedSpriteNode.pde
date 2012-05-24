import processing.opengl.*;
import toxi.geom.Vec2D;



// Animated sprite
// by Evan Raskob
// 2012
// AGPL 3.0+ license



final int NUM_SPRITES = 50;
float spriteWidth = 20;
float spriteHeight = 30;
float speedLimit = 4f; // in pixels

PImage spriteImage;
String spriteName = "kidicarus_walkleft.png";
AnimatedImageNode sprites[];

DrawableNode boundaries[];


void setup()
{
  size(640, 480, OPENGL);

  boundaries = new DrawableNode[4];
  boundaries[0] = new DrawableNode(0, -40, width, 20); // x,y,w,h - top
  boundaries[1] = new DrawableNode(width-10, 10, 40, height-10); // x,y,w,h - right
  boundaries[2] = new DrawableNode(0, height-20, width-10, 40); // x,y,w,h - bottom
  boundaries[3] = new DrawableNode(-30, 0, 40, height-20); // x,y,w,h - left

  for (int i=0; i < boundaries.length; i++)
  {
    boundaries[i].movable = false;
  }

  spriteImage = loadImage(spriteName);

  sprites = new AnimatedImageNode[NUM_SPRITES];
  for (int i=0; i < sprites.length; i++)
  {
    float x = random(10, width-10);
    float y = random(10, height-10);

    sprites[i] = new AnimatedImageNode(spriteImage, x, y, spriteWidth, spriteHeight, 4, 1); 
    sprites[i].stop(); // stop animating
  }
}



void draw()
{
  background(255);

  // for all sprites
  for (int i=0; i < sprites.length; i++)
  {
    sprites[i].update();
    sprites[i].draw(this.g);

    // if we hit the sprite with the mouse, knock it around and start animating
    if (sprites[i].pointInside(mouseX, mouseY))
    {
      sprites[i].rotationSpeed = PI/10f;
      sprites[i].accelerate((new Vec2D(mouseX-pmouseX, mouseY-pmouseY)).limit(speedLimit));
      sprites[i].start(); // start animating
    }

    // if the sprite hit a boundary on the sides, bounce it off (e.g. collide it)
    for (int b=0; b < boundaries.length; b++)
    {
      if (sprites[i].intersects(boundaries[b]))
        Collider.collide(sprites[i], boundaries[b]);
    }
  }
}

