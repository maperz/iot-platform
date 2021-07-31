#include "connectivity.h"
#include "logger.h"
#include "Arduino.h"
#include "utils.h"
#include "device.h"

#include <ArduinoJson.h>

namespace Connectivity
{
    WiFiServer server(80);
    IPAddress serverIP;
    WiFiUDP udp;
    WiFiClient client;
    PubSubClient mqtt(client);

    Controller *controller;

    void setupSoftAccesspoint()
    {
        WiFi.mode(WIFI_AP);
        WiFi.softAP("NodeMCU HotSpot");
        log(LogLevel::Info, "Created SoftAccessPoint!");
        serverIP = WiFi.softAPIP();
    }
    
    void setupServer()
    {
        server.begin();
        log(LogLevel::Info, "Server is listening at: ");
        log(LogLevel::Info, "%s\n", serverIP.toString().c_str());
    }

    void setupUdp()
    {
        unsigned int localUdpPort = 6437;
        udp.begin(localUdpPort);
    }

    void topicCallback(char *topic, byte *payload, unsigned int length);

    void setupMqtt(const String &address, uint16 port)
    {
        mqtt.setServer(address.c_str(), port);
        mqtt.setCallback(topicCallback);

        // Loop until we're reconnected
        Serial.print("Establishing MQTT connection ");
        while (!client.connected())
        {
            String clientId = getClientId();

            if (mqtt.connect(clientId.c_str()))
            {
                log(LogLevel::Info, "[Connected]\nConnected MQTT to Host at %s:%d\n", address.c_str(), port);
                mqtt.subscribe(getRequestChannel("#").c_str());
            }
            else
            {
                delay(2000);
                log(LogLevel::Info, ".");
            }
        }

        sendDeviceInfo();
        controller->sendStateUpdate();
    }

    void topicCallback(char *topicBytes, byte *rawPayload, unsigned int length)
    {
        log(LogLevel::Info, "Received message in topic: %s\n", topicBytes);

        char payload[length + 1];
        memcpy(payload, rawPayload, length);
        payload[length] = 0;

        String topic(topicBytes);

        if (topic.equals(getRequestChannel("name")))
        {
            Device::setName(payload);
            sendDeviceInfo();
            return;
        }

        if (topic.equals(getRequestChannel("info")))
        {
            controller->sendStateUpdate();
            return;
        }

        if (controller->onRequest(topic, payload, length))
        {
            controller->sendStateUpdate();
        }
    }

    void sendDeviceInfo()
    {
        String topic = getDeviceChannel("device");
        StaticJsonDocument<200> document;
        document["name"] = Device::getName();
        document["type"] = controller->getType();
        document["version"] = controller->getVersion();

        size_t size = serializeJson(document, sharedBuffer, SHARED_BUFFER_SIZE);
        mqtt.publish(topic.c_str(), sharedBuffer, size);
    }
} // namespace Connectivity