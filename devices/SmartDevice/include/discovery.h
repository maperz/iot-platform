#ifndef DISCOVERY_H_GUARD
#define DISCOVERY_H_GUARD

#include <Arduino.h>

#include <mdns.h>
#include "time.h"

#define SERVICE_NAME "_iotmqtt._tcp.local"

struct MSDNHost
{
public:
    String serviceName;
    String hostName;
    String address;
    int port;
};

class ServiceDiscovery
{
public:
    ServiceDiscovery(byte *buffer, int bufferSize);
    void loop();
    void reset();
    bool discoveryCompleted();
    MSDNHost getHost();

private:
    void sendQuery();

    mdns::MDns mdnsClient;

    clock_t lastSent;
    long ticks = 0;
};

#endif // DISCOVERY_H_GUARD