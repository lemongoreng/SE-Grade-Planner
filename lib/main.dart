import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'utils/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Ensure bindings are initialized first
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Initialize Timezones
    tz.initializeTimeZones();

    // 3. Initialize Notifications (Safely)
    // We await this, but we wrap it so it doesn't kill the app if it fails
    await NotificationService.init();
  } catch (e) {
    // If notifications fail, print error but LET THE APP CONTINUE
    debugPrint("Error initializing services: $e");
  }

  // 4. Launch the App
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) => 
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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
      themeMode: _themeMode,
      home: const HomeScreen(),
    );
  }
}