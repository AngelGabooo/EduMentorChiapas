import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onMore;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onRepost,
    required this.onMore,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'logro':
        return const Color(0xFFFFD166);
      case 'consejo':
        return const Color(0xFF06D6A0);
      case 'duda':
        return const Color(0xFF118AB2);
      case 'anuncio':
        return const Color(0xFFEF476F);
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'logro':
        return '🎯 Logro';
      case 'consejo':
        return '💡 Consejo';
      case 'duda':
        return '❓ Duda';
      case 'anuncio':
        return '📢 Anuncio';
      default:
        return '📝 Publicación';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'logro':
        return Icons.emoji_events;
      case 'consejo':
        return Icons.lightbulb;
      case 'duda':
        return Icons.help;
      case 'anuncio':
        return Icons.announcement;
      default:
        return Icons.post_add;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
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
                  child: Center(
                    child: Text(
                      post['user']['avatar'],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['user']['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            _getTypeIcon(post['type']),
                            size: 14,
                            color: _getTypeColor(post['type']),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${post['user']['level']} • ${post['timestamp']}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (post['isOwnPost'])
                  _buildOwnPostBadge()
                else
                  IconButton(
                    icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                    onPressed: onMore,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
              ],
            ),
          ),

          // Contenido del post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              post['content'],
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Imagen del post
          if (post['image'] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Estadísticas del post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildStatItem(
                  icon: Icons.favorite,
                  count: post['likes'],
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.chat_bubble_outline,
                  count: post['comments'],
                  color: Colors.blue.shade400,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  icon: Icons.repeat,
                  count: post['reposts'],
                  color: Colors.green.shade400,
                ),
              ],
            ),
          ),

          // Acciones del post
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompactActionButton(
                  icon: post['isLiked'] ? Icons.favorite : Icons.favorite_outline,
                  label: 'Me gusta',
                  isActive: post['isLiked'],
                  activeColor: Colors.red,
                  onTap: onLike,
                  colorScheme: colorScheme,
                ),
                _buildCompactActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Comentar',
                  onTap: onComment,
                  colorScheme: colorScheme,
                ),
                _buildCompactActionButton(
                  icon: post['isReposted'] ? Icons.repeat_on : Icons.repeat,
                  label: 'Repostear',
                  isActive: post['isReposted'],
                  activeColor: Colors.green,
                  onTap: onRepost,
                  colorScheme: colorScheme,
                ),
                _buildCompactActionButton(
                  icon: Icons.share,
                  label: 'Compartir',
                  onTap: onMore,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnPostBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 10, color: AppTheme.primaryColor),
          const SizedBox(width: 2),
          const Text(
            'Tú',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          _formatCount(count),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Versión compacta de los botones de acción
  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color activeColor = AppTheme.primaryColor,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}