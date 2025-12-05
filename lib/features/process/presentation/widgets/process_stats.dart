import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class ProcessStats extends StatelessWidget {
  final Map<String, dynamic> userProgress;

  const ProcessStats({
    super.key,
    required this.userProgress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso General',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${userProgress['progressPercentage']}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: userProgress['progressPercentage'] / 100,
            backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(10),
            minHeight: 12,
          ),
          const SizedBox(height: 8),
          Text(
            '${userProgress['completedLessons']} de ${userProgress['totalLessons']} lecciones completadas (incluyendo ${userProgress['completedGames']} juegos)',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0,  // Ajustado: Más ancho para evitar overflow (de 2.5 a 2.0)
            children: [
              _buildStatCard(
                'Nivel Actual',
                userProgress['currentLevel'],
                Icons.school,
                AppTheme.primaryColor,
                colorScheme,
              ),
              _buildStatCard(
                'Racha Actual',
                '${userProgress['streakDays']} días',
                Icons.local_fire_department,
                const Color(0xFFFF6B35),
                colorScheme,
              ),
              _buildStatCard(
                'Puntos Totales',
                userProgress['totalPoints'].toString(),
                Icons.emoji_events,
                const Color(0xFFFFD166),
                colorScheme,
              ),
              _buildStatCard(
                'Games\nCompletados',  // Acortado: Título en 2 líneas para evitar overflow
                userProgress['completedGames'].toString(),
                Icons.gamepad,
                const Color(0xFF8B5CF6),
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(  // Ajustado: Usa Expanded para título flexible y evitar overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(  // Flexible para título multi-línea
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,  // Ligeramente más pequeño para caber mejor
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.visible,  // Permite wrap
                    maxLines: 2,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}