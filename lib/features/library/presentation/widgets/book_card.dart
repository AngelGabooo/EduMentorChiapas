import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageWidth = constraints.maxWidth * 0.62;  // Aumentado a 55% para más ancho y acoplamiento
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(8),  // Reducido a 8px para más espacio a la imagen
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (book['color'] as Color).withOpacity(0.1),
                    (book['color'] as Color).withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Portada más ancha y centrada (ahora acopla mejor al contenedor)
                  Container(
                    width: imageWidth,
                    height: 140,
                    margin: const EdgeInsets.symmetric(horizontal: 4),  // Leve margen para integración visual
                    decoration: BoxDecoration(
                      color: book['color'],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: book['cover'].toString().startsWith('http')
                          ? Image.network(
                        book['cover'],
                        fit: BoxFit.cover,  // Cover para llenar sin distorsión
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 50,
                        ),
                      )
                          : Center(
                        child: Text(
                          book['cover'].toString(),
                          style: const TextStyle(fontSize: 50, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título y autor (ajustados)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book['author'],
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Nivel, rating y favorito (abajo)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: book['color'] as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book['level'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            book['rating'].toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              book['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                              color: book['isFavorite'] ? Colors.red : colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            onPressed: onFavorite,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}