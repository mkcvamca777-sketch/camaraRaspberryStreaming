import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/drive_command.dart';
import '../models/telemetry.dart';

enum WsConnectionState { disconnected, connecting, connected, error }

class WebSocketService {
  WebSocketChannel? _channel;
  WsConnectionState _connectionState = WsConnectionState.disconnected;
  
  final _stateController = StreamController<WsConnectionState>.broadcast();
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  
  Stream<WsConnectionState> get stateStream => _stateController.stream;
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  WsConnectionState get connectionState => _connectionState;
  
  String? _currentUrl;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _lastPingTimestamp = 0;
  int _currentLatency = 0;
  bool _shouldReconnect = true;

  int get currentLatency => _currentLatency;

  void connect(String host, int port) {
    _shouldReconnect = true;
    _currentUrl = 'ws://$host:$port';
    _initConnection();
  }

  void _initConnection() {
    if (_currentUrl == null) return;
    _updateState(WsConnectionState.connecting);

    try {
      final uri = Uri.parse(_currentUrl!);
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (dynamic message) {
          if (_connectionState != WsConnectionState.connected) {
            _updateState(WsConnectionState.connected);
            _startPingTimer();
          }
          _handleIncomingMessage(message);
        },
        onError: (error) {
          debugPrint("[WebSocket] Error: $error");
          _handleDisconnect();
        },
        onDone: () {
          debugPrint("[WebSocket] Conexión cerrada");
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("[WebSocket] Excepción al conectar: $e");
      _handleDisconnect();
    }
  }

  void _handleIncomingMessage(dynamic raw) {
    try {
      final Map<String, dynamic> data = jsonDecode(raw.toString());
      final type = data['type'] as String?;

      if (type == 'telemetry') {
        final telemetry = TelemetryData.fromJson(data);
        // Anexar la latencia medida si el servidor no la reporta
        final finalTelemetry = telemetry.copyWith(
          latency: _currentLatency > 0 ? _currentLatency : telemetry.latency,
        );
        _telemetryController.add(finalTelemetry);
      } else if (type == 'pong') {
        final now = DateTime.now().millisecondsSinceEpoch;
        _currentLatency = now - _lastPingTimestamp;
      }
    } catch (e) {
      debugPrint("[WebSocket] Error decodificando payload: $e");
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_connectionState == WsConnectionState.connected) {
        _lastPingTimestamp = DateTime.now().millisecondsSinceEpoch;
        sendRaw({'type': 'ping', 'timestamp': _lastPingTimestamp});
      }
    });
  }

  void sendDrive(DriveCommand cmd) {
    if (_connectionState == WsConnectionState.connected) {
      sendRaw(cmd.toJson());
    }
  }

  void sendStop() {
    sendRaw(DriveCommand.stopJson());
  }

  void sendLight(bool enabled) {
    sendRaw(DriveCommand.lightJson(enabled));
  }

  void sendCameraPanTilt(double pan, double tilt) {
    sendRaw(DriveCommand.cameraJson(pan, tilt));
  }

  void sendRaw(Map<String, dynamic> payload) {
    if (_channel != null && _connectionState == WsConnectionState.connected) {
      try {
        _channel!.sink.add(jsonEncode(payload));
      } catch (e) {
        debugPrint("[WebSocket] Error enviando paquete: $e");
      }
    }
  }

  void _handleDisconnect() {
    _pingTimer?.cancel();
    _updateState(WsConnectionState.disconnected);

    if (_shouldReconnect) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 2), () {
        if (_shouldReconnect && _connectionState != WsConnectionState.connected) {
          debugPrint("[WebSocket] Reintentando conexión...");
          _initConnection();
        }
      });
    }
  }

  void _updateState(WsConnectionState state) {
    _connectionState = state;
    _stateController.add(state);
  }

  void disconnect() {
    _shouldReconnect = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    sendStop(); // Intentar parada previa al corte
    _channel?.sink.close();
    _channel = null;
    _updateState(WsConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _telemetryController.close();
  }
}
