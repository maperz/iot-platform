#ifndef DM_CONTROLLER_H_GUARD
#define DM_CONTROLLER_H_GUARD

#include "controller.h"

class DistanceMeasureController : public Controller
{
public:
    DistanceMeasureController(PubSubClient *client) : Controller(client)
    {
        setup();
    };

    void setup();

    virtual void loop();

    virtual bool onRequest(const String &request, char *payload, size_t plength);
    virtual String getState();

    virtual String getType() { return "distance-measure"; }
    virtual String getVersion() { return "1.0.0"; }

private:
    float measureDistance();
    float _measuredDistance;
    unsigned long _lastMeasureTime = 0;
};

#endif // DM_CONTROLLER_H_GUARD