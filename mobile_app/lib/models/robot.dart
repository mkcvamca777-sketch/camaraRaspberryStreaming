import 'telemetry.dart';

class Robot {
  final String id;
  final String name;
  final String host;
  final int wsPort;
  final int rtcPort;
  final bool isOnline;
  final TelemetryData telemetry;

  const Robot({
    required this.id,
    required this.name,
    required this.host,
    this.wsPort = 8765,
    this.rtcPort = 8080,
    this.isOnline = false,
    this.telemetry = const TelemetryData(),
  });

  Robot copyWith({
    String? id,
    String? name,
    String? host,
    int? wsPort,
    int? rtcPort,
    bool? isOnline,
    TelemetryData? telemetry,
  }) {
    return Robot(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      wsPort: wsPort ?? this.wsPort,
      rtcPort: rtcPort ?? this.rtcPort,
      isOnline: isOnline ?? this.isOnline,
      telemetry: telemetry ?? this.telemetry,
    );
  }
}
