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

//Initialise the players
Player[] players = new Player[2];

//Variables for the game
boolean bGameStarted = false;
int radius = 25; //radius of the ball
int movementStep = 117; //distance moved by paddle in each step

void setup() {
  //Work with a retina display
  //Commented for now, slows down the sketch on this laptop
  //pixelDensity(2);
  
  //Setup the size
  size(750, 468);
  
  //Load the images we need
  imgBackground = loadImage("../assets/canvas.png");
  imgBall = loadImage("../assets/ball.png");
  imgPaddle = loadImage("../assets/paddle.png");
  
  //Load our fonts
  titleFont = createFont("../assets/Liberator-Heavy.otf", 144);
  subtitleFont = createFont("../assets/Sansita-Regular.otf", 32);
  
  //Create our players
  players[0] = new Player(-20, 1);
  players[1] = new Player(width-45, 0);
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
  drawPlayers();
  //image(imgPaddle, -20, 100);
  //image(imgPaddle, width-45, 300);
  drawScore(); //<>//
  checkPlayerCollision();
  drawBall();
}

void startGame() {
  ball.initialise();
}

void drawPlayers() {
  players[0].update();
  players[1].update();
  imageMode(CORNER);
  players[0].draw();
  players[1].draw();
}

void drawBall() {
  ball.update();
  ball.draw();
}

void resetGame() {
  ball.reset();
}

void drawScore() {
  updateScore();
  textFont(titleFont);
  fill(scoreColor);
  text(players[0].score, 142, 120);
  text(players[1].score, 527, 120);
}

void updateScore() {
  if (ball.result >= 0) {
    if (ball.result == 0) {
      players[1].score++;
    }
    else if (ball.result == 1) {
      players[0].score++;
    }
    ball.reset();
  }
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
  if (key == 'z' || key == 'Z') {
    players[0].setStep(3);
    //resetGame();
  }
}

void checkPlayerCollision() {
  //Check with player on the left
  if (ball.position.x < 2*radius) {
    if ((ball.position.y > players[0].yPos) && (ball.position.y < players[0].yPos+movementStep)) {
        ball.velocity.x = ball.velocity.x * -1;
    }
  }
  
  //Check with player on the right
  if (ball.position.x > width-2*radius) {
    if ((ball.position.y > players[1].yPos) && (ball.position.y < players[1].yPos+movementStep)) {
        ball.velocity.x = ball.velocity.x * -1;
    }
  }
  
}

class Ball { 
  PVector position;
  PVector velocity;
  //float easing = 0.05;
  int result;
  
  Ball () {  
    position = new PVector(width/2, height/2);  //<>//
    velocity = new PVector(0, 0);
    result = -1;
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
    checkOutofBounds();
  }
  
  void draw() {
    imageMode(CENTER);
    image(imgBall, position.x, position.y); //<>//
  }
  
  void checkOutofBounds() {
    if (position.x < 0) {
      result = 0;
    }
    else if (position.x > width) {
      result = 1;
    }
  }
  
  void reset() {
    position = new PVector(width/2, height/2);
    velocity.x = 0;
    velocity.y = 0;
    result = -1;
  }
}

class Player {
  int xPos;
  int yPos;
  int newYPos;
  float easing = 0.05;
  int currentStep;
  int score;
  
  Player(int _xPos, int _step) {
    currentStep = _step;
    xPos = _xPos;
    yPos = currentStep * movementStep;
    newYPos = yPos;
    score = 0;
  }
  
  void setStep(int _step) {
    currentStep = _step;
    updateTargetPosition();
  }
  
  void updateTargetPosition () {
    newYPos = currentStep * movementStep;
  }
  
  void update() {
    float dy = newYPos - yPos;
    if (dy < 1) {
      yPos = newYPos;
    }
    yPos += easing * dy;
  }
  
  void draw() {
    imageMode(CORNER);
    image(imgPaddle, xPos, yPos);
  }
  
}