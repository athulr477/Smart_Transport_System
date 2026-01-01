import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/data/route_data.dart';
import 'package:smart_transport_frontend/screens/role_selection_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  // Simple search filter
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // Filter routes based on search
    final filteredRoutes = RouteData.routes.where((route) {
      final query = _searchQuery.toLowerCase();
      return route.routeName.toLowerCase().contains(query) ||
             route.startPoint.toLowerCase().contains(query) ||
             route.endPoint.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Bus"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Exit",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search route or location...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          // --- ROUTE LIST ---
          Expanded(
            child: filteredRoutes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRoutes.length,
                    itemBuilder: (context, index) {
                      final route = filteredRoutes[index];
                      return _buildRouteCard(route);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "No routes found",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BusRoute route) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRouteTimeline(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      route.routeName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      "LIVE",
                      style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, size: 12, color: Colors.blue),
                      Container(width: 2, height: 20, color: Colors.grey[300]),
                      const Icon(Icons.circle, size: 12, color: Colors.red),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.startPoint, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 14),
                        Text(route.endPoint, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(route.estimatedDuration, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("${route.stops.length} stops", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- THE "TRACKING" UI (TIMELINE) ---
  void _showRouteTimeline(BusRoute route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.directions_bus, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(route.routeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text("Live Tracking", style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            // Timeline List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: route.stops.length,
                itemBuilder: (context, index) {
                  final stop = route.stops[index];
                  // Fake "Bus Location" logic: 
                  // We'll pretend the bus is always at the 2nd stop for the demo
                  final isBusHere = (index == 1); 

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.circle, 
                            size: 14, 
                            color: isBusHere ? Colors.blue : Colors.grey[300]
                          ),
                          if (index != route.stops.length - 1)
                            Container(width: 2, height: 40, color: Colors.grey[300]),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isBusHere ? FontWeight.bold : FontWeight.normal,
                                color: isBusHere ? Colors.black : Colors.grey[600],
                              ),
                            ),
                            if (isBusHere)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "BUS IS HERE",
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 24), // Spacing for line
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            // Footer Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notifications enabled for this trip")),
                    );
                  },
                  child: const Text("Notify Me When Bus Arrives"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}