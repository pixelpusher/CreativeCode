ImageParticleSwarm newSwarm(GLTexture tex, TriangleMesh mesh, int id)
{
  if (swarms[id] != null) swarms[id].destroy();

  swarms[id] = new ImageParticleSwarm(this, tex);
  
  swarms[id].makeModel( mesh );
  
  // clear tri mesh
  mesh.clear();

  return swarms[id];
}



void handJerked()
{
  Vec3D pos=new Vec3D(leftHandPos.x-width/4, leftHandPos.y-height/4, leftHandPos.z);

  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);

  Vec3D a=pos.add(0, 0, weight);
  Vec3D b=pos.add(0, 0, -weight);

  // store current points for next iteration
  prev = pos;
  p.set(pos);
  q.set(pos);

  //println("JERKED");

  //handPositions.add(pos);
}


void handMoved()
{
  // get 3D rotated mouse position
  Vec3D pos=new Vec3D(leftHandPos.x-width/4, leftHandPos.y-height/4, leftHandPos.z);
  //pos.scaleSelf(1.5);
  /*
    text("new pos:" + pos,20,30);
   
   pushMatrix();
   translate(pos.x+width/4,pos.y+height/4);
   image(fireballTex, 0,0, 32, 32);
   popMatrix();
   */
  pos.rotateX(rotation.x);
  pos.rotateY(rotation.y);


  // use distance to previous point as target stroke weight
  weight+=(sqrt(pos.distanceTo(prev))*2-weight)*0.1;
  // define offset points for the triangle strip

  //  println("weight " + weight + " / " + MIN_DIST );

  if (weight > MIN_DIST)
  {
    //  handPositions.add(pos);

    Vec3D a=pos.add(0, 0, weight);
    Vec3D b=pos.add(0, 0, -weight);

    // add 2 faces to the mesh
    triMesh.addFace(p, b, q);
    triMesh.addFace(p, a, b);
    // store current points for next iteration
    prev=pos;
    p=a;
    q=b;

    //prev.set(pos);
  }

  /*
  if (triMesh.getNumVertices() > 600)
   {
   newSwarm();
   }
   */
}




void drawMesh(GLGraphicsOffScreen buffer) {

  buffer.noStroke();
  //buffer.pushMatrix();
  //buffer.scale(1,1,5);
  buffer.fill(255, 180, 20, 80);
  buffer.beginShape(TRIANGLES);
  // iterate over all faces/triangles of the mesh
  for (Iterator i=triMesh.faces.iterator(); i.hasNext();) {
    Face f=(Face)i.next();
    // create vertices for each corner point
    buffer.vertex(f.a.x, f.a.y, f.a.z);
    buffer.vertex(f.b.x, f.b.y, f.b.z);
    buffer.vertex(f.c.x, f.c.y, f.c.z);
  }
  buffer.endShape();
  //buffer.popMatrix();
}



void drawMeshUniqueVerts(GLGraphicsOffScreen buffer) {
  //    noStroke();
  buffer.stroke(255, 80);
  buffer.strokeWeight(6);

  buffer.beginShape(POINTS);
  // get unique vertices, use with indices
  float[] triVerts = triMesh.getUniqueVerticesAsArray(); 
  for (int i=0; i < triVerts.length; i += 3)
  { 
    /*   pushMatrix(); 
     translate(triVerts[i], triVerts[i+1], triVerts[i+2]);
     image(tex,0,0,32,32);
     popMatrix();
     */
    buffer.vertex(triVerts[i], triVerts[i+1], triVerts[i+2]);
  }
  buffer.endShape();
}

/*
void drawHandPositions()
 {
 
 for (Vec3D v : handPositions)
 {
 pushMatrix();
 translate(v.x,v.y,v.z);
 image(fireballTex, 0,0, 32, 32);
 popMatrix();
 }
 } 
 */
