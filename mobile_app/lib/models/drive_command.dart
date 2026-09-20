class DriveCommand {
  final double x; // Giro entre -1.0 (izquierda) y +1.0 (derecha)
  final double y; // Avance (+1.0) / Retroceso (-1.0)
  final double speedLimit; // Límite de velocidad (0.1 a 1.0)

  const DriveCommand({
    required this.x,
    required this.y,
    required this.speedLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'drive',
      'x': double.parse(x.toStringAsFixed(3)),
      'y': double.parse(y.toStringAsFixed(3)),
      'speedLimit': double.parse(speedLimit.toStringAsFixed(2)),
    };
  }

  static Map<String, dynamic> stopJson() {
    return {
      'type': 'stop',
    };
  }

  static Map<String, dynamic> lightJson(bool enabled) {
    return {
      'type': 'light',
      'value': enabled,
    };
  }

  static Map<String, dynamic> cameraJson(double pan, double tilt) {
    return {
      'type': 'camera',
      'pan': double.parse(pan.toStringAsFixed(1)),
      'tilt': double.parse(tilt.toStringAsFixed(1)),
    };
  }
}
