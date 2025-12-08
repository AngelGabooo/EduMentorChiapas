import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/activity_stats_section.dart';
import '../widgets/weekly_activity_chart.dart';

class UserProfilePagee extends StatefulWidget {
  const UserProfilePagee({super.key});

  @override
  State<UserProfilePagee> createState() => _UserProfilePageeState();
}

class _UserProfilePageeState extends State<UserProfilePagee> {
  int _currentIndex = 4;
  final ScrollController _scrollController = ScrollController();

  // Variables para datos del perfil cargados
  String _fullName = 'Usuario';
  String _avatar = 'person';
  String _language = 'Español';
  String _educationLevel = 'No especificado';
  String _municipality = 'No especificado';
  List<String> _favoriteSubjects = [];
  String _birthDate = 'No especificado';
  String _currentGrade = 'No especificado';
  String _schoolName = 'No especificado';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // De registro
      _fullName = prefs.getString('full_name') ?? 'Usuario';

      // De ProfileForm
      _educationLevel = prefs.getString('education_level') ?? 'No especificado';
      _municipality = prefs.getString('municipality') ?? 'No especificado';
      _birthDate = prefs.getString('birth_date') ?? 'No especificado';
      _currentGrade = prefs.getString('current_grade') ?? 'No especificado';
      _schoolName = prefs.getString('school_name') ?? 'No especificado';

      // De CustomizeProfile
      _avatar = prefs.getString('selected_avatar') ?? 'person';
      final subjectsStr = prefs.getString('selected_subjects');
      if (subjectsStr != null) {
        final subjectsMap = jsonDecode(subjectsStr) as Map<String, dynamic>;
        _favoriteSubjects = subjectsMap.entries
            .where((entry) => entry.value as bool)
            .map((entry) => entry.key)
            .toList();
      }

      // De LanguageSelection
      final langCode = prefs.getString('selected_language') ?? 'es';
      _language = _mapLanguageCodeToName(langCode);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando datos de perfil: $e');
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

  // FUNCIÓN CORREGIDA: ahora espera el resultado y recarga si se guardó
  void _editProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    final userData = {
      'name': _fullName,
      'avatar': _avatar,
      'level': _calculateLevelFromPoints(progressProvider.totalPoints),
      'points': progressProvider.totalPoints,
      'language': _language,
      'educationLevel': _educationLevel,
      'community': _municipality,
      'favoriteSubjects': _favoriteSubjects,
      'birthDate': _birthDate,
      'currentGrade': _currentGrade,
      'schoolName': _schoolName,
      // Añadimos el código del idioma para que CustomizeProfile lo lea bien
      'languageCode': prefs.getString('selected_language') ?? 'es',
    };

    // Esperamos el resultado del pop()
    final result = await context.push('/customize-my-profile', extra: userData);

    // Si el usuario guardó y volvió (result == true), recargamos todo
    if (result == true) {
      await _loadProfileData(); // ESTO ES LO QUE HACÍA FALTA
    }
  }

  void _goBackToHome() {
    context.go('/home');
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/chat');
        break;
      case 1:
        context.go('/games');
        break;
      case 2:
        context.go('/library');
        break;
      case 3:
        context.go('/process');
        break;
      case 4:
        break;
    }
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
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        // Usar datos reales del ProgressProvider
        final recentActivity = progressProvider.getRecentActivity();
        final weeklyActivity = progressProvider.getWeeklyActivity();
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              onPressed: _goBackToHome,
            ),
            title: Text(
              'Mi Perfil Completo',
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
                    bottom: 20 + bottomPadding + kBottomNavigationBarHeight,
                  ),
                  child: Column(
                    children: [
                      ProfileHeader(
                        name: _fullName,  // Carga real
                        avatar: _avatar,  // Carga real
                        level: _calculateLevelFromPoints(progressProvider.totalPoints),
                        points: progressProvider.totalPoints,
                      ),
                      const SizedBox(height: 20),
                      PersonalInfoSection(
                        language: _language,  // Carga real
                        educationLevel: _educationLevel,  // Carga real
                        community: _municipality,  // Carga real
                        favoriteSubjects: _favoriteSubjects,  // Carga real
                      ),
                      const SizedBox(height: 16),
                      ActivityStatsSection(recentActivity: recentActivity),
                      const SizedBox(height: 16),
                      WeeklyActivityChart(weeklyActivity: weeklyActivity),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  // Calcular nivel basado en puntos (puedes ajustar esta lógica)
  int _calculateLevelFromPoints(int points) {
    if (points < 1000) return 1;
    if (points < 2000) return 2;
    if (points < 3000) return 3;
    if (points < 4000) return 4;
    if (points < 5000) return 5;
    if (points < 6000) return 6;
    if (points < 7000) return 7;
    if (points < 8000) return 8;
    if (points < 9000) return 9;
    if (points < 10000) return 10;
    return 12; // Nivel máximo por ahora
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat_rounded),
            label: 'Chat IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset_outlined),
            activeIcon: Icon(Icons.videogame_asset_rounded),
            label: 'Juegos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books_rounded),
            label: 'Biblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_outlined),
            activeIcon: Icon(Icons.timeline_rounded),
            label: 'Proceso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}