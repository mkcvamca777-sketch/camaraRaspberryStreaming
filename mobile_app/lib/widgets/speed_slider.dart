import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedSlider extends StatelessWidget {
  final double speedLimit;
  final ValueChanged<double> onChanged;
  final bool vertical;

  const SpeedSlider({
    super.key,
    required this.speedLimit,
    required this.onChanged,
    this.vertical = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (speedLimit * 100).round();

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Velocidad",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 125,
            child: RotatedBox(
              quarterTurns: 3, // Orientación vertical
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: AppTheme.primaryElectric,
                  inactiveTrackColor: const Color(0xFF16253F),
                  thumbColor: AppTheme.primaryElectric,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                  overlayColor: AppTheme.primaryElectric.withOpacity(0.2),
                ),
                child: Slider(
                  value: speedLimit,
                  min: 0.10,
                  max: 1.00,
                  divisions: 18,
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$percentage%",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      );
    }

    // Versión horizontal de respaldo
    return Row(
      children: [
        const Text(
          "Velocidad:",
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        Expanded(
          child: Slider(
            value: speedLimit,
            min: 0.10,
            max: 1.00,
            divisions: 18,
            activeColor: AppTheme.primaryElectric,
            inactiveColor: const Color(0xFF16253F),
            onChanged: onChanged,
          ),
        ),
        Text(
          "$percentage%",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
      ],
    );
  }
}
