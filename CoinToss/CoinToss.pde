int tosses = 10;

int results[];

void flipCoins()
{
  results = new int[tosses+1]; // count 0 too
  int sameTossCount = 0;
  
  int lastFlip = -1; 
  
  for (int i=0; i < tosses; i++)
  {
    int flip = floor( random(0,2) ); // 0 or 1
    
    println("toss["+i+"]=" + flip);
    
    if (lastFlip == flip) sameTossCount++;
    else
    {
      results[sameTossCount] += 1;
      sameTossCount = 0;
    } 
      
    println("same toss count: " + sameTossCount);   
    lastFlip = flip;
    
    
  }  
  
  for (int i=0; i < results.length; i++)
  {
    println(""+i+" "+ results[i]);
  }
  redraw();
}


void setup()
{
  size(800,400);
  flipCoins();
}


void draw()
{
  background(0);
  
  
  int xticks = width/results.length;
  int yticks = height/results.length;
  
  rectMode(CORNERS);
  
  for (int i=0; i < results.length; i++)
  {
    stroke(180);
    line(0, i*yticks, width, i*yticks);
    stroke(120);
    line(i*xticks, 0, i*xticks, height);
  
    fill(255);
    noStroke();
    int x = i*xticks;
    int y = results[i] * yticks;

    //ellipse(x,height,10,10);
    //ellipse(x+xticks,y,10,10);
    
    rect(x,height, x+xticks,height-y); 
  }
  noLoop();
}


void keyPressed()
{
  flipCoins();
}