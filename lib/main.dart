import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectoedumentor/config/providers/theme_provider.dart';
import 'package:proyectoedumentor/config/providers/progress_provider.dart';
import 'package:proyectoedumentor/config/router/app_router.dart';
import 'package:proyectoedumentor/config/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ProgressProvider()), // loadProgress se llama post-frame
      ],
      child: _ProgressInitializer(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp.router(
              title: 'EduMentor',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getLightTheme(fontSizeSetting: themeProvider.fontSizeSetting),
              darkTheme: AppTheme.getDarkTheme(fontSizeSetting: themeProvider.fontSizeSetting),
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}

// Inicializador async para ProgressProvider
class _ProgressInitializer extends StatefulWidget {
  final Widget child;
  const _ProgressInitializer({required this.child});

  @override
  State<_ProgressInitializer> createState() => _ProgressInitializerState();
}

class _ProgressInitializerState extends State<_ProgressInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressProvider>(context, listen: false).loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}