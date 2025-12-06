// settings_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/providers/theme_provider.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'Español';

  final List<String> _languages = [
    'Español',
    'English',
    'Tsotsil',
    'Tseltal',
    'Zoque'
  ];

  final List<String> _fontSizes = [
    'Pequeño',
    'Medio',
    'Grande',
    'Extra Grande'
  ];

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seleccionar Idioma',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return ListTile(
                    leading: Icon(
                      Icons.language,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      language,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: language == _selectedLanguage
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: language == _selectedLanguage
                        ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = language;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeSelection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tamaño de Texto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _fontSizes.length,
                itemBuilder: (context, index) {
                  final fontSize = _fontSizes[index];
                  final isSelected = fontSize == themeProvider.fontSizeSetting;
                  return ListTile(
                    leading: Icon(
                      Icons.text_fields,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      fontSize,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: isSelected ? 16 : 14,
                      ),
                    ),
                    subtitle: Text(
                      _getFontSizeDescription(fontSize),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                    )
                        : null,
                    onTap: () {
                      themeProvider.setFontSize(fontSize);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _getFontSizeDescription(String fontSize) {
    switch (fontSize) {
      case 'Pequeño':
        return 'Texto más pequeño para más contenido en pantalla';
      case 'Medio':
        return 'Tamaño estándar recomendado';
      case 'Grande':
        return 'Texto más grande para mejor legibilidad';
      case 'Extra Grande':
        return 'Texto muy grande para máxima accesibilidad';
      default:
        return '';
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            'Limpiar Datos',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar todos los datos de la aplicación? Esta acción no se puede deshacer.',
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
                // Aquí iría la lógica para limpiar datos
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Datos limpiados correctamente',
                      style: TextStyle(color: theme.colorScheme.onPrimary),
                    ),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.go('/home'),  // Cambio aquí: va directamente a Home
        ),
        title: Text(
          'Configuración',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Preferencias
              _buildSectionTitle('Preferencias', theme),
              _buildSettingCard(
                theme: theme,
                children: [
                  _buildSettingSwitch(
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    subtitle: 'Recibir notificaciones de la aplicación',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingSwitch(
                    icon: Icons.dark_mode,
                    title: 'Modo Oscuro',
                    subtitle: 'Activar el tema oscuro',
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.setDarkMode(value);
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingSwitch(
                    icon: Icons.volume_up,
                    title: 'Efectos de Sonido',
                    subtitle: 'Reproducir sonidos en la aplicación',
                    value: _soundEffectsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEffectsEnabled = value;
                      });
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingSwitch(
                    icon: Icons.vibration,
                    title: 'Vibración',
                    subtitle: 'Activar vibración en interacciones',
                    value: _vibrationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sección de Personalización
              _buildSectionTitle('Personalización', theme),
              _buildSettingCard(
                theme: theme,
                children: [
                  _buildSettingOption(
                    icon: Icons.language,
                    title: 'Idioma',
                    subtitle: _selectedLanguage,
                    onTap: _showLanguageSelection,
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.text_fields,
                    title: 'Tamaño de Texto',
                    subtitle: '${themeProvider.fontSizeSetting} - ${_getFontSizeDescription(themeProvider.fontSizeSetting)}',
                    onTap: () => _showFontSizeSelection(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sección de Cuenta
              _buildSectionTitle('Cuenta', theme),
              _buildSettingCard(
                theme: theme,
                children: [
                  _buildSettingOption(
                    icon: Icons.person,
                    title: 'Gestionar Perfil',
                    subtitle: 'Editar información personal',
                    onTap: () => context.go('/my-profile'),
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.security,
                    title: 'Privacidad y Seguridad',
                    subtitle: 'Configurar opciones de privacidad',
                    onTap: () => context.push('/privacy'), // Actualizado: usa push para permitir pop de vuelta
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sección de Aplicación
              _buildSectionTitle('Aplicación', theme),
              _buildSettingCard(
                theme: theme,
                children: [
                  _buildSettingOption(
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    subtitle: 'Centro de ayuda y contacto',
                    onTap: () {
                      // Navegar a pantalla de ayuda
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    subtitle: 'Información de la aplicación',
                    onTap: () {
                      // Navegar a pantalla acerca de
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.star_border,
                    title: 'Calificar App',
                    subtitle: 'Deja tu opinión en la store',
                    onTap: () {
                      // Abrir store para calificar
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.share,
                    title: 'Compartir App',
                    subtitle: 'Compartir con amigos',
                    onTap: () {
                      // Compartir aplicación
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Sección de Datos
              _buildSectionTitle('Datos', theme),
              _buildSettingCard(
                theme: theme,
                children: [
                  _buildSettingOption(
                    icon: Icons.storage,
                    title: 'Almacenamiento',
                    subtitle: 'Gestionar espacio de almacenamiento',
                    onTap: () {
                      // Mostrar información de almacenamiento
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.backup,
                    title: 'Copia de Seguridad',
                    subtitle: 'Respaldar tus datos',
                    onTap: () {
                      // Realizar copia de seguridad
                    },
                  ),
                  _buildDivider(theme),
                  _buildSettingOption(
                    icon: Icons.delete_outline,
                    title: 'Limpiar Datos',
                    subtitle: 'Eliminar todos los datos',
                    onTap: _showClearDataDialog,
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Información de versión
              Center(
                child: Text(
                  'EduMentor AI v1.0.0',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? Colors.red
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDestructive
                          ? Colors.red.withOpacity(0.7)
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? Colors.red.withOpacity(0.5)
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: theme.colorScheme.onSurface.withOpacity(0.1),
      ),
    );
  }
}