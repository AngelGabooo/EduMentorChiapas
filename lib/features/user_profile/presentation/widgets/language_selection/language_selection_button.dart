import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class LanguageSelectionButton extends StatefulWidget {
  const LanguageSelectionButton({super.key});

  @override
  State<LanguageSelectionButton> createState() => _LanguageSelectionButtonState();
}

class _LanguageSelectionButtonState extends State<LanguageSelectionButton> {
  bool _isLoading = false;

  void _onContinuePressed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Guarda idioma (asumiendo _selectedLanguage de LanguageSelector; similar, usa key o prop)
      final selectedLanguageCode = 'es';  // Reemplaza con valor real de LanguageSelector
      await prefs.setString('selected_language', selectedLanguageCode);

      print('Idioma guardado: $selectedLanguageCode');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Idioma configurado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar al onboarding
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            context.go('/onboarding');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onContinuePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Continuar al Inicio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}