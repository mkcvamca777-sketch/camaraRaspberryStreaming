#ifndef MOTOR_DRIVER_H
#define MOTOR_DRIVER_H

#include <Arduino.h>

class MotorDriver {
public:
    // Configuración para TB6612FNG o L298N
    MotorDriver(int pinPwma, int pinAin1, int pinAin2,
                int pinPwmb, int pinBin1, int pinBin2,
                int pinStby = -1);

    void begin();
    
    // speedLeft y speedRight entre -255 (retroceso máximo) y +255 (avance máximo)
    void setSpeeds(int speedLeft, int speedRight);
    
    // Parada inmediata (freno / neutro seguro)
    void stop();

private:
    int _pinPwma, _pinAin1, _pinAin2;
    int _pinPwmb, _pinBin1, _pinBin2;
    int _pinStby;

    void _setMotor(int speed, int pinPwm, int pinIn1, int pinIn2);
};

#endif // MOTOR_DRIVER_H
