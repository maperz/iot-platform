#ifndef CONNECTIVITY_H_GUARD
#define CONNECTIVITY_H_GUARD

#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <PubSubClient.h>

namespace Connectivity
{
    extern WiFiServer server;
    extern IPAddress serverIP;
    extern WiFiUDP udp;
    extern PubSubClient mqtt;

    bool isWifiConnected();

    void setupLocalWifi(const char *ssid, const char *password);

    void setupSoftAccesspoint();

    void setupServer();

    void setupUdp();

    void setupMqtt(const char *host);

    void sendStateUpdate(double speed);

} // namespace Connectivity

#endif // CONNECTIVITY_H_GUARD