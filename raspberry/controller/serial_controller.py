import json
import logging
import serial
import time
from typing import Optional

logger = logging.getLogger("SerialController")

class SerialController:
    """Gestiona el enlace UART/USB entre la Raspberry Pi y el Microcontrolador (Pico 2 W / ESP32)."""

    def __init__(self, port: str = "/dev/ttyACM0", baudrate: int = 115200, mock_mode: bool = False):
        self.port = port
        self.baudrate = baudrate
        self.mock_mode = mock_mode
        self._serial: Optional[serial.Serial] = None

    def connect(self) -> bool:
        if self.mock_mode:
            logger.info("[MOCK SERIAL] Modo emulador de microcontrolador activo.")
            return True

        try:
            self._serial = serial.Serial(self.port, self.baudrate, timeout=0.1)
            time.sleep(1.0) # Esperar reset de arranque del MCU
            logger.info(f"Conexión serial abierta en {self.port} a {self.baudrate} baudios.")
            return True
        except Exception as e:
            logger.error(f"No se pudo abrir el puerto serial {self.port}: {e}")
            logger.warning("Activando modo Mock Serial por seguridad.")
            self.mock_mode = True
            return True

    def send_drive(self, x: float, y: float, speed_limit: float):
        payload = {
            "cmd": "drive",
            "x": round(float(x), 3),
            "y": round(float(y), 3),
            "spd": round(float(speed_limit), 2)
        }
        self._send_payload(payload)

    def send_stop(self):
        payload = {"cmd": "stop"}
        self._send_payload(payload)

    def send_light(self, enabled: bool):
        payload = {"cmd": "light", "val": 1 if enabled else 0}
        self._send_payload(payload)

    def _send_payload(self, payload: dict):
        line = json.dumps(payload, separators=(',', ':')) + "\n"
        if self.mock_mode:
            logger.debug(f"[MOCK SERIAL TX] -> {line.strip()}")
            return

        if self._serial and self._serial.is_open:
            try:
                self._serial.write(line.encode("ascii"))
                self._serial.flush()
            except Exception as e:
                logger.error(f"Error escribiendo en UART: {e}")
                self.mock_mode = True

    def close(self):
        self.send_stop()
        if self._serial and self._serial.is_open:
            self._serial.close()
            logger.info("Puerto serial cerrado.")
