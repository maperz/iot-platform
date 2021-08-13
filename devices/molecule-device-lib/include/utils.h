#ifndef UTILS_H_GUARD
#define UTILS_H_GUARD

#include <Arduino.h>

#define SHARED_BUFFER_SIZE 512
extern unsigned char sharedBuffer[SHARED_BUFFER_SIZE];

String getClientId();
String getDeviceChannel(String channelName);
String getRequestChannel(String channelName);

#endif // UTILS_H_GUARD