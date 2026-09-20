# Robot Móvil de Telepresencia

Sistema integral de robótica de telepresencia con control remoto desde una aplicación Android (Flutter), servidor central multimedia en Raspberry Pi 4 (WebRTC + WebSocket) y controlador en tiempo real de tracción y seguridad en microcontrolador (ESP32 / Raspberry Pi Pico 2 W).

---

## Estructura del Repositorio

```
.
├── mobile_app/                  # Aplicación Flutter para Android
│   ├── lib/                     # Código modular (main, screens, widgets, services, models)
│   ├── android/                 # Proyecto nativo Android configurado para WebRTC
│   └── pubspec.yaml             # Dependencias
│
├── raspberry/                   # Software central para Raspberry Pi 4 (Python)
│   ├── run_server.py            # Servidor principal
│   ├── communication/           # Servidor WebSocket y validación de comandos
│   ├── safety/                  # Watchdog y failsafe de desconexión
│   ├── controller/              # Enlace UART/USB serial hacia el MCU
│   ├── telemetry/               # Monitor de batería y salud del sistema
│   ├── config.json              # Configuración de red y puertos
│   └── requirements.txt         # Dependencias Python
│
├── firmware/                    # Firmware de tracción para ESP32 / Pico 2 W
│   ├── platformio.ini           # Configuración PlatformIO
│   └── src/                     # Código C++ (Cinemática diferencial, PWM, Watchdog)
│
├── docs/                        # Documentación técnica completa
│   ├── apk_build_guide.md       # Guía paso a paso para generar la APK
│   ├── architecture.md          # Arquitectura de capas y flujos
│   ├── protocol.md              # Especificación del protocolo JSON
│   ├── wiring.md                # Diagrama de conexiones pin a pin
│   ├── power.md                 # Guía de alimentación y baterías
│   ├── testing.md               # Procedimiento de pruebas fase por fase
│   └── troubleshooting.md       # Diagnóstico de problemas
│
├── .github/workflows/           # CI/CD en la nube
│   └── build_apk.yml            # Compilación automática de la APK en GitHub
│
└── scripts/
    └── build_apk.ps1            # Script de compilación local en Windows
```

---

## 🚀 Inicio Rápido

### 1. ¿Cómo compilar la APK de Android?
Consulta la [Guía de Compilación de APK](docs/apk_build_guide.md):
- **Opción A (Recomendada en la Nube):** Sube este proyecto a tu GitHub y la APK se compilará automáticamente en minutos mediante GitHub Actions (se descarga el `.apk` listo).
- **Opción B (Local):** Si tienes Flutter instalado en Windows, ejecuta:
  ```powershell
  .\scripts\build_apk.ps1 -Mode release
  ```

### 2. ¿Cómo probar la APK inmediatamente (Modo Simulador)?
La aplicación incluye un **Modo Simulador** integrado:
1. Abre la app en tu teléfono Android.
2. En la lista de robots, toca el botón **"PROBAR"** dentro del recuadro *Modo Simulador Disponible*.
3. Podrás interactuar en pantalla horizontal con el **Joystick virtual**, el **Slider de velocidad**, el botón de **Parada de Emergencia (STOP)**, el **Push-to-Talk (PTT)** y observar los indicadores de batería y telemetría sin depender del hardware físico.

### 3. ¿Cómo iniciar el Servidor en Raspberry Pi?
```bash
cd raspberry
pip install -r requirements.txt
python run_server.py
```

### 4. ¿Cómo flashear el Microcontrolador?
Abre la carpeta `firmware/` en VS Code con la extensión **PlatformIO** y haz clic en **Upload** (soporta ESP32 y Raspberry Pi Pico 2 W).
