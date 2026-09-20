#include "kinematics.h"
#include <math.h>

DifferentialKinematics::DifferentialKinematics(float deadband, float rampStep)
    : _deadband(deadband), _rampStep(rampStep), _currentLeftPwm(0), _currentRightPwm(0) {}

void DifferentialKinematics::resetRamp() {
    _currentLeftPwm = 0;
    _currentRightPwm = 0;
}

void DifferentialKinematics::compute(float x, float y, float speedLimit, int &pwmLeft, int &pwmRight) {
    // 1. Filtrar zona muerta
    if (fabs(x) < _deadband) x = 0.0f;
    if (fabs(y) < _deadband) y = 0.0f;

    // Si ambos están en reposo, desacelerar de inmediato a 0
    if (x == 0.0f && y == 0.0f) {
        resetRamp();
        pwmLeft = 0;
        pwmRight = 0;
        return;
    }

    // 2. Mezcla diferencial
    // Y: avance/retroceso, X: giro (derecha suma a izq y resta a der)
    float rawLeft = y + x;
    float rawRight = y - x;

    // 3. Normalizar si excede 1.0
    float maxMag = fmax(fabs(rawLeft), fabs(rawRight));
    if (maxMag > 1.0f) {
        rawLeft /= maxMag;
        rawRight /= maxMag;
    }

    // 4. Aplicar límite de velocidad
    speedLimit = constrain(speedLimit, 0.1f, 1.0f);
    float targetLeft = rawLeft * speedLimit * 255.0f;
    float targetRight = rawRight * speedLimit * 255.0f;

    // 5. Aplicar rampa de aceleración para evitar picos de corriente inductiva
    if (targetLeft > _currentLeftPwm) {
        _currentLeftPwm = fmin(_currentLeftPwm + _rampStep, targetLeft);
    } else {
        _currentLeftPwm = fmax(_currentLeftPwm - _rampStep, targetLeft);
    }

    if (targetRight > _currentRightPwm) {
        _currentRightPwm = fmin(_currentRightPwm + _rampStep, targetRight);
    } else {
        _currentRightPwm = fmax(_currentRightPwm - _rampStep, targetRight);
    }

    pwmLeft = (int)round(_currentLeftPwm);
    pwmRight = (int)round(_currentRightPwm);
}
