#ifndef DEVICE_H_GUARD
#define DEVICE_H_GUARD

#include <Arduino.h>

class Device
{
public:
    static String getType();

    static String getName();

    static String getVersion();

    static void setName(const String &name);
};

#endif // DEVICE_H_GUARD