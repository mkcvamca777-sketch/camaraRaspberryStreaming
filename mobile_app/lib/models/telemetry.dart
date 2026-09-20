class TelemetryData {
  final int battery;         // Porcentaje 0 - 100
  final double voltage;      // Voltios ej. 7.62V
  final int rssi;            // dBm ej. -52
  final int latency;         // ms ej. 42
  final double temperature;  // Grados Celsius ej. 51.2
  final String status;       // "online", "idle", "moving", "failsafe", "offline"

  const TelemetryData({
    this.battery = 100,
    this.voltage = 8.40,
    this.rssi = -50,
    this.latency = 0,
    this.temperature = 40.0,
    this.status = "offline",
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      battery: (json['battery'] as num?)?.toInt() ?? 0,
      voltage: (json['voltage'] as num?)?.toDouble() ?? 0.0,
      rssi: (json['rssi'] as num?)?.toInt() ?? -99,
      latency: (json['latency'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] as String?) ?? "unknown",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'telemetry',
      'battery': battery,
      'voltage': voltage,
      'rssi': rssi,
      'latency': latency,
      'temperature': temperature,
      'status': status,
    };
  }

  TelemetryData copyWith({
    int? battery,
    double? voltage,
    int? rssi,
    int? latency,
    double? temperature,
    String? status,
  }) {
    return TelemetryData(
      battery: battery ?? this.battery,
      voltage: voltage ?? this.voltage,
      rssi: rssi ?? this.rssi,
      latency: latency ?? this.latency,
      temperature: temperature ?? this.temperature,
      status: status ?? this.status,
    );
  }
}
