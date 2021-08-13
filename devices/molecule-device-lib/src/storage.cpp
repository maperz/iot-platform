
#include "storage.h"

const size_t EEPROM_SIZE = 512;

void Storage::init() { EEPROM.begin(EEPROM_SIZE); }

void Storage::clear() {
  for (size_t i = 0; i < EEPROM_SIZE; i++) {
    EEPROM.write(i, 0);
  }
  EEPROM.commit();
  delay(500);
}

bool Storage::write(size_t address, const char *value, size_t size) {
  size_t endAddress = min(address + size, EEPROM_SIZE);
  for (size_t i = 0; (i + address) < endAddress; i++) {
    EEPROM.write(i + address, value[i]);
  }

  bool success = EEPROM.commit();
  delay(500);
  return success;
}

void Storage::read(size_t address, char *buffer, size_t size) {
  size_t endAddress = min(address + size, EEPROM_SIZE);
  for (size_t i = 0; (i + address) < endAddress; i++) {
    buffer[i] = EEPROM.read(i + address);
  }
}
