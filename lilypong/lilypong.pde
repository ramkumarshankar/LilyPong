//Our images
PImage imgBackground;
PImage imgBall;
PImage imgPaddle;

//Our fonts
PFont titleFont;
PFont subtitleFont;

//Font colours
color titleColor = color(255, 255, 255, 240);
color subtitleColor = color(255, 255, 255, 204);
color scoreColor = color(255, 255, 255, 153);

//Variables for the game
boolean bGameStarted = false;

void setup() {
  //Work with a retina display
  pixelDensity(2);
  
  //Setup the size
  size(750, 468);
  
  //Load the images we need
  imgBackground = loadImage("../assets/canvas.png");
  imgBall = loadImage("../assets/ball.png");
  imgPaddle = loadImage("../assets/paddle.png");
  titleFont = createFont("../assets/Liberator-Heavy.otf", 144);
  subtitleFont = createFont("../assets/Sansita-Regular.otf", 32);
}

void draw() {
  image(imgBackground, 0, 0);
  if (!bGameStarted) {
    drawTitleScreen();
  }
  else {
    drawGameScreen();
  }
}

void drawTitleScreen () {
  image(imgBall, 161, 90);
  textFont(titleFont);
  fill(titleColor);
  text("LILYPONG", 100, 253);
  textFont(subtitleFont);
  fill(subtitleColor);
  text("Jump to Start!", 278, 328);
}

void drawGameScreen() {
  stroke(255);
  noFill();
  line(width/2, 0, width/2, height);
  ellipse(width/2, height/2, 100, 100);
  image(imgPaddle, -20, 100);
  image(imgPaddle, width-45, 300);
  drawBall();
  drawScore();
}

void drawBall() {
  image(imgBall, 200, 300);
}

void drawScore() {
  textFont(titleFont);
  fill(scoreColor);
  text("5", 142, 120);
  text("3", 527, 120);
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    bGameStarted = true;
  }
  if (key == 'q' || key == 'Q') {
    bGameStarted = false;
  }
}

class Ball {
  
}