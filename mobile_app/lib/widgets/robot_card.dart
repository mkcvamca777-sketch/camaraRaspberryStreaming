import 'package:flutter/material.dart';
import '../models/robot.dart';
import '../theme/app_theme.dart';
import 'robot_avatar.dart';

class RobotCard extends StatelessWidget {
  final Robot robot;
  final VoidCallback onTap;

  const RobotCard({
    super.key,
    required this.robot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = robot.telemetry.status;
    final isOnline = status == "online";
    final isWaiting = status == "waiting" || status == "idle";

    Color statusColor;
    String statusText;
    if (isOnline) {
      statusColor = AppTheme.positiveGreen;
      statusText = "En línea";
    } else if (isWaiting) {
      statusColor = AppTheme.warningAmber;
      statusText = "En espera";
    } else {
      statusColor = AppTheme.dangerRed;
      statusText = "Desconectado";
    }

    final hasBattery = isOnline || isWaiting;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder, width: 1.2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Miniatura o ilustración del robot
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder, width: 1),
                ),
                child: const Center(
                  child: RobotAvatar(size: 50, showWifi: false),
                ),
              ),
              const SizedBox(width: 14),

              // Información Central
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del Robot
                    Text(
                      robot.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Estado (● En línea / Desconectado / En espera)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Fila Batería y Wi-Fi
                    Row(
                      children: [
                        if (hasBattery) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.battery_charging_full_rounded, size: 12, color: statusColor),
                                const SizedBox(width: 3),
                                Text(
                                  "${robot.telemetry.battery}%",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wifi_rounded, size: 13, color: AppTheme.textSecondary),
                              const SizedBox(width: 3),
                              Text(
                                "${robot.telemetry.rssi} dBm",
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            "--",
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            "--",
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Flecha Chevron >
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
