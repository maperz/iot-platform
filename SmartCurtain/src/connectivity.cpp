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
    PubSubClient pubSubClient(client);

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
        while (WiFi.status() != WL_CONNECTED)
        {
            delay(500);
            log(LogLevel::Info, ".");
        }
        log(LogLevel::Info, " Connected to WIFI.\n");
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

    void setupPubSub(const char *host)
    {
        pubSubClient.setServer(host, 1883);
        pubSubClient.setCallback(topicCallback);

        // Loop until we're reconnected
        while (!client.connected())
        {
            Serial.print("Attempting MQTT connection...");
            String clientId = String("SC_") + getUniqueDeviceId();

            if (pubSubClient.connect(clientId.c_str()))
            {
                log(LogLevel::Info, "Setup PubSub Client - Connected to %s\n", host);
                pubSubClient.subscribe("speed");
            }
            else
            {
                delay(2000);
            }
        }
    }

    void topicCallback(char *topicBytes, byte *payload, unsigned int length)
    {
        log(LogLevel::Info, "Received message in topic: ");
        log(LogLevel::Info, "%s\n", topicBytes);

        String topic(topicBytes);
        if (topic.equals("speed"))
        {
            char *start = (char *)payload;
            double val = strtod(start, NULL);
            driveMotor(val, Direction::Forward);
        }
    }

} // namespace Connectivity