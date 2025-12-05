import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> municipalities;
  final String? Function(String?)? validator;

  const LocationField({
    super.key,
    required this.controller,
    required this.municipalities,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Comunidad o Municipio',
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        prefixIcon: Icon(Icons.location_on_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        suffixIcon: PopupMenuButton<String>(
          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          onSelected: (String value) {
            controller.text = value;
          },
          itemBuilder: (BuildContext context) {
            return municipalities.map((String municipality) {
              return PopupMenuItem<String>(
                value: municipality,
                child: Text(municipality),
              );
            }).toList();
          },
        ),
        hintText: 'Selecciona tu municipio',
      ),
      readOnly: true,
      validator: validator,
    );
  }
}