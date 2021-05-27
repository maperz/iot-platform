#include "domain/thermometer/thermo-controller.h"
#include <ArduinoJson.h>

#include "DHT.h"
#include <Adafruit_Sensor.h>

DHT dht(D1, DHT22);

bool ThermoController::onRequest(const String &request, char *payload, size_t plength)
{
    if (request.equals(getRequestChannel("temperature")))
    {
        return measureTemperature();
    }
    return false;
}

void ThermoController::loop()
{
    unsigned long timeMs = millis();
    const int deltaMs = 60000; 

    if (timeMs - _lastTime >= deltaMs)
    {
        if (measureTemperature())
        {
            sendStateUpdate();
        }
        _lastTime = timeMs;
    }
}

String ThermoController::getState()
{
    if (!_initialized) {
        return "";
    }
    
    StaticJsonDocument<200> json;
    json["temp"] = _lastMeasuredTemp;
    json["hum"] = _lastMeasuredHum;
    serializeJson(json, sharedBuffer, SHARED_BUFFER_SIZE);
    return String((char *)sharedBuffer);
}

bool ThermoController::measureTemperature()
{
    if (!_initialized)
    {
        Serial.printf("Setting up temperature sensor\n");
        dht.begin();
        _initialized = true;
    }

    float hum = dht.readHumidity();
    float temp = dht.readTemperature();

    Serial.printf("Measured T: %f°C, H: %f%%\n", temp, hum);

    bool changedTemp = fabs(temp - _lastMeasuredTemp) >= 0.001f;
    bool changedHum = fabs(hum - _lastMeasuredHum) >= 0.01f;

    _lastMeasuredTemp = temp;
    _lastMeasuredHum = hum;

    return changedTemp || changedHum;
}