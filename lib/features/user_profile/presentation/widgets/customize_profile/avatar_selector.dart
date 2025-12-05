import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

class AvatarSelector extends StatefulWidget {
  const AvatarSelector({super.key});

  @override
  State<AvatarSelector> createState() => AvatarSelectorState();  // Público: sin _
}

class AvatarSelectorState extends State<AvatarSelector> {  // Público: sin _
  String? _selectedAvatar;

  // Getter público para acceder desde el padre
  String? get selectedAvatar => _selectedAvatar;

  final List<Map<String, dynamic>> _maleAvatars = [
    {'code': '👦', 'name': 'Niño', 'gender': 'male'},
    {'code': '👨', 'name': 'Joven', 'gender': 'male'},
    {'code': '🧔', 'name': 'Hombre', 'gender': 'male'},
    {'code': '👨‍🎓', 'name': 'Estudiante', 'gender': 'male'},
    {'code': '👨‍💻', 'name': 'Programador', 'gender': 'male'},
    {'code': '🦸', 'name': 'Superhéroe', 'gender': 'male'},
  ];

  final List<Map<String, dynamic>> _femaleAvatars = [
    {'code': '👧', 'name': 'Niña', 'gender': 'female'},
    {'code': '👩', 'name': 'Joven', 'gender': 'female'},
    {'code': '👩‍🎓', 'name': 'Estudiante', 'gender': 'female'},
    {'code': '👩‍💻', 'name': 'Programadora', 'gender': 'female'},
    {'code': '👩‍🏫', 'name': 'Maestra', 'gender': 'female'},
    {'code': '🦸‍♀️', 'name': 'Superheroína', 'gender': 'female'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedAvatar();
  }

  Future<void> _loadSelectedAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final avatarStr = prefs.getString('selected_avatar');
      if (avatarStr != null && mounted) {
        setState(() {
          _selectedAvatar = avatarStr;
        });
      }
    } catch (e) {
      print('Error cargando avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        _buildSectionHeader('Elige tu avatar', theme),
        const SizedBox(height: 20),

        // Selector de género
        Text(
          'Avatar masculino',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),

        // Avatares masculinos
        _buildAvatarGrid(_maleAvatars, isDarkMode),
        const SizedBox(height: 24),

        Text(
          'Avatar femenino',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),

        // Avatares femeninos
        _buildAvatarGrid(_femaleAvatars, isDarkMode),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarGrid(List<Map<String, dynamic>> avatars, bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = _selectedAvatar == avatar['code'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAvatar = avatar['code'];
            });
            print('Avatar seleccionado: ${avatar['name']} (${avatar['code']})');
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : isDarkMode ? Colors.grey[800] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  avatar['code'],
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  avatar['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}