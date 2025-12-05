import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class WeeklyActivityChart extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyActivity;

  const WeeklyActivityChart({
    super.key,
    required this.weeklyActivity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Encontrar el valor máximo para escalar las barras
    double maxHours = 0;
    for (var day in weeklyActivity) {
      final hours = (day['hours'] as num).toDouble();
      if (hours > maxHours) {
        maxHours = hours;
      }
    }
    // Si maxHours es 0, usar 1 para evitar división por cero
    maxHours = maxHours > 0 ? maxHours : 1.0;

    return Container(
      width: double.infinity, // Ancho fijo para evitar overflow
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Importante: evitar que se expanda demasiado
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Actividad Semanal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de barras con altura fija
          SizedBox(
            height: 120, // Altura fija para evitar overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyActivity.map((dayData) {
                final day = dayData['day'] as String;
                final hours = (dayData['hours'] as num).toDouble();
                final percentage = hours / maxHours;

                return _buildBar(
                  context: context,
                  day: day,
                  hours: hours,
                  percentage: percentage,
                  isDarkMode: isDarkMode,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required BuildContext context,
    required String day,
    required double hours,
    required double percentage,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra
        Container(
          width: 24, // Ancho fijo
          height: 80 * percentage, // Altura máxima de 80px
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Día de la semana
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Horas
        Text(
          hours.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}