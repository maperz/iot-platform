#ifndef LOGGER_H_GUARD
#define LOGGER_H_GUARD

enum class LogLevel { Debug, Info, Warn, Error };

#define MLQ_LOG_ENABLED 1

#ifdef MLQ_LOG_ENABLED
#define printLog(level, ...)                                                   \
  do {                                                                         \
    Serial.printf(__VA_ARGS__);                                                \
  } while (0)
#else
#define printLog(level, ...)                                                   \
  do {                                                                         \
  } while (0)
#endif

#endif // LOGGER_H_GUARD