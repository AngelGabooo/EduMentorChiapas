import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import 'package:intl/intl.dart'; // ← NUEVO: Para formatear la fecha

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final Function(DateTime) onDateSelected;
  final String? Function(String?)? validator;
  const DatePickerField({
    super.key,
    required this.controller,
    required this.onDateSelected,
    this.validator,
  });

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // ← MODIFICADO: Fechas fijas para años 2000 a 2030
    final firstDate = DateTime(2000, 1, 1); // Inicio del año 2000
    final lastDate = DateTime(2030, 12, 31); // Fin del año 2030
    final initialDate = DateTime(2015, 1, 1); // Inicial en el medio del rango para mejor UX

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: AppTheme.onPrimaryColor,
              surface: AppTheme.darkSurfaceColor,
              onSurface: AppTheme.darkTextColor,
              background: AppTheme.darkBackgroundColor,
            )
                : ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: AppTheme.onPrimaryColor,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textColor,
              background: AppTheme.backgroundColor,
            ),
            dialogBackgroundColor: isDarkMode ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // ← NUEVO: Formatear la fecha al seleccionar (DD/MM/AAAA)
      final formatter = DateFormat('dd/MM/yyyy');
      controller.text = formatter.format(picked);
      onDateSelected(picked);
    }
  }

  // ← NUEVO: Función para calcular edad actual
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final currentMonth = now.month;
    final birthMonth = birthDate.month;
    if (currentMonth < birthMonth || (currentMonth == birthMonth && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ← MODIFICADO: Validador ajustado para el nuevo rango (opcional: puedes remover si no necesitas validación de edad)
  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona tu fecha de nacimiento';
    }
    // Parsear la fecha del texto (asumiendo formato DD/MM/AAAA)
    try {
      final formatter = DateFormat('dd/MM/yyyy');
      final birthDate = formatter.parseStrict(value);
      // Verificar que esté en el rango 2000-2030 (el picker ya lo limita, pero por seguridad)
      if (birthDate.year < 2000 || birthDate.year > 2030) {
        return 'La fecha debe estar entre 2000 y 2030';
      }
      // Opcional: Mantener validación de edad (ajusta si es necesario)
      final age = _calculateAge(birthDate);
      if (age < 0) { // No permitir fechas futuras
        return 'No se permiten fechas futuras';
      }
      return null;
    } catch (e) {
      return 'Fecha inválida. Usa el selector de fecha';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Fecha de nacimiento',
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        prefixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.onSurface.withOpacity(0.6)),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_month, color: colorScheme.onSurface.withOpacity(0.6)),
          onPressed: () => _selectDate(context),
        ),
        hintText: 'DD/MM/AAAA',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.1),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      // ← MODIFICADO: Usar validador por defecto si no se proporciona uno
      validator: validator ?? _defaultValidator,
    );
  }
}