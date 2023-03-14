#include "device.h"
#include "logger.h"
#include "storage.h"

const size_t STORAGE_NAME_ADDRESS = 0;
const size_t STORAGE_MAX_NAME_LEN = 50;

String Device::getName() {
  char nameBuffer[STORAGE_MAX_NAME_LEN];
  Storage::read(STORAGE_NAME_ADDRESS, nameBuffer, STORAGE_MAX_NAME_LEN);
  nameBuffer[STORAGE_MAX_NAME_LEN - 1] = 0;
  return String(nameBuffer);
}

void Device::setName(const String &name) {
  printLog(LogLevel::Info, "Setting name: %s\n", name.c_str());
  int nameLength = std::min(name.length() + 1, STORAGE_MAX_NAME_LEN);
  Storage::write(STORAGE_NAME_ADDRESS, name.c_str(), nameLength);
}