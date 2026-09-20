import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ListenButton extends StatelessWidget {
  final bool isListening;
  final ValueChanged<bool> onToggle;

  const ListenButton({
    super.key,
    required this.isListening,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!isListening),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isListening ? AppTheme.surface : AppTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isListening ? AppTheme.primaryElectric : AppTheme.cardBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isListening ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: isListening ? AppTheme.textPrimary : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              "Escuchar",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isListening ? AppTheme.textPrimary : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
