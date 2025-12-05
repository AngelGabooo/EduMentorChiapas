import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:proyectoedumentor/core/constants/app_constants.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import '../widgets/customize_profile/avatar_selector.dart';
import '../widgets/customize_profile/subject_selector.dart';
import '../widgets/customize_profile/customize_button.dart';

class CustomizeProfilePage extends StatefulWidget {
  const CustomizeProfilePage({super.key});

  @override
  State<CustomizeProfilePage> createState() => _CustomizeProfilePageState();
}

class _CustomizeProfilePageState extends State<CustomizeProfilePage> {
  final GlobalKey<AvatarSelectorState> _avatarKey = GlobalKey<AvatarSelectorState>();  // Usa tipo público (State<AvatarSelector>)
  final GlobalKey<SubjectSelectorState> _subjectKey = GlobalKey<SubjectSelectorState>();  // Usa tipo público
  bool _isSaving = false;  // Para loading en el botón

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_retouching_natural,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Personaliza tu perfil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Elige tu avatar y tus materias favoritas para una experiencia más personalizada.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Título principal
              Center(
                child: Column(
                  children: [
                    Text(
                      'Personaliza tu perfil',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Haz tu experiencia única',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Selector de avatar
              AvatarSelector(key: _avatarKey),
              const SizedBox(height: 40),
              // Selector de materias favoritas
              SubjectSelector(key: _subjectKey),
              const SizedBox(height: 40),
              // Botón de guardar personalización
              CustomizeButton(
                onPressed: _saveCustomization,  // Ahora usa el parámetro
                isLoading: _isSaving,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomization() async {
    final avatarState = _avatarKey.currentState;
    final subjectState = _subjectKey.currentState;

    if (avatarState == null || subjectState == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona un avatar y materias antes de guardar.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final selectedAvatar = avatarState.selectedAvatar;  // Usa el getter
    final selectedSubjects = subjectState.selectedSubjects;  // Usa el getter

    if (selectedAvatar == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un avatar.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    if (selectedSubjects.values.where((v) => v).length < 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona al menos 3 materias.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_avatar', selectedAvatar);
      await prefs.setString('selected_subjects', jsonEncode(selectedSubjects));

      print('Personalización guardada:');
      print('Avatar: $selectedAvatar');
      print('Subjects: ${jsonEncode(selectedSubjects)}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Perfil personalizado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a la selección de idioma
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            context.go('/language-selection');
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
          _isSaving = false;
        });
      }
    }
  }
}