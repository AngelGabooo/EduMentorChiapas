import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart';

class ProcessSection extends StatelessWidget {
  const ProcessSection({super.key});

  void _viewProcess(BuildContext context) {
    context.go('/process');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        final double progress = (progressProvider.progressPercentage.isNaN ||
            progressProvider.progressPercentage < 0)
            ? 0.0
            : progressProvider.progressPercentage / 100;

        final int completed = progressProvider.completedGames; // Cambiado a completedGames
        final int total = progressProvider.totalLessons;
        final int points = progressProvider.totalPoints;
        final String level = progressProvider.currentLevel; // Usamos el nivel del provider

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 4), // Margen para evitar bordes
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                AppTheme.primaryColor.withOpacity(0.15),
                AppTheme.secondaryColor.withOpacity(0.1),
              ]
                  : [
                const Color(0xFFF0F9FF),
                const Color(0xFFE0F2FE),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header responsive
              _buildHeader(context, level, theme),
              const SizedBox(height: 16),

              // Estadísticas responsive
              _buildStatsSection(context, completed, total, points, theme),
              const SizedBox(height: 20),

              // Barra de progreso
              _buildProgressSection(context, progress, completed, total, progressProvider, theme),
              const SizedBox(height: 20),

              // Mensaje motivacional
              _buildMotivationalSection(progressProvider, theme),
              const SizedBox(height: 20),

              // Botón
              _buildActionButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String level, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Progreso de Aprendizaje',
                  style: TextStyle(
                    fontSize: 16, // Reducido para responsividad
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Nivel del usuario
        Container(
          constraints: const BoxConstraints(
            minWidth: 70, // Ancho mínimo para evitar texto cortado
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getLevelColor(level).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getLevelColor(level).withOpacity(0.3),
            ),
          ),
          child: Text(
            level,
            style: TextStyle(
              fontSize: 11, // Reducido para pantallas pequeñas
              fontWeight: FontWeight.bold,
              color: _getLevelColor(level),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, int completed, int total, int points, ThemeData theme) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.play_lesson,
            value: '$completed',
            label: 'Completados',
            color: const Color(0xFF10B981),
            isSmallScreen: isSmallScreen,
          ),
          _buildStatItem(
            context,
            icon: Icons.flag,
            value: '${total - completed}',
            label: 'Pendientes',
            color: const Color(0xFFF59E0B),
            isSmallScreen: isSmallScreen,
          ),
          _buildStatItem(
            context,
            icon: Icons.emoji_events,
            value: '$points',
            label: 'Puntos',
            color: const Color(0xFF8B5CF6),
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isSmallScreen,
  }) {
    final theme = Theme.of(context);

    return Flexible( // Usar Flexible en lugar de Expanded
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 14 : 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : 10,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress, int completed, int total, ProgressProvider progressProvider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso General',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${progressProvider.progressPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final double barWidth = constraints.maxWidth * progress;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  height: 10,
                  width: barWidth.isNaN ? 0 : barWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '$completed de $total juegos completados',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${((completed / total) * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMotivationalSection(ProgressProvider progressProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getMotivationalMessage(progressProvider.progressPercentage),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _viewProcess(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ver Proceso Detallado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'avanzado':
        return const Color(0xFF10B981);
      case 'medio':
        return const Color(0xFFF59E0B);
      case 'fácil':
        return const Color(0xFF3B82F6);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 90) return '¡Increíble! Estás cerca de completar todo el contenido.';
    if (progress >= 70) return '¡Excelente progreso! Sigue así para alcanzar tus metas.';
    if (progress >= 50) return '¡Vas por buen camino! Continúa con tu aprendizaje.';
    if (progress >= 30) return '¡Bien hecho! Cada juego te acerca a tu objetivo.';
    if (progress >= 10) return '¡Gran comienzo! Sigue aprendiendo día a día.';
    return '¡Comienza tu journey educativo! Cada paso cuenta.';
  }
}