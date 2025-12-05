// features/teacher/presentation/pages/teacher_register_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import '../widgets/teacher_register_form.dart';

class TeacherRegisterPage extends StatelessWidget {
  const TeacherRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de imagen (35% de la pantalla)
            Container(
              height: screenHeight * 0.35,
              width: double.infinity,
              child: Stack(
                children: [
                  // Imagen que cubre todo el ancho
                  Image.asset(
                    'assets/img/logo.png',
                    width: double.infinity,
                    height: screenHeight * 0.35,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: screenHeight * 0.35,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [
                              Color(0xFF1E293B),
                              Color(0xFF0F172A),
                            ]
                                : [
                              Color(0xFF3B82F6),
                              Color(0xFF1D4ED8),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  // Overlay oscuro para mejor contraste
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                  // Botón de regreso
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        onPressed: () => context.go('/register'),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenido del formulario
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Título
                    Text(
                      'Registro de Maestro',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completa tu información como educador',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Formulario de registro para maestros
                    const TeacherRegisterForm(),
                    const SizedBox(height: 20),
                    // Enlace a login
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: RichText(
                          text: TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            children: [
                              TextSpan(
                                text: 'Inicia Sesión',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }
}