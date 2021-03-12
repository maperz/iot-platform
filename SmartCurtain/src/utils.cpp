#include "utils.h"
#include <ESP8266WiFi.h>

String getUniqueDeviceId()
{
    String id = WiFi.macAddress();
    id.replace(":", "");
    return id;
}