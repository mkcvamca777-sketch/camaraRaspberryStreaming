import logging

logger = logging.getLogger("ProtocolValidator")

class ProtocolValidator:
    """Valida tramas y rangos de datos entrantes desde el cliente WebSocket."""

    @staticmethod
    def validate_command(data: dict) -> tuple[bool, str]:
        if not isinstance(data, dict):
            return False, "Payload debe ser un objeto JSON"

        cmd_type = data.get("type")
        if not cmd_type:
            return False, "Falta el campo 'type'"

        if cmd_type == "drive":
            x = data.get("x")
            y = data.get("y")
            speed = data.get("speedLimit", 1.0)

            if not isinstance(x, (int, float)) or not (-1.0 <= x <= 1.0):
                return False, f"Valor inválido para 'x': {x}"
            if not isinstance(y, (int, float)) or not (-1.0 <= y <= 1.0):
                return False, f"Valor inválido para 'y': {y}"
            if not isinstance(speed, (int, float)) or not (0.0 <= speed <= 1.0):
                return False, f"Valor inválido para 'speedLimit': {speed}"

            return True, "OK"

        elif cmd_type == "stop":
            return True, "OK"

        elif cmd_type == "light":
            val = data.get("value")
            if not isinstance(val, bool):
                return False, "Campo 'value' en 'light' debe ser booleano"
            return True, "OK"

        elif cmd_type == "camera":
            pan = data.get("pan", 0)
            tilt = data.get("tilt", 0)
            if not isinstance(pan, (int, float)) or not (-90 <= pan <= 90):
                return False, f"Valor inválido para 'pan': {pan}"
            if not isinstance(tilt, (int, float)) or not (-45 <= tilt <= 45):
                return False, f"Valor inválido para 'tilt': {tilt}"
            return True, "OK"

        elif cmd_type == "ping":
            return True, "OK"

        else:
            return False, f"Comando desconocido: {cmd_type}"
