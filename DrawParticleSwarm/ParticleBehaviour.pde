interface ParticleBehaviour
{
  void setParameters(HashMap<String,Object> params) throws ParticleBehaviourParamsException;
  void updateVertex(float[] v);
  void updateColour(float[] c);
  void calcLifeFactor(int currentLife, int maxLife);
}


class ParticleBehaviourParamsException extends Exception
{
  ParticleBehaviourParamsException()
  {
    super("ParticleBehaviour missing required parameter");
  }
  
  ParticleBehaviourParamsException(String message)
  {
    super("ParticleBehaviourParamsException: " + message);
  }
}


//
// Particle Expander!
//


class ParticleExpander implements ParticleBehaviour
{
  float mExpansion = 0.03f;
  int mMaxLife = 2000;
  private float mLifeFactor = 1.0f;
  
  
  // default
  ParticleExpander() 
  { }
  
  // with params list
  ParticleExpander(HashMap<String,Object> params) throws ParticleBehaviourParamsException
  {
    setParameters(params);
  }
  
  void setParameters(HashMap<String,Object> params) throws ParticleBehaviourParamsException
  {
    Iterator i = params.entrySet().iterator();  // Get an iterator

    while (i.hasNext()) 
    {
      Map.Entry me = (Map.Entry)i.next();
      if ( me.getKey().equals("expansion") )
      {
          mExpansion = ( (Float)(me.getValue()) ).floatValue();
      }
      else if ( me.getKey().equals("maxLife") )
      {
        mExpansion = ( (Integer)(me.getValue()) ).intValue();
      }
      else
        throw new ParticleBehaviourParamsException("Extra value:" + me.getKey());
    }
  }
  
  
  //
  // pre-calc current life factor - more efficient than doing it for every vertex!
  //
  void calcLifeFactor(int currentLife, int maxLife)
  {
    mLifeFactor = 1.0f - constrain(currentLife/float(mMaxLife), 0.0f, 1.0f);
  }
  
  //
  // update vertex
  //
  void updateVertex(float[] v)
  {
    v[0] += v[0]*mExpansion;
    v[1] += v[1]*mExpansion;
    v[2] += v[2]*mExpansion;    
  }
  
  //
  // update vertex color
  //
  void updateColour(float[] c)
  {
    // only deal with alpha
    c[3] = mLifeFactor;
  }
  
// end class ParticleExpander  
}



