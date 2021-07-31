#include <Arduino.h>
#include "connectivity.h"
#include "logger.h"
#include "discovery.h"
#include "storage.h"
#include "utils.h"

#include "domain/motor/motor-controller.h"
#include "domain/lamp/lamp-controller.h"
#include "domain/thermometer/thermo-controller.h"
#include "domain/distance-measure/dm-controller.h"

#include <WiFiManager.h>

void setupController()
{
  //Connectivity::controller = new MotorController(&Connectivity::mqtt);
  //Connectivity::controller = new LampController(&Connectivity::mqtt);
  Connectivity::controller = new ThermoController(&Connectivity::mqtt);
  //Connectivity::controller = new DistanceMeasureController(&Connectivity::mqtt);
}

WiFiManager wifiManager;

void setup()
{
  Serial.begin(115200);
  Storage::init();

  log(LogLevel::Info, "Starting WiFi connection routine");
  wifiManager.autoConnect(getClientId().c_str());
  log(LogLevel::Info, "Connected to WiFi successfully");

  printf("\n\n");
  setupController();

}

bool forward = true;
ServiceDiscovery serviceDiscovery(sharedBuffer, SHARED_BUFFER_SIZE);

void loop()
{

  bool discoveryCompleted = serviceDiscovery.discoveryCompleted();
  if (!discoveryCompleted)
  {
    serviceDiscovery.loop();
    return;
  }

  if (!Connectivity::mqtt.connected() && discoveryCompleted)
  {
    MSDNHost host = serviceDiscovery.getHost();
    Connectivity::setupMqtt(host.address, host.port);
  }

  if (Connectivity::mqtt.connected())
  {
    Connectivity::mqtt.loop();
    Connectivity::controller->loop();
  }
}