import 'dart:async';
import 'package:flutter/material.dart';
// IMPORT the Role Selection Screen we created earlier
import 'package:smart_transport_frontend/screens/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // CHANGED: Delay set to 1 second as requested
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        // CHANGED: Navigate to RoleSelectionScreen
        MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Smart Transport',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Real-Time Bus Tracking System',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}