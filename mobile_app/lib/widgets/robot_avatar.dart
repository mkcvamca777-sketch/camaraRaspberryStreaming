import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RobotAvatar extends StatelessWidget {
  final double size;
  final bool showWifi;

  const RobotAvatar({
    super.key,
    this.size = 120,
    this.showWifi = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RobotPainter(showWifi: showWifi),
      ),
    );
  }
}

class _RobotPainter extends CustomPainter {
  final bool showWifi;

  _RobotPainter({required this.showWifi});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pintar ondas Wi-Fi en la parte superior si está activado
    if (showWifi) {
      final wifiPaint = Paint()
        ..color = AppTheme.primaryElectric.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeCap = StrokeCap.round;

      final wifiCenter = Offset(w * 0.5, h * 0.38);
      
      // Arco superior
      canvas.drawArc(
        Rect.fromCircle(center: wifiCenter, radius: w * 0.32),
        -pi * 0.8,
        pi * 0.6,
        false,
        wifiPaint,
      );

      // Arco intermedio
      canvas.drawArc(
        Rect.fromCircle(center: wifiCenter, radius: w * 0.22),
        -pi * 0.75,
        pi * 0.5,
        false,
        wifiPaint..color = AppTheme.primaryElectric.withOpacity(0.9),
      );

      // Arco inferior
      canvas.drawArc(
        Rect.fromCircle(center: wifiCenter, radius: w * 0.12),
        -pi * 0.7,
        pi * 0.4,
        false,
        wifiPaint..color = AppTheme.primaryElectric,
      );
    }

    final bodyPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final darkPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final cyanPaint = Paint()
      ..color = AppTheme.primaryElectric
      ..style = PaintingStyle.fill;

    final wheelPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final wheelBorder = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;

    // 1. Ruedas (4 ruedas)
    // Rueda delantera izquierda
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.65, w * 0.15, h * 0.26), Radius.circular(w * 0.06)),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.65, w * 0.15, h * 0.26), Radius.circular(w * 0.06)),
      wheelBorder,
    );

    // Rueda delantera derecha
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.73, h * 0.65, w * 0.15, h * 0.26), Radius.circular(w * 0.06)),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.73, h * 0.65, w * 0.15, h * 0.26), Radius.circular(w * 0.06)),
      wheelBorder,
    );

    // Ruedas centrales (cubo interior)
    canvas.drawCircle(Offset(w * 0.20, h * 0.78), w * 0.035, cyanPaint);
    canvas.drawCircle(Offset(w * 0.80, h * 0.78), w * 0.035, cyanPaint);

    // 2. Chasis del Robot
    final chassisRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.58, w * 0.60, h * 0.24),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(chassisRect, bodyPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.64, w * 0.44, h * 0.12), Radius.circular(w * 0.04)),
      darkPaint,
    );

    // Luces delanteras
    canvas.drawCircle(Offset(w * 0.35, h * 0.70), w * 0.035, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.65, h * 0.70), w * 0.035, Paint()..color = Colors.white);

    // 3. Mástil y Cabeza de Cámara
    // Mástil
    canvas.drawRect(Rect.fromLTWH(w * 0.46, h * 0.46, w * 0.08, h * 0.13), darkPaint);

    // Cabeza con cámara
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.32, w * 0.32, h * 0.16),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(headRect, bodyPaint);

    // Pantalla / Lente
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.38, h * 0.35, w * 0.24, h * 0.10),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(screenRect, darkPaint);

    // Lente de la cámara con brillo
    canvas.drawCircle(Offset(w * 0.50, h * 0.40), w * 0.04, cyanPaint);
    canvas.drawCircle(Offset(w * 0.49, h * 0.39), w * 0.015, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
