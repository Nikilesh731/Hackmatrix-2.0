import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

class AmbientAIScribeApp extends StatelessWidget {
  const AmbientAIScribeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambient AI Scribe',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}