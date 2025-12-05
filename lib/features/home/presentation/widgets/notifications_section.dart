import 'package:flutter/material.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header del bottom sheet
          _buildHeader(),

          // Barra de acciones en modo selección
          if (widget.isSelectionMode) _buildSelectionActions(),

          // Lista de notificaciones
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (!widget.isSelectionMode && widget.notifications.isNotEmpty)
                TextButton(
                  onPressed: () {
                    widget.onSelectAll();
                  },
                  child: const Text(
                    'Seleccionar',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
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
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: AppTheme.primaryColor),
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

  Widget _buildNotificationsList() {
    if (widget.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las notificaciones aparecerán aquí',
              style: TextStyle(
                color: Colors.grey.shade400,
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
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : (notification['isRead'] ? Colors.white : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : (notification['isRead']
                    ? Colors.grey.shade200
                    : (notification['color'] as Color).withOpacity(0.3)),
                width: isSelected ? 2 : (notification['isRead'] ? 1 : 2),
              ),
            ),
            child: Row(
              children: [
                // Checkbox de selección (solo en modo selección)
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
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['timestamp'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador de no leído y botón de eliminar (solo cuando no está en modo selección)
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
                          color: Colors.grey.shade400,
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