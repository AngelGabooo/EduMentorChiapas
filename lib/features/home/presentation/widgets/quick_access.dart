import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'quick_access_item.dart';

class QuickAccess extends StatelessWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: const [
            QuickAccessItem(
              icon: Icons.videogame_asset,
              title: 'Juegos',
              color: Color(0xFF10B981),
            ),
            QuickAccessItem(
              icon: Icons.chat,
              title: 'Chat AI',
              color: Color(0xFF3B82F6),
            ),
            QuickAccessItem(
              icon: Icons.people,
              title: 'Comunidad',
              color: Color(0xFF8B5CF6),
            ),
            QuickAccessItem(
              icon: Icons.library_books,
              title: 'Biblioteca',
              color: Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }
}