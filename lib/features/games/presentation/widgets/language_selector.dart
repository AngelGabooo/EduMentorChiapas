import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final List<String> languages;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12), // Reducido
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Idioma del Juego',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6), // Reducido
          SizedBox(
            height: 40, // Reducido
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final language = languages[index];
                final isSelected = language == selectedLanguage;

                return Padding(
                  padding: const EdgeInsets.only(right: 6), // Reducido
                  child: ChoiceChip(
                    label: Text(
                      language,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onLanguageChanged(language);
                      }
                    },
                    backgroundColor: isDarkMode ? theme.cardColor : Colors.white,
                    selectedColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}