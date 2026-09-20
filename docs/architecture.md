# Arquitectura del Sistema --- Robot Móvil de Telepresencia

Este documento detalla la arquitectura de software y hardware, las capas de comunicación y la distribución de responsabilidades del proyecto.

---

## 1. Principio Fundamental de Diseño

El sistema opera bajo una estricta jerarquía de 3 capas:
1. **Frontend Móvil (Android / Flutter):** Interfaz ergonómica del operador.
2. **Cerebro Multimedia y Red (Raspberry Pi 4):** Lógica de alto nivel, servidor WebSocket, streaming WebRTC y telemetría de sistema.
3. **Controlador Determinista de Tracción (ESP32 o Pico 2 W):** Generación de PWM, gestión de dirección, frenado y Watchdog de seguridad en tiempo real.

```
┌──────────────── SMARTPHONE ANDROID ────────────────┐
│                                                    │
│                  APK FLUTTER                       │
│                                                    │
│  ├── Video                                         │
│  ├── Audio                                         │
│  ├── Joystick                                      │
│  ├── Velocidad                                     │
│  ├── Push-to-Talk                                  │
│  ├── STOP                                          │
│  └── Telemetría                                    │
│                                                    │
│        WebRTC              WebSocket               │
└───────────┬───────────────────┬────────────────────┘
            │                   │
            └──── Wi-Fi / Internet ────┐
                                       │
                                       ▼
┌────────────────────── ROBOT ───────────────────────┐
│                                                   │
│                 Raspberry Pi 4                    │
│                                                   │
│  Cámara ───────────────► WebRTC                   │
│  Micrófono ────────────► WebRTC                   │
│  Altavoz ◄────────────── WebRTC                   │
│  Telemetría ───────────► WebSocket                │
│  Comandos ◄───────────── WebSocket                │
│                                                   │
│                  UART / USB                       │
│                      │                            │
│                      ▼                            │
│              Pico 2 W / ESP32                    │
│                      │                            │
│                Driver motores                     │
│                 │          │                      │
│              Motor L    Motor R                   │
└───────────────────────────────────────────────────┘
```

---

## 2. Red y Protocolos

### A. Canal de Control y Telemetría: WebSocket (`ws://<IP>:8765`)
- Protocolo bidireccional de baja sobrecarga sobre TCP.
- Transporta objetos JSON para:
  - Movimiento (`drive`)
  - Parada inmediata (`stop`)
  - Control de luces (`light`)
  - Orientación de cámara (`camera`)
  - Heartbeat / Ping-Pong (`ping` / `pong` para latencia)
  - Telemetría periódica (`telemetry`: batería, voltaje, RSSI, temperatura).

### B. Canal Multimedia: WebRTC
- Transporte sobre UDP (RTP/SRTP) para latencia ultra-baja (< 150 ms en LAN).
- Video: H.264 o VP8 a 720p / 30 FPS.
- Audio robot -> smartphone: Códec Opus continuo (con control de mute en la app).
- Audio smartphone -> robot: Códec Opus activado exclusivamente mediante Push-to-Talk para mitigar cancelaciones de eco en el robot.

---

## 3. Seguridad de Movimiento (Watchdog Multinivel)

1. **Nivel App:** Al soltar el joystick o salir de la pantalla de conducción, la app envía un paquete de neutro o parada.
2. **Nivel Servidor (Raspberry Pi):** Si se pierde el socket WebSocket durante >350ms, el watchdog de software interviene y ordena parada por UART.
3. **Nivel Firmware (MCU):** Si el cable USB/UART se desconecta o la Raspberry Pi se congela, el temporizador de 400ms del MCU vence y desactiva físicamente todos los pines PWM.
