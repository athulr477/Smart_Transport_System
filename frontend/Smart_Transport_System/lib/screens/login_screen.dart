import 'package:flutter/material.dart';
import '../services/auth_service.dart';

import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';
import 'package:smart_transport_frontend/admin/data/driver_data.dart'; 
import 'package:smart_transport_frontend/screens/driver_home.dart';
// Import your service file here
// import 'package:smart_transport_frontend/services/auth_service.dart'; 

class LoginScreen extends StatefulWidget {
  final String userType; // 'admin' or 'driver'

  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final inputId = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (inputId.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Admin Login (Local logic)
      if (widget.userType == 'admin') {
        if (inputId == 'admin' && password == 'admin123') {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const AdminDashboard())
          );
        } else {
          _showError('Invalid Admin Credentials');
        }
      } 
      // 2. Driver Login (Using AuthService)
      else {
        // Calling your AuthService method
        final response = await AuthService.driverLogin(inputId, password);

        if (response["success"] == true) {
          // Map the response data to your Driver model
          final driver = Driver(
            id: inputId,
            name: response['name'] ?? 'Driver',
            licenseNumber: 'PENDING',
            password: password,
            assignedBusId: response['bus_id'],
          );

          if (mounted) {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => DriverHomeScreen(driver: driver))
            );
          }
        } else {
          _showError(response["error"] ?? "Login failed");
        }
      }
    } catch (e) {
      _showError("Server error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red)
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userType == 'admin';
    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? "Admin Login" : "Driver Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: isAdmin ? "Admin ID" : "Driver ID (e.g. D001)",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}