import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'screens/auth_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ambient AI Scribe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      routerConfig: GoRouter(
        initialLocation: '/auth',
        routes: [
          GoRoute(
            path: '/auth',
            builder: (context, state) => const AuthScreen(),
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) {
              return StreamBuilder(
                stream: AuthService.authStateChanges,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return const DoctorDashboardScreen();
                  }
                  return const AuthScreen();
                },
              );
            },
          ),
        ],
        redirect: (context, state) {
          final isAuthenticated = Supabase.instance.client.auth.currentSession != null;
          final isAuthRoute = state.location == '/auth';
          
          if (!isAuthenticated && !isAuthRoute) {
            return '/auth';
          }
          
          if (isAuthenticated && isAuthRoute) {
            return '/dashboard';
          }
          
          return null;
        },
      ),
    );
  }
}
