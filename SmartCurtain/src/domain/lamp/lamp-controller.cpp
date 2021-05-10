#include "domain/lamp/lamp-controller.h"

void LampController::setup()
{
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, HIGH);
}

void LampController::onRequest(const String &request, char *payload, size_t plength)
{
    if (request.equals(getRequestChannel("switch")))
    {
        double value = strtod(payload, NULL);
        isOn = value > 0;
        digitalWrite(LED_BUILTIN, isOn ? LOW : HIGH);
    }
}

void LampController::loop()
{
}

String LampController::getState()
{
    // TODO
    return isOn ? "1" : "0";
}