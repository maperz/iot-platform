#include <Arduino.h>
#include <molecule.h>

#include "lamp-controller.h"

void setup() {
  Serial.begin(115200);
  mlq::init(new LampController());
}

void loop() {
  mlq::update();
}