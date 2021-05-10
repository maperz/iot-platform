#include "domain/base-controller.h"

void BaseController::sendStateUpdate(const String &state)
{
    String topic = getDeviceChannel("state");
    client->publish(topic.c_str(), state.c_str(), state.length());
}
