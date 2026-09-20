import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmergencyStopButton extends StatefulWidget {
  final VoidCallback onStop;

  const EmergencyStopButton({
    super.key,
    required this.onStop,
  });

  @override
  State<EmergencyStopButton> createState() => _EmergencyStopButtonState();
}

class _EmergencyStopButtonState extends State<EmergencyStopButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.onStop();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFFB71C1C) : AppTheme.dangerRed,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.dangerRed.withOpacity(_isPressed ? 0.8 : 0.4),
              blurRadius: _isPressed ? 18 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Center(
                child: Icon(Icons.stop_rounded, color: AppTheme.dangerRed, size: 16),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "PARADA DE EMERGENCIA",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
