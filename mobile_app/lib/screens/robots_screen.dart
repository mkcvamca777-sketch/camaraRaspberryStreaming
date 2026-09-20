import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/robot.dart';
import '../models/telemetry.dart';
import '../services/robot_service.dart';
import '../theme/app_theme.dart';
import '../widgets/robot_card.dart';
import 'control_screen.dart';

class RobotsScreen extends StatefulWidget {
  const RobotsScreen({super.key});

  @override
  State<RobotsScreen> createState() => _RobotsScreenState();
}

class _RobotsScreenState extends State<RobotsScreen> {
  // Lista de robots exacta de la Pantalla 3 del diseño oficial
  final List<Robot> _robots = [
    const Robot(
      id: "robot-01",
      name: "ROBOT-01",
      host: "192.168.1.100",
      wsPort: 8080,
      rtcPort: 8554,
      isOnline: true,
      telemetry: TelemetryData(
        battery: 76,
        voltage: 7.62,
        rssi: -52,
        latency: 42,
        temperature: 51.2,
        status: "online",
      ),
    ),
    const Robot(
      id: "robot-02",
      name: "ROBOT-02",
      host: "192.168.1.101",
      wsPort: 8080,
      rtcPort: 8554,
      isOnline: false,
      telemetry: TelemetryData(
        battery: 0,
        voltage: 0.0,
        rssi: 0,
        latency: 0,
        temperature: 0.0,
        status: "offline",
      ),
    ),
    const Robot(
      id: "robot-03",
      name: "ROBOT-03",
      host: "192.168.1.102",
      wsPort: 8080,
      rtcPort: 8554,
      isOnline: false,
      telemetry: TelemetryData(
        battery: 34,
        voltage: 7.10,
        rssi: -70,
        latency: 85,
        temperature: 42.0,
        status: "waiting",
      ),
    ),
  ];

  void _openControlScreen(Robot robot) {
    final robotService = Provider.of<RobotService>(context, listen: false);
    // Modo simulación habilitado por defecto para permitir pruebas inmediatas sin hardware
    robotService.setActiveRobot(robot, mockMode: true);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ControlScreen(robot: robot),
      ),
    );
  }

  void _showAddRobotDialog() {
    final nameCtrl = TextEditingController(text: "ROBOT-04");
    final hostCtrl = TextEditingController(text: "192.168.1.104");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Agregar Robot", style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Identificador del robot"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hostCtrl,
              decoration: const InputDecoration(labelText: "Dirección IP del robot"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _robots.add(Robot(
                    id: "robot-${DateTime.now().millisecondsSinceEpoch}",
                    name: nameCtrl.text.trim(),
                    host: hostCtrl.text.trim(),
                    telemetry: const TelemetryData(
                      battery: 100,
                      rssi: -48,
                      latency: 35,
                      status: "online",
                    ),
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 6.0),
          child: Text(
            "Mis robots",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: IconButton(
              icon: const Icon(Icons.add_rounded, size: 28, color: AppTheme.textPrimary),
              onPressed: _showAddRobotDialog,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Lista de tarjetas de robots
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                itemCount: _robots.length,
                itemBuilder: (context, index) {
                  final robot = _robots[index];
                  return RobotCard(
                    robot: robot,
                    onTap: () => _openControlScreen(robot),
                  );
                },
              ),
            ),

            // Botón inferior: "+ Agregar robot"
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: InkWell(
                onTap: _showAddRobotDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: AppTheme.textPrimary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Agregar robot",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
