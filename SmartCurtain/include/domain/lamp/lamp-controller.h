#ifndef LAMP_CONTROLLER_H_GUARD
#define LAMP_CONTROLLER_H_GUARD

#include "domain/base-controller.h"

class LampController : public BaseController
{
public:
    LampController(PubSubClient *client) : BaseController(client)
    {
        setup();
    };

    void setup();

    virtual void loop();

    virtual void onRequest(const String &request, char *payload, size_t plength);
    virtual String getState();

private:
    bool isOn;
};

#endif // LAMP_CONTROLLER_H_GUARD