#include "domain/lamp/lamp-controller.h"
#include <ArduinoJson.h>

void LampController::setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, HIGH);
}

bool LampController::onRequest(const String &request, char *payload, size_t plength)
{
    if (request.equals(getRequestChannel("switch")))
    {
        float value = strtof(payload, NULL);
        bool requestedOn = value > 0;

        if (requestedOn == isOn)
        {
            return false;
        }

        isOn = requestedOn;
        digitalWrite(LED_BUILTIN, isOn ? LOW : HIGH);
        return true;
    }
    return false;
}

void LampController::loop()
{
}

String LampController::getState()
{
    StaticJsonDocument<200> json;
    json["isOn"] = isOn;
    json["color"] = "#8870FF";
    serializeJson(json, sharedBuffer, SHARED_BUFFER_SIZE);
    return String((char *)sharedBuffer);
}