//Our pins
int buttonPin = 7;
int player1LeftPin = A0;
int player1RightPin = A1;
int player2LeftPin = A2;
int player2RightPin = A3;

//Readings
int player1Left;
int player1LeftAvg;
int player1Right;
int player1RightAvg;
int player2Left;
int player2LeftAvg;
int player2Right;
int player2RightAvg;

//Push button
int switchValue;
int buttonState = HIGH;
long debounceDelay = 50;
boolean bPressed = false;

//Data from the game
int winValue = -1;

//RGB LED
const int redPin = 9;
const int greenPin = 10;
const int bluePin = 11;

//Set if input is allowed
boolean bAllowPlayer1 = true;
boolean bAllowPlayer2 = true;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

  //Initialise our pins
  pinMode(buttonPin, INPUT);
  pinMode(redPin, OUTPUT);
  pinMode(greenPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  
  calibrate();

  initialiseLightPattern();

}

void loop() {
  // put your main code here, to run repeatedly:

  //Read Button
//  readSwitchPin();
//  if (switchValue == LOW) {
//    Serial.println("00");
//  }

  //Read Serial port
  readDataFromGame();

  //Read sensors
  readSensors();

  Serial.println(player1Left);
  Serial.println(player1Right);
//  Serial.println(player2Left);
//  Serial.println(player2Right);
  delay(1000);

  //Check if pressed
  checkValuesPlayer1();
  checkValuesPlayer2();

  delay(50);

}

void calibrate() {
  player1LeftAvg = 0;
  player1RightAvg = 0;
  player2LeftAvg = 0;
  player2RightAvg = 0;

  for (int i = 0; i < 10; i++) {
    player1LeftAvg += analogRead(player1LeftPin);
    player1RightAvg += analogRead(player1RightPin);
    player2LeftAvg += analogRead(player2LeftPin);
    player2RightAvg += analogRead(player2RightPin);
  }
  player1LeftAvg /= 10;
  player1LeftAvg -= 200;
  player1RightAvg /= 10;
  player1RightAvg -= 200;
  player2LeftAvg /= 10;
  player2LeftAvg -= 200;
  player2RightAvg /= 10;
  player2RightAvg -= 200;
}

void readDataFromGame() {
  winValue = -1;
  if (Serial.available()) {
    winValue = Serial.read();
  }
  if (winValue == 1) {
    player2Goal();
    waitForNextRound();
  }
  else if (winValue == 0) {
    player1Goal();
    waitForNextRound();
  }
}

void readSensors() {
  player1Left = analogRead(player1LeftPin);
  player1Right = analogRead(player1RightPin);
  player2Left = analogRead(player2LeftPin);
  player2Right = analogRead(player2RightPin);
}

void checkValuesPlayer1() {
  if (player1Left <= player1LeftAvg) {
    if (bAllowPlayer1) {
      Serial.println("1l");
      bAllowPlayer1 = false;
    }
    return;
  }
  
  if (player1Right <= player1RightAvg) {
    if (bAllowPlayer1) {
      Serial.println("1r");
      bAllowPlayer1 = false;
    }
    return;
  }

  bAllowPlayer1 = true;

}

void checkValuesPlayer2() {
  if (player2Left <= player2LeftAvg) {
    if (bAllowPlayer2) {
      Serial.println("2l");
      bAllowPlayer2 = false;
    }
    return;
  }
  
  if (player2Right <= player2RightAvg) {
    if (bAllowPlayer2) {
      Serial.println("2r");
      bAllowPlayer2 = false;
    }
    return;
  }

  bAllowPlayer2 = true;

}

void waitForNextRound() {
  delay(1000);
  Serial.println("00");
}

//Function to read push button switch
//Uses a debounce delay to avoid detecting multiple presses
//Code adapted from IDEA9101 lab exercises

void readSwitchPin() {

  buttonState = HIGH;

  switchValue = digitalRead(buttonPin);
  if (switchValue != buttonState) {
    delay(debounceDelay);
    switchValue = digitalRead(buttonPin);
    if (switchValue != buttonState) {
      buttonState = switchValue;
    }
  }

}

//Color generating function
//Adapted from http://lilypadarduino.org/?page_id=702

void outputLED (unsigned char red, unsigned char green, unsigned char blue)  //the color generating function
{
  analogWrite(redPin, 255-red);
  analogWrite(greenPin, 255-green);
  analogWrite(bluePin, 255-blue);
}

void initialiseLightPattern() {
  outputLED(0, 255, 0);
  delay(200);
  outputLED(0, 0, 0);
  delay(200);
  outputLED(0, 255, 0);
  delay(200);
  outputLED(0, 0, 0);
  delay(200);
  outputLED(0, 255, 0);
}

void player1Goal() {
  outputLED(252, 57, 144);
  delay(200);
  outputLED(0, 0, 0);
  delay(200);
  outputLED(252, 57, 144);
  delay(200);
  outputLED(0, 0, 0);
  delay(200);
  outputLED(252, 57, 144);
  delay(500);
  outputLED(0, 255, 0);
}

void player2Goal() {
  outputLED(57, 142, 252);
  delay(200);
  outputLED(0, 0, 0);
  delay(200);
  outputLED(57, 142, 252);
  delay(200);
  outputLED(0, 0, 0);
  delay(200);
  outputLED(57, 142, 252);
  delay(500);
  outputLED(0, 255, 0);
}

