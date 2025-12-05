import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class PersonalInfoSection extends StatelessWidget {
  final String language;
  final String educationLevel;
  final String community;
  final List<String> favoriteSubjects;

  const PersonalInfoSection({
    super.key,
    required this.language,
    required this.educationLevel,
    required this.community,
    required this.favoriteSubjects,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Personal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.onSurfaceVariant.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _buildInfoRow('Idioma Principal', language, colorScheme),
              const SizedBox(height: 12),
              _buildInfoRow('Nivel Educativo', educationLevel, colorScheme),
              const SizedBox(height: 12),
              _buildInfoRow('Comunidad', community, colorScheme),
              const SizedBox(height: 12),
              _buildInfoRow('Materias Favoritas', favoriteSubjects.join(', '), colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}