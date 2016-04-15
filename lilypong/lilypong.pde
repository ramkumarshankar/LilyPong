import cc.arduino.*;
import org.firmata.*;
import processing.serial.*;

//Initialise our lilypad
Arduino arduino;

//String from Lilypad
String controlString;

//Readings from the lilypad
//Pin values
int vibePin = 5;
int player1LeftPin = 0;
int player1RightPin = 1;
int player2LeftPin = 2;
int player2RightPin = 3;

int redPin = 9;
int greenPin = 10;
int bluePin = 11;


//Player controls
int player1Left;
int player1LeftAvg;
int player1Right;
int player1RightAvg;
int player2Left;
int player2LeftAvg;
int player2Right;
int player2RightAvg;

//Flags to detect change in controls
boolean bAllowPlayer1 = true;
boolean bAllowPlayer2 = true;

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
boolean bGameOver = false;
int radius = 25; //radius of the ball
int movementStep = 117; //distance moved by paddle in each step

void setup() {
  //Work with a retina display
  //Commented for now, slows down the sketch on this laptop
  //pixelDensity(2);
  
  //Initialise our Arduino
  //There are problems with Firmata running at baud 115200 on the Lilypad
  //We've changed the bluetooth module to use 57600 instead! (Thanks Susana!)
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  delay(500);
  
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
  players[0] = new Player(-20, 2);
  players[1] = new Player(width-45, 0);
  
  //Calibrate the sensors
  calibrate();
  
  //Setup pin modes
  arduino.pinMode(redPin, Arduino.OUTPUT);
  arduino.pinMode(greenPin, Arduino.OUTPUT);
  arduino.pinMode(bluePin, Arduino.OUTPUT);
  
  arduino.pinMode(vibePin, Arduino.OUTPUT); 
  
  initialiseLightPattern();
}

