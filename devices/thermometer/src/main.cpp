#include <Arduino.h>

#include <molecule.h>

#include "thermo-controller.h"

void setup() {
  Serial.begin(115200);
  printLog(LogLevel::Info, "Setting up!");
  auto controller = new ThermoController();
  mlq::init(controller);
}

void loop() { mlq::update(); }