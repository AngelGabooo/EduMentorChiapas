import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const QuickAccessItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  void _onItemPressed(BuildContext context, String title) {
    switch(title) {
      case 'Juegos':
        context.go('/games'); // Navegar a juegos
        break;
      case 'Chat AI':
        context.go('/chat'); // Navegar al chat
        break;
      case 'Comunidad':
        context.go('/community');
        break;
      case 'Biblioteca':
        context.go('/library');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDarkMode ? theme.cardColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onItemPressed(context, title),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}