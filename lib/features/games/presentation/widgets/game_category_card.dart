import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class GameCategoryCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final VoidCallback onTap;

  const GameCategoryCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12), // Reducido padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (game['color'] as Color).withOpacity(0.1),
                (game['color'] as Color).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y dificultad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36, // Reducido
                    height: 36, // Reducido
                    decoration: BoxDecoration(
                      color: game['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      game['icon'] as IconData,
                      color: Colors.white,
                      size: 18, // Reducido
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reducido
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(game['difficulty']),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      game['difficulty'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9, // Reducido
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Reducido

              // Título
              Text(
                game['title'],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Reducido

              // Descripción
              Expanded(
                child: Text(
                  game['description'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4), // Reducido

              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.quiz,
                    size: 12, // Reducido
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 2), // Reducido
                  Text(
                    '${game['questionCount']} preguntas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // Reducido

              // Botón de jugar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6), // Reducido
                decoration: BoxDecoration(
                  color: game['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'JUGAR',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return const Color(0xFF10B981);
      case 'intermedio':
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'avanzado':
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return AppTheme.primaryColor;
    }
  }
}