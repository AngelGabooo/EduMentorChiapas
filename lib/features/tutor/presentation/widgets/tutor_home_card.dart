// features/tutor/presentation/pages/widgets/tutor_home_card.dart

import 'package:flutter/material.dart';

class TutorHomeCard extends StatelessWidget {
  final String hijoNombre;
  final String hijoEdad;
  final double promedio;

  const TutorHomeCard({
    super.key,
    required this.hijoNombre,
    required this.hijoEdad,
    required this.promedio,
  });

  Color get _colorPromedio {
    if (promedio >= 9.0) return Colors.green;
    if (promedio >= 8.0) return Colors.blue;
    if (promedio >= 7.0) return Colors.orange;
    return Colors.red;
  }

  String get _mensajePromedio {
    if (promedio >= 9.5) return "¡Excelente trabajo! Sigue así";
    if (promedio >= 9.0) return "Muy buen desempeño académico";
    if (promedio >= 8.0) return "Buen progreso en los estudios";
    if (promedio >= 7.0) return "Puede mejorar con más dedicación";
    return "Necesita apoyo adicional";
  }

  IconData get _iconPromedio {
    if (promedio >= 9.0) return Icons.emoji_events_rounded;
    if (promedio >= 8.0) return Icons.star_rounded;
    if (promedio >= 7.0) return Icons.trending_up_rounded;
    return Icons.lightbulb_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.1),
            colors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primaryContainer,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 32,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hijoNombre,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (hijoEdad.isNotEmpty)
                        Text(
                          "$hijoEdad años",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _iconPromedio,
                              color: _colorPromedio,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Promedio General",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mensajePromedio,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _colorPromedio.withOpacity(0.15),
                          _colorPromedio.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _colorPromedio.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          promedio.toStringAsFixed(1),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _colorPromedio,
                            fontSize: 28,
                          ),
                        ),
                        Text(
                          "/10",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _colorPromedio.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
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