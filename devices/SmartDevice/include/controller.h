#ifndef CONTROLLER_H_GUARD
#define CONTROLLER_H_GUARD

#include "utils.h"
#include <PubSubClient.h>

class Controller
{
public:
    Controller(PubSubClient *client) : client(client) {}
    virtual ~Controller(){};

    virtual void loop(){};

    virtual bool onRequest(const String &request, char *payload, size_t plength) = 0;

    virtual String getState() = 0;

    void sendStateUpdate();

    // Info
    virtual String getType() = 0;
    virtual String getVersion() = 0;

private:
    PubSubClient *client;
};

#endif // CONTROLLER_H_GUARD