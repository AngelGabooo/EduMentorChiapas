import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // Necesario para hashear contraseña
import '../../domain/models/teacher_model.dart';

class TeacherRegisterForm extends StatefulWidget {
  const TeacherRegisterForm({super.key});

  @override
  _TeacherRegisterFormState createState() => _TeacherRegisterFormState();
}

class _TeacherRegisterFormState extends State<TeacherRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  final List<String> _availableSubjects = [
    'Matemáticas',
    'Español',
    'Ciencias',
    'Historia',
    'Geografía',
    'Inglés',
    'Arte',
    'Música',
    'Educación Física',
    'Computación'
  ];

  final List<String> _availableLanguages = [
    'Español',
    'Tsotsil',
    'Tseltal',
    'Chol',
    'Zoque',
    'Man',
    'Lacandon',
    'Tojol-ab'
  ];

  List<String> _selectedSubjects = [];
  List<String> _selectedLanguages = [];
  bool _isLoading = false;

  void _registerTeacher() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSubjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona al menos una materia')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final email = _emailController.text.trim().toLowerCase();

        // Verificar si el correo ya está registrado (en registered_emails)
        final registeredJson = prefs.getString('registered_emails') ?? '[]';
        final List<dynamic> registered = json.decode(registeredJson);
        if (registered.contains(email)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('El correo $email ya está registrado'), backgroundColor: Colors.red),
          );
          setState(() => _isLoading = false);
          return;
        }

        // Hashear contraseña
        final passwordBytes = utf8.encode(_passwordController.text);
        final hashedPassword = sha256.convert(passwordBytes).toString();

        // Crear modelo del maestro
        final teacher = TeacherModel(
          email: email,
          password: hashedPassword,
          name: _nameController.text.trim(),
          subjects: _selectedSubjects,
          languages: _selectedLanguages,
          registrationNumber: _registrationNumberController.text.trim(),
          userType: 'maestro',
        );

        // GUARDAR COMO USUARIO REAL (igual que estudiante)
        await prefs.setString('user_$email', json.encode({
          'email': email,
          'hashed_password': hashedPassword,
          'role': 'maestro',
          'full_name': teacher.name,
          'profileCompleted': true,
          'teacherData': teacher.toJson(), // Guardamos todo el perfil del maestro
        }));

        // GUARDAR SESIÓN ACTIVA (ESTO ES LO MÁS IMPORTANTE)
        await prefs.setString('current_user_email', email);
        await prefs.setString('email', email);
        await prefs.setString('role', 'maestro');
        await prefs.setString('full_name', teacher.name);

        // Añadir a lista de registrados
        registered.add(email);
        await prefs.setString('registered_emails', json.encode(registered));

        // Éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro como maestro exitoso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar al home del maestro
        if (mounted) {
          context.go('/teacher-home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showSubjectsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Selecciona las materias'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _availableSubjects[index];
                  return CheckboxListTile(
                    title: Text(subject),
                    value: _selectedSubjects.contains(subject),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedSubjects.add(subject);
                        } else {
                          _selectedSubjects.remove(subject);
                        }
                      });
                      setState(() {}); // Actualiza el texto principal
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguagesDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Selecciona los idiomas'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableLanguages.length,
                itemBuilder: (context, index) {
                  final language = _availableLanguages[index];
                  return CheckboxListTile(
                    title: Text(language),
                    value: _selectedLanguages.contains(language),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedLanguages.add(language);
                        } else {
                          _selectedLanguages.remove(language);
                        }
                      });
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre completo';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registrationNumberController,
            decoration: const InputDecoration(
              labelText: 'Número de matrícula',
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu número de matrícula';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showSubjectsDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Materias que imparte',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSubjects.isEmpty
                        ? 'Selecciona las materias'
                        : _selectedSubjects.join(', '),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showLanguagesDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Idiomas que habla',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLanguages.isEmpty
                        ? 'Selecciona los idiomas'
                        : _selectedLanguages.join(', '),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerTeacher,
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Registrarse como Maestro'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }
}