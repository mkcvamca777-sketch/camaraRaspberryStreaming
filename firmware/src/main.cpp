#include <Arduino.h>
#include <ArduinoJson.h>
#include "motor_driver.h"
#include "kinematics.h"
#include "safety_watchdog.h"

// ==========================================
// ASIGNACIÓN DE PINES (ESP32 / PICO)
// ==========================================
#if defined(ESP32)
  // Pines para ESP32 DevKit V1
  const int PIN_PWMA = 18;
  const int PIN_AIN1 = 19;
  const int PIN_AIN2 = 21;
  const int PIN_PWMB = 22;
  const int PIN_BIN1 = 23;
  const int PIN_BIN2 = 25;
  const int PIN_STBY = 26;
  const int PIN_LIGHT = 2; // LED integrado / Luces
#else
  // Pines estándar para Raspberry Pi Pico / Pico 2 W
  const int PIN_PWMA = 2;
  const int PIN_AIN1 = 3;
  const int PIN_AIN2 = 4;
  const int PIN_PWMB = 5;
  const int PIN_BIN1 = 6;
  const int PIN_BIN2 = 7;
  const int PIN_STBY = 8;
  const int PIN_LIGHT = 25; // LED onboard Pico
#endif

// ==========================================
// INSTANCIAS DE CONTROL
// ==========================================
MotorDriver motorDriver(PIN_PWMA, PIN_AIN1, PIN_AIN2,
                        PIN_PWMB, PIN_BIN1, PIN_BIN2,
                        PIN_STBY);

DifferentialKinematics kinematics(0.05f, 20.0f);

void onWatchdogTimeout() {
    motorDriver.stop();
    kinematics.resetRamp();
    Serial.println("{\"status\":\"watchdog_timeout\",\"motors\":0}");
}

SafetyWatchdog safetyWatchdog(400, onWatchdogTimeout); // 400ms timeout

// ==========================================
// SETUP
// ==========================================
void setup() {
    Serial.begin(115200);
    
    pinMode(PIN_LIGHT, OUTPUT);
    digitalWrite(PIN_LIGHT, LOW);

    motorDriver.begin();
    safetyWatchdog.begin();

    Serial.println("{\"status\":\"ready\",\"firmware\":\"v1.0.0\"}");
}

// ==========================================
// PROCESAMIENTO DE COMANDOS SERIALES
// ==========================================
String inputBuffer = "";

void processCommand(const String& jsonStr) {
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, jsonStr);

    if (error) {
        Serial.print("{\"error\":\"json_invalid\",\"msg\":\"");
        Serial.print(error.c_str());
        Serial.println("\"}");
        return;
    }

    const char* cmd = doc["cmd"] | "";

    if (strcmp(cmd, "drive") == 0) {
        float x = doc["x"] | 0.0f;
        float y = doc["y"] | 0.0f;
        float speedLimit = doc["spd"] | 1.0f;

        // Validar rangos por seguridad antes de actuar
        if (x < -1.0f || x > 1.0f || y < -1.0f || y > 1.0f) {
            motorDriver.stop();
            return;
        }

        // Alimentar watchdog
        safetyWatchdog.feed();

        // Calcular cinemática diferencial con rampas
        int pwmLeft = 0;
        int pwmRight = 0;
        kinematics.compute(x, y, speedLimit, pwmLeft, pwmRight);

        // Aplicar a los motores
        motorDriver.setSpeeds(pwmLeft, pwmRight);

    } else if (strcmp(cmd, "stop") == 0) {
        motorDriver.stop();
        kinematics.resetRamp();
        Serial.println("{\"status\":\"stopped\"}");

    } else if (strcmp(cmd, "light") == 0) {
        int val = doc["val"] | 0;
        digitalWrite(PIN_LIGHT, val ? HIGH : LOW);
    }
}

// ==========================================
// BUCLE PRINCIPAL (LOOP)
// ==========================================
void loop() {
    // 1. Lectura no bloqueante del buffer serial
    while (Serial.available()) {
        char c = (char)Serial.read();
        if (c == '\n') {
            inputBuffer.trim();
            if (inputBuffer.length() > 0) {
                processCommand(inputBuffer);
            }
            inputBuffer = "";
        } else {
            inputBuffer += c;
        }
    }

    // 2. Comprobar periódicamente el watchdog de seguridad
    safetyWatchdog.check();

    delay(10); // Ciclo de muestreo a ~100 Hz
}
