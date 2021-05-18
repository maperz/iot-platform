#ifndef MOTOR_H_GUARD
#define MOTOR_H_GUARD

enum class Direction
{
    Forward = 1,
    Backward = 2,
};

void initMotor();
void driveMotor(double speed, Direction direction);
void motorLoop();

#endif //MOTOR_H_GUARD