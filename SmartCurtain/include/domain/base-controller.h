#ifndef BASE_CONTROLLER_H_GUARD
#define BASE_CONTROLLER_H_GUARD

#include "utils.h"
#include <PubSubClient.h>

class BaseController
{
public:
    BaseController(PubSubClient *client) : client(client) {}
    virtual ~BaseController() {};

    virtual void loop() {};

    virtual void onRequest(const String &request, char *payload, size_t plength) = 0;

    virtual String getState() = 0;

    void sendStateUpdate(const String &state);

private:
    PubSubClient *client;
};

#endif // BASE_CONTROLLER_H_GUARD