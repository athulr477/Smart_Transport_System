import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  String selectedRole = "User";

  final List<String> roles = [
    "User",
    "Bus Driver",
    "Admin",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  isLogin ? "Sign In" : "Sign Up",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Login / Signup Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleButton("Login", true),
                    _buildToggleButton("Signup", false),
                  ],
                ),

                const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Role dropdown (Signup only)
                      if (!isLogin)
                        DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          items: roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                          validator: (value) =>
                              value == null ? "Please select a role" : null,
                          decoration: InputDecoration(
                            labelText: "Select Role",
                            prefixIcon:
                                const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                      if (!isLogin) const SizedBox(height: 16),

                      _buildTextField(
                        label: "Email",
                        icon: Icons.email,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        label: "Password",
                        icon: Icons.lock,
                        obscure: true,
                      ),

                      const SizedBox(height: 24),

                      // Main Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isLogin ? "LOGIN" : "SIGN UP",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Forgot password (Login only)
                      if (isLogin)
                        GestureDetector(
                          onTap: () {
                            // TODO: Forgot Password UI
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= AUTH HANDLER =================

  void _handleAuth() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ ADMIN NAVIGATION (CORRECT PLACE)
    if (selectedRole == "Admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboard(),
        ),
      );
    } else {
      // UI-only placeholder for other roles
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$selectedRole dashboard coming soon",
          ),
        ),
      );
    }
  }

  // ================= UI HELPERS =================

  Widget _buildToggleButton(String text, bool loginSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isLogin = loginSelected;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isLogin == loginSelected
              ? Colors.blue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isLogin == loginSelected
                ? Colors.white
                : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextFormField(
      obscureText: obscure,
      validator: (value) =>
          value == null || value.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
