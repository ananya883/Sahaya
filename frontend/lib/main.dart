import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/registration.dart';
import 'screens/forgot_password.dart';
import 'screens/homepage.dart';
import 'screens/sos_page.dart';
import 'screens/sahaya_title_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahaya',
      debugShowCheckedModeBanner: false,

      // 🔵 Blue–White Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        useMaterial3: false, // keep classic look (stable)
      ),

      // 🔹 Title page opens first
      initialRoute: '/title',

      routes: {
        '/title': (context) => const SahayaTitlePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
        '/sos': (context) => const SosPage(),
      },
    );
  }
}
