/*
* This example loads an OpenStreetMap data file of Greenwich, London
* and only draws the nodes (areas submitted by users) with "useful" tags
*
* by Evan Raskob : evan@FLKR.com
* Code licensed GNU Affero 3.0+ (AGPL 3.0+)
* Data licensed CC-BY-ATTRIBUTION SHARE ALIKE by http://OpenStreetMap.org
*
*/


// root xml node for config data
XML osmXML;


final String[] IgnoredTags = { 
  "created", "user", "junk"
};

String OSMXmlFileName = "data/map.osm";

float MinLongitude, MaxLongitude, MinLatitude, MaxLatitude;

ArrayList<OSMNode> OSMNodes;



class OSMNode
{
  int id;
  float latitude, longitude;
  String user;
  String timestamp;
  HashMap<String, String> tagData;

  OSMNode()
  {
    tagData = new HashMap<String, String>();
  }
  
  String toString()
  {
    String s =  "[id:" + id + ", lat:" + latitude + ", lon:" + longitude + ", user:" + user + "\n[";
    for (String k : tagData.keySet())
    {
      s += "[" + k + ":" + tagData.get(k) + "]";
    }
    return s;
  }
}





void setup()
{
  size(800, 600);
  smooth();
  OSMNodes = new ArrayList<OSMNode>();

  readOSMXML(OSMXmlFileName);
  
  background(0);
  
  for (OSMNode node : OSMNodes)
  {
    if (node.tagData.size() > 0)
    {
      
      float x = map(node.longitude, MinLongitude, MaxLongitude, 0, width);
       float y = map(node.latitude, MinLatitude, MaxLatitude, 0, height);
      //println("x:"+x+", "+"y:" + y);
      stroke(255,100);
      ellipse(x,y,4,4);
    }
  }
  
  
  noLoop();
} 



//
// Read OSM XML file, create data structure from it
//

boolean readOSMXML(String filename)
{
  println("READING XML CONFIG FROM: " + filename);

  BufferedReader reader = null;

  reader = createReader(filename);

  // open XML file  
  //osmXML = new XML (this, CONFIG_FILE_NAME);

  if (reader != null)
  {

    OSMNodes.clear();

    osmXML = new XML (reader);

    XML boundsNodes[] = osmXML.getChildren("bounds");

    println("XML: Found " + boundsNodes.length + " bounds nodes");


    //
    // HANDLE bounds
    //   
    for (int i=0; i < boundsNodes.length; ++i)
    {
      XML node = boundsNodes[i];

      MinLongitude = node.getFloat("minlon");
      MaxLongitude = node.getFloat("maxlon");
      MinLatitude = node.getFloat("minlat");
      MaxLatitude = node.getFloat("maxlat");
      
      println("MinLon:" + MinLongitude +", " + "MaxLon:" + MaxLongitude); 
    }

    // now go through all nodes!!

    XML nodes[] = osmXML.getChildren("node");

    println("XML: Found " + nodes.length + " nodes");

    for (int i=0; i < nodes.length; ++i)
    {
      XML node = nodes[i];

      OSMNode osmnode = new OSMNode();
      osmnode.id = node.getInt("id");
      osmnode.latitude = node.getFloat("lat");
      osmnode.longitude = node.getFloat("lon");
      osmnode.user = node.getString("user");

      // load verts
      XML nodeTags[] = node.getChildren("tag");
      for (int ii=0; ii < nodeTags.length; ++ii)
      {
        String tagKey = nodeTags[ii].getString("k");

        // assume it's ignored unless otherwise proven
        boolean ignored = false;

        // test for ignored tags - not very efficient
        for (String ignoredTag : IgnoredTags)
        {
          if ( tagKey.toLowerCase().contains(ignoredTag) )
          {
            ignored = true;
            break;
          }
        }

        if (!ignored)
        {
          String v = nodeTags[ii].getString("v");
          //println("tag::putting: " + tagKey + ":" + v);
          osmnode.tagData.put(tagKey, v);
        }
        // done with tags
      }
      
      // DEBUG
      // ONLY PRINT IF THERE'S A TAG
      //if (osmnode.tagData.size() > 0)
      //  println(osmnode);
      
      OSMNodes.add(osmnode);
      
      // done with nodes
    }
    
  // done with file exists test  
  }
  else
  {
    println("FAILED OPENING CONFIG FILE! Bad name?? Check it:" + filename);
  }

  return (reader != null);
}

