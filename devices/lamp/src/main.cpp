#include <Arduino.h>

#include <molecule.h>

#include "lamp-controller.h"

void setup() {
  Serial.begin(115200);
  printLog(LogLevel::Info, "Setting up!");
  auto controller = new LampController();
  mlq::init(controller);
}

void loop() { mlq::update(); }