import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectoedumentor/features/auth/presentation/pages/welcome_page.dart';
import 'package:proyectoedumentor/features/auth/presentation/pages/auth_page.dart';
import 'package:proyectoedumentor/features/auth/presentation/pages/login_page.dart';
import 'package:proyectoedumentor/features/auth/presentation/pages/register_page.dart';
import 'package:proyectoedumentor/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:proyectoedumentor/features/user_profile/presentation/pages/customize_profile_page.dart';
import 'package:proyectoedumentor/features/user_profile/presentation/pages/language_selection_page.dart';
import 'package:proyectoedumentor/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:proyectoedumentor/features/home/presentation/pages/home_page.dart';
import 'package:proyectoedumentor/features/chat/presentation/pages/chat_page.dart';
import 'package:proyectoedumentor/features/process/presentation/pages/process_page.dart';
import 'package:proyectoedumentor/features/games/presentation/pages/games_page.dart';
import 'package:proyectoedumentor/features/games/presentation/pages/game_play_page.dart';
import 'package:proyectoedumentor/features/community/presentation/pages/community_page.dart';
import 'package:proyectoedumentor/features/community/presentation/pages/create_post_page.dart';
import 'package:proyectoedumentor/features/library/presentation/pages/book_detail_page.dart';
import 'package:proyectoedumentor/features/library/presentation/pages/library_page.dart';
import 'package:proyectoedumentor/features/user_profilee/presentation/pages/user_profile_pagee.dart';
import 'package:proyectoedumentor/features/user_profilee/presentation/pages/customize_profile_pagee.dart';
import 'package:proyectoedumentor/features/settings/presentation/pages/settings_page.dart';
import 'package:proyectoedumentor/features/settings/presentation/pages/privacy_page.dart';
// Importaciones para maestros
import 'package:proyectoedumentor/features/teacher/presentation/pages/teacher_register_page.dart';
import 'package:proyectoedumentor/features/teacher/presentation/pages/teacher_home_page.dart';
import 'package:proyectoedumentor/features/teacher/presentation/pages/teacher_profile_dashboard.dart';
import 'package:proyectoedumentor/features/home/presentation/pages/student_classes_page.dart';
// NUEVA IMPORTACIÓN: Registro de Tutor
import 'package:proyectoedumentor/features/tutor/presentation/pages/tutor_register_page.dart';
// NUEVA IMPORTACIÓN: Home del Tutor (padre/madre)
import 'package:proyectoedumentor/features/tutor/presentation/pages/tutor_home_page.dart';

class AppRouter {
  // FUNCIÓN MEJORADA CON SOPORTE PARA "ACABA DE REGISTRARSE"
  static Future<String?> _redirectBasedOnAuth(BuildContext context, GoRouterState state) async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString('current_user_email');
    final role = prefs.getString('role') ?? 'estudiante';
    final justRegistered = prefs.getBool('just_registered') ?? false; // ← CAMBIO AQUÍ

    print('DEBUG Redirect: Email: $currentEmail, Role: $role, JustRegistered: $justRegistered, Path: ${state.uri.path}');

    // SI HAY SESIÓN ACTIVA
    if (currentEmail != null && currentEmail.isNotEmpty) {

      // ← CAMBIO AQUÍ: PRIORIDAD MÁXIMA SI ACABA DE REGISTRARSE
      if (justRegistered) {
        await prefs.remove('just_registered'); // Limpiamos la bandera para que solo pase una vez

        if (role == 'maestro') {
          return '/teacher-profile-dashboard';    // Maestro → su dashboard de perfil
        } else if (role == 'tutor') {
          return '/my-profile';                   // Tutor → pantalla de completar perfil
        } else {
          return '/profile';                      // Estudiante → pantalla de completar perfil (la que quieres)
        }
      }

      // Lógica normal cuando YA TIENE PERFIL COMPLETO
      String targetHome;
      if (role == 'maestro') {
        targetHome = '/teacher-home';
      } else if (role == 'tutor') {
        targetHome = '/tutor-home';
      } else {
        targetHome = '/home';
      }

      if (state.uri.path == targetHome) {
        return null;
      }

      final authPaths = [
        '/',
        '/auth',
        '/login',
        '/register',
        '/teacher-register',
        '/tutor-register',
      ];
      if (authPaths.contains(state.uri.path)) {
        print('Sesión activa → redirigiendo a $targetHome');
        return targetHome;
      }

      return null;
    }

