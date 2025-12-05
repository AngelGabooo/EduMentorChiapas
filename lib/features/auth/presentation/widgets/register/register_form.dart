import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../register/register_button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    bool hasMinLength = password.length >= 8;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumbers) score++;
    if (hasSpecialChars) score++;
    setState(() {
      if (score <= 2) {
        _passwordStrength = 'baja';
        _passwordStrengthColor = Colors.red;
      } else if (score == 3) {
        _passwordStrength = 'media';
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrength = 'segura';
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe contener al menos una minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  // MODIFICADO: Ahora soporta tutor también
  void _handleRoleSelection(String? value) {
    if (value == 'maestro') {
      _saveTemporaryData(role: 'maestro');
      if (mounted) {
        context.go('/teacher-register');
      }
    } else if (value == 'tutor') {
      _saveTemporaryData(role: 'tutor');
      if (mounted) {
        context.go('/tutor-register'); // Crea esta pantalla cuando quieras
      }
    } else {
      setState(() {
        _selectedRole = value;
      });
    }
  }

  // MODIFICADO: Ahora recibe el rol como parámetro
  void _saveTemporaryData({required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temp_name', _nameController.text.trim());
    await prefs.setString('temp_email', _emailController.text.trim().toLowerCase());
    final passwordBytes = utf8.encode(_passwordController.text);
    final hashedPassword = sha256.convert(passwordBytes).toString();
    await prefs.setString('temp_hashed_password', hashedPassword);
    await prefs.setString('temp_role', role); // Ahora guarda 'maestro' o 'tutor'
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validación adicional para el rol
      if (_selectedRole == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes seleccionar tu rol')),
          );
        }
        return;
      }
      if (!_acceptedTerms) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes aceptar los términos y condiciones')),
          );
        }
        return;
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('full_name', _nameController.text.trim());
        await prefs.setString('email', _emailController.text.trim().toLowerCase());
        // Hashear la contraseña para seguridad
        final passwordBytes = utf8.encode(_passwordController.text);
        final hashedPassword = sha256.convert(passwordBytes).toString();
        await prefs.setString('hashed_password', hashedPassword);
        // Guardar el rol seleccionado
        await prefs.setString('role', _selectedRole!);
        // Flag para permitir /profile sin redirect a home
        await prefs.setBool('profileCompleted', false);
        print('DEBUG Registro: profileCompleted set to false');
        // Limpiar campos
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _selectedRole = null;
        setState(() {
          _acceptedTerms = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Registro iniciado! Completa tu perfil para continuar.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar a profile después de un breve delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              print('DEBUG: Navegando a /profile');
              context.go('/profile');
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar los datos: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de nombre completo
          TextFormField(
            controller: _nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText:
              'Nombre completo',
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
              ),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre completo';
              }
              if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
                return 'El nombre solo debe contener letras y espacios';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Selección de rol (AHORA CON TUTOR)
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
              DropdownMenuItem(
                value: 'estudiante',
                child: Text('Estudiante'),
              ),
              DropdownMenuItem(
                value: 'maestro',
                child: Text('Maestro'),
              ),
              DropdownMenuItem(
                value: 'tutor',
                child: Text('Tutor'), // AÑADIDO
              ),
            ],
            onChanged: _handleRoleSelection,
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona tu rol';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Campo de email
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
          // Resto del formulario (sin cambios)...
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
            validator: _validatePassword,
          ),
          // Indicador de fortaleza de contraseña
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: _getPasswordStrengthValue(),
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    color: _passwordStrengthColor,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _passwordStrength,
                  style: TextStyle(
                    color: _passwordStrengthColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildPasswordRequirements(isDarkMode),
          ],
          const SizedBox(height: 20),
          // Campo de confirmar contraseña
          TextFormField(
            controller: _confirmPasswordController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Términos y condiciones
          Row(
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
          ),
          const SizedBox(height: 30),
          // Botón de registro (AHORA TAMBIÉN PARA TUTOR)
          if (_selectedRole == 'estudiante' || _selectedRole == 'tutor' || _selectedRole == null)
            RegisterButton(
              onPressed: _submitForm,
            ),
        ],
      ),
    );
  }

  double _getPasswordStrengthValue() {
    switch (_passwordStrength) {
      case 'baja':
        return 0.2;
      case 'media':
        return 0.5;
      case 'segura':
        return 1.0;
      default:
        return 0.0;
    }
  }

  Widget _buildPasswordRequirements(bool isDarkMode) {
    final password = _passwordController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirementItem(
          'Mínimo 8 caracteres',
          password.length >= 8,
          isDarkMode: isDarkMode,
        ),
        _buildRequirementItem(
          'Al menos una mayúscula',
          password.contains(RegExp(r'[A-Z]')),
          isDarkMode: isDarkMode,
        ),
        _buildRequirementItem(
          'Al menos una minúscula',
          password.contains(RegExp(r'[a-z]')),
          isDarkMode: isDarkMode,
        ),
        _buildRequirementItem(
          'Al menos un número',
          password.contains(RegExp(r'[0-9]')),
          isDarkMode: isDarkMode,
        ),
        _buildRequirementItem(
          'Carácter especial (opcional)',
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
          optional: true,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isMet, {bool optional = false, required bool isDarkMode}) {
    final textColor = isDarkMode
        ? (isMet ? Colors.green[300] : Colors.grey[400])
        : (isMet ? Colors.green : Colors.grey);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : (isDarkMode ? Colors.grey[500] : Colors.grey),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 4),
            Text(
              '(opcional)',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[500] : Colors.grey,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}