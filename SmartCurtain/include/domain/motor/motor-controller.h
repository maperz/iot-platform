#ifndef MOTOR_CONTROLLER_H_GUARD
#define MOTOR_CONTROLLER_H_GUARD

#include "../base-controller.h"

class MotorController : public BaseController
{
public:
    MotorController(PubSubClient *client) : BaseController(client)
    {
        setup();
    };

    void setup();

    virtual void loop();
    virtual void onRequest(const String &request, char *payload, size_t plength);
    virtual String getState();
};

#endif // MOTOR_CONTROLLER_H_GUARD