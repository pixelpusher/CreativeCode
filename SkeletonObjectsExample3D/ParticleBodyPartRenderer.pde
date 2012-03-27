/////////////////////////////////////
//
// PARTICLES RENDERER 
//
//

float boneMinDist = 80*80;
float boneDistFactor = 0.1f;
float particleMassAttractFactor = 0.2f;


//import toxi.geom.Vec2D;

public class JointLine
{
  final PVector p0, p1;

  JointLine(final PVector _p0, final PVector _p1)
  {
    p0 = _p0;
    p1 = _p1;
  }
} 


public class ParticleBodyPartRenderer implements BodyPartRenderer
{
  private PGraphics renderer;
  private Skeleton mSkeleton;

  ArrayList<Particle> particles = new ArrayList<Particle>();
  float D;             // base diameter of all particles
  float mass = 0.2f;    // universal mass of all particles
  float DIST = 80*80;  // min distance for forces to act on
  float MIN_DIST = 30; // min dist between mouse positions for adding new particles
  boolean drawLines = true;  // draw lines btw particles?
  int MAX_PARTICLES = 200;

  private ArrayList<PVector> allJointPositions;
  private ArrayList<JointLine> allJointLines;


  public ParticleBodyPartRenderer(PGraphics g)
  {
    renderer = g;

    D = min(renderer.width, renderer.height) / 25;  // base diameter of particles on screen size.  change this for bigger/smaller particles
    DIST = 16f*pow(D, 2);     // distance between particles.  Smaller = more detail in final image
    MIN_DIST = D/2f;              // see above

    allJointPositions = new ArrayList<PVector>();
    allJointLines = new ArrayList<JointLine>();

    mSkeleton = null;
  }

  public void setRenderer(PGraphics g)
  {
    renderer = g;
  }

  public void setSkeleton(Skeleton s)
  {
    mSkeleton = s;
  }   

  public void render()
  {
    render(mSkeleton);
  }


  /*
   * render a full skeleton, part-by-part
   */
  void render(Skeleton skeleton)
  {
    if (skeleton != null)
    {
      allJointPositions.clear();
      allJointLines.clear();

      renderer.hint(DISABLE_DEPTH_TEST);
      if (skeleton.calibrated)  // first check if there is anything to draw!
      {
        fill(255);
        // these draw based on percentages (so they scale to the body parts)
        for (BodyPart bodyPart : skeleton.mBodyParts)
        {
          render( bodyPart );

          if (bodyPart.getType() == bodyPart.RIGHT_ARM_LOWER)
          {
            PVector prev = bodyPart.getPrevJoint(SimpleOpenNI.SKEL_RIGHT_HAND);
            PVector current = bodyPart.getJoint(SimpleOpenNI.SKEL_RIGHT_HAND);

            createNewParticle(current, prev);
          }
          else if (bodyPart.getType() == bodyPart.LEFT_ARM_LOWER)
          {
            PVector prev = bodyPart.getPrevJoint(SimpleOpenNI.SKEL_LEFT_HAND);
            PVector current = bodyPart.getJoint(SimpleOpenNI.SKEL_LEFT_HAND);

            createNewParticle(current, prev);
          }
        }

        // optional - keep track of "dead" particles, to remove later
        ArrayList<Particle> deadParticles = new ArrayList<Particle>();

        renderer.noStroke();

        // go through the particles and update their position data
        for (Particle p : particles)
        {
          p.update();

          if (p.alive)
          {
            //color c = bgImage.pixels[((int)p.pos.y)*bgImage.width + (int)p.pos.x];

            //color c = getColorFromPosition(p.pos); 
            color c = color(255);

            p.draw(c);
          }
          else
            deadParticles.add(p);
        }

        // not using this yet... but could...
        for (Particle p : deadParticles)
        {
          particles.remove(p);
          p = null;
        }

        // handle inter-particle forces
        repulseParticles(allJointPositions);
      }

      renderer.hint(ENABLE_DEPTH_TEST);
    }
  }


