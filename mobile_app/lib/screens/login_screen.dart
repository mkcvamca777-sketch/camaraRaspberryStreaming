import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'robots_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: "operador@robot.lan");
  final _passwordController = TextEditingController(text: "••••••••");
  bool _rememberMe = true;
  bool _obscurePassword = true;

  void _handleLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RobotsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // Título Oficial
                  const Text(
                    "Inicio de sesión",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtítulo
                  const Text(
                    "Accede a tu cuenta para continuar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Campo Correo Electrónico
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Correo electrónico",
                      prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Contraseña
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Recordarme & ¿Olvidaste tu contraseña?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppTheme.primaryElectric,
                              checkColor: Colors.white,
                              side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _rememberMe = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Recordarme",
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryElectric, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón Iniciar sesión >
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryElectric,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Iniciar sesión",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Divisor "o continúa con"
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppTheme.cardBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          "o continúa con",
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppTheme.cardBorder)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botones Sociales: Google y Discord
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: "Google",
                          icon: Icons.g_mobiledata_rounded,
                          onPressed: _handleLogin,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildSocialButton(
                          label: "Discord",
                          icon: Icons.forum_rounded,
                          onPressed: _handleLogin,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ¿No tienes cuenta? Regístrate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿No tienes cuenta? ",
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Regístrate",
                          style: TextStyle(fontSize: 13, color: AppTheme.primaryElectric, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
