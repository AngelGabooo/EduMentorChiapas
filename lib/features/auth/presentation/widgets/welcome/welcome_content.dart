import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/core/constants/app_constants.dart';
import 'welcome_button.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
          _buildCenteredContent(context, isDarkMode),
          const Expanded(
            flex: 2,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredContent(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Título principal
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        // Logo de la app debajo del título
        _buildLogo(),

        const SizedBox(height: 30),

        // Descripción
        Text(
          'Tu mentor educativo inteligente para el estado de Chiapas',
          style: TextStyle(
            fontSize: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Solo un botón "Comenzar"
        WelcomeButton(
          text: 'Comenzar',
          onPressed: () {
            context.go('/auth');
          },
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/img/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF1D4ED8),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}