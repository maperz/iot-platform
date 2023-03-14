#include "connectivity.h"
#include "discovery.h"
#include "logger.h"
#include "storage.h"
#include "utils.h"
#include <Arduino.h>

#include "domain/distance-measure/dm-controller.h"
#include "domain/lamp/lamp-controller.h"
#include "domain/motor/motor-controller.h"
#include "domain/thermometer/thermo-controller.h"
#include "domain/blind/blind-controller.h"

#include <ESP8266WiFi.h>
#include <WiFiManager.h>

void setupController() {
  // Connectivity::controller = new MotorController(&Connectivity::mqtt);
  // Connectivity::controller = new LampController(&Connectivity::mqtt);
  // Connectivity::controller = new ThermoController(&Connectivity::mqtt);
  // Connectivity::controller = new DistanceMeasureController(&Connectivity::mqtt);
  Connectivity::controller = new BlindController(&Connectivity::mqtt);
}

void setup() {
  Serial.begin(115200);
  Storage::init();

  printLog(LogLevel::Info, "Starting WiFi connection routine");

  WiFiManager wifiManager;
  wifiManager.autoConnect(getClientId().c_str());
  
  printLog(LogLevel::Info, "Connected to WiFi successfully");

  printf("\n\n");
  setupController();
}

ServiceDiscovery serviceDiscovery(sharedBuffer, SHARED_BUFFER_SIZE);

void loop() {

  bool discoveryCompleted = serviceDiscovery.discoveryCompleted();
  if (!discoveryCompleted) {
    serviceDiscovery.loop();
    return;
  }

  if (!Connectivity::mqtt.connected() && discoveryCompleted) {
    MSDNHost host = serviceDiscovery.getHost();
    Connectivity::setupMqtt(host.address, host.port);
  }

  if (Connectivity::mqtt.connected()) {
    Connectivity::mqtt.loop();
    Connectivity::controller->loop();
  }
}