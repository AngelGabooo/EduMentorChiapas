import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart'; // Import nuevo
import '../widgets/process_stats.dart';
import '../widgets/process_timeline.dart';
import '../widgets/process_lessons.dart';

class ProcessPage extends StatefulWidget {
  const ProcessPage({super.key});

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  // Lecciones base (inicialmente todas no completadas para reset)
  List<Map<String, dynamic>> baseLessons = [
    {
      'id': 1,
      'title': 'Introducción a las Matemáticas',
      'description': 'Conceptos básicos y operaciones fundamentales',
      'completed': false, // Cambiado a false para reset inicial
      'duration': '30 min',
      'points': 100,
    },
    {
      'id': 2,
      'title': 'Álgebra Básica',
      'description': 'Ecuaciones y expresiones algebraicas',
      'completed': false, // Cambiado a false
      'duration': '45 min',
      'points': 150,
    },
    {
      'id': 3,
      'title': 'Geometría',
      'description': 'Formas y medidas geométricas',
      'completed': false, // Cambiado a false
      'duration': '40 min',
      'points': 200,
    },
    {
      'id': 4,
      'title': 'Trigonometría',
      'description': 'Funciones trigonométricas y aplicaciones',
      'completed': false,
      'duration': '50 min',
      'points': 250,
    },
    {
      'id': 5,
      'title': 'Cálculo Básico',
      'description': 'Introducción a derivadas e integrales',
      'completed': false,
      'duration': '60 min',
      'points': 300,
    },
  ];

  // Función para regresar al home
  void _goBackToHome(BuildContext context) {
    context.goNamed('home');
  }

  // Función para reiniciar progreso (llama al provider y resetea base lessons)
  void _resetProgress(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reiniciar Progreso'),
          content: const Text(
            '¿Estás seguro? Esto borrará todos tus puntos, rachas, avances y lecciones. No se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                progressProvider.resetProgress();
                // Reinicia base lessons: todas completed = false
                setState(() {
                  for (var lesson in baseLessons) {
                    lesson['completed'] = false;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progreso reiniciado exitosamente. ¡Empieza de nuevo!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  // Manejo de navegación del bottom nav (índice 2 para Process activo)
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
      // Ya está en Process, no hace nada
        break;
      case 3:
        context.go('/my-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>( // Usa Consumer para updates en tiempo real
      builder: (context, progressProvider, child) {
        // Lecciones dinámicas: base + juegos completados (se resetean en dialog)
        List<Map<String, dynamic>> dynamicLessons = List.from(baseLessons);
        // Agrega entradas de juegos completados (últimos 5 para no sobrecargar)
        final recentGames = progressProvider.completedGamesHistory.take(5).toList();
        for (int i = 0; i < recentGames.length; i++) {
          dynamicLessons.add({
            'id': 'game-${progressProvider.completedGames - recentGames.length + i + 1}',
            'title': 'Juego Completado: ${recentGames[i]}', // Muestra el apartado específico del juego
            'description': 'Ganaste puntos en esta categoría de juego educativo.',
            'completed': true,
            'duration': '15-30 min', // Estimado para juegos
            'points': 0, // No suma puntos aquí; ya en totalPoints
          });
        }

        final Map<String, dynamic> userProgress = {
          'totalLessons': progressProvider.totalLessons + progressProvider.completedGames, // Incluye juegos
          'completedLessons': progressProvider.completedLessons + progressProvider.completedGames,
          'currentLevel': progressProvider.currentLevel,
          'streakDays': progressProvider.streakDays,
          'totalPoints': progressProvider.totalPoints,
          'progressPercentage': progressProvider.progressPercentage,
          'completedGames': progressProvider.completedGames,
        };

        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              onPressed: () => _goBackToHome(context),
            ),
            title: Text(
              'Mi Proceso de Aprendizaje',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: () => _resetProgress(context), // Botón de reset
                tooltip: 'Reiniciar Progreso',
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estadísticas del progreso (ahora dinámico con juegos)
                  ProcessStats(userProgress: userProgress),
                  const SizedBox(height: 24),
                  // Línea de tiempo del progreso (con juegos en "Tu Journey Educativo")
                  Text(
                    'Tu Journey Educativo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProcessTimeline(lessons: dynamicLessons), // Usa dinámicas (se resetean)
                  const SizedBox(height: 24),
                  // Lista de lecciones (con juegos)
                  Text(
                    'Lecciones y Juegos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ProcessLessons(lessons: dynamicLessons), // Usa dinámicas (se resetean)
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar fija en la parte inferior
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,  // Para que se vea bien con 4 items
            currentIndex: 2,  // Índice actual para Process (índice 2)
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            backgroundColor: Theme.of(context).colorScheme.surface,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timeline),
                label: 'Proceso',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Perfil',
              ),
            ],
            onTap: _onBottomNavTap,
          ),
        );
      },
    );
  }
}