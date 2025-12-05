import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectoedumentor/core/constants/app_constants.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';
import '../widgets/home_header.dart';
import '../widgets/process_section.dart';
import '../widgets/quick_access.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Datos cargados del usuario
  String _userName = 'Usuario';
  String _userAvatar = 'User';
  // GlobalKey para el Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Variables para selección múltiple
  Set<String> _selectedNotifications = {};
  bool _isSelectionMode = false;

  // Ejemplo de notificaciones
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'game_achievement',
      'title': '¡Logro Desbloqueado!',
      'message': 'Completaste el nivel avanzado de Matemáticas',
      'icon': 'Trophy',
      'timestamp': 'Hace 5 min',
      'isRead': false,
      'color': const Color(0xFFFFD166),
    },
    {
      'id': '2',
      'type': 'community_like',
      'title': 'Nuevo like en tu publicación',
      'message': 'A Ana García le gustó tu publicación sobre derivadas',
      'icon': 'Red Heart',
      'timestamp': 'Hace 15 min',
      'isRead': false,
      'color': const Color(0xFFEF476F),
    },
    {
      'id': '3',
      'type': 'community_comment',
      'title': 'Nuevo comentario',
      'message': 'Carlos López comentó: "¡Excelente consejo!"',
      'icon': 'Speech Bubble',
      'timestamp': 'Hace 30 min',
      'isRead': true,
      'color': const Color(0xFF118AB2),
    },
    {
      'id': '4',
      'type': 'game_level',
      'title': 'Nivel Completado',
      'message': 'Avanzaste al nivel intermedio de Vocabulario',
      'icon': 'Star',
      'timestamp': 'Hace 1 hora',
      'isRead': true,
      'color': const Color(0xFF06D6A0),
    },
    {
      'id': '5',
      'type': 'community_share',
      'title': 'Publicación compartida',
      'message': 'María Fernández compartió tu consejo de estudio',
      'icon': 'Repeat',
      'timestamp': 'Hace 2 horas',
      'isRead': true,
      'color': const Color(0xFF8B5CF6),
    },
  ];
  int get _unreadCount {
    return _notifications.where((notification) => !notification['isRead']).length;
  }
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('full_name') ?? 'Usuario';
      _userAvatar = prefs.getString('selected_avatar') ?? 'User';
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error cargando datos de usuario: $e');
    }
  }

  // FUNCIÓN DE LOGOUT CORREGIDA: AHORA SÍ TE SACA DEL HOME
  Future<void> _performLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ESTAS SON LAS CLAVES QUE DEBES BORRAR PARA QUE EL ROUTER DETECTE QUE NO HAY SESIÓN
      await prefs.remove('current_user_email'); // LA MÁS IMPORTANTE
      await prefs.remove('email');
      await prefs.remove('role');
      await prefs.remove('full_name');
      await prefs.remove('profileCompleted');
      await prefs.remove('selected_avatar');
      await prefs.remove('selected_subjects');
      await prefs.remove('selected_language');
      // Si usas más claves de sesión, agrégalas aquí

      // Mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navegar al welcome y LIMPIAR TODA LA PILA DE NAVEGACIÓN
      if (mounted) {
        context.go('/'); // El router ahora detectará que no hay sesión y se quedará en Welcome
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Métodos para selección múltiple
  void _toggleNotificationSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
      // Salir del modo selección si no hay notificaciones seleccionadas
      if (_selectedNotifications.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }
  void _selectAllNotifications() {
    setState(() {
      _selectedNotifications = Set.from(_notifications.map((n) => n['id']));
      _isSelectionMode = true;
    });
  }
  void _deselectAllNotifications() {
    setState(() {
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
  }
  void _markSelectedAsRead() {
    setState(() {
      for (var notification in _notifications) {
        if (_selectedNotifications.contains(notification['id'])) {
          notification['isRead'] = true;
        }
      }
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });
  }
  void _deleteSelectedNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar notificaciones'),
          content: Text(
            '¿Estás seguro de que quieres eliminar ${_selectedNotifications.length} notificación(es)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _notifications.removeWhere(
                          (notification) => _selectedNotifications.contains(notification['id']));
                  _selectedNotifications.clear();
                  _isSelectionMode = false;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }
  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }
  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
  }
  void _onNotificationTap(Map<String, dynamic> notification) {
    _markAsRead(notification['id']);
    // Navegar según el tipo de notificación
    switch (notification['type']) {
      case 'game_achievement':
      case 'game_level':
        context.go('/games');
        break;
      case 'community_like':
      case 'community_comment':
      case 'community_share':
        context.go('/community');
        break;
    }
  }
  // Método para navegar a la pantalla de salida
  void _goToExitScreen() {
    context.go('/exit');
  }
  // Método actualizado para mostrar notificaciones
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NotificationsBottomSheet(
          notifications: _notifications,
          onNotificationTap: _onNotificationTap,
          onMarkAllAsRead: _markAllAsRead,
          onDeleteNotification: _deleteNotification,
          selectedNotifications: _selectedNotifications,
          isSelectionMode: _isSelectionMode,
          onToggleSelection: _toggleNotificationSelection,
          onSelectAll: _selectAllNotifications,
          onDeselectAll: _deselectAllNotifications,
          onMarkSelectedAsRead: _markSelectedAsRead,
          onDeleteSelected: _deleteSelectedNotifications,
        );
      },
    ).then((_) {
      // Limpiar selección cuando se cierra el bottom sheet
      setState(() {
        _selectedNotifications.clear();
        _isSelectionMode = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: theme.colorScheme.primary),
          onPressed: _openDrawer,
        ),
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Badge de notificaciones
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
                onPressed: _showNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Icono de salir
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
            ),
            onPressed: _goToExitScreen,
          ),
          // Icono de perfil
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              ),
            ),
            onPressed: () {
              context.go('/my-profile');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        scaffoldKey: _scaffoldKey,
        onLogout: _performLogout, // Pasa la función de logout al drawer
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo y avatar
              HomeHeader(
                userName: _userName, // Usa el nombre cargado
                userAvatar: _userAvatar, // Usa el avatar cargado
              ),
              const SizedBox(height: 32),
              // Sección de Proceso
              const ProcessSection(),
              const SizedBox(height: 32),
              // Accesos Rápidos
              const QuickAccess(),
              const SizedBox(height: 32),
              // NUEVO: Acceso rápido a Mis Clases en la pantalla principal
              _buildClassesQuickAccess(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // NUEVO: Widget para acceso rápido a Mis Clases
  Widget _buildClassesQuickAccess(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go('/student-classes'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.class_,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mis Clases',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Accede rápidamente a tus clases y actividades',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de Salida/Despedida (sin cambios)
class ExitScreen extends StatefulWidget {
  const ExitScreen({super.key});
  @override
  State<ExitScreen> createState() => _ExitScreenState();
}
class _ExitScreenState extends State<ExitScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _feedbackSubmitted = false;
  void _submitFeedback() {
    if (_feedbackController.text.trim().isNotEmpty) {
      setState(() {
        _feedbackSubmitted = true;
      });
      // Aquí podrías enviar el feedback a tu base de datos
      print('Feedback del usuario: ${_feedbackController.text}');
    }
  }
  Future<void> _logout() async {
    // Llama a la función de logout para limpiar sesión y navegar
    final homeState = context.findAncestorStateOfType<_HomePageState>();
    if (homeState != null) {
      await homeState._performLogout();
    } else {
      // Fallback: Limpia directamente aquí
      await _performLogoutDirect();
    }
  }
  // Fallback para limpiar sesión directamente en ExitScreen
  Future<void> _performLogoutDirect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_email');
      await prefs.remove('email');
      await prefs.remove('role');
      await prefs.remove('full_name');
      await prefs.remove('profileCompleted');
      await prefs.remove('selected_avatar');
      await prefs.remove('selected_subjects');
      await prefs.remove('selected_language');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      print('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  void _goBackToHome() {
    context.go('/home');
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: _goBackToHome,
        ),
        title: Text(
          'Salir',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mensaje de despedida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Hasta Pronto!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gracias por usar EduMentor AI. Esperamos verte pronto de nuevo.',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Sección de feedback
              if (!_feedbackSubmitted) ...[
                Text(
                  '¿Te gustaría compartir tu opinión?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _feedbackController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu opinión, sugerencia o comentario...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Enviar Opinión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Gracias por tu opinión! Tu feedback nos ayuda a mejorar.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Botones de acción
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _goBackToHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Regresar al Inicio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
// Bottom Sheet para ver todas las notificaciones con selección múltiple (sin cambios)
class NotificationsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(Map<String, dynamic>) onNotificationTap;
  final VoidCallback onMarkAllAsRead;
  final Function(String) onDeleteNotification;
  final Set<String> selectedNotifications;
  final bool isSelectionMode;
  final Function(String) onToggleSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final VoidCallback onMarkSelectedAsRead;
  final VoidCallback onDeleteSelected;
  const NotificationsBottomSheet({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    required this.onMarkAllAsRead,
    required this.onDeleteNotification,
    required this.selectedNotifications,
    required this.isSelectionMode,
    required this.onToggleSelection,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.onMarkSelectedAsRead,
    required this.onDeleteSelected,
  });
  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();
}
class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header del bottom sheet
          _buildHeader(isDarkMode),
          // Barra de acciones en modo selección
          if (widget.isSelectionMode) _buildSelectionActions(isDarkMode),
          // Lista de notificaciones
          Expanded(
            child: _buildNotificationsList(isDarkMode),
          ),
        ],
      ),
    );
  }
  Widget _buildHeader(bool isDarkMode) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
            widget.isSelectionMode
                ? '${widget.selectedNotifications.length} seleccionadas'
                : 'Notificaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              if (!widget.isSelectionMode && widget.notifications.isNotEmpty)
                TextButton(
                  onPressed: () {
                    widget.onSelectAll();
                  },
                  child: Text(
                    'Seleccionar',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildSelectionActions(bool isDarkMode) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: widget.selectedNotifications.length == widget.notifications.length
                    ? widget.onDeselectAll
                    : widget.onSelectAll,
                child: Text(
                  widget.selectedNotifications.length == widget.notifications.length
                      ? 'Deseleccionar todas'
                      : 'Seleccionar todas',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                onPressed: widget.onMarkSelectedAsRead,
                tooltip: 'Marcar como leídas',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDeleteSelected,
                tooltip: 'Eliminar seleccionadas',
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationsList(bool isDarkMode) {
    final theme = Theme.of(context);
    if (widget.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las notificaciones aparecerán aquí',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.notifications.length,
      itemBuilder: (context, index) {
        final notification = widget.notifications[index];
        final isSelected = widget.selectedNotifications.contains(notification['id']);
        return NotificationItem(
          notification: notification,
          onTap: () {
            if (widget.isSelectionMode) {
              widget.onToggleSelection(notification['id']);
            } else {
              widget.onNotificationTap(notification);
              Navigator.pop(context);
            }
          },
          onDelete: () => widget.onDeleteNotification(notification['id']),
          isSelected: isSelected,
          isSelectionMode: widget.isSelectionMode,
          onToggleSelection: () => widget.onToggleSelection(notification['id']),
        );
      },
    );
  }
}
class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onToggleSelection;
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onToggleSelection,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          onLongPress: () {
            if (!isSelectionMode) {
              onToggleSelection();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : (notification['isRead']
                  ? (isDarkMode ? Colors.grey[800] : Colors.white)
                  : (isDarkMode ? Colors.grey[800] : Colors.white)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (notification['isRead']
                    ? (isDarkMode ? Colors.grey[700]! : Colors.grey.shade200)
                    : (notification['color'] as Color).withOpacity(0.3)),
                width: isSelected ? 2 : (notification['isRead'] ? 1 : 2),
              ),
            ),
            child: Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => onToggleSelection(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                // Icono de la notificación
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notification['icon'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Contenido de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification['isRead'] && !isSelected
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['timestamp'],
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSelectionMode) ...[
                  Column(
                    children: [
                      if (!notification['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Future<void> Function() onLogout;
  const AppDrawer({
    super.key,
    required this.scaffoldKey,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Drawer(
      backgroundColor: theme.cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'EduMentor AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chiapas',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.home,
            title: 'Inicio',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.timeline,
            title: 'Proceso',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/process');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.videogame_asset,
            title: 'Juegos',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/games');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.chat,
            title: 'Chat IA',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/chat');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.people,
            title: 'Comunidad',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/community');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.library_books,
            title: 'Biblioteca',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/library');
            },
          ),
          // NUEVO: Ítem para Mis Clases
          _buildDrawerItem(
            context: context,
            icon: Icons.class_,
            title: 'Mis Clases',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/student-classes');
            },
          ),
          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          _buildDrawerItem(
            context: context,
            icon: Icons.person,
            title: 'Perfil',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/my-profile');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.settings,
            title: 'Ajustes',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.go('/settings');
            },
          ),
          Divider(color: isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          _buildDrawerItem(
            context: context,
            icon: Icons.help_outline,
            title: 'Ayuda',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              // context.go('/help');
            },
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.exit_to_app,
            title: 'Cerrar Sesión',
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
  void _showLogoutDialog(BuildContext context) {
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
              'Cerrar Sesión',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            content: Text(
              '¿Estás seguro de que quieres cerrar sesión?',
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
                onPressed: () async {
                  Navigator.pop(context);
                  await onLogout(); // Llama a la función de logout que limpia y navega
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        );
      },
    );
  }
}