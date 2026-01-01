import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';
import 'package:smart_transport_frontend/admin/data/driver_data.dart';
import 'package:smart_transport_frontend/admin/data/bus_data.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // New Password Field
  
  String? _selectedBusId;

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveDriver() {
    final name = _nameController.text.trim();
    final license = _licenseController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || license.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields including Password are required'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      DriverData.drivers.add(
        Driver(
          id: DriverData.generateDriverId(),
          name: name,
          licenseNumber: license,
          password: password, // Save password
          assignedBusId: _selectedBusId,
        ),
      );
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Driver added successfully'), backgroundColor: Colors.green),
    );
  }

  void _showAddDriverDialog() {
    _nameController.clear();
    _licenseController.clear();
    _passwordController.clear();
    _selectedBusId = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Driver'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Driver Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _licenseController,
                      decoration: const InputDecoration(labelText: 'License Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    // PASSWORD FIELD ADDED
                    TextField(
                      controller: _passwordController,
                      obscureText: false, // Visible for Admin to see what they are setting
                      decoration: const InputDecoration(
                        labelText: 'Assign Password',
                        hintText: 'e.g., pass123',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // BUS ASSIGNMENT DROPDOWN
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Assign Bus',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_bus),
                      ),
                      initialValue: _selectedBusId,
                      items: BusData.buses.map((bus) {
                        return DropdownMenuItem(
                          value: bus.id,
                          child: Text("${bus.name} (${bus.number})"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedBusId = value;
                        });
                      },
                      hint: const Text("Select a Bus"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(onPressed: _saveDriver, child: const Text('Save')),
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
        title: const Text('Manage Drivers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverDialog,
        child: const Icon(Icons.add),
      ),
      body: DriverData.drivers.isEmpty
          ? const Center(child: Text("No drivers added yet"))
          : ListView.builder(
              itemCount: DriverData.drivers.length,
              itemBuilder: (ctx, i) {
                final driver = DriverData.drivers[i];
                // Resolve Bus Name
                String busInfo = "No Bus Assigned";
                if(driver.assignedBusId != null) {
                   final bus = BusData.buses.firstWhere((b) => b.id == driver.assignedBusId, orElse: () => Bus(id: '', name: 'Unknown', number: ''));
                   if(bus.id.isNotEmpty) busInfo = "${bus.name} (${bus.number})";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(driver.name[0])),
                    title: Text(driver.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ID: ${driver.id} | Lic: ${driver.licenseNumber}"),
                        Text("Bus: $busInfo", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        Text("Pass: ${driver.password}", style: const TextStyle(fontSize: 10, color: Colors.grey)), // Helping you see password during demo
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                         setState(() {
                           DriverData.drivers.removeAt(i);
                         });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}