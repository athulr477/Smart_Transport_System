import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/dashboard/admin_dashboard.dart';
import 'package:smart_transport_frontend/admin/data/route_data.dart';
import 'package:smart_transport_frontend/admin/data/bus_data.dart'; 

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _endPointController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _stopController = TextEditingController();

  final List<String> _tempStops = [];
  String? _selectedBusId; 

  @override
  void dispose() {
    _routeNameController.dispose();
    _startPointController.dispose();
    _endPointController.dispose();
    _durationController.dispose();
    _stopController.dispose();
    super.dispose();
  }

  void _addStop() {
    final stop = _stopController.text.trim();
    if (stop.isNotEmpty && !_tempStops.contains(stop)) {
      setState(() {
        _tempStops.add(stop);
      });
      _stopController.clear();
    }
  }

  void _saveRoute() {
    final routeName = _routeNameController.text.trim();
    final startPoint = _startPointController.text.trim();
    final endPoint = _endPointController.text.trim();
    final duration = _durationController.text.trim();

    if (routeName.isEmpty || startPoint.isEmpty || endPoint.isEmpty || _tempStops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and add at least 2 stops')));
      return;
    }

    setState(() {
      RouteData.routes.add(
        BusRoute(
          id: RouteData.generateRouteId(),
          routeName: routeName,
          startPoint: startPoint,
          endPoint: endPoint,
          estimatedDuration: duration,
          stops: _tempStops.map((name) => RouteStop(name: name)).toList(),
          assignedBusId: _selectedBusId, 
        ),
      );
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Route added successfully')));
  }

  void _showAddRouteDialog() {
    _routeNameController.clear();
    _startPointController.clear();
    _endPointController.clear();
    _durationController.clear();
    _stopController.clear();
    _tempStops.clear();
    _selectedBusId = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Route'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _routeNameController, decoration: const InputDecoration(labelText: 'Route Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _startPointController, decoration: const InputDecoration(labelText: 'Start Point', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _endPointController, decoration: const InputDecoration(labelText: 'End Point', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Est. Duration', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                
                // ✅ FIXED DROPDOWN HERE
                DropdownButtonFormField<String>(
                  isExpanded: true, // <--- THIS LINE FIXES THE PIXEL OVERFLOW
                  decoration: const InputDecoration(
                    labelText: 'Assign to Bus',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_bus),
                  ),
                  initialValue: _selectedBusId,
                  items: BusData.buses.map((bus) {
                    return DropdownMenuItem(
                      value: bus.id,
                      // Also added TextOverflow to be extra safe
                      child: Text(
                        "${bus.name} (${bus.number})", 
                        overflow: TextOverflow.ellipsis, 
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedBusId = value;
                    });
                  },
                  hint: const Text("Select Bus (Optional)"),
                ),
                
                const SizedBox(height: 15),
                const Divider(),
                
                // STOPS LOGIC
                Row(
                  children: [
                    Expanded(child: TextField(controller: _stopController, decoration: const InputDecoration(labelText: 'Stop Name', isDense: true))),
                    IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), onPressed: () {
                      _addStop();
                      setDialogState(() {});
                    }),
                  ],
                ),
                Wrap(
                  spacing: 8.0,
                  children: _tempStops.map((stop) => Chip(
                    label: Text(stop),
                    onDeleted: () {
                      _tempStops.remove(stop);
                      setDialogState(() {});
                    },
                  )).toList(),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: _saveRoute, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboard())),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRouteDialog,
        child: const Icon(Icons.add),
      ),
      body: RouteData.routes.isEmpty
          ? const Center(child: Text("No routes added"))
          : ListView.builder(
              itemCount: RouteData.routes.length,
              itemBuilder: (context, index) {
                final route = RouteData.routes[index];
                
                String assignedBusName = "No Bus Assigned";
                if (route.assignedBusId != null) {
                  final bus = BusData.buses.firstWhere((b) => b.id == route.assignedBusId, orElse: () => Bus(id: '', name: '', number: ''));
                  if (bus.id.isNotEmpty) assignedBusName = bus.name;
                }

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.alt_route),
                    title: Text(route.routeName),
                    subtitle: Text("${route.startPoint} -> ${route.endPoint}\nBus: $assignedBusName"),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => RouteData.routes.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}