import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

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
      questions[currentQuestionIndex];

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
      showResult = true;

      if (index == currentQuestion['correctAnswer']) {
        score += 10;
      }
    });

    // Pasar a la siguiente pregunta después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswer = null;
          showResult = false;
        });
      } else {
        // Juego terminado
        _showGameOverDialog();
      }
    });
  }

  void _speakQuestion() {
    // Aquí implementarás la funcionalidad de texto a voz
    // Por ahora solo mostraremos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leyendo pregunta: ${currentQuestion['question']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Juego Terminado!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Puntuación: $score/${questions.length * 10}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Has completado ${widget.gameData['game']['title']}',
                textAlign: TextAlign.center,
              ),
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
              child: const Text('Jugar Otra Vez'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.go('/games'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.gameData['game']['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            Text(
              'Pregunta ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppTheme.primaryColor),
            onPressed: _speakQuestion,
            tooltip: 'Escuchar pregunta',
          ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Puntos: $score',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: questions.isEmpty
          ? const Center(child: Text('No hay preguntas disponibles'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de progreso
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.grey[300],
              color: AppTheme.primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Pregunta
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      currentQuestion['question'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 32),
                      onPressed: _speakQuestion,
                      color: AppTheme.primaryColor,
                      tooltip: 'Escuchar pregunta en voz alta',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de respuesta
            Expanded(
              child: ListView.builder(
                itemCount: (currentQuestion['options'] as List).length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == currentQuestion['correctAnswer'];

                  Color? backgroundColor;
                  if (showResult) {
                    if (isCorrect) {
                      backgroundColor = const Color(0xFF10B981).withOpacity(0.1);
                    } else if (isSelected && !isCorrect) {
                      backgroundColor = const Color(0xFFEF4444).withOpacity(0.1);
                    }
                  }

                  return Card(
                    color: backgroundColor,
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getOptionColor(
                            index,
                            isSelected,
                            isCorrect
                        ),
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        option,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        if (!showResult) {
                          _selectAnswer(index);
                        }
                      },
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
        return const Color(0xFF10B981); // Verde para respuesta correcta
      } else if (isSelected && !isCorrect) {
        return const Color(0xFFEF4444); // Rojo para respuesta incorrecta seleccionada
      }
    }
    return isSelected
        ? AppTheme.primaryColor
        : Colors.grey;
  }
}