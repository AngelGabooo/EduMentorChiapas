import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/features/user_profilee/domain/entities/user_entity.dart';

class CustomizeProfilePagee extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const CustomizeProfilePagee({super.key, this.extraData});

  @override
  State<CustomizeProfilePagee> createState() => _CustomizeProfilePageeState();
}

class _CustomizeProfilePageeState extends State<CustomizeProfilePagee> {
  late TextEditingController _nameController;
  String _selectedLanguageName = 'Español';
  String _selectedLanguageCode = 'es';
  String _selectedEducationLevel = 'Preparatoria';
  List<String> _selectedSubjects = [];
  String _selectedAvatar = 'person';

  final List<String> _languages = [
    'Español',
    'Tsotsil',
    'Tseltal',
    "Ch'ol",
    'Zoque',
    "Tojol-ab'al",
    'Mam',
    'Lacandón',
    'Inglés'
  ];

  final Map<String, String> _languageNameToCode = {
    'Español': 'es',
    'Tsotsil': 'tsotsil',
    'Tseltal': 'tseltal',
    "Ch'ol": 'chol',
    'Zoque': 'zoque',
    "Tojol-ab'al": 'tojolabal',
    'Mam': 'mam',
    'Lacandón': 'lacandon',
    'Inglés': 'en',
  };

  final Map<String, String> _languageCodeToName = {
    'es': 'Español',
    'tsotsil': 'Tsotsil',
    'tseltal': 'Tseltal',
    'chol': "Ch'ol",
    'zoque': 'Zoque',
    'tojolabal': "Tojol-ab'al",
    'mam': 'Mam',
    'lacandon': 'Lacandón',
    'en': 'Inglés',
  };

  final List<String> _educationLevels = [
    'Primaria',
    'Secundaria',
    'Preparatoria',
    'Universidad',
    'Posgrado'
  ];

  final List<String> _availableSubjects = [
    'Matemáticas',
    'Física',
    'Química',
    'Biología',
    'Historia',
    'Geografía',
    'Literatura',
    'Programación',
    'Inglés',
    'Arte',
    'Música',
    'Deportes'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final extra = widget.extraData ?? {};

      // Nombre
      final savedName = extra['name'] ?? prefs.getString('full_name') ?? 'Juan Pérez';
      _nameController.text = savedName;

      // Avatar
      _selectedAvatar = extra['avatar'] ?? prefs.getString('selected_avatar') ?? 'person';

      // Idioma: seguro contra valores inválidos
      final savedLangCode = extra['languageCode'] ?? prefs.getString('selected_language') ?? 'es';
      if (_languageCodeToName.containsKey(savedLangCode)) {
        _selectedLanguageCode = savedLangCode;
        _selectedLanguageName = _languageCodeToName[savedLangCode]!;
      } else {
        _selectedLanguageCode = 'es';
        _selectedLanguageName = 'Español';
      }

      // Nivel educativo: SOLUCIÓN AL ERROR DEL DROPDOWN
      final savedLevel = extra['educationLevel'] ?? prefs.getString('education_level');
      if (savedLevel == null || !_educationLevels.contains(savedLevel)) {
        _selectedEducationLevel = 'Preparatoria';
      } else {
        _selectedEducationLevel = savedLevel;
      }

      // Materias favoritas
      final savedSubjects = extra['favoriteSubjects'] ?? [];
      if (savedSubjects.isNotEmpty) {
        _selectedSubjects = List<String>.from(savedSubjects);
      } else {
        final subjectsStr = prefs.getString('selected_subjects');
        if (subjectsStr != null) {
          try {
            final subjectsMap = jsonDecode(subjectsStr) as Map<String, dynamic>;
            _selectedSubjects = subjectsMap.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .toList();
          } catch (e) {
            _selectedSubjects = [];
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando datos existentes: $e');
    }
  }

  Future<void> _saveProfile() async {
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('full_name', _nameController.text.trim());
      await prefs.setString('selected_avatar', _selectedAvatar);
      await prefs.setString('selected_language', _selectedLanguageCode);
      await prefs.setString('education_level', _selectedEducationLevel);

      final subjectsMap = <String, bool>{};
      for (var subject in _availableSubjects) {
        subjectsMap[subject] = _selectedSubjects.contains(subject);
      }
      await prefs.setString('selected_subjects', jsonEncode(subjectsMap));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // IMPORTANTE: pasar true para que la página anterior recargue
      context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else if (_selectedSubjects.length < 5) {
        _selectedSubjects.add(subject);
      }
    });
  }

  void _onLanguageChanged(String? newName) {
    if (newName != null) {
      setState(() {
        _selectedLanguageName = newName;
        _selectedLanguageCode = _languageNameToCode[newName] ?? 'es';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 3,
                ),
              ),
              child: Center(
                child: Text(
                  _selectedAvatar,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selector de avatar en desarrollo')),
                );
              },
              child: Text(
                'Cambiar Avatar',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nombre', _nameController, colorScheme),
            const SizedBox(height: 20),
            _buildDropdown(
              'Idioma Principal',
              _selectedLanguageName,
              _languages,
              _onLanguageChanged,
              colorScheme,
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              'Nivel Educativo',
              _selectedEducationLevel,
              _educationLevels,
                  (value) => setState(() => _selectedEducationLevel = value!),
              colorScheme,
            ),
            const SizedBox(height: 20),
            _buildSubjectsSelector(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
      String label,
      String value,
      List<String> items,
      Function(String?) onChanged,
      ColorScheme colorScheme,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceVariant.withOpacity(0.1),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            style: TextStyle(color: colorScheme.onSurface),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: TextStyle(color: colorScheme.onSurface)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Materias Favoritas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona tus materias favoritas (máximo 5)',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSubjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject, style: TextStyle(color: isSelected ? Colors.white : colorScheme.onSurface)),
              selected: isSelected,
              onSelected: (_selectedSubjects.length < 5 || isSelected)
                  ? (_) => _toggleSubject(subject)
                  : null,
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: colorScheme.surfaceVariant.withOpacity(0.1),
              side: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.3)),
            );
          }).toList(),
        ),
        if (_selectedSubjects.length >= 5) ...[
          const SizedBox(height: 8),
          Text(
            'Has alcanzado el máximo de materias seleccionadas',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}