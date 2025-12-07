import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_info_dialog.dart'; // ← Crea este archivo en la misma carpeta

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Línea divisoria con texto
        Row(
          children: [
            Expanded(child: Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 20),

        // Botones sociales
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GOOGLE BUTTON
            _buildGoogleButton(
              onPressed: () => _handleGoogleSignIn(context),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: 16),

            // FACEBOOK BUTTON (deshabilitado por ahora)

          ],
        ),
      ],
    );
  }

  // BOTÓN DE GOOGLE (con logo real y diseño premium)
  Widget _buildGoogleButton({
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            'assets/icon/google.png', // Logo oficial de Google
            width: 36,
            height: 36,
            errorBuilder: (context, error, stackTrace) {
              // Si por algún motivo falla el asset, muestra el icono G
              return const Icon(Icons.g_mobiledata, size: 36, color: Color(0xFF4285F4));
            },
          ),
        ),
      ),
    );
  }

  // Botón genérico (Facebook, Apple, etc.)
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey[800] : Colors.transparent,
        border: Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
      ),
      child: IconButton(
        icon: Icon(icon, size: 30, color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
        onPressed: onPressed,
      ),
    );
  }

  // FUNCIÓN PRINCIPAL: Login con Google + aviso + restricción de rol
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    // 1. Mostrar diálogo de confirmación
    final bool? confirm = await showGoogleInfoDialog(context);
    if (confirm != true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión cancelado'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    // 2. Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: Colors.white)),
            SizedBox(width: 16),
            Text('Conectando con Google...'),
          ],
        ),
        duration: Duration(seconds: 15),
      ),
    );

    final success = await AuthService.signInWithGoogle();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role') ?? 'estudiante';

      // RESTRICCIÓN: Solo estudiantes pueden usar Google
      if (role != 'estudiante') {
        await AuthService.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solo los alumnos pueden iniciar sesión con Google'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Bienvenido, alumno!'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Redirección segura
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo iniciar sesión con Google'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}