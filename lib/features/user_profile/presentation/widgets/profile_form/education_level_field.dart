import 'package:flutter/material.dart';

class EducationLevelField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onLevelSelected;
  final String? Function(String?)? validator;

  const EducationLevelField({
    super.key,
    required this.controller,
    required this.onLevelSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const educationLevels = [
      'Primaria',
      'Secundaria',
      'Preparatoria',
      'Universidad',
    ];

    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Nivel educativo',
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        prefixIcon: Icon(Icons.school_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        suffixIcon: PopupMenuButton<String>(
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          onSelected: onLevelSelected,
          itemBuilder: (BuildContext context) {
            return educationLevels.map((String level) {
              return PopupMenuItem<String>(
                value: level,
                child: Text(level),
              );
            }).toList();
          },
        ),
        hintText: 'Selecciona tu nivel educativo',
      ),
      readOnly: true,
      validator: validator,
    );
  }
}