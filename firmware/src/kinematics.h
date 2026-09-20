#ifndef KINEMATICS_H
#define KINEMATICS_H

#include <Arduino.h>

class DifferentialKinematics {
public:
    DifferentialKinematics(float deadband = 0.05f, float rampStep = 15.0f);

    // Convierte X e Y normalizados (-1.0 a 1.0) y speedLimit (0.1 a 1.0) a PWM (-255 a +255)
    void compute(float x, float y, float speedLimit, int &pwmLeft, int &pwmRight);

    void resetRamp();

private:
    float _deadband;
    float _rampStep; // Paso máximo de aceleración por ciclo para suavizar transiciones

    float _currentLeftPwm;
    float _currentRightPwm;
};

#endif // KINEMATICS_H