    // NO HAY SESIÓN ACTIVA
    final protectedPaths = [
      '/home',
      '/teacher-home',
      '/tutor-home',
      '/profile',
      '/my-profile',
      '/chat',
      '/games',
      '/library',
      '/community',
      '/process',
      '/student-classes',
      '/teacher-profile-dashboard',
    ];

    if (protectedPaths.contains(state.uri.path) ||
        state.uri.path.startsWith('/game-play') ||
        state.uri.path.startsWith('/book-detail')) {
      print('No hay sesión → redirigiendo a welcome');
      return '/';
    }

    return null;
  }

  static final GoRouter router = GoRouter(
    redirect: _redirectBasedOnAuth,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'welcome',
        pageBuilder: (context, state) => const MaterialPage(child: WelcomePage()),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        pageBuilder: (context, state) => const MaterialPage(child: AuthPage()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => const MaterialPage(child: RegisterPage()),
      ),
      // RUTA DE REGISTRO DE MAESTRO
      GoRoute(
        path: '/teacher-register',
        name: 'teacher-register',
        pageBuilder: (context, state) => const MaterialPage(child: TeacherRegisterPage()),
      ),
      // NUEVA RUTA: Registro de Tutor
      GoRoute(
        path: '/tutor-register',
        name: 'tutor-register',
        pageBuilder: (context, state) => const MaterialPage(child: TutorRegisterPage()),
      ),
      // Home de maestros
      GoRoute(
        path: '/teacher-home',
        name: 'teacher-home',
        pageBuilder: (context, state) => const MaterialPage(child: TeacherHomePage()),
      ),
      // NUEVA RUTA: Home del Tutor (padre/madre)
      GoRoute(
        path: '/tutor-home',
        name: 'tutor-home',
        pageBuilder: (context, state) => const MaterialPage(child: TutorHomePage()),
      ),
      GoRoute(
        path: '/teacher-profile-dashboard',
        name: 'teacher-profile-dashboard',
        pageBuilder: (context, state) => const MaterialPage(child: TeacherProfileDashboard()),
      ),
      GoRoute(
        path: '/student-classes',
        name: 'student-classes',
        pageBuilder: (context, state) => const MaterialPage(child: StudentClassesPage()),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => const MaterialPage(child: UserProfilePage()),
      ),
      GoRoute(
        path: '/my-profile',
        name: 'my-profile',
        pageBuilder: (context, state) => const MaterialPage(child: UserProfilePagee()),
      ),
      GoRoute(
        path: '/customize-my-profile',
        name: 'customize-my-profile',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return MaterialPage(child: CustomizeProfilePagee(extraData: extra));
        },
      ),
      GoRoute(
        path: '/customize-profile',
        name: 'customize-profile',
        pageBuilder: (context, state) => const MaterialPage(child: CustomizeProfilePage()),
      ),
      GoRoute(
        path: '/language-selection',
        name: 'language-selection',
        pageBuilder: (context, state) => const MaterialPage(child: LanguageSelectionPage()),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => const MaterialPage(child: OnboardingPage()),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => const MaterialPage(child: HomePage()),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        pageBuilder: (context, state) => const MaterialPage(child: ChatPage()),
      ),
      GoRoute(
        path: '/process',
        name: 'process',
        pageBuilder: (context, state) => const MaterialPage(child: ProcessPage()),
      ),
      GoRoute(
        path: '/games',
        name: 'games',
        pageBuilder: (context, state) => const MaterialPage(child: GamesPage()),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        pageBuilder: (context, state) => const MaterialPage(child: CommunityPage()),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        pageBuilder: (context, state) => const MaterialPage(child: CreatePostPage()),
      ),
      GoRoute(
        path: '/game-play',
        name: 'game-play',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(child: GamePlayPage(gameData: extra ?? {}));
        },
      ),
      GoRoute(
        path: '/library',
        name: 'library',
        pageBuilder: (context, state) => const MaterialPage(child: LibraryPage()),
      ),
      GoRoute(
        path: '/book-detail',
        name: 'book-detail',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(child: BookDetailPage(book: extra ?? {}));
        },
      ),
      GoRoute(
        path: '/exit',
        name: 'exit',
        pageBuilder: (context, state) => const MaterialPage(child: ExitScreen()),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        pageBuilder: (context, state) => const MaterialPage(child: PrivacyPage()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => const MaterialPage(child: SettingsPage()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
}

