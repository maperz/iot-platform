#ifndef LAMP_CONTROLLER_H_GUARD
#define LAMP_CONTROLLER_H_GUARD

#include "controller.h"

class LampController : public Controller
{
public:
    LampController(PubSubClient *client) : Controller(client)
    {
        setup();
    };

    void setup();

    virtual void loop();

    virtual bool onRequest(const String &request, char *payload, size_t plength);
    virtual String getState();

    virtual String getType() { return "lamp"; }
    virtual String getVersion() { return "1.0.0"; }

private:
    bool isOn;
};

#endif // LAMP_CONTROLLER_H_GUARD