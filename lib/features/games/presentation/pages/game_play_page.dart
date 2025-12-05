import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart'; // Import nuevo

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

  List<Map<String, dynamic>> get questions =>
      widget.gameData['questions'] ?? [];

  Map<String, dynamic> get currentQuestion =>
      questions.isNotEmpty ? questions[currentQuestionIndex] : {};

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      showResult = true;

      if (index == currentQuestion['correctAnswer']) {
        score += 10;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
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

  void _speakQuestion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leyendo pregunta: ${currentQuestion['question']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showGameOverDialog() {
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    // Integra al progreso global: suma puntos y marca como completado
    progressProvider.addPoints(score);
    progressProvider.completeGame(widget.gameData['game']['title']);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '¡Juego Terminado!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Puntuación: $score/${questions.length * 10}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¡Puntos agregados al progreso general! Total: ${progressProvider.totalPoints}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                'Has completado ${widget.gameData['game']?['title'] ?? 'el juego'}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.go('/games'),
              child: Text(
                'Volver a Juegos',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Jugar Otra Vez'),
            ),
          ],
        );
      },
    );
  }

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
          onPressed: () => context.go('/games'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.gameData['game']?['title'] ?? 'Juego',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Pregunta ${currentQuestionIndex + 1}/${questions.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up, color: theme.colorScheme.primary),
            onPressed: _speakQuestion,
            tooltip: 'Escuchar pregunta',
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Puntos: $score',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? Center(
        child: Text(
          'No hay preguntas disponibles',
          style: theme.textTheme.bodyLarge,
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de progreso
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              color: AppTheme.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),

            // Tarjeta de pregunta
            Card(
              elevation: 4,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      currentQuestion['question'] ?? 'Pregunta no disponible',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: Icon(Icons.volume_up, size: 28),
                      onPressed: _speakQuestion,
                      color: theme.colorScheme.primary,
                      tooltip: 'Escuchar pregunta en voz alta',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Opciones de respuesta
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: (currentQuestion['options'] as List?)?.length ?? 0,
                itemBuilder: (context, index) {
                  final options = currentQuestion['options'] as List? ?? [];
                  final option = options.isNotEmpty ? options[index] : 'Opción no disponible';
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == currentQuestion['correctAnswer'];

                  Color? backgroundColor;
                  Color? textColor = theme.colorScheme.onSurface;

                  if (showResult) {
                    if (isCorrect) {
                      backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
                    } else if (isSelected && !isCorrect) {
                      backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
                    }
                  } else {
                    backgroundColor = theme.cardColor;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      color: backgroundColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _getOptionColor(
                              index,
                              isSelected,
                              isCorrect
                          ),
                          radius: 16,
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: theme.textTheme.bodySmall?.fontSize,
                            ),
                          ),
                        ),
                        title: Text(
                          option,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          if (!showResult) {
                            _selectAnswer(index);
                          }
                        },
                      ),
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

  Color _getOptionColor(int index, bool isSelected, bool isCorrect) {
    if (showResult) {
      if (isCorrect) {
        return const Color(0xFF10B981);
      } else if (isSelected && !isCorrect) {
        return const Color(0xFFEF4444);
      }
    }
    return isSelected
        ? AppTheme.primaryColor
        : Colors.grey;
  }
}