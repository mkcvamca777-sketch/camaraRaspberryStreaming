import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Valores exactos de la Pantalla 5 del diseño oficial
  String _resolution = "1280 x 720 (HD)";
  String _fps = "30";
  String _quality = "Automática";

  double _volume = 0.70;
  String _mic = "Predeterminado";
  String _audioMode = "Push-to-Talk";

  final _serverController = TextEditingController(text: "192.168.1.100");
  final _wsPortController = TextEditingController(text: "8080");
  final _rtcPortController = TextEditingController(text: "8554");

  String _theme = "Oscuro";
  String _language = "Español";
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Ajustes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        children: [
          // 1. Sección Video
          _buildSectionHeader("Video"),
          _buildSettingsContainer([
            _buildNavigationItem("Resolución", _resolution, () {
              _showSelectionDialog("Resolución", ["640 x 480 (VGA)", "1280 x 720 (HD)", "1920 x 1080 (FHD)"], (v) {
                setState(() => _resolution = v);
              });
            }),
            _buildDivider(),
            _buildNavigationItem("FPS", _fps, () {
              _showSelectionDialog("FPS", ["15", "30", "60"], (v) {
                setState(() => _fps = v);
              });
            }),
            _buildDivider(),
            _buildNavigationItem("Calidad", _quality, () {
              _showSelectionDialog("Calidad", ["Baja", "Automática", "Alta"], (v) {
                setState(() => _quality = v);
              });
            }),
          ]),
          const SizedBox(height: 22),

          // 2. Sección Audio
          _buildSectionHeader("Audio"),
          _buildSettingsContainer([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Text(
                    "Volumen (robot)",
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 140,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: AppTheme.primaryElectric,
                        inactiveTrackColor: AppTheme.surfaceLight,
                        thumbColor: AppTheme.primaryElectric,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (v) => setState(() => _volume = v),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      "${(_volume * 100).round()}%",
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            _buildDivider(),
            _buildNavigationItem("Micrófono", _mic, () {
              _showSelectionDialog("Micrófono", ["Predeterminado", "Auricular Bluetooth"], (v) {
                setState(() => _mic = v);
              });
            }),
            _buildDivider(),
            _buildNavigationItem("Modo de audio", _audioMode, () {
              _showSelectionDialog("Modo de audio", ["Push-to-Talk", "Continuo"], (v) {
                setState(() => _audioMode = v);
              });
            }),
          ]),
          const SizedBox(height: 22),

          // 3. Sección Conexión
          _buildSectionHeader("Conexión"),
          _buildSettingsContainer([
            _buildInputRow("Servidor", _serverController),
            _buildDivider(),
            _buildInputRow("Puerto WebSocket", _wsPortController),
            _buildDivider(),
            _buildInputRow("Puerto WebRTC", _rtcPortController),
          ]),
          const SizedBox(height: 22),

          // 4. Sección General
          _buildSectionHeader("General"),
          _buildSettingsContainer([
            _buildNavigationItem("Tema", _theme, () {
              _showSelectionDialog("Tema", ["Oscuro", "Claro (Próximamente)"], (v) {
                setState(() => _theme = v);
              });
            }),
            _buildDivider(),
            _buildNavigationItem("Idioma", _language, () {
              _showSelectionDialog("Idioma", ["Español", "English"], (v) {
                setState(() => _language = v);
              });
            }),
            _buildDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notificaciones",
                    style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  Switch(
                    value: _notifications,
                    activeColor: AppTheme.primaryElectric,
                    activeTrackColor: AppTheme.primaryElectric.withOpacity(0.3),
                    inactiveTrackColor: AppTheme.surfaceLight,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder, width: 1.2),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavigationItem(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: AppTheme.cardBorder);
  }

  void _showSelectionDialog(String title, List<String> options, ValueChanged<String> onSelected) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
              onTap: () {
                onSelected(opt);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