  /*
   * render a single body part
   */
  void render(BodyPart bodyPart)
  {
    renderer.pushMatrix();
    renderer.translate(bodyPart.getScreenOffsetX(), bodyPart.getScreenOffsetY(), bodyPart.getScreenOffsetZ());

    if (bodyPart instanceof OnePointBodyPart)
    {
      PImage tex = bodyPart.getTexture();
      OnePointBodyPart obp = (OnePointBodyPart)bodyPart;

      allJointPositions.add(obp.screenPoint1);
      allJointLines.add(new JointLine(obp.screenPoint1, obp.screenPoint1));

      renderer.pushMatrix();
      renderer.translate(obp.screenPoint1.x, obp.screenPoint1.y, obp.screenPoint1.z);  

      float w = renderer.width*(obp.getLeftPadding()+obp.getRightPadding());
      float h = renderer.height*(obp.getTopPadding()+obp.getBottomPadding());

      if (obp.depthDisabled)
      {
        hint(DISABLE_DEPTH_TEST);
      }

      if (tex != null)
      {
        renderer.imageMode(CENTER);    
        renderer.image(tex, 0, 0, w, h);
      }
      else
      {
        fill(255);
        renderer.rectMode(CENTER);    
        renderer.rect(0, 0, w, h);
      }
      if (obp.depthDisabled)
      {
        hint(ENABLE_DEPTH_TEST);
      }
      renderer.popMatrix();
    }
    else if (bodyPart instanceof TwoPointBodyPart)
    {      
      TwoPointBodyPart tbp = (TwoPointBodyPart)bodyPart;
      renderer.pushMatrix();
      renderer.translate(tbp.screenPoint1.x, tbp.screenPoint1.y, tbp.screenPoint1.z);
      renderer.ellipse(0, 0, renderer.width/30, renderer.width/30);
      renderer.popMatrix();

      allJointPositions.add(tbp.screenPoint1);

      renderer.pushMatrix();
      renderer.translate(tbp.screenPoint2.x, tbp.screenPoint2.y, tbp.screenPoint2.z);
      renderer.ellipse(0, 0, renderer.width/30, renderer.width/30);
      renderer.popMatrix();

      allJointPositions.add(tbp.screenPoint2);
      allJointLines.add(new JointLine(tbp.screenPoint1, tbp.screenPoint2));

      //      renderRectFromVectors(tbp.screenPoint1, tbp.screenPoint2, tbp.getLeftPadding(), tbp.getRightPadding(), 
      //      tbp.getTopPadding(), tbp.getBottomPadding(), tbp.getTexture(), tbp.getReversed() );
    }
    else if (bodyPart instanceof FourPointBodyPart)
    {
      FourPointBodyPart fbp = (FourPointBodyPart)bodyPart;

      //      renderRectFromVectors(fbp.screenPoint1, fbp.screenPoint2, fbp.screenPoint3, fbp.screenPoint4, 
      //      fbp.getLeftPadding(), fbp.getRightPadding(), fbp.getTopPadding(), fbp.getBottomPadding(), 
      //      fbp.getTexture(), fbp.getReversed() );

      allJointLines.add(new JointLine(fbp.screenPoint1, fbp.screenPoint2));
      allJointLines.add(new JointLine(fbp.screenPoint2, fbp.screenPoint3));
      allJointLines.add(new JointLine(fbp.screenPoint3, fbp.screenPoint4));
      allJointLines.add(new JointLine(fbp.screenPoint4, fbp.screenPoint1));
    }

    renderer.popMatrix();
  }


  void createNewParticle(PVector prev, PVector current)
  {
    PVector diff = PVector.sub(current, prev);
    // add a new particle if the mouse is pressed
    if (diff.mag() > MIN_DIST)
    {
      Particle p = new Particle(current.x, current.y, D);
      //    p.v.x = 0.01*(pmouseX-mouseX);
      //    p.v.y = 0.01*(pmouseY-mouseY);

      // set max velocity based on screen size
      p.MAXV.x = renderer.width/200.0;
      p.MAXV.y = renderer.height/200.0;

      particles.add(p);

      if (particles.size() > MAX_PARTICLES)
      {
        particles.remove(0);
      }
    }
  }


