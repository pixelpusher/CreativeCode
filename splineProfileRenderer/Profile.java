import toxi.geom.LineStrip2D;
import toxi.geom.Vec2D;
import java.util.List;


public interface Profile {
  
  public String getName();
  
  public LineStrip2D calcPoints(double x, double z);
  public List<Vec2D> getControlPoints(); // mainly for spline
  
}
  
