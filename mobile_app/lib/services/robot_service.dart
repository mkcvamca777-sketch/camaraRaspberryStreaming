import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/drive_command.dart';
import '../models/robot.dart';
import '../models/telemetry.dart';
import 'telemetry_service.dart';
import 'webrtc_service.dart';
import 'websocket_service.dart';

class RobotService extends ChangeNotifier {
  final WebSocketService wsService = WebSocketService();
  final WebRtcService rtcService = WebRtcService();
  final TelemetryService telemetryService = TelemetryService();

  Robot? _activeRobot;
  double _currentSpeedLimit = 0.60; // 60% por defecto
  bool _lightEnabled = false;
  bool _isMockMode = false;
  Timer? _mockTimer;

  Robot? get activeRobot => _activeRobot;
  double get currentSpeedLimit => _currentSpeedLimit;
  bool get lightEnabled => _lightEnabled;
  bool get isMockMode => _isMockMode;
  bool get isConnected => _isMockMode || wsService.connectionState == WsConnectionState.connected;

  RobotService() {
    // Escuchar telemetría del WebSocket real
    wsService.telemetryStream.listen((data) {
      if (!_isMockMode) {
        telemetryService.updateTelemetry(data);
      }
    });

    wsService.stateStream.listen((state) {
      notifyListeners();
    });
  }

  void setActiveRobot(Robot robot, {bool mockMode = false}) {
    _activeRobot = robot;
    _isMockMode = mockMode;

    if (_isMockMode) {
      _startMockTelemetry();
      notifyListeners();
    } else {
      _mockTimer?.cancel();
      wsService.connect(robot.host, robot.wsPort);
      rtcService.startSession(robot.host, robot.rtcPort);
    }
  }

  void setSpeedLimit(double limit) {
    _currentSpeedLimit = limit.clamp(0.1, 1.0);
    notifyListeners();
  }

  void drive(double x, double y) {
    final cmd = DriveCommand(
      x: x,
      y: y,
      speedLimit: _currentSpeedLimit,
    );

    if (_isMockMode) {
      debugPrint("[MOCK DRIVE] x: ${cmd.x}, y: ${cmd.y}, speed: ${cmd.speedLimit}");
    } else {
      wsService.sendDrive(cmd);
    }
  }

  void stop() {
    if (_isMockMode) {
      debugPrint("[MOCK STOP] Frenado de emergencia activado.");
    } else {
      wsService.sendStop();
    }
  }

  void toggleLight() {
    _lightEnabled = !_lightEnabled;
    if (_isMockMode) {
      debugPrint("[MOCK LIGHT] Luces: $_lightEnabled");
    } else {
      wsService.sendLight(_lightEnabled);
    }
    notifyListeners();
  }

  void disconnect() {
    _mockTimer?.cancel();
    wsService.disconnect();
    rtcService.dispose();
    _activeRobot = null;
    notifyListeners();
  }

  void _startMockTelemetry() {
    _mockTimer?.cancel();
    // Simulación según especificaciones del Prompt Maestro:
    // Batería 76%, Voltaje 7.62V, RSSI -52dBm, Latencia 42ms, Temp 51.2°C
    telemetryService.updateTelemetry(const TelemetryData(
      battery: 76,
      voltage: 7.62,
      rssi: -52,
      latency: 42,
      temperature: 51.2,
      status: "online",
    ));

    _mockTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final current = telemetryService.currentData;
      // Fluctuación leve realista
      final jitterLatency = 38 + (timer.tick % 8);
      telemetryService.updateTelemetry(current.copyWith(
        latency: jitterLatency,
        status: "online",
      ));
    });
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    wsService.dispose();
    rtcService.dispose();
    super.dispose();
  }
}
