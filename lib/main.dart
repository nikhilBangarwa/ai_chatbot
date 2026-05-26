import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_preview_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: SplashScreen.backgroundColor,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = AppAccentColor.purple.color;
  bool _showSplash = true;

  void _onSplashFinished() => setState(() => _showSplash = false);

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPreviewScreen(
          themeMode: _themeMode,
          accentColor: _accentColor,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
          onAccentColorChanged: (color) =>
              setState(() => _accentColor = color),
        ),
      ),
    );
  }

  Widget _authGate() {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return LoginScreen(authService: _authService);
        }

        return HomeScreen(
          authService: _authService,
          onOpenSettings: _openSettings,
          onSignedOut: () => setState(() {}),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chatbot',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.light(seedColor: _accentColor),
      darkTheme: AppTheme.dark(seedColor: _accentColor),
      home: _showSplash
          ? SplashScreen(onFinished: _onSplashFinished)
          : _authGate(),
    );
  }
}
