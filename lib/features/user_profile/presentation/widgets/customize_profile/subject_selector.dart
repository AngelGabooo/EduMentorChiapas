import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class SubjectSelector extends StatefulWidget {
  const SubjectSelector({super.key});

  @override
  State<SubjectSelector> createState() => SubjectSelectorState();  // Público: sin _
}

class SubjectSelectorState extends State<SubjectSelector> {  // Público: sin _
  Map<String, bool> _selectedSubjects = {
    'Español': false,
    'Matemáticas': false,
    'Ciencias Naturales': false,
    'Historia': false,
    'Geografía': false,
    'Formación Cívica y Ética': false,
    'Inglés': false,
    'Artes': false,
    'Educación Física': false,
    'Programación': false,
    'Biología': false,
    'Química': false,
    'Física': false,
    'Literatura': false,
    'Música': false,
    'Dibujo Técnico': false,
    'Economía': false,
    'Filosofía': false,
    'Tecnología': false,
    'Robótica': false,
  };

  // Getter público para acceder desde el padre
  Map<String, bool> get selectedSubjects => _selectedSubjects;

  @override
  void initState() {
    super.initState();
    _loadSelectedSubjects();
  }

  Future<void> _loadSelectedSubjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsStr = prefs.getString('selected_subjects');
      if (subjectsStr != null && mounted) {
        final subjectsMap = jsonDecode(subjectsStr) as Map<String, dynamic>;
        setState(() {
          _selectedSubjects = {
            for (var entry in subjectsMap.entries) entry.key: entry.value as bool
          };
        });
      }
    } catch (e) {
      print('Error cargando subjects: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedCount = _selectedSubjects.values.where((isSelected) => isSelected).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        _buildSectionHeader('Materias favoritas', theme),
        const SizedBox(height: 8),
        Text(
          'Selecciona al menos 3 materias que más te gusten ($selectedCount seleccionadas)',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Grid de materias
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.5,
          ),
          itemCount: _selectedSubjects.length,
          itemBuilder: (context, index) {
            final subject = _selectedSubjects.keys.elementAt(index);
            final isSelected = _selectedSubjects[subject]!;

            return _buildSubjectChip(subject, isSelected, isDarkMode);
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

  Widget _buildSubjectChip(String subject, bool isSelected, bool isDarkMode) {
    return FilterChip(
      label: Text(
        subject,
        style: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedSubjects[subject] = selected;
        });
        print('Materia $subject: ${selected ? 'seleccionada' : 'deseleccionada'}');
      },
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
      selectedColor: AppTheme.primaryColor,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? AppTheme.primaryColor
              : isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
    );
  }
}