import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../models/telemetry.dart';
import '../services/webrtc_service.dart';
import '../theme/app_theme.dart';

class RobotVideoView extends StatefulWidget {
  final WebRtcService rtcService;
  final bool isMockMode;
  final TelemetryData telemetry;

  const RobotVideoView({
    super.key,
    required this.rtcService,
    required this.isMockMode,
    required this.telemetry,
  });

  @override
  State<RobotVideoView> createState() => _RobotVideoViewState();
}

class _RobotVideoViewState extends State<RobotVideoView> {
  bool _isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    final hasActiveVideo = !widget.isMockMode && widget.rtcService.state == RtcState.connected;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder, width: 1.2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video WebRTC o Stream Realista Simulador
            if (hasActiveVideo)
              RTCVideoView(
                widget.rtcService.remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: false,
              )
            else
              _buildSimulatedCameraFeed(),

            // Badge Superior Izquierdo: HD
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: const Text(
                  "HD",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Botón Superior Derecho: Pantalla Completa [ ⛶ ]
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _isFullscreen = !_isFullscreen);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatedCameraFeed() {
    // Fondo de salón interior moderno simulando la cámara del robot (idéntico al mockup)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _RoomPerspectivePainter(),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded, size: 16, color: AppTheme.primaryElectric),
                  SizedBox(width: 6),
                  Text(
                    "CÁMARA DEL ROBOT (STREAMING)",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomPerspectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Suelo con líneas de perspectiva de madera
    final floorPaint = Paint()..color = const Color(0xFF1E222B);
    final floorPath = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(floorPath, floorPaint);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 8; i++) {
      canvas.drawLine(
        Offset(w * 0.5, h * 0.55),
        Offset(w * (i / 8.0), h),
        linePaint,
      );
    }

    // Ventana al fondo
    final windowPaint = Paint()..color = const Color(0xFF64748B).withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.15, w * 0.20, h * 0.40), windowPaint);

    final framePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.15, w * 0.20, h * 0.40), framePaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.15), Offset(w * 0.50, h * 0.55), framePaint);
    canvas.drawLine(Offset(w * 0.40, h * 0.35), Offset(w * 0.60, h * 0.35), framePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
