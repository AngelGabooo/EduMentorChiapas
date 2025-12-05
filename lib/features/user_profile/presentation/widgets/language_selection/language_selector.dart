import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String? _selectedLanguage;

  // Lista de idiomas de Chiapas
  final List<Map<String, String>> _languages = [
    {
      'code': 'es',
      'name': 'Español',
      'nativeName': 'Español',
      'description': 'Idioma oficial de México'
    },
    {
      'code': 'tzo',
      'name': 'Tsotsil',
      'nativeName': 'Bats\'i k\'op',
      'description': 'Lengua maya de los Altos de Chiapas'
    },
    {
      'code': 'tze',
      'name': 'Tseltal',
      'nativeName': 'Kop o winik atel',
      'description': 'Lengua maya de los Altos de Chiapas'
    },
    {
      'code': 'ctu',
      'name': 'Ch\'ol',
      'nativeName': 'Lak ty\'añ',
      'description': 'Lengua maya del norte de Chiapas'
    },
    {
      'code': 'zos',
      'name': 'Zoque',
      'nativeName': 'O\'de püt',
      'description': 'Lengua mixe-zoque de Chiapas'
    },
    {
      'code': 'toj',
      'name': 'Tojol-ab\'al',
      'nativeName': 'Tojol-winik',
      'description': 'Lengua maya de la región fronteriza'
    },
    {
      'code': 'mam',
      'name': 'Mam',
      'nativeName': 'Qyool',
      'description': 'Lengua maya de la región Soconusco'
    },
    {
      'code': 'lac',
      'name': 'Lacandón',
      'nativeName': 'Hach t\'an',
      'description': 'Lengua maya de la selva lacandona'
    },
    {
      'code': 'en',
      'name': 'Inglés',
      'nativeName': 'English',
      'description': 'Idioma internacional'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        _buildSectionHeader('Idiomas disponibles', theme),
        const SizedBox(height: 20),

        // Lista de idiomas
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _languages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final language = _languages[index];
            final isSelected = _selectedLanguage == language['code'];

            return _buildLanguageCard(language, isSelected, isDarkMode);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageCard(Map<String, String> language, bool isSelected, bool isDarkMode) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? AppTheme.primaryColor.withOpacity(0.05)
          : isDarkMode ? theme.cardColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.language,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language['name']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : theme.colorScheme.onSurface,
              ),
            ),
            Text(
              language['nativeName']!,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? AppTheme.primaryColor
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            language['description']!,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.8)
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        trailing: isSelected
            ? Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        )
            : null,
        onTap: () {
          setState(() {
            _selectedLanguage = language['code'];
          });
          print('Idioma seleccionado: ${language['name']} (${language['code']})');
        },
      ),
    );
  }
}
