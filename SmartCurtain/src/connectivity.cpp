#include "connectivity.h"
#include "logger.h"
#include "Arduino.h"
#include "motor.h"
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

    void setupSoftAccesspoint()
    {
        WiFi.mode(WIFI_AP);
        WiFi.softAP("NodeMCU HotSpot");
        log(LogLevel::Info, "Created SoftAccessPoint!");
        serverIP = WiFi.softAPIP();
    }

    bool isWifiConnected()
    {
        return WiFi.status() == WL_CONNECTED;
    }

    void setupLocalWifi(const char *ssid, const char *password)
    {
        WiFi.begin(ssid, password);
        log(LogLevel::Info, "Trying to connect to Wifi ");
        while (WiFi.status() != WL_CONNECTED)
        {
            delay(500);
            log(LogLevel::Info, ".");
        }
        log(LogLevel::Info, "[Connected]\n");
        serverIP = WiFi.localIP();
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

    String getClientId()
    {
        String clientId = String("SC_") + getUniqueDeviceId();
        return clientId;
    }

    String getDeviceChannel(String channelName)
    {
        return getClientId() + "/" + channelName;
    }

    String getRequestChannel(String channelName)
    {
        return getClientId() + "/r/" + channelName;
    }

    double getState()
    {
        // TODO: Get actual speed
        return 11.11;
    }

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
        sendStateUpdate(getState());
    }

    void topicCallback(char *topicBytes, byte *payload, unsigned int length)
    {
        log(LogLevel::Info, "Received message in topic: %s\n", topicBytes);

        String topic(topicBytes);
        if (topic.equals(getRequestChannel("speed")))
        {
            char *start = (char *)payload;
            double speed = strtod(start, NULL);
            sendStateUpdate(speed);

            speed = max(-1.0, min(1.0, speed));
            auto direction = speed >= 0.0 ? Direction::Forward : Direction::Backward;
            driveMotor(fabs(speed), direction);
            return;
        }

        if (topic.equals(getRequestChannel("name")))
        {
            char *newName = (char *)payload;
            Device::setName(newName);
            sendDeviceInfo();
            return;
        }

        if (topic.equals(getRequestChannel("info")))
        {
            sendStateUpdate(getState());
            return;
        }
    }

    void sendDeviceInfo()
    {
        String topic = getDeviceChannel("device");
        StaticJsonDocument<200> document;
        document["name"] = Device::getName();
        document["type"] = Device::getType();

        size_t size = serializeJson(document, sharedBuffer, SHARED_BUFFER_SIZE);
        mqtt.publish(topic.c_str(), sharedBuffer, size);
    }

    void sendStateUpdate(double speed)
    {
        String topic = getDeviceChannel("state");
        String speedString(speed);
        mqtt.publish(topic.c_str(), speedString.c_str(), speedString.length());
    }
} // namespace Connectivity