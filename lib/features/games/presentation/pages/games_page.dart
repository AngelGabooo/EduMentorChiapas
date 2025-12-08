import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart';
import 'package:proyectoedumentor/core/services/gemini_service.dart';
import '../widgets/game_category_card.dart';
import '../widgets/language_selector.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  String selectedLanguage = 'Español';
  final List<String> languages = ['Español', 'English', 'Lacandón', 'Mam', 'Tojol-ab\'al', 'Zoque'];
  int _currentIndex = 1;

  final List<Map<String, dynamic>> gameCategories = [
    {
      'id': 1,
      'title': 'Matemáticas Básicas',
      'description': 'Sumas, restas, multiplicaciones y divisiones',
      'icon': Icons.calculate,
      'color': const Color(0xFF3B82F6),
      'difficulty': 'Fácil → Difícil',
      'topic': 'matemáticas básicas para primaria y secundaria',
    },
    {
      'id': 2,
      'title': 'Vocabulario',
      'description': 'Aprende palabras nuevas y su significado',
      'icon': Icons.language,
      'color': const Color(0xFF10B981),
      'difficulty': 'Fácil → Difícil',
      'topic': 'vocabulario en español e inglés',
    },
    {
      'id': 3,
      'title': 'Gramática',
      'description': 'Reglas y uso correcto del idioma',
      'icon': Icons.edit_note,
      'color': const Color(0xFF8B5CF6),
      'difficulty': 'Fácil → Difícil',
      'topic': 'gramática española',
    },
    {
      'id': 4,
      'title': 'Ciencias',
      'description': 'Biología, física y química',
      'icon': Icons.science,
      'color': const Color(0xFFF59E0B),
      'difficulty': 'Fácil → Difícil',
      'topic': 'ciencias naturales',
    },
    {
      'id': 5,
      'title': 'Cultura General',
      'description': 'Historia, arte y curiosidades',
      'icon': Icons.public,
      'color': const Color(0xFFEF4444),
      'difficulty': 'Fácil → Difícil',
      'topic': 'cultura general y historia de Chiapas y México',
    },
    {
      'id': 6,
      'title': 'Geografía',
      'description': 'Países, capitales, ríos y montañas',
      'icon': Icons.map,
      'color': const Color(0xFF06D6A0),
      'difficulty': 'Fácil → Difícil',
      'topic': 'geografía mundial y de México',
    },
  ];

  final geminiService = GeminiService();

  void _onLanguageChanged(String language) {
    setState(() {
      selectedLanguage = language;
    });
  }

  Future<void> _onGameSelected(Map<String, dynamic> game) async {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final String prompt = _buildPrompt(game, selectedLanguage);
      final String response = await geminiService.enviarMensaje(prompt);
      final List<Map<String, dynamic>> questions = _parseGeminiResponse(response);

      if (!mounted) return;
      Navigator.pop(context);

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudieron generar preguntas. Intenta de nuevo.')),
        );
        return;
      }

      context.push('/game-play', extra: {
        'game': game,
        'language': selectedLanguage,
        'questions': questions,
        'gameId': game['id'],
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _buildPrompt(Map<String, dynamic> game, String language) {
    final String topic = game['topic'];
    final String title = game['title'];

    // MAPEO PARA FORZAR EL IDIOMA EXACTO
    final Map<String, String> languageNames = {
      'Español': 'español',
      'English': 'inglés',
      'Lacandón': 'lacandón (lengua mayense de Chiapas)',
      'Mam': 'mam (lengua mayense de Chiapas y Guatemala)',
      'Tojol-ab\'al': 'tojol-ab\'al (lengua mayense de Chiapas)',
      'Zoque': 'zoque (lengua mixe-zoque de Chiapas)',
    };

    final String targetLanguage = languageNames[language] ?? 'español';

    return '''
Eres un experto educativo intercultural para Chiapas.

Genera exactamente 10 preguntas de opción múltiple sobre "$topic" ($title).

TODAS las preguntas, opciones y respuestas deben estar 100% en $targetLanguage.

Dificultad progresiva:
- 1-4: muy fáciles (primaria)
- 5-7: intermedias (secundaria)
- 8-10: difíciles (preparatoria)

Formato JSON exacto (solo el JSON, nada más):

[
  {
    "question": "Pregunta en $targetLanguage",
    "options": ["A", "B", "C", "D"],
    "correctAnswer": 0
  }
]
''';
  }

  List<Map<String, dynamic>> _parseGeminiResponse(String response) {
    try {
      String cleaned = response.trim();
      if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
      if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
      cleaned = cleaned.trim();

      final List<dynamic> jsonList = jsonDecode(cleaned);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error parseando JSON: $e');
      print('Respuesta cruda: $response');
      return [];
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: break;
      case 2: context.go('/library'); break;
      case 3: context.go('/process'); break;
      case 4: context.go('/my-profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Juegos Educativos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LanguageSelector(
              selectedLanguage: selectedLanguage,
              languages: languages,
              onLanguageChanged: _onLanguageChanged,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categorías de Juegos - $selectedLanguage',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Las preguntas son generadas con IA en tiempo real',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: gameCategories.length,
                        itemBuilder: (context, index) {
                          final game = gameCategories[index];
                          return GameCategoryCard(
                            game: game,
                            onTap: () => _onGameSelected(game),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset_outlined), activeIcon: Icon(Icons.videogame_asset_rounded), label: 'Juegos'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books_rounded), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_outlined), activeIcon: Icon(Icons.timeline_rounded), label: 'Proceso'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}