import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

enum RtcState { disconnected, connecting, connected, failed }

class WebRtcService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  RtcState _state = RtcState.disconnected;
  final _stateController = StreamController<RtcState>.broadcast();
  Stream<RtcState> get stateStream => _stateController.stream;
  RtcState get state => _state;

  bool _isListening = true;
  bool _isSpeaking = false; // Push-to-Talk activo
  bool _isInitialized = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  final Map<String, dynamic> _rtcConfiguration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  Future<void> initialize() async {
    if (_isInitialized) return;
    await remoteRenderer.initialize();
    _isInitialized = true;
  }

  Future<void> startSession(String host, int signalingPort) async {
    await initialize();
    _updateState(RtcState.connecting);

    try {
      _peerConnection = await createPeerConnection(_rtcConfiguration);

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState iceState) {
        debugPrint("[WebRTC] ICE State: $iceState");
        if (iceState == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _updateState(RtcState.connected);
        } else if (iceState == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                   iceState == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          _updateState(RtcState.failed);
        }
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'video') {
          remoteRenderer.srcObject = event.streams[0];
        }
      };

      // Inicializar recepción de audio / video
      // El pipeline de señalización se coordinará vía HTTP o WebSocket signaling
      debugPrint("[WebRTC] PeerConnection preparado para señalización con $host:$signalingPort");
      _updateState(RtcState.connected);
    } catch (e) {
      debugPrint("[WebRTC] Error iniciando sesión: $e");
      _updateState(RtcState.failed);
    }
  }

  void toggleListen(bool enabled) {
    _isListening = enabled;
    if (_peerConnection != null) {
      // Activar / silenciar las pistas de audio remotas
      final receivers = _peerConnection!.getReceivers();
      receivers.then((list) {
        for (var r in list) {
          if (r.track?.kind == 'audio') {
            r.track?.enabled = enabled;
          }
        }
      });
    }
  }

  Future<void> setPushToTalk(bool active) async {
    _isSpeaking = active;
    try {
      if (active) {
        // Habilitar captura de micrófono
        if (_localStream == null) {
          final mediaConstraints = <String, dynamic>{
            'audio': true,
            'video': false,
          };
          _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
          _localStream?.getAudioTracks().forEach((track) {
            _peerConnection?.addTrack(track, _localStream!);
          });
        }
        _localStream?.getAudioTracks().forEach((track) {
          track.enabled = true;
        });
      } else {
        // Silenciar inmediatamente al soltar
        _localStream?.getAudioTracks().forEach((track) {
          track.enabled = false;
        });
      }
    } catch (e) {
      debugPrint("[WebRTC PTT] Error manipulando micrófono: $e");
    }
  }

  void _updateState(RtcState state) {
    _state = state;
    _stateController.add(state);
  }

  Future<void> dispose() async {
    _stateController.close();
    await _localStream?.dispose();
    await _peerConnection?.close();
    await remoteRenderer.dispose();
  }
}
