import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';

// 1. Updated Imports
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  // --- 2. State Variables ---
  List<Vehicle> drivers = [];
  bool isLoading = true;
  String? error;

  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDrivers(); // Initial data fetch
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverIdController.dispose();
    super.dispose();
  }

  // --- 3. API Call Logic ---
  Future<void> loadDrivers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      // Reusing fetchVehicles pattern as requested
      final result = await VehicleService.fetchVehicles();
      if (mounted) {
        setState(() {
          drivers = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  // --- ADD DRIVER LOGIC ---
  Future<void> _addDriver() async {
    final driverName = _driverNameController.text.trim();
    final driverId = _driverIdController.text.trim();

    if (driverName.isEmpty || driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields required")),
      );
      return;
    }

    try {
      await VehicleService.createVehicle(
        vehicleId: driverId,
        vehicleType: driverName, // Mapping name to type field for this implementation
      );

      if (mounted) {
        _driverNameController.clear();
        _driverIdController.clear();
        Navigator.pop(context); // Close dialog

        await loadDrivers(); // Refresh list

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Driver added successfully"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add driver: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Driver"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _driverNameController,
              decoration: const InputDecoration(
                labelText: "Driver Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _driverIdController,
              decoration: const InputDecoration(
                labelText: "Driver ID",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _addDriver,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Drivers'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadDrivers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text("Error: $error", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: loadDrivers, child: const Text("Retry")),
          ],
        ),
      );
    }

    if (drivers.isEmpty) {
      return const Center(child: Text("No drivers found in the database"));
    }

    return ListView.builder(
      itemCount: drivers.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (ctx, i) {
        final driver = drivers[i];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: driver.status == 'active' ? Colors.green : Colors.grey,
              child: Text(driver.vehicleType?[0].toUpperCase() ?? "D", 
                style: const TextStyle(color: Colors.white)),
            ),
            title: Text(driver.vehicleType ?? "Unnamed Driver"),
            subtitle: Text("ID: ${driver.vehicleId} | Status: ${driver.status.toUpperCase()}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // DELETE CONFIRMATION DIALOG
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Driver"),
                    content: const Text("Are you sure you want to delete this driver?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                try {
                  await VehicleService.deleteVehicle(driver.vehicleId);
                  if (mounted) {
                    await loadDrivers(); // Refresh list

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Driver deleted successfully")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete driver: $e")),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}