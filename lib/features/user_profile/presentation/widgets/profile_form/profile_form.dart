import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← NUEVO: Para inputFormatters
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../profile_button.dart';
import 'date_picker_field.dart';
import 'education_level_field.dart';
import 'location_field.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Nuevo: para loading en submit
  // Controladores
  final _birthDateController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _currentGradeController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _schoolNameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _selectedEducationLevel;
  // Lista de municipios de Chiapas
  final List<String> _municipalities = [
    'Tuxtla Gutiérrez',
    'Tapachula',
    'San Cristóbal de las Casas',
    'Comitán de Domínguez',
    'Chiapa de Corzo',
    'Cintalapa',
    'Arriaga',
    'Villaflores',
    'Pichucalco',
    'Ocosingo',
    'Yajalón',
    'Palenque',
    'Bochil',
    'Huixtla',
    'Tonalá',
    'Reforma',
    'Ocozocoautla',
    'Las Rosas',
    'Acala',
    'Venustiano Carranza',
    'Otro municipio...'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Nuevo: Cargar datos previos si existen
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    _educationLevelController.dispose();
    _currentGradeController.dispose();
    _municipalityController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final birthDateStr = prefs.getString('birth_date');
      final educationLevel = prefs.getString('education_level');
      final currentGrade = prefs.getString('current_grade');
      final municipality = prefs.getString('municipality');
      final schoolName = prefs.getString('school_name');
      if (birthDateStr != null) {
        final parts = birthDateStr.split('/').map(int.parse).toList();
        if (parts.length == 3) {
          _selectedBirthDate = DateTime(parts[2], parts[1], parts[0]);
          _birthDateController.text = birthDateStr;
        }
      }
      if (educationLevel != null) {
        _selectedEducationLevel = educationLevel;
        _educationLevelController.text = educationLevel;
      }
      if (currentGrade != null) _currentGradeController.text = currentGrade;
      if (municipality != null) _municipalityController.text = municipality;
      if (schoolName != null) _schoolNameController.text = schoolName;
      if (mounted) setState(() {});
    } catch (e) {
      print('Error cargando datos de perfil: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        // Guardar fecha de nacimiento (formato string para simplicidad)
        if (_selectedBirthDate != null) {
          await prefs.setString('birth_date', _formatDate(_selectedBirthDate!));
        }
        // Guardar otros campos
        await prefs.setString('education_level', _selectedEducationLevel ?? '');
        await prefs.setString('current_grade', _currentGradeController.text.trim());
        await prefs.setString('municipality', _municipalityController.text.trim());
        await prefs.setString('school_name', _schoolNameController.text.trim());
        print('Perfil guardado:');
        print('Fecha: $_selectedBirthDate');
        print('Nivel: $_selectedEducationLevel');
        print('Grado: ${_currentGradeController.text}');
        print('Municipio: ${_municipalityController.text}');
        print('Escuela: ${_schoolNameController.text}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar a la pantalla de personalización
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              context.go('/customize-profile');
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _onBirthDateSelected(DateTime date) {
    setState(() {
      _selectedBirthDate = date;
      _birthDateController.text = _formatDate(date);
    });
  }

  void _onEducationLevelSelected(String level) {
    setState(() {
      _selectedEducationLevel = level;
      _educationLevelController.text = level;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _validateBirthDate(String? value) {
    if (_selectedBirthDate == null) {
      return 'Por favor selecciona tu fecha de nacimiento';
    }
    final now = DateTime.now();
    final age = now.year - _selectedBirthDate!.year;
    if (age < 6) {
      return 'Debes tener al menos 6 años';
    }
    if (age > 100) {
      return 'Por favor verifica tu fecha de nacimiento';
    }
    return null;
  }

  // ← MODIFICADO: Validador simplificado para grado actual (solo vacío y símbolos)
  String? _validateCurrentGrade(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu grado actual';
    }
    final gradeText = value.trim();
    // Verificar que solo contenga números, letras, acentos, ñ y espacios
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]+$').hasMatch(gradeText)) {
      return 'Solo se permiten números y letras';
    }
    return null;
  }

  // ← NUEVO: Validador para nombre de escuela (solo letras, números y espacios)
  String? _validateSchoolName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa el nombre de tu escuela';
    }
    final schoolName = value.trim();
    // Regex: letras (incluyendo acentos y ñ), números, espacios
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]+$').hasMatch(schoolName)) {
      return 'Solo se permiten letras, números y espacios';
    }
    return null;
  }

  // ← NUEVO: Handler para cambios en el nombre de la escuela
  void _onSchoolNameChanged(String newText) {
    // Remover caracteres no permitidos
    final validText = newText.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]'), '');
    // Si hubo cambios (se removieron símbolos), actualizar el texto y mostrar mensaje
    if (newText != validText) {
      _schoolNameController.value = TextEditingValue(
        text: validText,
        selection: TextSelection.collapsed(offset: validText.length),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se aceptan símbolos'),
            duration: Duration(milliseconds: 2000),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // ← NUEVO: Handler para cambios en el grado actual
  void _onGradeChanged(String newText) {
    // Remover caracteres no permitidos (solo números, letras, acentos, ñ, espacios)
    final validText = newText.replaceAll(RegExp(r'[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9\s]'), '');
    // Si hubo cambios (se removieron símbolos), actualizar el texto y mostrar mensaje
    if (newText != validText) {
      _currentGradeController.value = TextEditingValue(
        text: validText,
        selection: TextSelection.collapsed(offset: validText.length),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se aceptan símbolos'),
            duration: Duration(milliseconds: 2000),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Información personal
          _buildSectionHeader('Información Personal', theme),
          const SizedBox(height: 16),
          // Campo de fecha de nacimiento
          DatePickerField(
            controller: _birthDateController,
            onDateSelected: _onBirthDateSelected,
            validator: _validateBirthDate,
          ),
          const SizedBox(height: 20),
          // Información educativa
          _buildSectionHeader('Información Educativa', theme),
          const SizedBox(height: 16),
          // Campo de nivel educativo
          EducationLevelField(
            controller: _educationLevelController,
            onLevelSelected: _onEducationLevelSelected,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona tu nivel educativo';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Campo de grado actual (MODIFICADO)
          TextFormField(
            controller: _currentGradeController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Grado actual',
              prefixIcon: Icon(Icons.grade_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              hintText: 'Ej: 3ro (para 3ro de primaria), 1er semestre, primer grado',
            ),
            // ← MODIFICADO: Removido digitsOnly, ahora permite letras y números
            keyboardType: TextInputType.text, // ← MODIFICADO: Teclado de texto
            onChanged: _onGradeChanged, // ← NUEVO: Detectar y filtrar en tiempo real
            validator: _validateCurrentGrade, // ← MODIFICADO: Usar validador actualizado
          ),
          const SizedBox(height: 20),
          // Ubicación
          _buildSectionHeader('Ubicación', theme),
          const SizedBox(height: 16),
          // Campo de municipio
          LocationField(
            controller: _municipalityController,
            municipalities: _municipalities,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor selecciona tu municipio';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Campo de nombre de la escuela (MODIFICADO)
          TextFormField(
            controller: _schoolNameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Nombre de tu escuela',
              prefixIcon: Icon(Icons.school_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              hintText: 'Ej: Escuela Primaria Federal 123',
            ),
            // ← REMOVIDO: inputFormatter para permitir detección en onChanged
            onChanged: _onSchoolNameChanged, // ← NUEVO: Detectar y filtrar en tiempo real
            validator: _validateSchoolName, // ← MODIFICADO: Usar validador específico
          ),
          const SizedBox(height: 40),
          // Botón de guardar perfil (con loading)
          ProfileButton(
            onPressed: _submitForm,
            isLoading: _isLoading,
          ),
        ],
      ),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}