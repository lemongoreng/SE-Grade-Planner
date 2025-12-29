import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'utils/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Required for async calls in main
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Timezone Database (Critical for scheduling)
  tz.initializeTimeZones();

  // 3. Initialize Notification Service
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This allows us to access the toggleTheme function from anywhere
  static _MyAppState? of(BuildContext context) => 
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Default to Light Mode
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNIMAS Grade Planner',
      
      // Light Theme Settings
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF02569B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),

      // Dark Theme Settings
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),

      themeMode: _themeMode, // Uses the state variable
      home: const HomeScreen(),
    );
  }
}