void draw() {
  imageMode(CORNER);
  image(imgBackground, 0, 0);
  readFromArduino();
  if (!bGameStarted && !bGameOver) {
    drawTitleScreen();
  }
  else if (bGameOver) {
    drawGameOverScreen();
  }
  else {
    readFromArduino();
    updateGame();
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
  text("First to 7 points wins!", 238, 328);
  text("Jump to Start!", 278, 368);
}

void drawGameOverScreen () {
  textFont(titleFont);
  fill(titleColor);
  text("Good Game!", 30, 253);
  textFont(subtitleFont);
  fill(subtitleColor);
  text("Jump to play again!", 278, 328);
}


//Use this with Firmata
void readFromArduino() {
  player1Left = arduino.analogRead(player1LeftPin);
  player1Right = arduino.analogRead(player1RightPin);
  player2Left = arduino.analogRead(player2LeftPin);
  player2Right = arduino.analogRead(player2RightPin);
  
  if ((player1Left < player1LeftAvg) || 
        (player1Right < player1RightAvg) ||
        (player2Left < player2LeftAvg) ||
        (player2Right < player2RightAvg)) {
     if (!bGameStarted) {
       startGame();
       bAllowPlayer1 = false;
       bAllowPlayer2 = false;
       //Delay for a bit to get readings back to normal
       delay(100);
       return;
     }
     else if (ball.isStationary()) {
       ball.initialise();
       bAllowPlayer1 = false;
       bAllowPlayer2 = false;
       return;
     }
     else {
       checkPlayer1Input();
       checkPlayer2Input();
     }
     
  }
  
}

void checkPlayer1Input() {
  
  if (player1Left <= player1LeftAvg) {
    if (bAllowPlayer1) {
      players[0].setStep(-1);
      bAllowPlayer1 = false;
    }
    return;
  }
  if (player1Right <= player1RightAvg) {
    if (bAllowPlayer1) {
      players[0].setStep(1);
      bAllowPlayer1 = false;
    }
    return;
  }
  bAllowPlayer1 = true;
}

void checkPlayer2Input() {
  
  if (player2Left <= player2LeftAvg) {
    if (bAllowPlayer2) {
      players[1].setStep(-1);
      bAllowPlayer2 = false;
    }
    return;
  }
  if (player2Left <= player2RightAvg) {
    if (bAllowPlayer2) {
      players[1].setStep(-1);
      bAllowPlayer2 = false;
    }
    return;
  }
  bAllowPlayer2 = true;
}

void updateGame() {
  //Update player positions
  players[0].update();
  players[1].update();
  
  //Update scores
  updateScore();
  
  //Check if ball hits the paddles
  checkPlayerCollision();
  
  //Update the ball position
  ball.update();
  
}

void drawGameScreen() {
  stroke(255);
  noFill();
  line(width/2, 0, width/2, height);
  ellipse(width/2, height/2, 100, 100);
  drawPlayers();
  drawScore();
  
  //Draw the ball
  ball.draw();
  
  //Show a message before starting next round
  if (ball.isStationary()) {
    textFont(subtitleFont);
    fill(subtitleColor);
    text("Get Ready", 305, 328);
    text("Jump to start!", 288, 368);
  }
}

void startGame() {
  bGameStarted = true;
  bGameOver = false;
}

void drawPlayers() {
  players[0].draw();
  players[1].draw();
}

void resetGame() {
  ball.reset();
  players[0].resetPlayer();
  players[1].resetPlayer();
}

void drawScore() {
  textFont(titleFont);
  fill(scoreColor);
  text(players[0].score, 142, 120);
  text(players[1].score, 527, 120);
}

void updateScore() {
  if (ball.result >= 0) {
    if (ball.result == 0) {
      players[1].score++;
      scoreVibration();
      player2Goal();
    }
    else if (ball.result == 1) {
      players[0].score++;
      scoreVibration();
      player1Goal();
    }
    ball.reset();
  }
  
  //Check for gameover condition
  for (int i = 0; i < players.length; i++) {
    if (players[i].checkGameOver()) {
      bGameOver = true;
      bGameStarted = false;
      resetGame();
    }
  }
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    startGame();
  }
  if (key == 'q' || key == 'Q') {
    bGameStarted = false;
    bGameOver = false;
    resetGame();
  }
  
  //Keyboard controls for development, change to lilypad input later on
  //Player 0
  //Move left
  if (key == 'z' || key == 'Z') {
    players[0].setStep(-1);
  }
  //Move right
  if (key == 'x' || key == 'X') {
    players[0].setStep(1);
  }
  //Player 0
  //Move left
  if (key == 'h' || key == 'H') {
    players[1].setStep(-1);
  }
  //Move right
  if (key == 'j' || key == 'J') {
    players[1].setStep(1);
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
 
void calibrate() {
  //Get some initial readings and average it out to know when flex sensor is pressed
  player1LeftAvg = 0;
  player1RightAvg = 0;
  player2LeftAvg = 0;
  player2RightAvg = 0;
  for (int i = 0; i < 10; i++) {
    player1LeftAvg += arduino.analogRead(player1LeftPin);
    player1RightAvg += arduino.analogRead(player1RightPin);
    player2LeftAvg += arduino.analogRead(player2LeftPin);
    player2RightAvg += arduino.analogRead(player2RightPin);
    delay(50);
  }
  player1LeftAvg /= 10;
  player1LeftAvg -= 100;
  player1RightAvg /= 10;
  player1RightAvg -= 100;
  player2LeftAvg /= 10;
  player2LeftAvg -= 100;
  player2RightAvg /= 10;
  player2RightAvg -= 100;
}

void initialiseLightPattern() {
  lightRGB(0, 255, 0);
  delay(200);
  lightRGB(0, 0, 0);
  delay(200);
  lightRGB(0, 255, 0);
  delay(200);
  lightRGB(0, 0, 0);
  delay(200);
  lightRGB(0, 255, 0);
}

void player1Goal() {
  lightRGB(252, 57, 144);
  delay(200);
  lightRGB(0, 0, 0);
  delay(200);
  lightRGB(252, 57, 144);
  delay(200);
  lightRGB(0, 0, 0);
  delay(200);
  lightRGB(252, 57, 144);
  delay(200);
  lightRGB(0, 255, 0);
}

void player2Goal() {
  lightRGB(57, 142, 252);
  delay(200);
  lightRGB(0, 0, 0);
  delay(200);
  lightRGB(57, 142, 252);
  delay(200);
  lightRGB(0, 0, 0);
  delay(200);
  lightRGB(57, 142, 252);
  delay(200);
  lightRGB(0, 255, 0);
}

void scoreVibration() {
  arduino.analogWrite(vibePin, 255);
  delay(1000);
  arduino.analogWrite(vibePin, 0);
}

//Function to control LED with Firmata
//Pass R, G, and B color values
void lightRGB(int red, int green, int blue) {
  arduino.analogWrite(redPin, 255-red);
  arduino.analogWrite(greenPin, 255-green);
  arduino.analogWrite(bluePin, 255-blue);
}

class Ball { 
  PVector position;
  PVector velocity;
  //float easing = 0.05;
  int result;
  
  Ball () {  
    position = new PVector(width/2, height/2); 
    velocity = new PVector(0, 0);
    result = -1;
  }
  
  void initialise() {
    position.x = width/2;
    position.y = height/2;
    if (random(0,1) > 0.5) {
      velocity.x = 4;
    }
    else {
      velocity.x = -4;
    }
    if (random(0,1) > 0.5) {
      velocity.y = int (random(1,4));
    }
    else {
      velocity.y = int (random(-4,-1));
    }
  }
  
  void update() {
    position.add(velocity);
    if ((position.y > height-radius) || (position.y < radius)) {
      velocity.y = velocity.y * -1;
    }
    checkOutofBounds();
  }
  
  void draw() {
    imageMode(CENTER);
    image(imgBall, position.x, position.y);
  }
  
  void checkOutofBounds() {
    if (position.x < 0-radius) {
      result = 0;
    }
    else if (position.x > width+radius) {
      result = 1;
    }
  }
  
  void reset() {
    position = new PVector(width/2, height/2);
    velocity.x = 0;
    velocity.y = 0;
    result = -1;
  }
  
  boolean isStationary() {
    if ((velocity.x == 0) && (velocity.y == 0)) {
      return true;
    }
    return false;
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
    if (_step < 0) {
      currentStep--;
    }
    else {
      currentStep++;
    }
    if (currentStep < 0) {
      currentStep = 0;
    }
    else if (currentStep > 3) {
      currentStep = 3;
    }
    updateTargetPosition();
  }
  
  void updateTargetPosition () {
    newYPos = currentStep * movementStep;
  }
  
  void update() {
    float dy = newYPos - yPos;
    if (abs(dy) < 1) {
      yPos = newYPos;
    }
    yPos += easing * dy;
  }
  
  boolean checkGameOver() {
    if (score == 7) {
      return true;
    }
    return false;
  }
  
  void resetPlayer() {
    score = 0;
  }
  
  void draw() {
    imageMode(CORNER);
    image(imgPaddle, xPos, yPos);
  }
  
}