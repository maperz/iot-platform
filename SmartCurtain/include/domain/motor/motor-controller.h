#ifndef MOTOR_CONTROLLER_H_GUARD
#define MOTOR_CONTROLLER_H_GUARD

#include "controller.h"

class MotorController : public Controller
{
public:
    MotorController(PubSubClient *client) : Controller(client)
    {
        setup();
    };

    void setup();

    virtual void loop();
    virtual bool onRequest(const String &request, char *payload, size_t plength);
    virtual String getState();

    virtual String getType() { return "curtain"; }
    virtual String getVersion() { return "1.0.0"; }

private:
    double _currentSpeed;
};

#endif // MOTOR_CONTROLLER_H_GUARD