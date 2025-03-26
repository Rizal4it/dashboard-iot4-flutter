import 'package:flutter/material.dart';
import 'package:manlogen/dashboard.dart';
import 'package:manlogen/led_control_screen.dart';
import 'constants/colors.dart'; // Pastikan diimpor
import 'screens/welcome.dart';
import 'screens/login_screen.dart';
import 'screens/signup.dart';
import 'services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(); // ✅ Tambahkan navigatorKey

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Pastikan binding sebelum async function
  AuthService authService = AuthService();
  bool expired = await authService.isTokenExpired();

  runApp(MyApp(isTokenExpired: expired));
}

class MyApp extends StatelessWidget {
  final bool isTokenExpired;

  const MyApp({super.key, required this.isTokenExpired});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:
          navigatorKey, // ✅ Tambahkan navigatorKey untuk logout global
      title: 'MyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: kPrimaryColor,
          secondary: kPrimaryLightColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home:
          isTokenExpired
              ? const WelcomeScreen()
              : const DashboardScreen(), // ✅ Cek apakah token expired
      debugShowCheckedModeBanner: false,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/status': (context) => const LEDControlScreen(),
      },
    );
  }
}
