import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class ProcessTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> lessons;

  const ProcessTimeline({
    super.key,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < lessons.length; i++)
            _buildTimelineItem(lessons[i], i, lessons.length, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> lesson, int index, int total, ColorScheme colorScheme) {
    final bool isCompleted = lesson['completed'] ?? false;
    final bool isLast = index == total - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea vertical y círculo
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primaryColor : colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppTheme.primaryColor : colorScheme.onSurfaceVariant,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                Icons.check,
                color: colorScheme.onPrimary,
                size: 14,
              )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? AppTheme.primaryColor : colorScheme.surfaceVariant,
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Contenido de la lección
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.none : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lesson['duration'],
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson['points']} pts',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}