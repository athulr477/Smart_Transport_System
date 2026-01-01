import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';
import 'package:smart_transport_frontend/admin/data/user_data.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Default role
  String _selectedRole = 'user';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- SAVE USER LOGIC ---
  void _saveUser() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    // 1. Validation
    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _showSnack('All fields are required', Colors.red);
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showSnack('Invalid email address', Colors.orange);
      return;
    }

    if (phone.length != 10 || int.tryParse(phone) == null) {
      _showSnack('Phone number must be 10 digits', Colors.orange);
      return;
    }

    // 2. Check Duplicates
    if (UserData.users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      _showSnack('Email already exists', Colors.orange);
      return;
    }

    if (UserData.users.any((u) => u.phone == phone)) {
      _showSnack('Phone number already exists', Colors.orange);
      return;
    }

    // 3. Add User
    setState(() {
      UserData.users.add(
        User(
          id: UserData.generateUserId(),
          name: name,
          email: email,
          phone: phone,
          role: _selectedRole,
        ),
      );
    });

    Navigator.pop(context);
    _showSnack('User added successfully', Colors.green);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _selectedRole = 'user'; // Reset to default
  }

  // --- DELETE LOGIC ---
  void _showDeleteConfirmation(User user, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              setState(() => UserData.users.removeAt(index));
              Navigator.pop(context);
              _showSnack('User deleted', Colors.grey);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // --- ADD USER DIALOG ---
  void _showAddUserDialog() {
    _clearForm();

    showDialog(
      context: context,
      builder: (context) {
        // Use StatefulBuilder to update Dropdown inside Dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New User'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        prefixIcon: Icon(Icons.security),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Passenger (User)')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            _selectedRole = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _saveUser,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          ),
        ),
        title: const Text('Manage Users'),
        actions: [
           Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${UserData.users.length} Users',
                style: const TextStyle(fontSize: 16),
              )
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: const Icon(Icons.add),
      ),
      body: UserData.users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No users added yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: UserData.users.length,
              itemBuilder: (_, i) {
                final user = UserData.users[i];
                final isAdmin = user.role == 'admin';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isAdmin ? Colors.orange : Colors.blueAccent,
                      child: Icon(
                        isAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text(
                          user.phone,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Text(
                              "ADMIN",
                              style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(user, i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}