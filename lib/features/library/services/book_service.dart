import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;  // Para Color, si no lo tienes ya

Future<List<Map<String, dynamic>>> fetchBooks({
  String search = '',
  String lang = 'es',
}) async {
  final String baseUrl = 'https://gutendex.com/books';  // CORREGIDO: https://gutendex (con 'e')
  final Map<String, String> params = {
    'languages': lang,
  };
  if (search.isNotEmpty) {
    params['search'] = search;
  }

  final uri = Uri.https(baseUrl, '', params);
  try {
    print('Fetching from: $uri');  // Debug: Verifica la URL en consola
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // Verifica que body sea JSON válido antes de decode
      if (response.body.startsWith('{') || response.body.startsWith('[')) {
        final data = json.decode(response.body);
        final List results = data['results'] as List? ?? [];
        return results.map((book) {
          final formats = book['formats'] as Map<String, dynamic>? ?? {};
          return {
            'id': book['id'].toString(),
            'title': book['title'] ?? 'Título desconocido',
            'author': (book['authors'] as List?)?.isNotEmpty == true
                ? (book['authors'] as List)[0]['name'] ?? 'Autor desconocido'
                : 'Autor desconocido',
            'description': (book['subjects'] as List?)?.take(3).join(', ') ?? 'Descripción no disponible',
            'cover': formats['image/jpeg'] ?? '',  // URL de portada
            'level': _getLevelFromSubjects(book['subjects'] as List? ?? []),
            'pages': book['downloads'] ?? 0,
            'rating': 4.0,
            'category': search.isEmpty ? 'Clásicos' : search,
            'isFavorite': false,
            'color': const ui.Color(0xFF3B82F6),  // Azul default
            'pdfUrl': formats['application/pdf'] ??
                formats['text/html'] ??
                formats['text/plain; charset=us-ascii'] ??
                '',
          };
        }).toList();
      } else {
        print('Body no es JSON válido: ${response.body.substring(0, 100)}');  // Debug
        return [];
      }
    } else {
      print('Error HTTP ${response.statusCode}: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error completo en fetch: $e');
    return [];  // Siempre devuelve [] en error, no crashea
  }
}

// Helper para nivel (sin cambios)
String _getLevelFromSubjects(List subjects) {
  final lowerSubjects = subjects.map((s) => s.toString().toLowerCase()).toList();
  if (lowerSubjects.any((s) => s.contains('matem') || s.contains('álgebra'))) return 'Matemáticas';
  if (lowerSubjects.any((s) => s.contains('física') || s.contains('química') || s.contains('biología'))) return 'Ciencias';
  if (lowerSubjects.any((s) => s.contains('literatura') || s.contains('poesía'))) return 'Literatura';
  if (lowerSubjects.any((s) => s.contains('historia'))) return 'Historia';
  if (lowerSubjects.any((s) => s.contains('idioma') || s.contains('lengua'))) return 'Idiomas';
  return 'General';
}