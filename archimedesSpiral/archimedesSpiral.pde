import processing.pdf.*;


// make an archimedes (logarhythmic) spiral
/* 
  "Divide the circumference into a number of equal parts, 
  drawing the radii and numbering the points. Divide the radius 
  No. 1 into the same number of equal parts, numbering from the center. 
  With C as center draw concentric arcs intersecting the radii of 
  corresponding numbers, and draw a smooth curve through these 
  intersections." —French, 1911
*/


final int numRings = 8;

void setup() 
{
  size(1280,720, PDF);
}


void draw() 
{
  noLoop();
  background(255);
  
  // center everything to make the maths easier
  pushMatrix();
  translate(width/2, height/2);
  
  // 10% padding
  int maxRingRadius = int(height/2*0.9);  
  
  point(0,0);
  
  ellipseMode(RADIUS); // center and radius
  
  for (int i=0; i <= numRings; i++)
  {
     stroke(0);
     strokeWeight(1.5);
     float ringRadius = maxRingRadius * float(i)/numRings;
     ellipse(0,0, ringRadius, ringRadius);
     
     line (0,0, maxRingRadius*cos( TWO_PI * float(i)/numRings), 
       maxRingRadius*sin( TWO_PI * float(i)/numRings));
  }

  popMatrix();  
}