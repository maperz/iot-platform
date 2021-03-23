#include <Arduino.h>
#include "motor.h"
#include "connectivity.h"
#include "logger.h"
#include "secrets.h"

void setup()
{
  Serial.begin(115200);
  printf("\n\n");
  initMotor();
}

bool forward = true;

void loop()
{
  if (!Connectivity::isWifiConnected())
  {
    Connectivity::setupLocalWifi(network_ssid, network_pw);
  }

  if (!Connectivity::mqtt.connected())
  {
    Connectivity::setupMqtt("10.0.0.111");
  }

  Connectivity::mqtt.loop();
  motorLoop();
}