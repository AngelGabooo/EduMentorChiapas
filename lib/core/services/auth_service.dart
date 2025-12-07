import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el login
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Datos del usuario
      final String email = googleUser.email.toLowerCase();
      final String displayName = googleUser.displayName ?? '';
      final String photoUrl = googleUser.photoUrl ?? '';
      final String googleId = googleUser.id;

      // Guardar en SharedPreferences (igual que tu login normal)
      final prefs = await SharedPreferences.getInstance();

      // Verificar si ya está registrado con este correo
      final registeredEmailsJson = prefs.getString('registered_emails') ?? '[]';
      final List<dynamic> registeredEmails = json.decode(registeredEmailsJson);

      if (!registeredEmails.contains(email)) {
        // Si no está registrado → mostrar mensaje o redirigir a registro
        // Por ahora lo permitimos y creamos uno básico (puedes cambiar esta lógica)
        await _registerGoogleUser(email, displayName, prefs);
        registeredEmails.add(email);
        await prefs.setString('registered_emails', json.encode(registeredEmails));
      }

      // Obtener rol del usuario (debes tenerlo guardado previamente)
      final userDataJson = prefs.getString('user_$email');
      String role = 'estudiante'; // por defecto

      if (userDataJson != null) {
        final userData = json.decode(userDataJson);
        role = userData['role'] ?? 'estudiante';
      }

      // Guardar sesión actual
      await prefs.setString('current_user_email', email);
      await prefs.setString('email', email);
      await prefs.setString('role', role);
      await prefs.setString('full_name', displayName);
      await prefs.setString('photo_url', photoUrl);
      await prefs.setBool('is_google_user', true);

      return true;
    } catch (e) {
      print('Error Google Sign-In: $e');
      return false;
    }
  }

  static Future<void> _registerGoogleUser(String email, String name, SharedPreferences prefs) async {
    final userData = {
      'full_name': name,
      'role': 'estudiante', // puedes preguntar después o tener un flujo de selección
      'hashed_password': '', // no tiene contraseña
      'registered_with_google': true,
    };
    await prefs.setString('user_$email', json.encode(userData));
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    await prefs.remove('role');
    await prefs.remove('email');
  }
}