#ifndef DEVICE_H_GUARD
#define DEVICE_H_GUARD

#include <Arduino.h>

class Device {
public:
  static String getName();

  static void setName(const String &name);
};

#endif // DEVICE_H_GUARD