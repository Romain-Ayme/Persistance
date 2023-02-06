import processing.sound.*;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
int port = 12000;

SoundFile soundfile;

PGraphics imgDraw;

PImage img;
PGraphics imgShow;

boolean isDrawingTime;

long startShowTime;
long startFadeTime;

color strokeColor;
int strokeWeight;

PrintWriter output;
int nb = 0;

String configFile = "nb.txt";

String word = "Draw me";
boolean isWord = true;

void setup() {
  
  oscP5 = new OscP5(this, port);
  
  cursor(CROSS);
  
  isDrawingTime = true;
  strokeColor = color(251, 240, 0);
  strokeWeight = 5;
  
  size(800, 600);
  imgDraw = createGraphics(width, height);
  imgShow = createGraphics(width, height);
  background(0);
  
  imgDraw.beginDraw(); 
  imgDraw.stroke(strokeColor);
  imgDraw.strokeWeight(strokeWeight);
  imgDraw.fill(255);
  imgDraw.endDraw();

  soundfile = new SoundFile(this, "sounds/pierre.aiff");
 
  try {
    String[] lines = loadStrings(configFile);
    nb = int(lines[0]);
  } catch (Exception e) {
    nb = 0;
  }

  textSize(32);
  textAlign(CENTER, CENTER);
  textLeading(-10);
  
}

void draw() {
  if (isDrawingTime) {

    if (mousePressed) {
      
      if (!isWord) {
        background(0);
      }

      imgDraw.beginDraw();
      imgDraw.line(mouseX, mouseY, pmouseX, pmouseY);
      imgDraw.endDraw();
  
      image(imgDraw, 0, 0);

      if (!soundfile.isPlaying()) {
        soundfile.loop();
      }

    } 
    
    if (!mousePressed) {

      if (soundfile.isPlaying()) {
        soundfile.pause();
      }

      if (isWord) {
        background(0);
        for (int i = 0; i < word.length(); i++) {
          int x = width / 2 - (word.length() / 2) *20 +i * 20;
          if (frameCount < (i+1)*8) {
            text(floor(random(10)), x, height / 2);
          } else {
            text(word.charAt(i), x, height /2);
            if (i == word.length() - 1 ) {
              isWord = false;
            }
          }
        }
      }

    }
  }

  if (!isDrawingTime) {

    isWord = true;

    if (millis() - startShowTime > 5000) {
      
      imgDraw.clear();
      imgShow.clear();
      background(0);
      
      isDrawingTime = true;
    }
  }
}

void keyPressed() {
  if (isDrawingTime) {
    switch (key) {
      case 'c' :
        isDrawingTime = false;

        imgDraw.save("img/img" + ++nb + ".png");

        imgDraw.clear();
        background(0);

        output = createWriter(configFile);
        output.println(nb);
        output.flush();
        output.close();

        for (int i = 1; i <= nb; i++) {
          img = loadImage("img/img" + i + ".png");
          imgShow.beginDraw();
          imgShow.background(255, 255, 255, 0); // fond transparent
          imgShow.image(img, 0, 0);
          imgShow.endDraw();
          image(imgShow, 0, 0);
        }
        startShowTime = millis();   
      break;

      case ESC :
        println("Close program");
        exit();
      break;

      default :
      break;	
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/Persistance_color")) {
    print("### received an osc message.");
    int strokeColorR = theOscMessage.get(0).intValue();
    int strokeColorG = theOscMessage.get(1).intValue();
    int strokeColorB = theOscMessage.get(2).intValue();
    
    println("color("+strokeColorR+", "+strokeColorG+", "+strokeColorB+")");
    
    strokeColor = color(strokeColorR, strokeColorG, strokeColorB);
          
    imgDraw.beginDraw();
    imgDraw.stroke(strokeColor);
    imgDraw.endDraw();
  }
}
