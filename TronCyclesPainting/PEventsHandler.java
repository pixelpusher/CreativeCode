import processing.core.*;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


// this is shitty, needs better thinking thru

public class PEventsHandler {
  PApplet parent;

  public PEventsHandler(PApplet parent) {
    this.parent = parent;
    parent.registerMethod("dispose", this);
  }

  public void dispose() {
    Method stopRecordingMethod = null;
    
    // Anything in here will be called automatically when 
    // the parent sketch shuts down. 
    try {
      stopRecordingMethod =
        parent.getClass().getMethod("stopRecording",
                                    null);
    } catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
      e.printStackTrace();
    }
    if (stopRecordingMethod != null)
    try {
      stopRecordingMethod.invoke(parent, null);
    } catch (Exception e) {
      // no such method, or an error.. which is fine, just ignore
      e.printStackTrace();
    }
  }
}