
//
// BASE INTERFACE
//

import processing.core.PGraphics;

public interface BodyPartRenderer
{
  // public PGraphics renderer;
  // public BodyPartRenderer(PGraphics g);

  /*
   * set the internal renderer for drawing things
   */
  public void setRenderer(PGraphics g);
  
  /*
   * set this to render specific skeleton - sets the internal render target to Skeleton s
   */
  public void setSkeleton(Skeleton s);

  /*
   * render the current internal render target (Skeleton or otherwise)
   */
  public void render();

  /*
   * render a full skeleton, part-by-part
   */
  public void render(Skeleton skeleton);
  /*
   * render a single body part
   */
  public void render(BodyPart bodyPart);
}
