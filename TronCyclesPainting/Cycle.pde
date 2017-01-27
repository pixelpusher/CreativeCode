//
// light cycle
//

class Cycle 
{
  // max number of PVectors in the path


  int x, y;
  int skip = 1;
  color c, deadColor, overlayColor;
  boolean alive;

  private ArrayList<PVector> path;
  private int ox, oy, dir, handedness;
  private int lifetime=0; // max number of ticks this 'lives' for
  private int currentTime=0; // current 'tick'

  private PShape pathShape;

  Cycle(int _x, int _y, int _lifetime) {
    init(_x, _y, _lifetime);
  }

  //
  // reset or re-init the Cycle
  //
  Cycle init(int _x, int _y, int _lifetime) {
    ox = x = _x;
    oy = y = _y;

    setLifetime(_lifetime);

    dir = millis()%4;
    c = color(255);
    deadColor = color(255, 100, 255);
    overlayColor = color(255, 255, 180);
    handedness = (random(1.0)>0.5) ? 1 : 3;
    alive = true;

    // set all points to original location
    for (PVector point : path)
    {
      point.set(ox, oy);
    }
    //skip = int(random(1,3));

    return this;
  }

  //
  // set how many ticks (or points) this Cycle 'lives' for
  //
  Cycle setLifetime(int i)
  {
    i = max(i, 1); // less than 1 is dumb
    lifetime = i;
    currentTime = 0; // reset elapsed time count

    path = null; // force garbage collection...
    path = new ArrayList<PVector>(lifetime);

    while (path.size() <lifetime)
    {
      path.add(new PVector(ox, oy));
    }

    // Now make the PShape with those vertices
    pathShape = createShape();
    pathShape.beginShape();
    pathShape.noFill();
    pathShape.stroke(255);
    pathShape.strokeWeight(2);

    for (PVector v : path) 
    {
      pathShape.vertex(v.x, v.y);
    }
    pathShape.endShape();

    return this;
  }


  void move(Grid g) 
  {
    currentTime++;
    if (currentTime >= lifetime) alive = false;
    else 
    {

      // only reason we check dir+2 is when just-reborn
      //  and thus just assigned a new random direction
      // otherwise we know it's blocked by our own trail
      int [] checkorder = { 
        (dir+handedness)%4, dir, (dir+handedness*3)%4, (dir+2)%4
      };

      int newx=x, newy=y, newd=dir;
      for (int i=0; i<4; i++) {
        newd = checkorder[i];
        newx = x + dxs[newd]/skip;
        newy = y + dys[newd]/skip;
        if (g.get(newx, newy))
          break;
      }

      // move or die
      if (g.get(newx, newy))
      {
        if ((x!=newx) || (y!=newy)) 
        {
          ox = x;
          oy = y;
          x = newx;
          y = newy;
          dir = newd;
          // update grid
          g.set(newx, newy, Grid.SOLID);
          // update path
          path.get(currentTime).set(newx, newy);
          pathShape.setVertex(currentTime, newx, newy);
        }
      } else alive = false;
    }// end within lifetime
  }// end move


  void draw() 
  {
    shape(pathShape);
  }

  void drawOverlay(int rez) 
  {
    //color newc = srcImg.pixels[srcImg.width*(y*grid.rez+grid.rez/2)+x*grid.rez+grid.rez/2];

    //color newc = srcImg.get(x*grid.rez+grid.rez/2, y*grid.rez+grid.rez/2);
    //c = blendC(c, newc, mixingRatio);
    //c = blendColor(c, newc, imgMode); 

    stroke(overlayColor);
    line(ox*rez+rez/2, oy*rez+rez/2, 
      x*rez+rez/2, y*rez+rez/2);
  }
}