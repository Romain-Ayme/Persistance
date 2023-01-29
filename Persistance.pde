import processing.sound.*;

SoundFile soundfile;

PGraphics imgDraw;
PGraphics[] drawings;

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

void setup() {
  isDrawingTime = true;
  strokeColor = color(255, 0, 0);
  strokeWeight = 5;
  
  size(800, 600);
  //fullScreen();
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
}

void draw() {
  if (isDrawingTime) {
    if (mousePressed) {
      
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

    }
  }

  if (!isDrawingTime) {
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
  }
}
