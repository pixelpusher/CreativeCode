//
// Swarm of images!!! 
//

class ImageParticleSwarm
{
  //
  // public class vars
  //

  int mLifeTime = 2000; // lifetime of this system in ms
  int mCreationTime;
  boolean mAlive;


  //
  // private class vars
  //
  private GLModel glmodel = null;
  PApplet parent;
  private GLTexture tex = null;




  void setTexture(GLTexture _tex)
  {
    tex = _tex;
    if (glmodel != null) glmodel.setTexture(0, tex);
  }

  ImageParticleSwarm(PApplet _parent, GLTexture _tex)
  {
    parent = _parent;
    setTexture(_tex);
    mCreationTime = millis();
    mAlive = true;
  }


  // 
  // make a GL model from a Vec3D ArrayList
  // 

  boolean makeModel(ArrayList<Vec3D> triVerts)
  {
    boolean success = false;

    if (glmodel != null)
    { 
      glmodel.delete();
      glmodel = null;
    }

    if (triVerts != null && triVerts.size() > 0)
    {
      success = true;

      int numV=triVerts.size();     

      glmodel = new GLModel(parent, numV, GLModel.POINT_SPRITES, GLModel.DYNAMIC);

      glmodel.beginUpdateVertices();
      for (int i = 0; i < numV; i++) 
      {
        Vec3D v = triVerts.get(i);
        
        glmodel.updateVertex(i, v.x, v.y, v.z);
      }
      glmodel.endUpdateVertices(); 

      //
      // Handle colors
      //

      glmodel.initColors();
      glmodel.beginUpdateColors();

      FloatBuffer cbuf = glmodel.colors;

      float col[] = { 
        0, 0, 0, 0
      };

      for (int n = 0; n < glmodel.getSize(); ++n) {

        // get colors (debugging purposes)
        cbuf.position(4 * n);
        cbuf.get(col, 0, 4);  
        //println("Color["+n+"]="+ col[0] +","+col[1] +","+col[2] +","+col[3]);

        // process col... make opaque white for testing
        col[0] = col[1] = col[2] = col[3] = 1.0f;
        cbuf.position(4 * n);
        cbuf.put(col, 0, 4);
      }

      cbuf.rewind();
      glmodel.endUpdateColors();

      //float pmax = glmodel.getMaxSpriteSize();
      //println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   

      glmodel.initTextures(1);
      glmodel.setTexture(0, tex);  

      // Setting the maximum sprite to the 90% of the maximum point size.
      //    model.setMaxSpriteSize(0.9 * pmax);
      // Setting the distance attenuation function so that the sprite size
      // is 20 when the distance to the camera is 400.

      glmodel.setSpriteSize(20, 2000);
      glmodel.setBlendMode(BLEND);
    }

    return success;
  }

    
    

  // 
  // make a GL model from a TriangleMesh
  // 

  boolean makeModel(TriangleMesh mesh)
  {

    boolean success = false;

    // get mesh as vertex array with stride 4
    float[] triVerts = mesh.getMeshAsVertexArray(); 

    if (glmodel != null)
    { 
      glmodel.delete();
      glmodel = null;
    }

    if (triVerts != null && triVerts.length > 0)
    {
      success = true;

      int numV=triVerts.length/4;  
      // update lighting information
      mesh.computeVertexNormals();
      float[] norms=mesh.getVertexNormalsAsArray();

      glmodel = new GLModel(parent, numV, GLModel.POINT_SPRITES, GLModel.DYNAMIC);

      glmodel.beginUpdateVertices();
      for (int i = 0; i < numV; i++) glmodel.updateVertex(i, triVerts[4 * i], triVerts[4 * i + 1], triVerts[4 * i + 2]);
      glmodel.endUpdateVertices(); 

      glmodel.initNormals();
      glmodel.beginUpdateNormals();
      for (int i = 0; i < numV; i++) glmodel.updateNormal(i, norms[4 * i], norms[4 * i + 1], norms[4 * i + 2]);
      glmodel.endUpdateNormals();  

      //
      // Handle colors
      //

      glmodel.initColors();
      glmodel.beginUpdateColors();

      FloatBuffer cbuf = glmodel.colors;

      float col[] = { 
        0, 0, 0, 0
      };

      for (int n = 0; n < glmodel.getSize(); ++n) {

        // get colors (debugging purposes)
        cbuf.position(4 * n);
        cbuf.get(col, 0, 4);  
        //println("Color["+n+"]="+ col[0] +","+col[1] +","+col[2] +","+col[3]);

        // process col... make opaque white for testing
        col[0] = col[1] = col[2] = col[3] = 1.0f;
        cbuf.position(4 * n);
        cbuf.put(col, 0, 4);
      }

      cbuf.rewind();
      glmodel.endUpdateColors();


      //float pmax = glmodel.getMaxSpriteSize();
      //println("Maximum sprite size supported by the video card: " + pmax + " pixels.");   

      glmodel.initTextures(1);
      glmodel.setTexture(0, tex);  

      // Setting the maximum sprite to the 90% of the maximum point size.
      //    model.setMaxSpriteSize(0.9 * pmax);
      // Setting the distance attenuation function so that the sprite size
      // is 20 when the distance to the camera is 400.

      glmodel.setSpriteSize(20, 400);
      glmodel.setBlendMode(BLEND);
    }

    return success;
  }


  void update(ParticleBehaviour particleBehaviour, int currentTime )
  {
    if (mAlive)
    {
      int timeDiff = currentTime-mCreationTime;
      if (timeDiff >= mLifeTime)
      {
        mAlive = false;
      }
      else
      {
        particleBehaviour.calcLifeFactor(timeDiff, mLifeTime);

        // now models
        glmodel.beginUpdateVertices();

        FloatBuffer vbuf = glmodel.vertices;

        float vert[] = { 
          0, 0, 0
        };

        for (int n = 0; n < glmodel.getSize(); ++n) {
          vbuf.position(4 * n);
          vbuf.get(vert, 0, 3);

          // process vert...
          particleBehaviour.updateVertex(vert);

          vbuf.position(4 * n);
          vbuf.put(vert, 0, 3);
        }
        vbuf.rewind();

        glmodel.endUpdateVertices();

        glmodel.beginUpdateColors();

        FloatBuffer cbuf = glmodel.colors;

        float col[] = { 
          0, 0, 0, 0
        };

        for (int n = 0; n < glmodel.getSize(); ++n) {

          // get colors (debugging purposes)
          cbuf.position(4 * n);
          cbuf.get(col, 0, 4);  
          //println("Color["+n+"]="+ col[0] +","+col[1] +","+col[2] +","+col[3]);

          particleBehaviour.updateColour(col);

          cbuf.position(4 * n);
          cbuf.put(col, 0, 4);
        }

        cbuf.rewind();
        glmodel.endUpdateColors();
        // end if within lifetime
      }

      //end if alive
    }
  }



  void render()
  {
    if (glmodel != null) glmodel.render();
  }


  void render(GLGraphicsOffScreen renderer)
  {
    renderer.model(glmodel);
  }

  void destroy()
  {
    parent = null;
    if (glmodel != null) glmodel.delete();
    glmodel = null;
  }
}

