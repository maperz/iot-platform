#include "controller.h"

void Controller::sendStateUpdate()
{
    String state = getState();
    String topic = getDeviceChannel("state");
    client->publish(topic.c_str(), state.c_str(), state.length());
}
