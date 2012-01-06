String[] getFilesWithExtension(final String ext)
{

  // we'll have a look in the data folder
  java.io.File folder = new java.io.File(dataPath(""));

  // let's set a filter (which returns true if file's extension is .jpg)
  java.io.FilenameFilter jpgFilter = new java.io.FilenameFilter() {
    public boolean accept(File dir, String name) {
      return name.toLowerCase().endsWith(ext);
    }
  };

  // list the files in the data folder, passing the filter as parameter
  String[] filenames = folder.list(jpgFilter);

  if (filenames != null)
  {
    // get and display the number of jpg files
    println(filenames.length + " ." + ext + " files in specified directory");

    // display the filenames
    for (int i = 0; i < filenames.length; i++) {
      println(filenames[i]);
    }
  }
  return filenames;
}


void refreshPresetFilesList(int guiX, int guiY)
{
  savedFiles = getFilesWithExtension("ser");
  if (savedFiles != null)
  {
    if (filesList != null) filesList.clear();
    else
      filesList = gui.addDropdownList("savedFileNames", guiX, guiY, 100, 120);

    filesList.setItemHeight(20);
    filesList.setBarHeight(15);
    filesList.captionLabel().set("preset files");
    filesList.captionLabel().style().marginTop = 3;
    filesList.captionLabel().style().marginLeft = 3;
    filesList.valueLabel().style().marginTop = 3;

    int i=0;

    for (String item : savedFiles)
    {
      filesList.addItem(item, i++);
    }
  }
}





void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("GROUP::" + theEvent.getGroup().getValue()+" from "+theEvent.getGroup());

    if (theEvent.getGroup().name().equals("savedFileNames"))
    {
      String loadFileName = savedFiles[int(theEvent.getGroup().getValue())];
      println("selected file: " + loadFileName);
      gui.getProperties().load("data/" + loadFileName);
    }
  } 
  else if (theEvent.isController()) {
    println(theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}

