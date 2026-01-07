import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';

// Service and Model Imports
import '../../models/vehicle.dart';
import '../../services/vehicle_service.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  // State variables for data and UI status
  List<Vehicle> buses = [];
  bool isLoading = true;
  String? error;

  // Controllers for the Add Bus dialog
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _busNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBuses(); // Fetch data when screen loads
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _busNameController.dispose();
    super.dispose();
  }

  /// 1. Fetch Buses from Backend
  Future<void> loadBuses() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result = await VehicleService.fetchVehicles();
      if (mounted) {
        setState(() {
          buses = result;
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

  /// 2. Add New Bus Logic
  Future<void> _addBus() async {
    final busNumber = _busNumberController.text.trim();
    final busName = _busNameController.text.trim();

    if (busNumber.isEmpty || busName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields required')),
      );
      return;
    }

    try {
      // Call Backend Service
      await VehicleService.createVehicle(
        vehicleId: busNumber,
        vehicleType: busName,
      );

      if (mounted) {
        _busNumberController.clear();
        _busNameController.clear();
        Navigator.pop(context); // Close Dialog

        await loadBuses(); // 🔥 Refresh the list automatically

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus added successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add bus: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 3. Show the Add Bus Popup
  void _showAddBusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Bus"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _busNameController,
              decoration: const InputDecoration(
                labelText: "Bus Name/Type (e.g. Express)", 
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _busNumberController,
              decoration: const InputDecoration(
                labelText: "Bus ID (License Plate)", 
                border: OutlineInputBorder()
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addBus, child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Buses"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const AdminDashboard())
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadBuses)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBusDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  /// 4. Main UI Content Handler
  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text("Error: $error", textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: loadBuses, child: const Text("Retry"))
          ],
        ),
      );
    }

    if (buses.isEmpty) {
      return const Center(child: Text("No buses found in the database."));
    }

    return ListView.builder(
      itemCount: buses.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (ctx, i) {
        final bus = buses[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.directions_bus, color: Colors.white),
            ),
            title: Text(bus.vehicleType ?? "Standard Bus", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("ID: ${bus.vehicleId}\nStatus: ${bus.status.toUpperCase()}"),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                // 5. Delete Confirmation Dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Bus"),
                    content: Text("Are you sure you want to delete bus ${bus.vehicleId}?"),
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

                // 6. Execute Delete
                try {
                  await VehicleService.deleteVehicle(bus.vehicleId);
                  if (mounted) {
                    await loadBuses(); // 🔥 Refresh list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bus deleted successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e')),
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