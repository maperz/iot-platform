#include <Arduino.h>
#include "motor.h"
#include "connectivity.h"
#include "logger.h"
#include "secrets.h"
#include "discovery.h"
#include "storage.h"
#include "utils.h"

void setup()
{
  Serial.begin(115200);
  Storage::init();
  printf("\n\n");
  initMotor();
}

bool forward = true;
ServiceDiscovery serviceDiscovery(sharedBuffer, SHARED_BUFFER_SIZE);

void loop()
{
  if (!Connectivity::isWifiConnected())
  {
    Connectivity::setupLocalWifi(network_ssid, network_pw);
  }

  bool discoveryCompleted = serviceDiscovery.discoveryCompleted();
  if (!discoveryCompleted)
  {
    serviceDiscovery.loop();
  }

  if (!Connectivity::mqtt.connected() && discoveryCompleted)
  {
    MSDNHost host = serviceDiscovery.getHost();
    Connectivity::setupMqtt(host.address, host.port);
  }

  Connectivity::mqtt.loop();
  motorLoop();
}