import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/telemetry.dart';

class TelemetryService extends ChangeNotifier {
  TelemetryData _currentData = const TelemetryData();
  final List<int> _latencyHistory = [];

  TelemetryData get currentData => _currentData;
  List<int> get latencyHistory => List.unmodifiable(_latencyHistory);

  void updateTelemetry(TelemetryData data) {
    _currentData = data;
    
    // Registrar historial para métricas de latencia
    if (data.latency > 0) {
      _latencyHistory.add(data.latency);
      if (_latencyHistory.length > 30) {
        _latencyHistory.removeAt(0);
      }
    }
    
    notifyListeners();
  }

  int get averageLatency {
    if (_latencyHistory.isEmpty) return _currentData.latency;
    final sum = _latencyHistory.reduce((a, b) => a + b);
    return (sum / _latencyHistory.length).round();
  }

  // Calidad estimada de conexión Wi-Fi según RSSI (dBm)
  String get connectionQuality {
    final rssi = _currentData.rssi;
    if (rssi >= -55) return "Excelente";
    if (rssi >= -67) return "Buena";
    if (rssi >= -80) return "Regular";
    return "Débil";
  }
}
