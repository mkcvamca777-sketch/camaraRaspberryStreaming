import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

typedef OnJoystickMoved = void Function(double x, double y);

class RobotJoystick extends StatefulWidget {
  final double radius;
  final double stickRadius;
  final OnJoystickMoved onMoved;
  final VoidCallback onReleased;

  const RobotJoystick({
    super.key,
    this.radius = 70,
    this.stickRadius = 26,
    required this.onMoved,
    required this.onReleased,
  });

  @override
  State<RobotJoystick> createState() => _RobotJoystickState();
}

class _RobotJoystickState extends State<RobotJoystick> {
  Offset _dragPosition = Offset.zero;
  Timer? _throttleTimer;
  double _lastSentX = 0.0;
  double _lastSentY = 0.0;
  bool _isDragging = false;

  static const double _deadband = 0.05;

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _updateOffset(details.localPosition);
    _startThrottleTimer();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updateOffset(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _throttleTimer?.cancel();
    setState(() {
      _dragPosition = Offset.zero;
    });
    _lastSentX = 0.0;
    _lastSentY = 0.0;
    widget.onMoved(0.0, 0.0);
    widget.onReleased();
  }

  void _updateOffset(Offset localPosition) {
    final center = Offset(widget.radius, widget.radius);
    final delta = localPosition - center;
    final distance = delta.distance;

    final maxDistance = widget.radius - widget.stickRadius;
    Offset clampedOffset;

    if (distance > maxDistance) {
      final angle = atan2(delta.dy, delta.dx);
      clampedOffset = Offset(cos(angle) * maxDistance, sin(angle) * maxDistance);
    } else {
      clampedOffset = delta;
    }

    setState(() {
      _dragPosition = clampedOffset;
    });

    _calculateAndEmit(clampedOffset, maxDistance);
  }

  void _startThrottleTimer() {
    _throttleTimer?.cancel();
    _throttleTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_isDragging) {
        widget.onMoved(_lastSentX, _lastSentY);
      }
    });
  }

  void _calculateAndEmit(Offset offset, double maxDist) {
    // Normalizar entre -1.0 y +1.0
    double rawX = offset.dx / maxDist;
    // Invertir Y: hacia arriba es avance (+1.0), hacia abajo es retroceso (-1.0)
    double rawY = -offset.dy / maxDist;

    // Zona muerta
    if (rawX.abs() < _deadband) rawX = 0.0;
    if (rawY.abs() < _deadband) rawY = 0.0;

    _lastSentX = double.parse(rawX.clamp(-1.0, 1.0).toStringAsFixed(3));
    _lastSentY = double.parse(rawY.clamp(-1.0, 1.0).toStringAsFixed(3));
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0F1A2E),
          border: Border.all(color: AppTheme.cardBorder, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Flecha Arriba (▲)
            Positioned(
              top: 10,
              child: Icon(Icons.arrow_drop_up_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 24),
            ),
            // Flecha Abajo (▼)
            Positioned(
              bottom: 10,
              child: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 24),
            ),
            // Flecha Izquierda (◄)
            Positioned(
              left: 10,
              child: Icon(Icons.arrow_left_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 24),
            ),
            // Flecha Derecha (►)
            Positioned(
              right: 10,
              child: Icon(Icons.arrow_right_rounded, color: AppTheme.textSecondary.withOpacity(0.6), size: 24),
            ),

            // Pomo Central Azul Eléctrico
            Transform.translate(
              offset: _dragPosition,
              child: Container(
                width: widget.stickRadius * 2,
                height: widget.stickRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryElectric,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryElectricGlow.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
