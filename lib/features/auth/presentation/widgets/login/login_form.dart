import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'login_button.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadStoredRole();
  }

  Future<void> _loadStoredRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedRole = prefs.getString('role');
      if (storedRole != null && mounted) {
        setState(() {
          _selectedRole = storedRole;
        });
      }
    } catch (e) {
      // Ignorar errores al cargar
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes seleccionar tu rol')),
          );
        }
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final storedEmail = prefs.getString('email')?.toLowerCase().trim();
        final storedHashedPassword = prefs.getString('hashed_password');
        final storedRole = prefs.getString('role');

        final enteredEmail = _emailController.text.toLowerCase().trim();
        final enteredPassword = _passwordController.text;

        if (storedEmail == null || storedHashedPassword == null || storedRole == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No hay cuenta registrada. Por favor, regístrate primero.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        if (enteredEmail != storedEmail) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Correo electrónico no encontrado.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (_selectedRole != storedRole) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol incorrecto. Verifica tu selección.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final passwordBytes = utf8.encode(enteredPassword);
        final hashedEnteredPassword = sha256.convert(passwordBytes).toString();

        if (hashedEnteredPassword != storedHashedPassword) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contraseña incorrecta.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Bienvenido!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al verificar: $e'),
              backgroundColor: Colors.red,
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!value.contains('@')) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // ROL CON TUTOR AÑADIDO
          DropdownButtonFormField<String>(
            value: _selectedRole,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Selecciona tu rol',
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              prefixIcon: Icon(Icons.school_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
              DropdownMenuItem(value: 'maestro', child: Text('Maestro')),
              DropdownMenuItem(value: 'tutor', child: Text('Tutor')), // AÑADIDO
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona tu rol';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _passwordController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navegar a recuperación de contraseña
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 30),
          LoginButton(
            onPressed: _submitForm,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}