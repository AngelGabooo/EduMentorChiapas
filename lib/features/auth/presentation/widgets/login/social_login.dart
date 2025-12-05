import 'package:flutter/material.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'O continúa con',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              onPressed: () {
                // Login con Google
              },
              isDarkMode: isDarkMode,
            ),
            const SizedBox(width: 16),
            _buildSocialButton(
              icon: Icons.facebook,
              onPressed: () {
                // Login con Facebook
              },
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDarkMode ? Colors.grey[800] : Colors.transparent,
        border: Border.all(
          color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 24,
          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
        ),
        onPressed: onPressed,
      ),
    );
  }
}