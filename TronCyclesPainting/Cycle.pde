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
  private int maxLife=0; // max number of ticks this 'lives' for
  private int currentLife=0; // current 'tick'

  private PShape pathShape;

  Cycle(int _x, int _y, int _maxLife) {
    init(_x, _y, _maxLife);
  }

  //
  // reset or re-init the Cycle
  //
  Cycle init(int _x, int _y, int _maxLife) {
    ox = x = _x;
    oy = y = _y;

    setmaxLife(_maxLife);

    dir = millis()%4;
    c = color(255);
    deadColor = color(180, 100, 180);
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
  Cycle setmaxLife(int i)
  {
    i = max(i, 1); // less than 1 is dumb
    maxLife = i;
    currentLife = 0; // reset elapsed time count

    path = null; // force garbage collection...
    path = new ArrayList<PVector>(maxLife);

    while (path.size() <maxLife)
    {
      path.add(new PVector(ox, oy));
    }

    // Now make the PShape with those vertices
    pathShape = createShape();
    pathShape.beginShape();
    pathShape.noFill();
    pathShape.stroke(255);
    pathShape.strokeWeight(4);

    for (PVector v : path) 
    {
      pathShape.vertex(v.x, v.y);
    }
    pathShape.endShape();

    return this;
  }

  void freeGrid(Grid g)
  {
    for (PVector v : path) 
    {
      grid.set((int)v.x, (int)v.y, Grid.CLEAR);
    }
  }


  void move(Grid g) 
  {
    currentLife++;
    if (currentLife < maxLife) 
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
          path.get(currentLife).set(newx, newy);
          
          for (int i=currentLife; i>0; i--)
          {
            PVector v = pathShape.getVertex(maxLife-i);
            pathShape.setVertex(maxLife-i-1,v);
          }
          pathShape.setVertex(maxLife-1, newx, newy);
          
          
        }
      } else 
      {
        alive = false;
        pathShape.setStroke(deadColor);
      }
    }
    else {
      alive = false;
        pathShape.setStroke(deadColor); // huh? got to rethink this
    }
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