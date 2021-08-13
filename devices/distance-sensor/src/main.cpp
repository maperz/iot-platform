#include <Arduino.h>

#include <molecule.h>

#include "dm-controller.h"

void setup() {
  Serial.begin(115200);
  auto controller = new DistanceMeasureController();
  mlq::init(controller);
}

void loop() { mlq::update(); }