import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/models/class_model.dart';
import '../../../../config/theme/app_theme.dart';

class TeacherProfileDashboard extends StatefulWidget {
  const TeacherProfileDashboard({super.key});

  @override
  State<TeacherProfileDashboard> createState() => _TeacherProfileDashboardState();
}

class _TeacherProfileDashboardState extends State<TeacherProfileDashboard> {
  final ScrollController _scrollController = ScrollController();
  // Variables para datos del perfil cargados
  String _fullName = 'Profesor';
  String _avatar = '👨‍🏫';
  String _language = 'Español';
  String _email = '';
  String _registrationNumber = '';
  List<String> _subjects = [];
  List<String> _languages = [];
  int _totalClasses = 0;
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Datos básicos del registro
      _fullName = prefs.getString('full_name') ?? 'Profesor';
      _email = prefs.getString('email') ?? '';
      _registrationNumber = prefs.getString('registration_number') ?? 'No especificado';
      // Datos específicos del maestro
      final teacherDataStr = prefs.getString('teacherData');
      if (teacherDataStr != null) {
        final teacherData = jsonDecode(teacherDataStr) as Map<String, dynamic>;
        _subjects = List<String>.from(teacherData['subjects'] ?? []);
        _languages = List<String>.from(teacherData['languages'] ?? []);
      }
      // Datos de clases (para estadísticas)
      final classesJson = prefs.getString('teacherClasses_${_email}') ?? '[]';
      final List<dynamic> classesList = json.decode(classesJson);
      _totalClasses = classesList.length;
      // Calcular total de estudiantes
      int totalStudents = 0;
      for (final classData in classesList) {
        final students = List<String>.from(classData['students'] ?? []);
        totalStudents += students.length;
      }
      _totalStudents = totalStudents;
      // De CustomizeProfile (si existe)
      _avatar = prefs.getString('selected_avatar') ?? '👨‍🏫';
      // De LanguageSelection
      final langCode = prefs.getString('selected_language') ?? 'es';
      _language = _mapLanguageCodeToName(langCode);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando datos de perfil del maestro: $e');
    }
  }

  String _mapLanguageCodeToName(String code) {
    final langMap = {
      'es': 'Español',
      'en': 'Inglés',
      'tsotsil': 'Tsotsil',
      'tseltal': 'Tseltal',
      'chol': "Ch'ol",
      'zoque': 'Zoque',
      'tojolabal': "Tojol-ab'al",
      'mam': 'Mam',
      'lacandon': 'Lacandón',
    };
    return langMap[code] ?? 'Español';
  }

  void _editProfile() {
    // Aquí puedes implementar la edición del perfil del maestro
    // Por ahora, redirigimos al perfil de edición existente
    context.push('/customize-my-profile');
  }

  // CORRECCIÓN: Regresar a TeacherHome con pop() para stack anterior
  void _goBackToTeacherHome() {
    context.pop();
  }

  // NUEVO MÉTODO: Navegar a configuración
  void _navigateToSettings() {
    context.push('/settings');
  }

  // NUEVO MÉTODO: Navegar a privacidad
  void _navigateToPrivacy() {
    context.push('/privacy');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: _goBackToTeacherHome,
        ),
        title: Text(
          'Mi Perfil - Maestro',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: _editProfile,
            tooltip: 'Editar Perfil',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20 + bottomPadding,
              ),
              child: Column(
                children: [
                  // Header del perfil
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  // Sección de acciones rápidas
                  _buildQuickActionsSection(),
                  const SizedBox(height: 20),
                  // Sección de información personal
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 16),
                  // Sección de estadísticas del maestro
                  _buildTeacherStatsSection(),
                  const SizedBox(height: 16),
                  // Sección de materias e idiomas
                  _buildSubjectsLanguagesSection(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                _avatar,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(height: 16),
            // Nombre
            Text(
              _fullName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Badge de Maestro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Maestro Certificado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO WIDGET: Sección de acciones rápidas
  Widget _buildQuickActionsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(
                  icon: Icons.settings,
                  label: 'Configuración',
                  onTap: _navigateToSettings,
                  color: Colors.blueGrey,
                ),
                _buildActionChip(
                  icon: Icons.security,
                  label: 'Privacidad',
                  onTap: _navigateToPrivacy,
                  color: Colors.green,
                ),
                _buildActionChip(
                  icon: Icons.help,
                  label: 'Ayuda',
                  onTap: () {
                    // Navegar a ayuda
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Centro de ayuda - Próximamente')),
                    );
                  },
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO WIDGET: Chip de acción
  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Personal',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.email,
              label: 'Correo electrónico',
              value: _email,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.badge,
              label: 'Número de matrícula',
              value: _registrationNumber,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.language,
              label: 'Idioma principal',
              value: _language,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherStatsSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de Enseñanza',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.class_,
                  value: _totalClasses.toString(),
                  label: 'Clases',
                  color: AppTheme.primaryColor,
                ),
                _buildStatItem(
                  icon: Icons.people,
                  value: _totalStudents.toString(),
                  label: 'Estudiantes',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.star,
                  value: '4.8',
                  label: 'Rating',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsLanguagesSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Áreas de Especialización',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Materias que imparte
            _buildListSection(
              title: 'Materias que imparte',
              items: _subjects,
              emptyText: 'No hay materias asignadas',
              icon: Icons.subject,
            ),
            const SizedBox(height: 16),
            // Idiomas que habla
            _buildListSection(
              title: 'Idiomas que habla',
              items: _languages,
              emptyText: 'No hay idiomas registrados',
              icon: Icons.translate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
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
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required String emptyText,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              emptyText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}