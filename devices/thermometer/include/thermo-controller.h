#ifndef THERMO_CONTROLLER_H_GUARD
#define THERMO_CONTROLLER_H_GUARD

#include "controller.h"

class ThermoController : public Controller
{
public:
    virtual void setup();

    virtual void loop();
    virtual bool onRequest(const String &request, char *payload, size_t plength);
    virtual String getState();
    virtual String getType() { return "thermo"; }
    virtual String getVersion() { return "1.0.0"; }

private:
    bool measureTemperature();
    
    bool _initialized = false;
    float _lastMeasuredTemp;
    float _lastMeasuredHum;
    unsigned long _lastTime = 0;
};

#endif // THERMO_CONTROLLER_H_GUARD