#!/usr/bin/env python3
"""
Servidor Central del Robot Móvil de Telepresencia (Raspberry Pi 4)
Integra comunicación WebSocket, Telemetría, Watchdog de Seguridad y Enlace Serial con MCU.
"""

import os
import sys
import json
import signal
import asyncio
import logging

# Añadir directorio base al path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
if BASE_DIR not in sys.path:
    sys.path.insert(0, BASE_DIR)

from communication.websocket_server import RobotWebSocketServer
from controller.serial_controller import SerialController
from safety.heartbeat_watchdog import HeartbeatWatchdog
from telemetry.telemetry_manager import TelemetryManager

# Configurar logging con formato legible
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] (%(name)s) %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger("MainRobotServer")

def load_config():
    config_path = os.path.join(BASE_DIR, "config.json")
    if os.path.exists(config_path):
        with open(config_path, "r") as f:
            return json.load(f)
    return {}

async def main():
    config = load_config()

    server_cfg = config.get("server", {})
    serial_cfg = config.get("serial", {})
    safety_cfg = config.get("safety", {})
    telemetry_cfg = config.get("telemetry", {})

    host = server_cfg.get("host", "0.0.0.0")
    ws_port = server_cfg.get("ws_port", 8765)

    logger.info("==================================================")
    logger.info("  ROBOT TELEPRESENCIA - SERVIDOR RASPBERRY PI 4   ")
    logger.info("==================================================")

    # 1. Inicializar Enlace Serial con MCU
    serial_ctrl = SerialController(
        port=serial_cfg.get("port", "/dev/ttyACM0"),
        baudrate=serial_cfg.get("baudrate", 115200),
        mock_mode=serial_cfg.get("mock_mode", True)
    )
    serial_ctrl.connect()

    # 2. Inicializar Watchdog de Seguridad
    watchdog = HeartbeatWatchdog(
        timeout_ms=safety_cfg.get("heartbeat_timeout_ms", 350),
        on_timeout_stop=lambda: serial_ctrl.send_stop()
    )
    watchdog.start()

    # 3. Inicializar Gestor de Telemetría
    telemetry_mgr = TelemetryManager(
        i2c_bus=telemetry_cfg.get("i2c_bus", 1),
        ina_address=telemetry_cfg.get("ina219_address", "0x40")
    )

    # 4. Inicializar Servidor WebSocket
    ws_server = RobotWebSocketServer(
        host=host,
        port=ws_port,
        serial_controller=serial_ctrl,
        watchdog=watchdog,
        telemetry_manager=telemetry_mgr
    )
    await ws_server.start()

    # Manejar señales de terminación del sistema (Ctrl+C o SIGTERM)
    stop_event = asyncio.Event()

    def shutdown():
        logger.info("Señal de apagado recibida. Deteniendo sistema...")
        serial_ctrl.send_stop()
        watchdog.stop()
        serial_ctrl.close()
        stop_event.set()

    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        try:
            loop.add_signal_handler(sig, shutdown)
        except NotImplementedError:
            # En Windows add_signal_handler no siempre está disponible
            pass

    logger.info(f"Sistema listo para recibir conexiones desde la APK en ws://<IP-RASPBERRY>:{ws_port}")
    
    try:
        await stop_event.wait()
    except (asyncio.CancelledError, KeyboardInterrupt):
        shutdown()
    finally:
        await ws_server.stop()
        logger.info("Servidor finalizado limpiamente.")

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
