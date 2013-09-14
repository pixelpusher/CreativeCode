import java.awt.datatransfer.*;
import java.awt.Toolkit;
import javax.swing.JOptionPane;


int SAMPLES = 30000;

final int BUFFER_SIZE = 2048;

float vals[];

void setup()
{

  size(512, 200);

  String file = selectInput("Select audio file to encode.");

  if (file == null) {
    exit();
    return;
  }

  try 
  {
    Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();

    // Open the wav file specified as the first argument
    WavFile wavFile = WavFile.openWavFile(new File(dataPath(file)));

    // Display information about the wav file
    wavFile.display();

    // Get the number of audio channels in the wav file
    int numChannels = wavFile.getNumChannels();

    // Create a buffer of 100 frames
    int[] buffer = new int[BUFFER_SIZE * numChannels];

    int maxFrames = int(wavFile.getNumFrames()/BUFFER_SIZE);

    vals = new float[(int)wavFile.getNumFrames()];

    int framesRead;
    int timesFramesRead = 0;

    float minVal = Float.MAX_VALUE;
    float maxVal = Float.MIN_VALUE;

    boolean reading = true;
    int totalFramesRead = 0;
    int totalreads = 0;
    
    while (reading)
    {
      // Read frames into buffer
      framesRead = wavFile.readFrames(buffer, BUFFER_SIZE);
      println("Read " + framesRead + " frames");
      totalFramesRead += framesRead;

      if ( framesRead > 0)
      {
        float b = 0.0f;

        // Loop through frames and look for minimum and maximum value
        for (int s=0 ; s<framesRead * numChannels ; s+=numChannels)
        {   
          b = (float)buffer[s];

          vals[totalreads] = b;
          totalreads++;
          
          if (buffer[s] > maxVal) maxVal = buffer[s];
          if (buffer[s] < minVal) minVal = buffer[s];

        }
      }
      else
      {
        reading = false;
      }

      timesFramesRead++;
      println("We read " + timesFramesRead + " times");
    }

    println("total reads:" + totalreads);

    // Close the wavFile
    wavFile.close();

    // Output the minimum and maximum value
    System.out.printf("Min: %f, Max: %f\n", minVal, maxVal);


    String result = "";  

    for (int i = 0; i < totalreads; i++) 
    {
      result += int(map(vals[i], minVal, maxVal, 0, 256)) + ", ";
    }

    clipboard.setContents(new StringSelection(result), null);

    JOptionPane.showMessageDialog(null, "Audio data copied to the clipboard.", "Success!", JOptionPane.INFORMATION_MESSAGE);
  } 
  catch (Exception e)
  {
    JOptionPane.showMessageDialog(null, "Maybe you didn't pick a valid audio file?\n" + e, "Error!", JOptionPane.ERROR_MESSAGE);
    System.err.println(e);
  }

  exit();
}

