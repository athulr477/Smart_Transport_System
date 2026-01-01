import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/data/bus_data.dart';
import 'package:smart_transport_frontend/admin/data/driver_data.dart';
import 'package:smart_transport_frontend/admin/data/route_data.dart';
import 'package:smart_transport_frontend/screens/role_selection_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  final Driver driver;
  const DriverHomeScreen({super.key, required this.driver});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool isTripStarted = false;

  @override
  Widget build(BuildContext context) {
    // 1. Find Assigned Bus
    final assignedBus = widget.driver.assignedBusId != null
        ? BusData.buses.firstWhere(
            (b) => b.id == widget.driver.assignedBusId, 
            orElse: () => Bus(id: '', name: 'Unknown', number: '')
          )
        : null;
    
    final bool hasBus = assignedBus != null && assignedBus.id.isNotEmpty;

    // 2. Find Assigned Route (Triangle: Driver -> Bus -> Route)
    BusRoute? assignedRoute;
    if (hasBus) {
       try {
         // Find a route that is assigned to THIS bus
         assignedRoute = RouteData.routes.firstWhere((r) => r.assignedBusId == assignedBus.id);
       } catch (e) {
         assignedRoute = null;
       }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.driver.name}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelectionScreen())),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DRIVER INFO
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, size: 40, color: Colors.indigo),
                title: Text(widget.driver.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Driver ID: ${widget.driver.id}"),
              ),
            ),
            const SizedBox(height: 10),

            // BUS INFO
            if (hasBus)
              Card(
                color: Colors.blue[50],
                child: ListTile(
                  leading: const Icon(Icons.directions_bus, color: Colors.blue),
                  title: Text("Bus: ${assignedBus.name}"),
                  subtitle: Text("Number: ${assignedBus.number}"),
                ),
              )
            else
              const Card(
                color: Colors.redAccent,
                child: ListTile(
                  leading: Icon(Icons.warning, color: Colors.white),
                  title: Text("No Bus Assigned", style: TextStyle(color: Colors.white)),
                ),
              ),

            const SizedBox(height: 10),

            // ROUTE INFO
            if (assignedRoute != null)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.map, color: Colors.orange),
                          const SizedBox(width: 10),
                          Text("Route: ${assignedRoute.routeName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      Text("${assignedRoute.startPoint} ➝ ${assignedRoute.endPoint}"),
                      const SizedBox(height: 5),
                      Text("Stops: ${assignedRoute.stops.map((s) => s.name).join(', ')}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
               Card(
                color: Colors.grey[200],
                child: const ListTile(
                  title: Text("No Route found for this Bus"),
                  leading: Icon(Icons.map_outlined),
                ),
              ),

            const SizedBox(height: 30),

            // START TRIP BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTripStarted ? Colors.red : Colors.green,
                ),
                onPressed: (hasBus && assignedRoute != null) ? () {
                  setState(() {
                    isTripStarted = !isTripStarted;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isTripStarted ? "Trip Started!" : "Trip Ended")));
                } : null,
                icon: Icon(isTripStarted ? Icons.stop : Icons.play_arrow),
                label: Text(isTripStarted ? "END TRIP" : "START TRIP"),
              ),
            )
          ],
        ),
      ),
    );
  }
}