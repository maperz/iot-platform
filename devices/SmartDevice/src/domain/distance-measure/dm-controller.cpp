#include "domain/distance-measure/dm-controller.h"
#include <ArduinoJson.h>
#include "logger.h"

const int triggerPin = D5;
const int echoPin = D6;

const float soundVelocity = 0.034f; // [cm/uS]
const unsigned long measureInterval = 2000; // [ms]

void DistanceMeasureController::setup()
{
    pinMode(triggerPin, OUTPUT);
    pinMode(echoPin, INPUT);
}

// Returns the difference to last measurment
float DistanceMeasureController::measureDistance() {
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(2);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin, LOW);
  
  float duration = pulseIn(echoPin, HIGH);
  float distance = duration * soundVelocity/2;
  float diff = distance - _measuredDistance;
  _measuredDistance = distance;

  log(LogLevel.Info, "[DM] Measured distance of %fcm - Diff %fcm\n", _measuredDistance, diff);
  return diff;
}

bool DistanceMeasureController::onRequest(const String &request, char *payload, size_t plength)
{
    if (request.equals(getRequestChannel("measure")))
    {
        measureDistance();
        return true;
    }
    return false;
}

void DistanceMeasureController::loop()
{
    unsigned long timeMs = millis();
    
    if (timeMs - _lastMeasureTime >= measureInterval)
    {
        float diff = measureDistance();
        if (abs(diff) >= 0.05) {
            sendStateUpdate();
        }
        _lastMeasureTime = timeMs;
    }
}

String DistanceMeasureController::getState()
{
    StaticJsonDocument<200> json;
    json["distance"] = _measuredDistance;
    serializeJson(json, sharedBuffer, SHARED_BUFFER_SIZE);
    return String((char *)sharedBuffer);
}