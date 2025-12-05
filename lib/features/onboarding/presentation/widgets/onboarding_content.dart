import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Título
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Descripción
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Icono decorativo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForPage(title),
              color: AppTheme.primaryColor,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(String title) {
    switch (title) {
      case 'Aprende en tu idioma':
        return Icons.language;
      case 'Contenido Adaptado':
        return Icons.school;
      case 'Tutoría Inteligente':
        return Icons.psychology;
      default:
        return Icons.emoji_objects;
    }
  }
}