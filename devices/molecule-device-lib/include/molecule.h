#ifndef MOLECULE_H
#define MOLECULE_H

#include <Arduino.h>
#include <ArduinoJson.h>
#include <WiFiManager.h>

#include "controller.h"
#include "device.h"
#include "discovery.h"
#include "logger.h"
#include "storage.h"
#include "utils.h"

namespace mlq {

void init(Controller *controller);

void update();

void setupMqtt(const String &address, uint16 port);

void sendDeviceInfo();

} // namespace mlq

#endif // MOLECULE_H