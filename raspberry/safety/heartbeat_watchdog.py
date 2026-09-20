import time
import asyncio
import logging
from typing import Callable

logger = logging.getLogger("SafetyWatchdog")

class HeartbeatWatchdog:
    """Watchdog de software en Raspberry Pi para parada automática ante pérdida de enlace."""

    def __init__(self, timeout_ms: int = 350, on_timeout_stop: Callable[[], None] = None):
        self.timeout_sec = timeout_ms / 1000.0
        self.on_timeout_stop = on_timeout_stop
        self._last_heartbeat = time.time()
        self._is_active = False
        self._is_moving = False
        self._task = None

    def start(self):
        self._is_active = True
        self._last_heartbeat = time.time()
        self._task = asyncio.create_task(self._monitor_loop())
        logger.info(f"Safety Watchdog iniciado (Timeout: {int(self.timeout_sec * 1000)}ms)")

    def feed(self, moving: bool = True):
        """Refresca el watchdog indicando que la conexión y el comando están vivos."""
        self._last_heartbeat = time.time()
        self._is_moving = moving

    def force_stop(self):
        self._is_moving = False
        if self.on_timeout_stop:
            self.on_timeout_stop()

    async def _monitor_loop(self):
        while self._is_active:
            await asyncio.sleep(0.05) # Chequeo a 20Hz
            now = time.time()
            elapsed = now - self._last_heartbeat

            if self._is_moving and elapsed > self.timeout_sec:
                logger.warning(f"¡TIMEOUT DE MOVIMIENTO ({int(elapsed*1000)}ms)! Activando parada de emergencia.")
                self._is_moving = False
                if self.on_timeout_stop:
                    self.on_timeout_stop()

    def stop(self):
        self._is_active = False
        if self._task:
            self._task.cancel()
