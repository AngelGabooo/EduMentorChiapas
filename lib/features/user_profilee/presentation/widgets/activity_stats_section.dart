import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class ActivityStatsSection extends StatelessWidget {
  final Map<String, dynamic> recentActivity;

  const ActivityStatsSection({
    super.key,
    required this.recentActivity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Estadísticas de Actividad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Usar Column con Rows en lugar de GridView
        Column(
          children: [
            // Primera fila
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Horas de Estudio',
                    '${recentActivity['studyHours'] is double ? recentActivity['studyHours'].toStringAsFixed(1) : '0.0'}',
                    Icons.access_time,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Ejercicios Completados',
                    '${recentActivity['exercisesCompleted'] ?? '0'}',
                    Icons.assignment_turned_in,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Segunda fila
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Racha Actual',
                    '${recentActivity['currentStreak'] ?? '0'} días',
                    Icons.local_fire_department,
                    const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Última Actividad',
                    recentActivity['lastActivity']?.toString() ?? 'Sin actividad',
                    Icons.update,
                    const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLongText = title == 'Última Actividad';

    return Container(
      height: 80, // Altura fija para consistencia
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isLongText ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: isLongText ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}