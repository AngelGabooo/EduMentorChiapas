// features/tutor/presentation/pages/widgets/tutor_register_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'tutor_register_button.dart';

class TutorRegisterForm extends StatefulWidget {
  const TutorRegisterForm({super.key});

  @override
  State<TutorRegisterForm> createState() => _TutorRegisterFormState();
}

class _TutorRegisterFormState extends State<TutorRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Campos del tutor (padre/madre)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Campos del hijo
  final _nombreHijoController = TextEditingController();
  final _edadHijoController = TextEditingController();
  final _telefonoController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreHijoController.dispose();
    _edadHijoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    setState(() {
      if (score <= 2) {
        _passwordStrength = 'Débil';
        _passwordStrengthColor = Colors.red;
      } else if (score <= 4) {
        _passwordStrength = 'Media';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Fuerte';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _finalizarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim().toLowerCase();
      final String password = _passwordController.text;
      final String hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Guardar datos del tutor
      await prefs.setString('full_name', name);
      await prefs.setString('email', email);
      await prefs.setString('hashed_password', hashedPassword);
      await prefs.setString('role', 'tutor');
      await prefs.setBool('profileCompleted', true);
      await prefs.setBool('isLoggedIn', true);

      // Guardar datos del hijo
      await prefs.setString('hijo_nombre', _nombreHijoController.text.trim());
      await prefs.setString('hijo_edad', _edadHijoController.text.trim());
      await prefs.setString('tutor_telefono', _telefonoController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro completado! Bienvenido, padre/madre'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1800));

        if (mounted) {
          context.go('/tutor-home'); // Entra directo al home del tutor
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // === DATOS DEL TUTOR (PADRE/MADRE) ===
          Text(
            'Tus datos',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo del padre/madre',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) => v?.trim().isEmpty ?? true ? 'Ingresa tu nombre' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onChanged: (_) => _checkPasswordStrength(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa una contraseña';
              if (v.length < 8) return 'Mínimo 8 caracteres';
              if (!v.contains(RegExp(r'[A-Z]'))) return 'Falta mayúscula';
              if (!v.contains(RegExp(r'[0-9]'))) return 'Falta un número';
              return null;
            },
          ),

          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _passwordStrength == 'Débil' ? 0.33 : _passwordStrength == 'Media' ? 0.66 : 1.0,
                    color: _passwordStrengthColor,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 12),
                Text(_passwordStrength, style: TextStyle(color: _passwordStrengthColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            validator: (v) => v != _passwordController.text ? 'Las contraseñas no coinciden' : null,
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // === DATOS DEL HIJO/A ===
          Text(
            'Datos de tu hijo/a',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nombreHijoController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo de tu hijo/a',
              prefixIcon: Icon(Icons.child_care),
            ),
            validator: (v) => v?.trim().isEmpty ?? true ? 'Ingresa el nombre del niño/a' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _edadHijoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Edad de tu hijo/a',
              prefixIcon: Icon(Icons.cake),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa la edad';
              final edad = int.tryParse(v);
              if (edad == null || edad < 3 || edad > 18) return 'Edad entre 3 y 18 años';
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Tu teléfono de contacto',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (v) => (v?.length ?? 0) < 10 ? 'Teléfono inválido (mín. 10 dígitos)' : null,
          ),

          const SizedBox(height: 40),

          // BOTÓN FINAL
          TutorRegisterButton(
            onPressed: _finalizarRegistro,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}