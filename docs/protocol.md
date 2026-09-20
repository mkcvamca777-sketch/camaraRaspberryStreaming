# Especificación del Protocolo de Comandos y Telemetría

Todos los mensajes transmitidos a través del canal de control WebSocket son objetos JSON codificados en UTF-8.

---

## 1. Comandos del Smartphone hacia la Raspberry Pi

### A. Movimiento Proporcional (`drive`)
Emitido periódicamente mientras el operador mantiene interactuando el joystick virtual.
```json
{
  "type": "drive",
  "x": 0.25,
  "y": 0.80,
  "speedLimit": 0.60
}
```
- `x` *(float)*: Giro entre `-1.0` (izquierda total) y `+1.0` (derecha total).
- `y` *(float)*: Tracción entre `+1.0` (avance total) y `-1.0` (retroceso total).
- `speedLimit` *(float)*: Escalador máximo de potencia permitido por el usuario (entre `0.10` y `1.00`).

### B. Parada Inmediata (`stop`)
Emitido al pulsar el botón STOP, al soltar controles o como failsafe.
```json
{
  "type": "stop"
}
```

### C. Luces Auxiliares (`light`)
```json
{
  "type": "light",
  "value": true
}
```

### D. Cámara Pan/Tilt (`camera`)
```json
{
  "type": "camera",
  "pan": 25.0,
  "tilt": -10.0
}
```
- `pan` *(float)*: Ángulo horizontal entre `-90.0°` y `+90.0°`.
- `tilt` *(float)*: Ángulo vertical entre `-45.0°` y `+45.0°`.

### E. Medición de Latencia (`ping`)
```json
{
  "type": "ping",
  "timestamp": 1774130000000
}
```

---

## 2. Mensajes de la Raspberry Pi hacia el Smartphone

### A. Respuesta de Latencia (`pong`)
```json
{
  "type": "pong"
}
```

### B. Telemetría Periódica (`telemetry`)
Transmitido periódicamente (1 Hz) para informar del estado del hardware:
```json
{
  "type": "telemetry",
  "battery": 76,
  "voltage": 7.62,
  "rssi": -52,
  "latency": 42,
  "temperature": 51.2,
  "status": "online"
}
```
- `battery` *(int)*: Porcentaje restante estimado (`0` a `100`).
- `voltage` *(float)*: Voltaje en bornes de la batería en voltios.
- `rssi` *(int)*: Intensidad de señal Wi-Fi en dBm (`-30` excelente, `-85` crítica).
- `latency` *(int)*: Latencia de ida y vuelta en milisegundos.
- `temperature` *(float)*: Temperatura del SoC de la Raspberry Pi en °C.
- `status` *(string)*: `"online"`, `"moving"`, `"idle"`, `"failsafe"`.

---

## 3. Tramas UART / USB entre Raspberry Pi y Microcontrolador

Las tramas son cadenas ASCII delimitadas por salto de línea `\n`:
- **Comando tracción:** `{"cmd":"drive","x":0.25,"y":0.8,"spd":0.6}\n`
- **Comando parada:** `{"cmd":"stop"}\n`
- **Comando luces:** `{"cmd":"light","val":1}\n`
- **Respuesta de estado:** `{"status":"ready","firmware":"v1.0.0"}\n`
