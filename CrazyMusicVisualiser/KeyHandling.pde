//
// Keyboard handling functions (for ease of finding)
//


void keyPressed()
{
}


int shapeIndex = 0;

void keyReleased()
{
  if (key ==' ') tapTempo();
  else
  if (key == 's' || key =='S' && currentShape != null)
  {
    currentShape.syncVertsToSource();
  }
  else if (key == 't' || key =='T' && currentShape != null)
  {
    currentShape.syncVertsToDest();
  }
  else if (key=='a' || (key=='A'))
  {
    //addNewShape(loadImageIfNecessary("7sac9xt9.bmp"));
    String name = "default";

    shapeIndex = ++shapeIndex % 3;

    if (  shapeIndex == 0)
      name = DynamicWhitney.NAME;
    else if (  shapeIndex == 1)
      name = DynamicWhitneyTwo.NAME;
    else if (  shapeIndex == 2)
      name = PsychedelicWhitney.NAME;

    addNewShape(sourceDynamic.get( name ) );

    currentShape.srcColor = color(random(0, 255), random(0, 255), random(0, 255), 180);
    //    currentShape.srcColor = color(255,255);
    currentShape.dstColor = currentShape.srcColor;
    currentShape.blendMode = BLEND;
  }
  else if (key=='D')
  {
    //addNewShape(loadImageIfNecessary("7sac9xt9.bmp"));
    addNewShape(sourceDynamic.get( PsychedelicWhitney.NAME ) );
    currentShape.srcColor = color(255, 160);
    //    currentShape.srcColor = color(random(0, 255), random(0, 255), random(0, 255), 180);
    currentShape.dstColor = currentShape.srcColor;
    currentShape.blendMode = ADD;
  }

  else if (key == '<')
  {
    // back up 1

    if (currentShape == null)
    {
      // may as well use the 1st
      currentShape = shapes.getFirst();
    }
    else
    {
      ListIterator<ProjectedShape> iter = shapes.listIterator();
      ProjectedShape prev = shapes.getLast();
      ProjectedShape nxt = prev;

      while (iter.hasNext () && currentShape != (nxt = iter.next()) )
      {
        prev = nxt;
      }
      currentShape = prev;
    }
  }

  else if (key == '>')
  {
    // back up 1

    if (currentShape == null)
    {
      // may as well use the 1st
      currentShape = shapes.getFirst();
    }
    else
    {
      ListIterator<ProjectedShape> iter = shapes.listIterator();
      ProjectedShape nxt = shapes.getLast();

      while (iter.hasNext () && currentShape != (nxt = iter.next()) );

      if ( iter.hasNext() )
        currentShape = iter.next();
      else
        currentShape = shapes.getFirst();
    }
  }
  else if (key == 'l' && currentShape != null)
  {
    // deep copy current selected shape
    ProjectedShape newShape = new ProjectedShape(currentShape);
    currentShape = newShape;

    currentShape.srcColor = color(random(0, 255), random(0, 255), random(0, 255), 180);
    currentShape.dstColor = currentShape.srcColor;
    shapes.add(currentShape);
  }
  else if (key == '/')
  {
    showFPS = false;
    //rendering = !rendering;
    //if (rendering) renderedFrames = 0;
    sequencing = !sequencing;
  }

  else if (key == '.')
  {
    showFPS = !showFPS;

    // advance 1 image
    /*
    if (currentShape != null)
     {
     Set<String> keys = sourceImages.keySet();
     
     ListIterator<String> iter = keys.listIterator();
     String prev = shapes.getLast();
     
     while (iter.hasNext () && currentShape != (nxt = iter.next()) );
     
     if ( iter.hasNext() )
     currentShape = iter.next();
     else
     currentShape = shapes.getFirst();
     }
     */
  }
  else if (key == 'i' && currentShape != null)
  {
    currentShape.clearVerts();
    currentShape.addVert(0, 0, 0, 0);
    currentShape.addVert(currentShape.srcImage.width, 0, currentShape.srcImage.width, 0);
    currentShape.addVert(currentShape.srcImage.width, currentShape.srcImage.height, currentShape.srcImage.width, currentShape.srcImage.height);
    currentShape.addVert(0, currentShape.srcImage.height, 0, currentShape.srcImage.height);
  }
  else if (key == 'I' && currentShape != null)
  {
    currentShape.clearVerts();
    currentShape.addVert(0, 0, 0, 0);
    currentShape.addVert(currentShape.srcImage.width, 0, mappedView.width, 0);
    currentShape.addVert(currentShape.srcImage.width, currentShape.srcImage.height, mappedView.width, mappedView.height);
    currentShape.addVert(0, currentShape.srcImage.height, 0, mappedView.height);
  }

  else if (key == 'x' && currentShape != null)
  {
    deleteShape = true;
  }
  else if (key == 'd' && currentVert != null)
  {
    currentShape.removeVert(currentVert);
    currentVert = null;
  }
  else if (key == 'v') 
  {
    currentShape.clearVerts();
    currentVert = null;
  }

  //  else if (key == 'i') 
  //  {
  //    drawImage = !drawImage;
  //  }  
  else if (key == 'm') 
  {
    ++displayMode;
    if (displayMode > SHOW_IMAGES)
      displayMode = SHOW_SOURCE;
  }
  else if (key == '[') 
  {
    cursor();
  }
  else if (key == ']') 
  {
    noCursor();
  }
  else if (key == ';')
  {
    Iterator<String> imgNamesIter = sourceImages.keySet().iterator();
    boolean looping = true;

    while (looping && imgNamesIter.hasNext ())
    {
      String imgName = imgNamesIter.next();
      PImage img = sourceImages.get(imgName);
      if (currentShape.srcImage == img)
      {
        //println("found it!");
        if (imgNamesIter.hasNext())
        {
          String nextImg = imgNamesIter.next();
          println("next image:" + nextImg);
          currentShape.srcImage = sourceImages.get( nextImg  );
        }
        else
        {
          // use first
          currentShape.srcImage = sourceImages.get( sourceImages.keySet().iterator().next() );
        }
        looping = false;
      }
    }
  }
  else if (key == '`')
  {
    createConfigXML();
    writeMainConfigXML();
  }
  else if (key == '~')
  {
    
    println("Chosing a file for saving:");
    noLoop();
    saveXMLFile();
    loop();
  
  /*
    println("Chosing a file");
    noLoop();
    CONFIG_FILE_NAME = selectOutput("Choose a file name for the XML configuration:");
    println("Chose: " + CONFIG_FILE_NAME);
    createConfigXML();
    writeMainConfigXML();
    loop();
    */
  }
  else if (key == '!')
  {
    readConfigXML();
  }
  else if (key == '@')
  {
    loadXMLFile();
  }
}

