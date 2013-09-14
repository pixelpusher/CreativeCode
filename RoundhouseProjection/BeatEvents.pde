RandomConfigFileChangeEvent configFileChangeEvent, 
                            secondConfigFileChangeEvent, 
                            laterConfigFileChangeEvent;

class FilenameProbability
{
  String name;
  float  prob;

  FilenameProbability(String s, float p)
  {
    name = s;
    prob = p;
  }
}


class RandomConfigFileChangeEvent implements IBeatEvent
{
  private ArrayList<FilenameProbability> configFileNames;
  private float totalProbability; // prob of all files

  RandomConfigFileChangeEvent()
  {
    configFileNames = new ArrayList<FilenameProbability>();
    totalProbability = 0f;
  }

  // should be like "data/config5.xml"
  RandomConfigFileChangeEvent add(String f, float p)
  {
    configFileNames.add(new FilenameProbability(f, p));
    totalProbability += p;
    return this;
  }
  RandomConfigFileChangeEvent clear()
  {
    configFileNames.clear();
    totalProbability = 0f;
    return this;
  }

  public void trigger() 
  { 
    String newFileName = null;
    float r = random(0, totalProbability);
    float currentProb=0f;

    //println("CONFIG CHANGE CHECK");

    for ( FilenameProbability f : configFileNames)
    {
      currentProb += f.prob;
      //println("r:" + r + " currentp " + currentProb);
      if (currentProb > r)
      {
        //println(f.name);
        if (!(CONFIG_FILE_NAME.equals( f.name )) )
        {
          CONFIG_FILE_NAME = f.name;        
          readConfigXML();
        }
        break;
      }
    }
  }
}
