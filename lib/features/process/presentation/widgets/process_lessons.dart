import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class ProcessLessons extends StatelessWidget {
  final List<Map<String, dynamic>> lessons;

  const ProcessLessons({
    super.key,
    required this.lessons,
  });

  void _onLessonTap(BuildContext context, Map<String, dynamic> lesson) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!lesson['completed']) {
      // Navegar a la lección o mostrar diálogo de confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Comenzar Lección',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            content: Text(
              '¿Quieres comenzar "${lesson['title']}"?',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navegar a la lección
                  print('Comenzar lección: ${lesson['title']}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimaryColor,
                ),
                child: const Text('Comenzar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var lesson in lessons)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _onLessonTap(context, lesson),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono de estado
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: lesson['completed']
                            ? const Color(0xFF06D6A0).withOpacity(0.1)
                            : AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        lesson['completed'] ? Icons.check_circle : Icons.play_arrow,
                        color: lesson['completed'] ? const Color(0xFF06D6A0) : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Información de la lección
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson['title'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: lesson['completed']
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                              decoration: lesson['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
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
                              _buildLessonInfo(
                                Icons.schedule,
                                lesson['duration'],
                                colorScheme,
                              ),
                              const SizedBox(width: 16),
                              _buildLessonInfo(
                                Icons.emoji_events,
                                '${lesson['points']} pts',
                                colorScheme,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Badge de estado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: lesson['completed']
                            ? const Color(0xFF06D6A0).withOpacity(0.1)
                            : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        lesson['completed'] ? 'Completado' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: lesson['completed'] ? const Color(0xFF06D6A0) : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLessonInfo(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}