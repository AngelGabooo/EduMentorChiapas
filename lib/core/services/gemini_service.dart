// lib/core/services/gemini_service.dart
import 'dart:ui';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class GeminiService {
  late final GenerativeModel _model;
  final List<Content> _history = [];

  GeminiService() {
    final googleAI = FirebaseAI.googleAI(auth: FirebaseAuth.instance);
    _model = googleAI.generativeModel(
      model: 'gemini-2.5-flash', // ← Tu modelo preferido (estable y gratis)
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 8192,
      ),
      systemInstruction: Content.text(
        'Eres un bibliotecario experto de la SEP México. Solo respondes con JSON válido. Nunca explicas, nunca usas markdown.',
      ),
    );
  }

  // NUEVA FUNCIÓN: Generar libros
  Future<List<Map<String, dynamic>>> generarLibros({
    required String nivel,
    required String materia,
    int cantidad = 12,
  }) async {
    try {
      final prompt = '''
Genera exactamente $cantidad libros educativos reales para $nivel en la materia "$materia" en México.

Usa SOLO libros oficiales de:
- CONALITEG (libros.conaliteg.gob.mx)
- UNAM, IPN, UAM (libros abiertos)
- SEP

Cada libro debe tener:
{
  "title": "Título oficial exacto",
  "author": "SEP / CONALITEG",
  "description": "Descripción corta y atractiva del libro",
  "cover": "URL real de la portada (termina en .jpg)",
  "pdfUrl": "URL real del libro (termina en .htm o .pdf)",
  "level": "$nivel",
  "category": "$materia",
  "pages": 200-400,
  "rating": 4.5-5.0,
  "isFavorite": false,
  "color": "0xFF3B82F6" o similar (solo el código hex sin Color())
}

Devuelve SOLO el JSON válido, sin texto extra, sin ```json:
[
  { ... },
  { ... }
]
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';

      // Limpiar respuesta
      String jsonStr = text.trim();
      if (jsonStr.startsWith('```')) {
        final lines = jsonStr.split('\n');
        jsonStr = lines.skip(1).join('\n');
        if (jsonStr.endsWith('```')) {
          jsonStr = jsonStr.substring(0, jsonStr.length - 3);
        }
      }

      final List<dynamic> list = jsonDecode(jsonStr);

      // CONVERTIR EL COLOR STRING → Color real
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final colorStr = map['color']?.toString() ?? '0xFF3B82F6';
        int colorValue = 0xFF3B82F6;
        try {
          if (colorStr.startsWith('0x') || colorStr.startsWith('0X')) {
            colorValue = int.parse(colorStr);
          } else if (colorStr.startsWith('#')) {
            colorValue = int.parse('0xFF${colorStr.substring(1)}');
          }
        } catch (e) {
          colorValue = 0xFF3B82F6;
        }
        map['color'] = Color(colorValue);
        return map;
      }).toList();

    } catch (e) {
      print('Error generando libros con Gemini: $e');
      return _librosEstaticos(nivel, materia);
    }
  }

  // Fallback si se acaba la cuota (CORREGIDO: sin const)
  List<Map<String, dynamic>> _librosEstaticos(String nivel, String materia) {
    return [
      {
        'title': '$materia - $nivel (SEP Oficial)',
        'author': 'SEP / CONALITEG',
        'description': 'Libro de texto gratuito oficial del gobierno de México.',
        'cover': 'https://libros.conaliteg.gob.mx/2025/c/P1MAT/000.jpg',
        'pdfUrl': 'https://libros.conaliteg.gob.mx/2025/P1MAT.htm',
        'level': nivel,
        'category': materia,
        'pages': 280,
        'rating': 4.9,
        'isFavorite': false,
        'color': Color(0xFF3B82F6), // ← SIN const: ahora funciona perfecto
      }
    ];
  }

  // Mantén tu función original para chat
  Future<String> enviarMensaje(String mensajeUsuario) async {
    try {
      _history.add(Content.text(mensajeUsuario));
      final response = await _model.generateContent(_history);
      final texto = response.text ?? "Lo siento, no pude responder.";
      _history.add(Content.model([TextPart(texto)]));
      return texto;
    } catch (e) {
      return "Error con IA: $e";
    }
  }

  void limpiarHistorial() => _history.clear();
}