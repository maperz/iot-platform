
#ifndef STORAGE_H_GUARD
#define STORAGE_H_GUARD

#include <Arduino.h>
#include <EEPROM.h>

class Storage {
public:
  static void init();
  static void clear();
  static bool write(size_t address, const char *value, size_t size);
  static void read(size_t address, char *value, size_t size);
};

#endif // STORAGE_H_GUARD