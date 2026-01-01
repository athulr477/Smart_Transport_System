import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/screens/login_screen.dart';
import 'package:smart_transport_frontend/screens/passenger_home.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.directions_bus_filled, size: 80, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text(
                "Smart Transport",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const Text(
                "Select your role to continue",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // --- PASSENGER BUTTON ---
              _RoleButton(
                icon: Icons.person_outline,
                label: " Passenger",
                color: Colors.blueAccent,
                onPressed: () {
                  // Passenger needs no login -> Go straight to Home
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PassengerHomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- DRIVER BUTTON ---
              _RoleButton(
                icon: Icons.drive_eta,
                label: " Driver",
                color: Colors.green,
                onPressed: () {
                  // Driver needs login
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(userType: 'driver'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // --- ADMIN BUTTON ---
              _RoleButton(
                icon: Icons.admin_panel_settings_outlined,
                label: " Admin",
                color: Colors.orange, // Distinct color for Admin
                onPressed: () {
                  // Admin needs login
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(userType: 'admin'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}