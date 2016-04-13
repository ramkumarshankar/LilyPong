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

//Initialise our ball
Ball ball = new Ball();

//Variables for the game
boolean bGameStarted = false;
int radius = 25;

void setup() {
  //Work with a retina display
  //Commented for now, slows down the sketch on this laptop
  //pixelDensity(2);
  
  //Setup the size
  size(750, 468);
  
  //frameRate(30);
  
  //Load the images we need
  imgBackground = loadImage("../assets/canvas.png");
  imgBall = loadImage("../assets/ball.png");
  imgPaddle = loadImage("../assets/paddle.png");
  
  //Load our fonts
  titleFont = createFont("../assets/Liberator-Heavy.otf", 144);
  subtitleFont = createFont("../assets/Sansita-Regular.otf", 32);
}

void draw() {
  imageMode(CORNER);
  image(imgBackground, 0, 0);
  if (!bGameStarted) {
    drawTitleScreen(); //<>//
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
  drawScore(); //<>//
  drawBall();
}

void startGame() {
  ball.initialise();
}

void drawBall() {
  ball.update();
  ball.draw();
}

void resetGame() {
  ball.reset();
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
    startGame();
  }
  if (key == 'q' || key == 'Q') {
    bGameStarted = false;
    resetGame();
  }
}

void checkPlayerCollision() {

}

class Ball { 
  PVector position;
  PVector velocity;
  //float easing = 0.05;
  
  Ball () {  
    position = new PVector(width/2, height/2);  //<>//
    velocity = new PVector(0, 0);
  }
  
  void initialise() {
    position.x = width/2;
    position.y = height/2;
    velocity.x = -2;
    velocity.y = -2;
  }
  
  void update() {
    position.add(velocity);
    if ((position.y > height-radius) || (position.y < radius)) {
      velocity.y = velocity.y * -1; //<>//
    }
  }
  
  void draw() {
    imageMode(CENTER);
    image(imgBall, position.x, position.y); //<>//
  }
  
  void reset() {
    position = new PVector(width/2, height/2);
    velocity.x = 0;
    velocity.y = 0;
  }
}

class Player {
  PVector position;
  PVector targetPosition;
  float easing;
  
}