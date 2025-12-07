// features/auth/domain/presentation/widgets/login/google_info_dialog.dart
import 'package:flutter/material.dart';

Future<bool?> showGoogleInfoDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // obliga a pulsar un botón
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.cardColor,
      elevation: 10,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con gradiente bonito
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E40AF), const Color(0xFF1E293B)]
                      : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Registro con Google',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'Importante',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Solo los alumnos (estudiantes) pueden registrarse usando Google.\n\n'
                        'Si eres maestro o tutor, por favor regístrate manualmente con tu correo y contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¿Eres alumno y deseas continuar?',
                    style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: theme.colorScheme.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Sí, soy alumno',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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