import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import '../widgets/community_header.dart';
import '../widgets/post_card.dart';
import '../widgets/create_post_button.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // Datos de ejemplo del usuario (en una app real vendrían de una base de datos o auth)
  final String currentUserName = "Juan Pérez"; // Reemplaza con el nombre real del usuario

  final List<Map<String, dynamic>> posts = [
    {
      'id': '1',
      'user': {
        'name': 'Ana García',
        'avatar': '👩‍🎓',
        'level': 'Avanzado',
      },
      'content': '¡Acabo de completar el nivel avanzado de matemáticas! 🎉 Fue un reto increíble pero lo logré. ¿Alguien más está estudiando cálculo?',
      'image': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400',
      'timestamp': 'Hace 2 horas',
      'likes': 24,
      'comments': 8,
      'reposts': 3,
      'isLiked': false,
      'isReposted': false,
      'isOwnPost': false,
      'type': 'logro',
    },
    {
      'id': '2',
      'user': {
        'name': 'Carlos López',
        'avatar': '👨‍💻',
        'level': 'Intermedio',
      },
      'content': 'Comparto este tip que me ayudó mucho: Establecer metas pequeñas diarias hace que el aprendizaje sea más llevadero. ¡Hoy completé 5 lecciones! 💪',
      'image': null,
      'timestamp': 'Hace 5 horas',
      'likes': 15,
      'comments': 5,
      'reposts': 2,
      'isLiked': true,
      'isReposted': false,
      'isOwnPost': false,
      'type': 'consejo',
    },
    {
      'id': '3',
      'user': {
        'name': 'Tú',
        'avatar': '👤',
        'level': 'Intermedio',
      },
      'content': '¡Mi primera publicación en la comunidad! Hoy aprendí sobre derivadas y me encantó cómo se aplican en la vida real. ¿Alguien tiene tips para practicar?',
      'image': 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400',
      'timestamp': 'Hace 1 día',
      'likes': 8,
      'comments': 3,
      'reposts': 1,
      'isLiked': false,
      'isReposted': false,
      'isOwnPost': true,
      'type': 'logro',
    },
  ];

  void _onLikePost(int index) {
    setState(() {
      posts[index]['isLiked'] = !posts[index]['isLiked'];
      if (posts[index]['isLiked']) {
        posts[index]['likes']++;
      } else {
        posts[index]['likes']--;
      }
    });
  }

  void _onRepost(int index) {
    setState(() {
      posts[index]['isReposted'] = !posts[index]['isReposted'];
      if (posts[index]['isReposted']) {
        posts[index]['reposts']++;
      } else {
        posts[index]['reposts']--;
      }
    });
  }

  void _onComment(int index) {
    _showCommentsBottomSheet(index);
  }

  void _onDeletePost(int index) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
          ),
          child: AlertDialog(
            title: Text(
              'Eliminar publicación',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar esta publicación? Esta acción no se puede deshacer.',
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    posts.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Publicación eliminada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMoreActions(int index) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (posts[index]['isOwnPost'])
                _buildBottomSheetItem(
                  icon: Icons.delete,
                  text: 'Eliminar publicación',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _onDeletePost(index);
                  },
                ),
              _buildBottomSheetItem(
                icon: Icons.flag,
                text: 'Reportar publicación',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _reportPost(index);
                },
              ),
              _buildBottomSheetItem(
                icon: Icons.share,
                text: 'Compartir enlace',
                color: theme.colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  _sharePost(index);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      onTap: onTap,
    );
  }

  void _showCommentsBottomSheet(int postIndex) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CommentsBottomSheet(
          post: posts[postIndex],
          onCommentAdded: (newComment) {
            setState(() {
              posts[postIndex]['comments']++;
            });
          },
        );
      },
    );
  }

  void _onCreatePost() async {
    final result = await context.push<Map<String, dynamic>?>('/create-post');
    if (result != null) {
      setState(() {
        posts.insert(0, {
          ...result,
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'isOwnPost': true,
          'timestamp': 'Ahora',
        });
      });
    }
  }

  void _reportPost(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reportando publicación de ${posts[index]['user']['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sharePost(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo publicación de ${posts[index]['user']['name']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Comunidad',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.primary),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header moderno de la comunidad - CORREGIDO
          CommunityHeader(userName: currentUserName),

          // Lista de publicaciones
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    post: posts[index],
                    onLike: () => _onLikePost(index),
                    onComment: () => _onComment(index),
                    onRepost: () => _onRepost(index),
                    onMore: () => _onMoreActions(index),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: CreatePostButton(onPressed: _onCreatePost),
    );
  }
}

// Bottom Sheet para comentarios (versión mejorada)
class CommentsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> post;
  final Function(String) onCommentAdded;

  const CommentsBottomSheet({
    super.key,
    required this.post,
    required this.onCommentAdded,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> _comments = [
    {
      'user': {'name': 'Luis Martínez', 'avatar': '👨‍🔬'},
      'content': '¡Felicidades Ana! Yo también estoy en esa lección.',
      'timestamp': 'Hace 1 hora',
      'isOwnComment': false,
    },
    {
      'user': {'name': 'Sofia Rodríguez', 'avatar': '👩‍💼'},
      'content': 'Me encantó tu consejo Carlos, lo pondré en práctica.',
      'timestamp': 'Hace 30 minutos',
      'isOwnComment': false,
    },
  ];

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          'user': {'name': 'Tú', 'avatar': '👤'},
          'content': _commentController.text,
          'timestamp': 'Ahora',
          'isOwnComment': true,
        });
      });
      widget.onCommentAdded(_commentController.text);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _deleteComment(int index) {
    setState(() {
      _comments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header moderno del bottom sheet
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Lista de comentarios
          Expanded(
            child: _comments.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay comentarios aún',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sé el primero en comentar',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Text(
                          comment['user']['avatar'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment['user']['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  if (comment['isOwnComment'])
                                    GestureDetector(
                                      onTap: () => _deleteComment(index),
                                      child: Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment['content'],
                                style: TextStyle(color: theme.colorScheme.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                comment['timestamp'],
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input moderno para nuevo comentario
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Escribe un comentario...',
                        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.emoji_emotions,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          onPressed: () {
                            // Implementar emojis
                          },
                        ),
                      ),
                      onSubmitted: (_) => _addComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}