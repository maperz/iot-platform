#include "motor.h"
#include "logger.h"
#include <Arduino.h>

uint8 dirForwardPin = D2;
uint8 dirBackwardPin = D3;
uint8 motorSpeedPin = D1;

double maxPWM = 1023;

void initMotor() {
  printLog(LogLevel::Info, "Setting up motor ");
  pinMode(dirForwardPin, OUTPUT);
  pinMode(dirBackwardPin, OUTPUT);
  pinMode(motorSpeedPin, OUTPUT);
  printLog(LogLevel::Info, "[DONE]\n");
}

int _speed = 0;
Direction _direction = Direction::Forward;

void driveMotor(double speed, Direction direction) {
  speed = max(0.0, min(1.0, speed));

  printLog(LogLevel::Debug, "Drive motor, Speed: %5.1f%%, Direction: %s\n",
      speed * 100, direction == Direction::Forward ? "FWD" : "BWD");

  _speed = speed * maxPWM;
  _direction = direction;
}

void motorLoop() {
  analogWrite(motorSpeedPin, _speed);
  digitalWrite(dirForwardPin, _direction == Direction::Forward ? HIGH : LOW);
  digitalWrite(dirBackwardPin, _direction == Direction::Backward ? HIGH : LOW);
}