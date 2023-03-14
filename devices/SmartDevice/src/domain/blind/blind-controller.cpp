#include "domain/blind/blind-controller.h"
#include "logger.h"
#include "storage.h"
#include "time.h"

#include <ArduinoJson.h>

const int DownPin = D5;
const int MidPin = D6;
const int UpPin = D7;

const int LONG_PRESS_DELAY_MS = 2500;

const char *ntpServer = "pool.ntp.org";

const int STORAGE_OPEN_TIME_ADDRESS = 100;
const int STORAGE_CLOSE_TIME_ADDRESS = 120;

void BlindController::setup() {
  pinMode(DownPin, OUTPUT);
  digitalWrite(DownPin, LOW);

  pinMode(MidPin, OUTPUT);
  digitalWrite(MidPin, LOW);

  pinMode(UpPin, OUTPUT);
  digitalWrite(UpPin, LOW);

  configTime(0, 0, ntpServer);

  Storage::read(STORAGE_OPEN_TIME_ADDRESS, (char *)&_openTime,
                sizeof(_openTime));
  Storage::read(STORAGE_CLOSE_TIME_ADDRESS, (char *)&_closeTime,
                sizeof(_closeTime));
}

bool BlindController::onRequest(const String &request, char *payload,
                                size_t plength) {
  if (request.equals(getRequestChannel("move"))) {
    if (strcmp("bot", payload) == 0) {
      Serial.println("Move request received for position: Bot");
      moveBlind(BlindPosition::Bot);
      return true;
    }
    if (strcmp("mid", payload) == 0) {
      Serial.println("Move request received for position: Mid");
      moveBlind(BlindPosition::Mid);
      return true;
    }
    if (strcmp("top", payload) == 0) {
      Serial.println("Move request received for position: Top");
      moveBlind(BlindPosition::Top);
      return true;
    }
  }
  return false;
}

void BlindController::loop() {
  time_t rawtime;
  struct tm *timeinfo;
  time(&rawtime);
  timeinfo = localtime(&rawtime);
  Serial.println(asctime(timeinfo));
  delay(1000);
}

void BlindController::moveBlind(BlindPosition position) const {
  digitalWrite(DownPin, LOW);
  digitalWrite(MidPin, LOW);
  digitalWrite(UpPin, LOW);

  int activePin;
  switch (position) {
  case BlindPosition::Top:
    activePin = UpPin;
    break;
  case BlindPosition::Mid:
    activePin = MidPin;
    break;
  case BlindPosition::Bot:
    activePin = DownPin;
    break;
  default:
    return;
  }

  digitalWrite(activePin, HIGH);
  delay(LONG_PRESS_DELAY_MS);
  digitalWrite(activePin, LOW);
}

String BlindController::getState() {
  StaticJsonDocument<200> json;
  // json["distance"] = _measuredDistance;

  serializeJson(json, sharedBuffer, SHARED_BUFFER_SIZE);
  return String((char *)sharedBuffer);
}