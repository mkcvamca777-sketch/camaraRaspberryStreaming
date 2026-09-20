import asyncio
import json
import logging
import websockets
from websockets.server import WebSocketServerProtocol
from communication.protocol_validator import ProtocolValidator
from controller.serial_controller import SerialController
from safety.heartbeat_watchdog import HeartbeatWatchdog
from telemetry.telemetry_manager import TelemetryManager

logger = logging.getLogger("WebSocketServer")

class RobotWebSocketServer:
    def __init__(
        self,
        host: str,
        port: int,
        serial_controller: SerialController,
        watchdog: HeartbeatWatchdog,
        telemetry_manager: TelemetryManager
    ):
        self.host = host
        self.port = port
        self.serial = serial_controller
        self.watchdog = watchdog
        self.telemetry = telemetry_manager
        self.connected_clients = set()
        self._server = None
        self._telemetry_task = None

    async def start(self):
        self._server = await websockets.serve(self._handle_client, self.host, self.port)
        self._telemetry_task = asyncio.create_task(self._telemetry_broadcast_loop())
        logger.info(f"Servidor WebSocket escuchando en ws://{self.host}:{self.port}")

    async def _handle_client(self, websocket: WebSocketServerProtocol):
        client_addr = websocket.remote_address
        logger.info(f"Cliente móvil conectado: {client_addr}")
        self.connected_clients.add(websocket)

        try:
            async for message in websocket:
                await self._process_message(websocket, message)
        except websockets.ConnectionClosed:
            logger.warning(f"Cliente desconectado: {client_addr}")
        except Exception as e:
            logger.error(f"Error en comunicación con cliente: {e}")
        finally:
            self.connected_clients.discard(websocket)
            logger.info("Failsafe: Activando parada de motores por desconexión de control.")
            self.watchdog.force_stop()
            self.serial.send_stop()

    async def _process_message(self, websocket: WebSocketServerProtocol, raw_message: str):
        try:
            data = json.loads(raw_message)
        except json.JSONDecodeError:
            logger.warning(f"Mensaje JSON no válido recibido: {raw_message}")
            return

        is_valid, reason = ProtocolValidator.validate_command(data)
        if not is_valid:
            logger.warning(f"Comando rechazado por validación: {reason} | {data}")
            return

        cmd_type = data["type"]

        if cmd_type == "drive":
            x = data["x"]
            y = data["y"]
            speed_limit = data.get("speedLimit", 1.0)
            is_moving = (abs(x) > 0.05 or abs(y) > 0.05)

            # Alimentar el watchdog de seguridad
            self.watchdog.feed(moving=is_moving)

            # Enviar hacia el MCU
            self.serial.send_drive(x, y, speed_limit)

        elif cmd_type == "stop":
            logger.info("Comando STOP recibido. Frenado inmediato.")
            self.watchdog.force_stop()
            self.serial.send_stop()

        elif cmd_type == "light":
            enabled = data["value"]
            logger.info(f"Comando Luz: {enabled}")
            self.serial.send_light(enabled)

        elif cmd_type == "camera":
            pan = data.get("pan", 0)
            tilt = data.get("tilt", 0)
            logger.info(f"Comando Cámara Pan: {pan}, Tilt: {tilt}")

        elif cmd_type == "ping":
            # Responder inmediatamente con Pong para cálculo de latencia de red
            await websocket.send(json.dumps({"type": "pong"}))

    async def _telemetry_broadcast_loop(self):
        while True:
            await asyncio.sleep(1.0)
            if not self.connected_clients:
                continue

            packet = self.telemetry.get_telemetry_packet(
                status="moving" if self.watchdog._is_moving else "online"
            )
            payload = json.dumps(packet)

            # Enviar a todos los clientes conectados
            tasks = [asyncio.create_task(ws.send(payload)) for ws in list(self.connected_clients)]
            if tasks:
                await asyncio.gather(*tasks, return_exceptions=True)

    async def stop(self):
        if self._telemetry_task:
            self._telemetry_task.cancel()
        if self._server:
            self._server.close()
            await self._server.wait_closed()
        logger.info("Servidor WebSocket detenido.")