  void repulseParticles(ArrayList<PVector> jointPositions) 
  {
    renderer.beginShape(LINES);

    for (int i=0; i<particles.size(); ++i)
    {
      Particle p0 = particles.get(i);

      /*
      for (PVector jointPos : jointPositions)
       {
       float distSquared = pow(p0.pos.x-jointPos.x, 2) + pow(p0.pos.y-jointPos.y, 2);
       float m = constrain((p0.d + D), 0.4f, 1.6f);
       Vec2D dir = p0.pos.sub(jointPos.x, jointPos.y);
       float F = min(0.02, 1.0f/distSquared) / m;
       
       dir.scaleSelf( F );
       p0.a.addSelf(dir);
       }
       */

      for (JointLine jointLine : allJointLines)
      {
        PVector closestPoint = closestPointToLine(jointLine.p0, jointLine.p1, new PVector(p0.pos.x, p0.pos.y));

        float distSquared = pow(p0.pos.x-closestPoint.x, 2) + pow(p0.pos.y-closestPoint.y, 2);

        if (distSquared < boneMinDist)
        {

          float m = constrain((p0.d)*particleMassAttractFactor, 0.1f, 1f);
          Vec2D dir = p0.pos.sub(closestPoint.x, closestPoint.y);

          float F = min(EPSILON, 1.0f/(distSquared*boneDistFactor)) / m;

          dir.scaleSelf( -F );
          p0.a.addSelf(dir);
        }
        renderer.stroke(p0.c & 0x66FFFFFF);                                      
        renderer.vertex(jointLine.p0.x, jointLine.p0.y);
        renderer.vertex(jointLine.p1.x, jointLine.p1.y);
      }


      for (int ii=i+1; ii<particles.size(); ++ii ) {

        Particle p1 = particles.get(ii);

        Vec2D dir = p0.pos.sub(p1.pos);

        float distSquared = dir.magSquared();

        if ( distSquared > 0.0f && distSquared <= DIST)
        {
          dir.normalize();

          float m = constrain((p0.d + p1.d)/D, 0.1f, 1f);

          float F = min(0.3, 16.0f/distSquared) / m;

          dir.scaleSelf( F );

          if (drawLines)
          {
            //stroke(255,80);
            //stroke(0,200,0);
            renderer.stroke(p0.c & 0x66FFFFFF);                                      
            //line(p0.pos.x, p0.pos.y, p1.pos.x, p1.pos.y);

            renderer.vertex(p0.pos.x, p0.pos.y);
            renderer.stroke(p1.c & 0x66FFFFFF);
            renderer.vertex(p1.pos.x, p1.pos.y);
          }
          p0.a.addSelf(dir);
          p1.a.subSelf(dir);
        }
      }
    }
    renderer.endShape();
  }




  // a simple Particle class with acceleration and velocity

  class Particle
  {
    Vec2D MAXV = new Vec2D(2, 2);  // max velocity this particle can have (absolute)

    Vec2D pos;  // position  
    Vec2D v;    // instantaneous velocity
    Vec2D a;    // instantaneous acceleration
    float d;    // diameter
    color c;    // color
    boolean alive = false; 
    int life = 355;

    Particle(float _x, float _y, float _d)
    {
      pos = new Vec2D(_x, _y);
      v = new Vec2D();
      a = new Vec2D();
      d = _d;
      alive = true;
    }


    void draw(color _c)
    {
      c = _c;
      renderer.fill(255, life);
      //d = lerp(d, (0.5*brightness(c)/255.0 + 0.1), 0.5);
      float realD = life/255f*D; 
      renderer.ellipse(pos.x, pos.y, realD, realD);
    }

    void update()
    {
      life--;
      if (life < 0)
        alive = false;
      else
      {

        if (v.x > MAXV.x)
          v.x = MAXV.x;

        if (v.x < -MAXV.x)
          v.x = -MAXV.x;

        if (v.y > MAXV.y)
          v.y = MAXV.y;

        if (v.y < -MAXV.y)
          v.y = -MAXV.y;

        pos.addSelf(v);
        v.scaleSelf(0.95);
        v.x += a.x;
        v.y += a.y;
        a.scaleSelf(0.5);

        //    if (pos.x >= width || pos.x <= 0 ||
        //        pos.y >= height || pos.y <= 0)

        if (pos.x >= renderer.width || pos.x <= 0)
        {
          alive = false;
          pos.x = constrain(pos.x, 0, renderer.width-1);
          v.x = -v.x;
          a.x = 0;
        }
        if (pos.y >= renderer.height || pos.y <= 0)
        {
          alive = false;
          pos.y = constrain(pos.y, 0, renderer.height-1);
          v.y = -v.y;
          a.y = 0;
        }
      }
    }
  }

  // Finds the closest PVector (point) to PVECtor p on a line given by l0 and l1

  PVector closestPointToLine(PVector l0, PVector l1, PVector p)
  {
    PVector direction = PVector.sub(l1, l0);
    PVector w = PVector.sub(p, l0);
    float proj = w.dot(direction);

    if (proj <= 0)
      return l0;
    else
    {
      float vsq = direction.dot(direction);
      if (proj >= vsq)
        return PVector.add(l0, direction);
      else
        return PVector.add(l0, PVector.mult(direction, proj/vsq));
    }
  }

  // end particles renderer
}

