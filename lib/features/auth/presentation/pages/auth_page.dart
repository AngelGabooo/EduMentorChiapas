import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/core/constants/app_constants.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'dart:async';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  double _progressValue = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _startLoadingSimulation();
  }

  void _startLoadingSimulation() {
    _controller.forward();

    const totalSteps = 10;
    var currentStep = 0;

    _loadingTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      setState(() {
        currentStep++;
        _progressValue = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
                Color(0xFF0F172A),
              ],
              stops: [0.0, 0.4, 1.0],
            )
                : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE0F2FE),
                Colors.white,
                Colors.white,
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            children: [
              _buildCornerGradients(isDarkMode),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Preparando tu entorno de aprendizaje',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildProgressIndicator(isDarkMode),
                    const SizedBox(height: 30),
                    _buildLoadingText(isDarkMode),
                    const SizedBox(height: 20),
                    Text(
                      '${(_progressValue * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDarkMode) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 12,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: MediaQuery.of(context).size.width * 0.8 * _progressValue,
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF1D4ED8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingText(bool isDarkMode) {
    String loadingText = 'Inicializando...';
    if (_progressValue > 0.3) loadingText = 'Cargando recursos...';
    if (_progressValue > 0.6) loadingText = 'Configurando IA...';
    if (_progressValue > 0.8) loadingText = 'Finalizando...';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        loadingText,
        key: ValueKey<String>(loadingText),
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCornerGradients(bool isDarkMode) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.primaryColor.withOpacity(0.1),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF3B82F6).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.secondaryColor.withOpacity(0.1),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF1D4ED8).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.accentColor.withOpacity(0.05),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF60A5FA).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomRight,
                radius: 1.0,
                colors: isDarkMode
                    ? [
                  AppTheme.primaryColor.withOpacity(0.05),
                  Colors.transparent,
                ]
                    : [
                  const Color(0xFF2563EB).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}