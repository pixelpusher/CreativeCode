/**
 * GoogleImageSearch
 * by Evan Raskob
 *
 * How to do get Facebook public stats using JSON.
 * You will need the JSON jar to use this.  Either make your own
 * by getting the code from http://www.json.org/java/ or
 * use our jar'ed version (put into a subfolder called "code"
 * in your sketch's folder):
 *
 * Copyright 2010 Evan Raskob
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **/


import java.net.URLEncoder;
import java.net.URLDecoder;
import org.json.JSONArray;      // JSON library from http://www.json.org/java/
import org.json.JSONObject;

//
// THIS IS THE URL OF THE FACEBOOK SOCIAL GRAPH (THEIR PAGE?)
//
private final String SEARCH_URL = "https://graph.facebook.com/LilWayne";


// the time between page checks 
// **DON'T MAKE THIS VERY SMALL! SHOULD BE GREATER THAN 10 SECONDS AT THE VERY LEAST**
int timeBetweenChecks = 2 * 60 * 1000; // 2 mins = 2 * (60 seconds in a minute, 1000 ms in a second)

int lastTimeChecked = -timeBetweenChecks;  // last time we checked - initially, we force it to check by making this negative

int likes;  // we store the number of likes for future use


//
// SETUP
//
void setup()
{
  // size of the sketch window, in pixels
  size(784, 256);
}

//
// DRAW
//
void draw()
{
  int currentTime = millis();
  int timeDiff = currentTime-lastTimeChecked; 

  if (timeDiff > timeBetweenChecks)
  {
    println("Checking for likes...");
    lastTimeChecked = millis();  // current time
    likes = getLikes();
    println("LIL Wayne has " + likes + " likes");
  }
}


//
// This contacts the facebook web page and get the number of likes as a JSON object
// 

int getLikes()
{
  int likes = 0;  

  try
  {
    JSONObject json = new JSONObject(join(loadStrings(SEARCH_URL), "\n"));
    println("GOT");
    println(json+"");

    // store it as a number 
    String likesStr = json.getString("likes");
    likes = int(trim(likesStr));
  }
  catch (Exception e) {
    println("Something went wrong...");
    e.printStackTrace();
  }

  return likes;
}

