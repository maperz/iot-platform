#ifndef CONNECTIVITY_H_GUARD
#define CONNECTIVITY_H_GUARD

#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <PubSubClient.h>
#include "controller.h"

namespace Connectivity
{
    extern WiFiServer server;
    extern IPAddress serverIP;
    extern WiFiUDP udp;
    extern PubSubClient mqtt;
    
    extern Controller* controller;

    bool isWifiConnected();

    void setupLocalWifi(const char *ssid, const char *password);

    void setupSoftAccesspoint();

    void setupServer();

    void setupUdp();

    void setupMqtt(const String& address, uint16 port);

    void sendStateUpdate(double speed);
    void sendDeviceInfo();

} // namespace Connectivity

#endif // CONNECTIVITY_H_GUARD