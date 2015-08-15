
PShape meshToRetained(Mesh3D mesh, boolean smth) {        
  PShape retained = createShape();
  
  retained.beginShape(TRIANGLES);
  retained.enableStyle();
  mesh.computeFaceNormals();
  
  if (smth) 
  {  
    mesh.computeVertexNormals();

    for (Face f : mesh.getFaces ()) {
      retained.normal(f.a.normal.x, f.a.normal.y, f.a.normal.z);
      retained.vertex(f.a.x, f.a.y, f.a.z);
      retained.normal(f.b.normal.x, f.b.normal.y, f.b.normal.z);
      retained.vertex(f.b.x, f.b.y, f.b.z);
      retained.normal(f.c.normal.x, f.c.normal.y, f.c.normal.z);
      retained.vertex(f.c.x, f.c.y, f.c.z);
    }
  } else {
    int i=0;
    for (Face f : mesh.getFaces ()) {
      // println("triangles"+ i++);
      retained.normal(f.normal.x, f.normal.y, f.normal.z);
      retained.vertex(f.a.x, f.a.y, f.a.z);
      retained.vertex(f.b.x, f.b.y, f.b.z);
      retained.vertex(f.c.x, f.c.y, f.c.z);
    }
  }
  retained.endShape();
  return retained;
}




PShape pathsToShape( ArrayList<LineStrip3D> paths)
{
  PShape retained = createShape();

  retained.enableStyle();
  retained.beginShape(LINES);
  //retained.fill(120,120,0,80);
  retained.noFill();
  retained.stroke(255, 180);
  retained.strokeWeight(2);


  for (LineStrip3D path : paths)
  {
    Iterator<Vec3D> iter = path.iterator();
    Vec3D currentP = iter.next();
    Vec3D nextP = currentP;

    while (iter.hasNext ()) 
    {
      nextP = iter.next();
      retained.vertex(currentP.x(), currentP.y(), currentP.z());
      retained.vertex(nextP.x(), nextP.y(), nextP.z());
      currentP = nextP;
    }
  }

  retained.endShape();
  return retained;
}

