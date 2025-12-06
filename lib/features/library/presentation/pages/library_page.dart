import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import '../widgets/book_card.dart';
import '../widgets/category_filter.dart';
import '../widgets/search_header.dart';
import 'package:proyectoedumentor/features/library/services/book_service.dart'; // Ajusta ruta si es necesario

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final String _userName = "Juan Pérez"; // Reemplaza con el nombre real del usuario
  final String _userAvatar = "👨‍🎓"; // Avatar del usuario

  String _selectedCategory = 'Todos';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Todos',
    'Primaria',
    'Secundaria',
    'Preparatoria',
    'Universidad',
    'Matemáticas',
    'Ciencias',
    'Literatura',
    'Historia',
    'Idiomas'
  ];

  // Lista estática de libros CONALITEG (siempre disponible)
  final List<Map<String, dynamic>> _staticBooks = [
    {
      'id': 'conaliteg-p1mla',
      'title': 'Múltiples lenguajes. Libro de Educación Primaria Grado 1°',
      'author': 'SEP / CONALITEG',
      'description': 'Libro de texto oficial para el desarrollo de habilidades en múltiples lenguajes. Incluye actividades lúdicas, lectoescritura y expresión oral para niños de primer grado de primaria.',
      'cover': 'https://libros.conaliteg.gob.mx/2025/c/P1MLA/000.jpg', // Cambiado: URL de la imagen real de portada
      'level': 'Primaria',
      'pages': 256,
      'rating': 4.5,
      'category': 'Idiomas',
      'isFavorite': false,
      'color': const Color(0xFF06D6A0), // Verde para idiomas
      'pdfUrl': 'https://libros.conaliteg.gob.mx/2023/P1MLA.htm', // Abre en navegador
    },
    {
      'id': 'conaliteg-s1hua',
      'title': 'Historia. Libro de Educación Secundaria Grado 1°',
      'author': 'SEP / CONALITEG',
      'description': 'Libro de texto oficial para el estudio de la historia universal y de México en primer grado de secundaria. Explora eventos clave, civilizaciones y análisis histórico para adolescentes.',
      'cover': 'https://libros.conaliteg.gob.mx/2025/c/S1HUA/000.jpg', // URL de la imagen real de portada
      'level': 'Secundaria',
      'pages': 200,
      'rating': 4.6,
      'category': 'Historia',
      'isFavorite': false,
      'color': const Color(0xFFF59E0B), // Naranja para historia
      'pdfUrl': 'https://libros.conaliteg.gob.mx/2025/S1HUA.htm', // Abre en navegador (sin #page/1 para inicio)
    },
    // Agrega más aquí si quieres, ej: Matemáticas Primaria
  ];

  late Future<List<Map<String, dynamic>>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooksForQuery();
  }

  Future<List<Map<String, dynamic>>> _fetchBooksForQuery({String category = '', String search = ''}) async {
    // Siempre empieza con estáticos
    List<Map<String, dynamic>> allBooks = List.from(_staticBooks);

    // Intenta cargar dinámicos solo si no es 'Todos' o hay búsqueda (opcional para debug)
    String query = '';
    if (category != 'Todos' || search.isNotEmpty) {
      if (category != 'Todos') {
        final Map<String, String> searchTerms = {
          'Primaria': 'primaria educación',
          'Secundaria': 'secundaria educación',
          'Preparatoria': 'bachillerato educación',
          'Universidad': 'universidad educación',
          'Matemáticas': 'matemáticas álgebra geometría',
          'Ciencias': 'ciencias naturales física química biología',
          'Literatura': 'literatura española clásicos',
          'Historia': 'historia México',
          'Idiomas': 'idiomas español',
        };
        query = searchTerms[category] ?? category;
      }
      if (search.isNotEmpty) {
        query = '$query $search';
      }

      try {
        final dynamicBooks = await fetchBooks(search: query.trim());
        // Fusiona sin duplicados
        allBooks.addAll(dynamicBooks.where((db) => !allBooks.any((sb) => sb['id'] == db['id'])));
      } catch (e) {
        print('Fallo en fetch dinámico (continúa con estáticos): $e');
        // No crashea; usa solo estáticos
      }
    }

    return allBooks;
  }

  List<Map<String, dynamic>> _filterBooks(List<Map<String, dynamic>> books, String category, String search) {
    var filtered = books;
    if (category != 'Todos') {
      filtered = filtered.where((book) =>
      book['title'].toLowerCase().contains(category.toLowerCase()) ||
          book['description'].toLowerCase().contains(category.toLowerCase()) ||
          book['level'].toLowerCase().contains(category.toLowerCase()) ||
          book['category'].toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (search.isNotEmpty) {
      filtered = filtered.where((book) =>
      book['title'].toLowerCase().contains(search.toLowerCase()) ||
          book['author'].toLowerCase().contains(search.toLowerCase()) ||
          book['description'].toLowerCase().contains(search.toLowerCase())).toList();
    }
    return filtered;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _booksFuture = _fetchBooksForQuery(category: category, search: _searchQuery);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _booksFuture = _fetchBooksForQuery(category: _selectedCategory, search: query);
    });
  }

  void _onBookTap(Map<String, dynamic> book) {
    context.push('/book-detail', extra: book);
  }

  void _onFavoriteTap(Map<String, dynamic> book) {
    setState(() {
      book['isFavorite'] = !book['isFavorite'];
    });
  }

  void _clearSearch() {
    _onSearchChanged('');
  }

  // Manejo de navegación del bottom nav
  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/process');
        break;
      case 3:
        context.go('/my-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar (sin cambios)
          SliverAppBar(
            elevation: 0,
            pinned: true,
            floating: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'Biblioteca',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              // Avatar del usuario
              Container(
                margin: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    _userAvatar,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),

          // Header de búsqueda
          SliverToBoxAdapter(
            child: SearchHeader(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onClearSearch: _clearSearch,
              searchQuery: _searchQuery,
            ),
          ),

          // Filtro de categorías
          SliverToBoxAdapter(
            child: CategoryFilter(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
          ),

          // Contador y manejo de errores
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _booksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Error en carga dinámica: ${snapshot.error}',
                          style: TextStyle(color: colorScheme.error, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _booksFuture = _fetchBooksForQuery(); // Reintenta
                            });
                          },
                          child: const Text('Reintentar'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mostrando libros disponibles (${_staticBooks.length})',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron libros',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta con otros términos o categorías',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final books = _filterBooks(snapshot.data!, _selectedCategory, _searchQuery);
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '${books.length} libros encontrados',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),

          // Grid de libros
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _booksFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox());
              final books = _filterBooks(snapshot.data!, _selectedCategory, _searchQuery);
              if (books.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.6, // Más alto para imagen prominente
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final book = books[index];
                      return BookCard(
                        book: book,
                        onTap: () => _onBookTap(book),
                        onFavorite: () => _onFavoriteTap(book),
                      );
                    },
                    childCount: books.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // Bottom Navigation Bar fija en la parte inferior
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // Para que se vea bien con 4 items
        currentIndex: 0,  // Índice actual (puedes hacerlo dinámico con GoRouter listener si quieres)
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Proceso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
        onTap: _onBottomNavTap,
      ),
    );
  }
}