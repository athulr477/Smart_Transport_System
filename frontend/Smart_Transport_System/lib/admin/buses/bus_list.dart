import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';
import 'package:smart_transport_frontend/admin/data/bus_data.dart';

class BusListScreen extends StatefulWidget {
  const BusListScreen({super.key});

  @override
  State<BusListScreen> createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _busNameController = TextEditingController();
  // REMOVED Capacity Controller

  void _addBus() {
    final busNumber = _busNumberController.text.trim();
    final busName = _busNameController.text.trim();

    if (busNumber.isEmpty || busName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields required')));
      return;
    }

    setState(() {
      BusData.buses.add(Bus(
        id: BusData.generateBusId(),
        name: busName,
        number: busNumber,
      ));
    });

    _busNumberController.clear();
    _busNameController.clear();
    Navigator.pop(context);
  }

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
              decoration: const InputDecoration(labelText: "Bus Name (e.g. Blue Express)", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 10),
             TextField(
              controller: _busNumberController,
              decoration: const InputDecoration(labelText: "Bus Number (e.g. KL-01-AB-1234)", border: OutlineInputBorder()),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBusDialog,
        child: const Icon(Icons.add),
      ),
      body: BusData.buses.isEmpty
          ? const Center(child: Text("No buses added"))
          : ListView.builder(
              itemCount: BusData.buses.length,
              itemBuilder: (ctx, i) {
                final bus = BusData.buses[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_bus),
                    title: Text(bus.name),
                    subtitle: Text("${bus.number}\nID: ${bus.id}"),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => BusData.buses.removeAt(i)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}