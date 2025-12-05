import 'package:flutter/material.dart';
import 'package:proyectoedumentor/features/auth/presentation/widgets/welcome/welcome_content.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E293B), // Azul oscuro en la parte superior
                Color(0xFF0F172A), // Más oscuro en el centro
                Color(0xFF0F172A), // Más oscuro en la parte inferior
              ],
              stops: [0.0, 0.4, 1.0],
            )
                : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F2FE), // Azul muy claro en la parte superior
                Colors.white,      // Blanco en el centro
                Colors.white,      // Blanco en la parte inferior
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Gradientes en las esquinas
              _buildCornerGradients(isDarkMode),

              // Contenido de la bienvenida
              const WelcomeContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCornerGradients(bool isDarkMode) {
    return Stack(
      children: [
        // Esquina superior izquierda - Gradiente azul
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF3B82F6).withOpacity(0.25),
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),
        ),

        // Esquina superior derecha - Gradiente azul
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.secondaryColor.withOpacity(0.2),
                  AppTheme.secondaryColor.withOpacity(0.05),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF1D4ED8).withOpacity(0.25),
                  const Color(0xFF1D4ED8).withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),
        ),

        // Esquina inferior izquierda - Gradiente suave
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.accentColor.withOpacity(0.1),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF60A5FA).withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.8],
              ),
            ),
          ),
        ),

        // Esquina inferior derecha - Gradiente suave
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.primaryColor.withOpacity(0.1),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF2563EB).withOpacity(0.15),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.8],
              ),
            ),
          ),
        ),
      ],
    );
  }
}