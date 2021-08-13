#include "molecule.h"

namespace mlq {

WiFiManager wifiManager;

void init(Controller *controller) {

  log(LogLevel::Info, "Starting WiFi connection routine");
  wifiManager.autoConnect(getClientId().c_str());
  log(LogLevel::Info, "Connected to WiFi successfully");

  printf("\n\n");
  Connectivity::controller = controller;
  controller->setPubSubClient(&Connectivity::mqtt);
}

ServiceDiscovery serviceDiscovery(sharedBuffer, SHARED_BUFFER_SIZE);

void update() {

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

} // namespace mlq