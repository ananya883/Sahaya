import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sahaya"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SOS Request Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement SOS request functionality
              },
              icon: const Icon(Icons.warning, size: 30),
              label: const Text(
                "SOS Request",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // First Aid Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement First Aid functionality
              },
              icon: const Icon(Icons.medical_services, size: 30),
              label: const Text(
                "First Aid",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
