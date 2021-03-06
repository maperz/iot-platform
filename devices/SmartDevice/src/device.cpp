#include "device.h"
#include "storage.h"
#include "logger.h"

const size_t STORAGE_NAME_ADDRESS = 0;
const size_t STORAGE_MAX_NAME_LEN = 50;

String Device::getName()
{
    char nameBuffer[STORAGE_MAX_NAME_LEN];
    Storage::read(STORAGE_NAME_ADDRESS, nameBuffer, STORAGE_MAX_NAME_LEN);
    return String(nameBuffer);
}

void Device::setName(const String &name)
{
    printLog(LogLevel::Info, "Setting name: %s\n", name.c_str());
    Storage::write(STORAGE_NAME_ADDRESS, name.c_str(), name.length() + 1);
}