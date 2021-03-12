#include <Arduino.h>
#include "motor.h"
#include "connectivity.h"
#include "logger.h"
#include "secrets.h"

void setup()
{
  Serial.begin(115200);
  initMotor();
}

bool forward = true;

void loop()
{
  if (!Connectivity::isWifiConnected())
  {
    Connectivity::setupLocalWifi(network_ssid, network_pw);
  }

  if (!Connectivity::pubSubClient.connected())
  {
    Connectivity::setupPubSub("10.0.0.111");
  }

  Connectivity::pubSubClient.loop();
  motorLoop();

  /*
  Direction dir = forward ? Direction::Forward : Direction::Backward;
  for (double speed = 0.0; speed < 1.0; speed += 0.05)
  {
    driveMotor(speed, dir);
    delay(200);
  }

  for (double speed = 1.0; speed > 0.0; speed -= 0.05)
  {
    driveMotor(speed, dir);
    delay(200);
  }
  forward = !forward;*/
}