#include "utils.h"
#include <ESP8266WiFi.h>

byte sharedBuffer[SHARED_BUFFER_SIZE];

String getUniqueDeviceId()
{
    String id = WiFi.macAddress();
    id.replace(":", "");
    return id;
}