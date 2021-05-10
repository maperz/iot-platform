#include "domain/motor/motor-controller.h"
#include "motor.h"

void MotorController::onRequest(const String &request, char *payload, size_t plength)
{
    if (request.equals(getRequestChannel("speed")))
    {
        double speed = strtod(payload, NULL);

        String speedString(speed);
        sendStateUpdate(speedString);

        speed = max(-1.0, min(1.0, speed));
        auto direction = speed >= 0.0 ? Direction::Forward : Direction::Backward;
        driveMotor(fabs(speed), direction);
    }
}

void MotorController::setup()
{
    initMotor();
}

void MotorController::loop()
{
    motorLoop();
}

String MotorController::getState()
{
    // TODO
    return "10.0";
}