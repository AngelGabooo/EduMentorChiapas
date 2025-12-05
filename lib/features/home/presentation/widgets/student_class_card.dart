// VERSIÓN ALTERNATIVA CON PopupMenuButton
import 'package:flutter/material.dart';
import '../../../teacher/domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';

class StudentClassCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;
  final VoidCallback? onLeaveClass;

  const StudentClassCard({
    super.key,
    required this.classModel,
    required this.onTap,
    this.onLeaveClass,
  });

  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    final index = classModel.name.hashCode % colors.length;
    return colors[index];
  }

  IconData _getSubjectIcon() {
    final subject = classModel.subject.toLowerCase();
    if (subject.contains('math') || subject.contains('matemática')) {
      return Icons.calculate_rounded;
    } else if (subject.contains('science') || subject.contains('ciencia')) {
      return Icons.science_rounded;
    } else if (subject.contains('history') || subject.contains('historia')) {
      return Icons.history_edu_rounded;
    } else if (subject.contains('language') || subject.contains('lenguaje')) {
      return Icons.language_rounded;
    } else if (subject.contains('art') || subject.contains('arte')) {
      return Icons.palette_rounded;
    } else if (subject.contains('music') || subject.contains('música')) {
      return Icons.music_note_rounded;
    } else if (subject.contains('physics') || subject.contains('física')) {
      return Icons.bolt_rounded;
    } else if (subject.contains('chemistry') || subject.contains('química')) {
      return Icons.emoji_objects_rounded;
    } else {
      return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final randomColor = _getRandomColor();
    final subjectIcon = _getSubjectIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: randomColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(40),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and code
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: randomColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          subjectIcon,
                          color: randomColor,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      // PopupMenuButton - MÁS SIMPLE Y FUNCIONAL
                      if (onLeaveClass != null)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onSelected: (value) {
                            if (value == 'leave') {
                              onLeaveClass!();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'leave',
                              child: Row(
                                children: [
                                  Icon(Icons.exit_to_app_rounded,
                                      color: Colors.red.shade600),
                                  const SizedBox(width: 8),
                                  const Text('Salir de la clase'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          classModel.accessCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Class name
                  Text(
                    classModel.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Subject
                  Text(
                    classModel.subject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (classModel.section != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Sección ${classModel.section!}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Footer with students count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${classModel.students.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Activa',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}