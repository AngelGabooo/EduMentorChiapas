import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/core/constants/app_constants.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_buttons.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navegar al home cuando termine el onboarding
      context.go('/home');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // Removido backgroundColor: se usa el del theme
      body: SafeArea(
        child: Column(
          children: [
            // Imagen que cubre el 30% de la pantalla
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Image.asset(
                'assets/img/logo.png',
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 60,
                      color: colorScheme.onPrimary, // Blanco o equivalente en oscuro
                    ),
                  );
                },
              ),
            ),

            // Contenido del onboarding
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  OnboardingContent(
                    title: 'Aprende en tu idioma',
                    description: 'Educación personalizada en español y lenguas indígenas de Chiapas.',
                  ),
                  OnboardingContent(
                    title: 'Contenido Adaptado',
                    description: 'Lecciones y ejercicios diseñados específicamente para tu nivel educativo y contexto cultural.',
                  ),
                  OnboardingContent(
                    title: 'Tutoría Inteligente',
                    description: 'Nuestra IA te acompaña en tu proceso de aprendizaje, ofreciendo ayuda personalizada cuando la necesites.',
                  ),
                ],
              ),
            ),

            // Indicador de páginas (3 puntos)
            OnboardingIndicator(
              currentPage: _currentPage,
              pageCount: 3,
            ),
            const SizedBox(height: 20),

            // Botones de regresar y siguiente
            OnboardingButtons(
              currentPage: _currentPage,
              onPrevious: _previousPage,
              onNext: _nextPage,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}