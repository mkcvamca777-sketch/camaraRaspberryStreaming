import 'package:flutter/material.dart';
import '../models/telemetry.dart';
import '../theme/app_theme.dart';

class RobotStatusBar extends StatelessWidget {
  final String robotName;
  final bool isOnline;
  final TelemetryData telemetry;
  final bool lightActive;
  final VoidCallback onBack;
  final VoidCallback onToggleLight;
  final VoidCallback onOpenSettings;
  final VoidCallback onCameraAction;

  const RobotStatusBar({
    super.key,
    required this.robotName,
    required this.isOnline,
    required this.telemetry,
    required this.lightActive,
    required this.onBack,
    required this.onToggleLight,
    required this.onOpenSettings,
    required this.onCameraAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: AppTheme.background,
      child: Row(
        children: [
          // Botón volver < ROBOT-01
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 16),
                const SizedBox(width: 8),
                Text(
                  robotName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Estado: Punto verde + "En línea"
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.positiveGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.positiveGreenGlow,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "En línea",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.positiveGreen,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Indicador de Batería (Badge Verde [🔋 76%])
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.positiveGreen.withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.positiveGreen.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.battery_charging_full_rounded, color: AppTheme.positiveGreen, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${telemetry.battery}%",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.positiveGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Latencia / Wi-Fi (📶 42 ms)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_rounded, color: AppTheme.primaryElectric, size: 15),
              const SizedBox(width: 4),
              Text(
                "${telemetry.latency} ms",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Iconos de la derecha: Captura 📷, Luces 💡, Configuración ⚙
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.textPrimary, size: 20),
            tooltip: "Captura de cámara",
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
            onPressed: onCameraAction,
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              lightActive ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
              color: lightActive ? AppTheme.warningAmber : AppTheme.textPrimary,
              size: 20,
            ),
            tooltip: "Luces",
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
            onPressed: onToggleLight,
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary, size: 20),
            tooltip: "Ajustes",
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
            onPressed: onOpenSettings,
          ),
        ],
      ),
    );
  }
}
