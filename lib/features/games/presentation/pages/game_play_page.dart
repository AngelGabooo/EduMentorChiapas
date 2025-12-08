import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart';

class GamePlayPage extends StatefulWidget {
  final Map<String, dynamic> gameData;

  const GamePlayPage({
    super.key,
    required this.gameData,
  });

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  int currentQuestionIndex = 0;
  int? selectedAnswer;
  int score = 0;
  bool showResult = false;
  late FlutterTts flutterTts;
  bool isSpeaking = false;

  List<Map<String, dynamic>> get questions =>
      (widget.gameData['questions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

  Map<String, dynamic> get gameInfo => widget.gameData['game'] as Map<String, dynamic>? ?? {};
  String get gameTitle => gameInfo['title']?.toString() ?? 'Juego Educativo';
  String get gameLanguage => widget.gameData['language']?.toString() ?? 'Español';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    flutterTts = FlutterTts();

    // MAPEO EXACTO: tu idioma → código TTS real
    final Map<String, String> ttsMap = {
      'Español': 'es-MX',
      'English': 'en-US',
      'Lacandón': 'es-MX',
      'Mam': 'es-GT',
      'Tojol-ab\'al': 'es-MX',
      'Zoque': 'es-MX',
    };

    final String ttsCode = ttsMap[gameLanguage] ?? 'es-MX';

    await flutterTts.setLanguage(ttsCode);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    // Aviso si es lengua indígena
    if (!['Español', 'English'].contains(gameLanguage)) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pregunta en $gameLanguage. Voz en español claro.'),
              backgroundColor: Colors.deepPurple[700],
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }

    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => isSpeaking = false);
    });
  }

  Future<void> _speakQuestion() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
      return;
    }

    final question = questions.isNotEmpty ? questions[currentQuestionIndex]['question']?.toString() ?? '' : '';
    if (question.isEmpty) return;

    setState(() => isSpeaking = true);
    await flutterTts.speak(question);
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      showResult = true;

      final correctIndex = questions[currentQuestionIndex]['correctAnswer'] as int?;
      if (correctIndex == index) {
        score += 10;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          showResult = false;
        });
      } else {
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    progressProvider.addPoints(score);
    progressProvider.completeGame(gameTitle);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('¡Juego Completado!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Puntuación: $score / ${questions.length * 10}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('¡Has ganado $score puntos!', textAlign: TextAlign.center),
              Text('Juego: $gameTitle', style: TextStyle(color: AppTheme.primaryColor)),
              const SizedBox(height: 8),
              Text('Idioma: $gameLanguage'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.go('/games'),
              child: const Text('Volver a Juegos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  currentQuestionIndex = 0;
                  selectedAnswer = null;
                  score = 0;
                  showResult = false;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('Jugar de Nuevo', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No se pudieron cargar las preguntas')),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = (currentQuestion['options'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gameTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Pregunta ${currentQuestionIndex + 1}/${questions.length}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isSpeaking ? Icons.volume_up_rounded : Icons.volume_up_outlined),
            onPressed: _speakQuestion,
            color: isSpeaking ? Colors.red : null,
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Puntos: $score', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              color: AppTheme.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),

            // Indicador de lengua indígena
            if (!['Español', 'English'].contains(gameLanguage))
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.deepPurple),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over, size: 16, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      'Juego en $gameLanguage',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      currentQuestion['question']?.toString() ?? 'Pregunta no disponible',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _speakQuestion,
                      icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
                      label: Text(isSpeaking ? 'Detener' : 'Escuchar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSpeaking ? Colors.red : AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final isCorrect = index == (currentQuestion['correctAnswer'] as int?);
                  final isSelected = selectedAnswer == index;

                  return Card(
                    color: showResult
                        ? (isCorrect ? Colors.green.withOpacity(0.15) : isSelected ? Colors.red.withOpacity(0.15) : null)
                        : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: showResult
                            ? (isCorrect ? Colors.green : isSelected ? Colors.red : Colors.grey)
                            : (isSelected ? AppTheme.primaryColor : Colors.grey),
                        child: Text(String.fromCharCode(65 + index), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(options[index]),
                      onTap: showResult ? null : () => _selectAnswer(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}