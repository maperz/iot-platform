#include "utils.h"
#include <ESP8266WiFi.h>

unsigned char sharedBuffer[SHARED_BUFFER_SIZE];

String getUniqueDeviceId() {
  String id = WiFi.macAddress();
  id.replace(":", "");
  return id;
}

String getClientId() {
  String clientId = String("SC_") + getUniqueDeviceId();
  return clientId;
}

String getDeviceChannel(String channelName) {
  return getClientId() + "/" + channelName;
}

String getRequestChannel(String channelName) {
  return getClientId() + "/r/" + channelName;
}