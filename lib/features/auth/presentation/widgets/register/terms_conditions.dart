import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return theme.colorScheme.primary;
            }
            return isDarkMode ? Colors.grey[600]! : Colors.grey[400]!;
          }),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Acepto los ',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'términos y condiciones',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' y la ',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                TextSpan(
                  text: 'política de privacidad',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}