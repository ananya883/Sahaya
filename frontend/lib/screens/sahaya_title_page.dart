import 'package:flutter/material.dart';

class SahayaTitlePage extends StatefulWidget {
  const SahayaTitlePage({super.key});

  @override
  State<SahayaTitlePage> createState() => _SahayaTitlePageState();
}

class _SahayaTitlePageState extends State<SahayaTitlePage> {
  @override
  void initState() {
    super.initState();
    // Navigate to login page after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Changed background color to white
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Image.asset(
                'assets/images/sahya_logo.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 20),

              // App Name
              const Text(
                'Sahaya',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Empowering Relief and Saving Lives',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}