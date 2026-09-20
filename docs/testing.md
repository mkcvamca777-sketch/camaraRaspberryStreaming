# Procedimiento de Pruebas y Validación (Testing Protocol)

Siga este protocolo riguroso antes de colocar el robot sobre el suelo.

---

## Prueba 1: Validación del Frontend (Modo Simulador)
1. Inicie la aplicación en Android.
2. En la lista de robots, pulse en **"PROBAR"** dentro del recuadro *Modo Simulador Disponible*.
3. Verifique:
   - **Joystick:** El pomo responde al dedo con suavidad y retorna al centro al soltarlo.
   - **Slider de velocidad:** Ajusta el límite de 10% a 100%.
   - **Botón STOP:** Muestra confirmación visual de parada de emergencia al presionarlo.
   - **Push-to-Talk:** El botón pulsa en verde con la leyenda "TRANSMITIENDO VOZ..." mientras se mantiene presionado y vuelve al estado de reposo al soltarlo.
   - **Retícula HUD:** Se muestra el visor de cámara con overlay de telemetría (batería 76%, voltaje, latencia).

---

## Prueba 2: Servidor en Raspberry Pi (Simulación en PC o Pi)
1. En la Raspberry Pi (o en una máquina de desarrollo con Python):
   ```bash
   cd raspberry
   python run_server.py
   ```
2. Verifique la salida en consola:
   ```
   [INFO] Conexión serial abierta en modo Mock Serial por seguridad.
   [INFO] Safety Watchdog iniciado (Timeout: 350ms)
   [INFO] Servidor WebSocket escuchando en ws://0.0.0.0:8765
   ```
3. Desde la app Flutter en el smartphone (conectado a la misma red Wi-Fi):
   - Ingrese la IP local de la Raspberry Pi.
   - Presione **CONTROLAR**.
   - En la consola de la Raspberry se deben observar los paquetes entrantes `drive`, `light`, `ping/pong`.

---

## Prueba 3: Cinemática y Motores con Ruedas en el Aire
> [!CAUTION]
> Coloque el chasis sobre un soporte para que las ruedas motrices no toquen el suelo durante esta prueba.

1. Conecte el microcontrolador por USB a la Raspberry Pi con el firmware cargado.
2. Inicie el servidor de control.
3. Desplace el joystick:
   - **Hacia arriba (Y > 0):** Ambas ruedas deben girar hacia adelante en el mismo sentido.
   - **Hacia abajo (Y < 0):** Ambas ruedas deben girar en reversa.
   - **Hacia la derecha (X > 0):** La rueda izquierda avanza más rápido que la derecha (giro sobre su eje).
   - **Hacia la izquierda (X < 0):** La rueda derecha avanza más rápido que la izquierda.
   - **Soltar:** Ambas ruedas deben frenar inmediatamente a cero.

---

## Prueba 4: Prueba Crítica de Failsafe y Watchdog
Esta prueba verifica que el robot no se convierta en un proyectil descontrolado si se pierde la red:
1. Con las ruedas en el aire, mantenga el joystick en avance continuo a media velocidad.
2. **Apague el Wi-Fi en el smartphone:**
   - La Raspberry Pi debe detectar el cierre del WebSocket en menos de 100 ms y enviar orden de parada por serial.
   - Las ruedas deben detenerse en menos de **350 milisegundos**.
3. **Desconecte físicamente el cable USB entre la Raspberry Pi y el microcontrolador:**
   - El temporizador del firmware del MCU debe vencer en **400 milisegundos** y forzar los pines PWM a cero de inmediato.
