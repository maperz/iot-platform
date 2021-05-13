#include "domain/motor/motor-controller.h"
#include "motor.h"

bool MotorController::onRequest(const String &request, char *payload, size_t plength)
{
    if (request.equals(getRequestChannel("speed")))
    {
        double speed = strtod(payload, NULL);

        speed = max(-1.0, min(1.0, speed));

        if (_currentSpeed == speed)
        {
            return false;
        }

        _currentSpeed = speed;

        auto direction = speed >= 0.0 ? Direction::Forward : Direction::Backward;
        driveMotor(fabs(speed), direction);

        return true;
    }
    return false;
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
    return String(_currentSpeed);
}