import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/robot.dart';
import '../services/robot_service.dart';
import '../theme/app_theme.dart';
import '../widgets/emergency_stop_button.dart';
import '../widgets/listen_button.dart';
import '../widgets/push_to_talk_button.dart';
import '../widgets/robot_joystick.dart';
import '../widgets/robot_status_bar.dart';
import '../widgets/robot_video_view.dart';
import '../widgets/speed_slider.dart';
import 'settings_screen.dart';

class ControlScreen extends StatefulWidget {
  final Robot robot;

  const ControlScreen({
    super.key,
    required this.robot,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool _isListening = true;

  @override
  void initState() {
    super.initState();
    // Forzar orientación horizontal para conducción telepresencial
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restaurar orientaciones al salir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _handleExit() {
    final robotService = Provider.of<RobotService>(context, listen: false);
    robotService.stop(); // Failsafe inmediato al salir
    Navigator.of(context).pop();
  }

  void _takeSnapshot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("📸 Captura de pantalla guardada"),
        duration: Duration(milliseconds: 900),
        backgroundColor: AppTheme.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final robotService = Provider.of<RobotService>(context);
    final telemetryService = robotService.telemetryService;

    return PopScope(
      canPop: true,
      onPopInvoked: (_) => robotService.stop(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Barra Superior (HUD Header de la pantalla 4)
              ListenableBuilder(
                listenable: telemetryService,
                builder: (context, _) {
                  return RobotStatusBar(
                    robotName: widget.robot.name,
                    isOnline: robotService.isConnected,
                    telemetry: telemetryService.currentData,
                    lightActive: robotService.lightEnabled,
                    onBack: _handleExit,
                    onToggleLight: robotService.toggleLight,
                    onCameraAction: _takeSnapshot,
                    onOpenSettings: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  );
                },
              ),

              // 2. Área Central (65% Video | 35% Controles)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                  child: Row(
                    children: [
                      // Video en vivo (60 - 65% del ancho)
                      Expanded(
                        flex: 64,
                        child: ListenableBuilder(
                          listenable: telemetryService,
                          builder: (context, _) {
                            return RobotVideoView(
                              rtcService: robotService.rtcService,
                              isMockMode: robotService.isMockMode,
                              telemetry: telemetryService.currentData,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Panel de Movimiento (Control de movimiento)
                      Expanded(
                        flex: 36,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.cardBorder, width: 1.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Control de movimiento",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Joystick Circular con flechas
                                  RobotJoystick(
                                    radius: 65,
                                    stickRadius: 24,
                                    onMoved: (x, y) => robotService.drive(x, y),
                                    onReleased: () => robotService.drive(0, 0),
                                  ),

                                  // Slider Vertical de Velocidad con porcentaje 60%
                                  SpeedSlider(
                                    vertical: true,
                                    speedLimit: robotService.currentSpeedLimit,
                                    onChanged: (val) => robotService.setSpeedLimit(val),
                                  ),
                                ],
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Barra Inferior: [Escuchar] | [Mantener para hablar] | [PARADA DE EMERGENCIA]
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  children: [
                    // Botón Escuchar
                    ListenButton(
                      isListening: _isListening,
                      onToggle: (val) {
                        setState(() => _isListening = val);
                        robotService.rtcService.toggleListen(val);
                      },
                    ),
                    const SizedBox(width: 14),

                    // Botón Grande Verde: Mantener para hablar (Push-to-Talk)
                    Expanded(
                      flex: 5,
                      child: PushToTalkButton(
                        onStateChanged: (active) {
                          robotService.rtcService.setPushToTalk(active);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Botón Rojo: PARADA DE EMERGENCIA
                    Expanded(
                      flex: 4,
                      child: EmergencyStopButton(
                        onStop: () {
                          robotService.stop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("⛔ PARADA DE EMERGENCIA ACTIVADA"),
                              duration: Duration(milliseconds: 900),
                              backgroundColor: AppTheme.dangerRed,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
