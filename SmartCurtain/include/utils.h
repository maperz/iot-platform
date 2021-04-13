#ifndef UTILS_H_GUARD
#define UTILS_H_GUARD

#include <Arduino.h>

#define SHARED_BUFFER_SIZE 512
extern byte sharedBuffer[SHARED_BUFFER_SIZE];

String getUniqueDeviceId();

#endif // UTILS_H_GUARD