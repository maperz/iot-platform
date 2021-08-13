#ifndef MOLECULE_H
#define MOLECULE_H

#include "connectivity.h"
#include "discovery.h"
#include "logger.h"
#include "storage.h"
#include "utils.h"
#include <Arduino.h>

#include <WiFiManager.h>

namespace mlq {

void init(Controller *controller);

void update();

} // namespace mlq

#endif // MOLECULE_H