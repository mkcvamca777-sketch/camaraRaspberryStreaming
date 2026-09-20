#include "motor_driver.h"

MotorDriver::MotorDriver(int pinPwma, int pinAin1, int pinAin2,
                         int pinPwmb, int pinBin1, int pinBin2,
                         int pinStby)
    : _pinPwma(pinPwma), _pinAin1(pinAin1), _pinAin2(pinAin2),
      _pinPwmb(pinPwmb), _pinBin1(pinBin1), _pinBin2(pinBin2),
      _pinStby(pinStby) {}

void MotorDriver::begin() {
    pinMode(_pinPwma, OUTPUT);
    pinMode(_pinAin1, OUTPUT);
    pinMode(_pinAin2, OUTPUT);

    pinMode(_pinPwmb, OUTPUT);
    pinMode(_pinBin1, OUTPUT);
    pinMode(_pinBin2, OUTPUT);

    if (_pinStby >= 0) {
        pinMode(_pinStby, OUTPUT);
        digitalWrite(_pinStby, HIGH); // Habilitar driver TB6612
    }

    stop();
}

void MotorDriver::_setMotor(int speed, int pinPwm, int pinIn1, int pinIn2) {
    speed = constrain(speed, -255, 255);

    if (speed > 0) {
        // Avance
        digitalWrite(pinIn1, HIGH);
        digitalWrite(pinIn2, LOW);
        analogWrite(pinPwm, speed);
    } else if (speed < 0) {
        // Retroceso
        digitalWrite(pinIn1, LOW);
        digitalWrite(pinIn2, HIGH);
        analogWrite(pinPwm, -speed);
    } else {
        // Neutro / Detenido
        digitalWrite(pinIn1, LOW);
        digitalWrite(pinIn2, LOW);
        analogWrite(pinPwm, 0);
    }
}

void MotorDriver::setSpeeds(int speedLeft, int speedRight) {
    _setMotor(speedLeft, _pinPwma, _pinAin1, _pinAin2);
    _setMotor(speedRight, _pinPwmb, _pinBin1, _pinBin2);
}

void MotorDriver::stop() {
    setSpeeds(0, 0);
}
