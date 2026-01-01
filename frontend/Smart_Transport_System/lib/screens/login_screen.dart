import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';
import 'package:smart_transport_frontend/admin/data/driver_data.dart'; // Ensure this path is correct
import 'package:smart_transport_frontend/screens/driver_home.dart';

class LoginScreen extends StatefulWidget {
  final String userType; // 'admin' or 'driver'

  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController(); 
  final _passwordController = TextEditingController();

  // Changed to async to support HTTP requests
  Future<void> _handleLogin() async {
    final inputId = _idController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Admin Login (Kept Local)
    if (widget.userType == 'admin') {
      if (inputId == 'admin' && password == 'admin123') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      } else {
        _showError('Invalid Admin Credentials');
      }
    } else {
      // 2. Driver Login (Connects to Python Backend)
      try {
        // Use 10.0.2.2 for Android Emulator, or localhost for Web/iOS
        final url = Uri.parse('http://10.0.2.2:8000/driver-login?driver_id=$inputId&password=$password');
        
        print("Connecting to: $url"); // Debugging

        final response = await http.post(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['success'] == true) {
            // Success! Create driver object from server data
            final driver = Driver(
              id: inputId,
              name: data['name'],
              licenseNumber: 'PENDING', // You can fetch this later if needed
              password: password,
              assignedBusId: data['bus_id'],
            );

            if (mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DriverHomeScreen(driver: driver)));
            }
          } else {
            _showError(data['error']); // Show error from Python server
          }
        } else {
          _showError('Server Error: ${response.statusCode}');
        }
      } catch (e) {
        print("Connection Error: $e");
        _showError('Could not connect to Server. Is Python running?');
      }
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
                onPressed: _handleLogin,
                child: const Text("LOGIN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}