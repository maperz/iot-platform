#include "molecule.h"

#include "discovery.h"
#include "logger.h"
#include "storage.h"
#include "utils.h"

namespace mlq {
WiFiClient client;
PubSubClient mqttClient(client);
Controller *controller;

void init(Controller *con) {
  Storage::init();

  printLog(LogLevel::Info, "Starting WiFi connection routine\n");
  WiFiManager wifiManager;
  wifiManager.autoConnect(getClientId().c_str());
  printLog(LogLevel::Info, "Connected to WiFi successfully\n");

  controller = con;
  controller->setPubSubClient(&mqttClient);
}

ServiceDiscovery serviceDiscovery(sharedBuffer, SHARED_BUFFER_SIZE);

void update() {

  bool discoveryCompleted = serviceDiscovery.discoveryCompleted();
  if (!discoveryCompleted) {
    serviceDiscovery.loop();
    return;
  }

  if (!mqttClient.connected() && discoveryCompleted) {
    MSDNHost host = serviceDiscovery.getHost();
    mlq::setupMqtt(host.address, host.port);
  }

  if (mqttClient.connected()) {
    mqttClient.loop();
    controller->loop();
  }
}

void topicCallback(char *topic, byte *payload, unsigned int length);

void setupMqtt(const String &address, uint16 port) {
  mqttClient.setServer(address.c_str(), port);
  mqttClient.setCallback(topicCallback);

  // Loop until we're reconnected
  printLog(LogLevel::Info, "Establishing MQTT connection ");
  while (!client.connected()) {
    String clientId = getClientId();

    if (mqttClient.connect(clientId.c_str())) {
      printLog(LogLevel::Info, "[Connected]\nConnected MQTT to Host at %s:%d\n",
          address.c_str(), port);
      mqttClient.subscribe(getRequestChannel("#").c_str());
    } else {
      delay(2000);
      printLog(LogLevel::Info, ".");
    }
  }

  sendDeviceInfo();
  controller->sendStateUpdate();
}

void topicCallback(char *topicBytes, byte *rawPayload, unsigned int length) {
  printLog(LogLevel::Info, "Received message in topic: %s\n", topicBytes);

  char payload[length + 1];
  memcpy(payload, rawPayload, length);
  payload[length] = 0;

  String topic(topicBytes);

  if (topic.equals(getRequestChannel("name"))) {
    Device::setName(payload);
    sendDeviceInfo();
    return;
  }

  if (topic.equals(getRequestChannel("info"))) {
    controller->sendStateUpdate();
    return;
  }

  if (controller->onRequest(topic, payload, length)) {
    controller->sendStateUpdate();
  }
}

void sendDeviceInfo() {
  String topic = getDeviceChannel("device");
  StaticJsonDocument<200> document;
  document["name"] = Device::getName();
  document["type"] = controller->getType();
  document["version"] = controller->getVersion();

  size_t size = serializeJson(document, sharedBuffer, SHARED_BUFFER_SIZE);
  mqttClient.publish(topic.c_str(), sharedBuffer, size);
}

} // namespace mlq