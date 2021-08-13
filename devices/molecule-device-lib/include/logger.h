#ifndef LOGGOR_H_GUARD
#define LOGGOR_H_GUARD

enum class LogLevel
{
    Debug,
    Info,
    Warn,
    Error
};

#define log(level, ...) Serial.printf(__VA_ARGS__)

#endif //LOGGOR_H_GUARD