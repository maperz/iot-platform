#include "connectivity.h"
#include "logger.h"
#include "Arduino.h"
#include "motor.h"
#include "utils.h"

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

    double getState()
    {
        // TODO: Get actual speed
        return 11.11;
    }

    void setupMqtt(const char *host)
    {
        mqtt.setServer(host, 1883);
        mqtt.setCallback(topicCallback);

        // Loop until we're reconnected
        Serial.print("Establishing MQTT connection ");
        while (!client.connected())
        {
            String clientId = getClientId();

            if (mqtt.connect(clientId.c_str()))
            {
                log(LogLevel::Info, "[Connected]\nConnected MQTT to Host at %s\n", host);
                mqtt.subscribe(getDeviceChannel("#").c_str());
            }
            else
            {
                delay(2000);
                log(LogLevel::Info, ".");
            }
        }

        sendStateUpdate(getState());
    }

    void topicCallback(char *topicBytes, byte *payload, unsigned int length)
    {
        log(LogLevel::Info, "Received message in topic: %s\n", topicBytes);

        String topic(topicBytes);
        if (topic.equals(getDeviceChannel("speed")))
        {
            char *start = (char *)payload;
            double speed = strtod(start, NULL);
            sendStateUpdate(speed);

            speed = max(-1.0, min(1.0, speed));
            auto direction = speed >= 0.0 ? Direction::Forward : Direction::Backward;
            driveMotor(fabs(speed), direction);
            return;
        }

        if (topic.equals(getDeviceChannel("info")))
        {
            sendStateUpdate(getState());
            return;
        }
    }

    void sendStateUpdate(double speed)
    {
        String stateTopic = getClientId() + "/state";
        String speedString(speed);
        mqtt.publish(stateTopic.c_str(), speedString.c_str(), speedString.length());
    }
} // namespace Connectivity