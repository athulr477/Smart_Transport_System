import 'package:flutter/material.dart';
import 'package:smart_transport_frontend/admin/buses/bus_list.dart';
import 'package:smart_transport_frontend/admin/drivers/driver_list.dart';
import 'package:smart_transport_frontend/admin/routes/routes_list.dart';
import 'package:smart_transport_frontend/admin/users/user_list.dart';
import 'package:smart_transport_frontend/screens/role_selection_screen.dart';

// New Imports for Backend Logic
import '../../services/admin_service.dart';
import '../../models/stats.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // --- New State Variables ---
  SystemStats? stats;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final result = await AdminService.fetchStats();
      if (mounted) {
        setState(() {
          stats = result;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadStats, // Allow refreshing data
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. System Stats Section (New) ---
            const Text(
              "System Stats",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStatsSection(),
            
            const SizedBox(height: 24),

            // --- 2. Management Section (Existing) ---
            const Text(
              "Management",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Important inside SingleChildScrollView
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashboardCard(
                  title: "Buses",
                  icon: Icons.directions_bus,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusListScreen())),
                ),
                _DashboardCard(
                  title: "Drivers",
                  icon: Icons.person_pin_circle,
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverListScreen())),
                ),
                _DashboardCard(
                  title: "Routes",
                  icon: Icons.map,
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteListScreen())),
                ),
                _DashboardCard(
                  title: "Users",
                  icon: Icons.group,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for the Stats Section
  Widget _buildStatsSection() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
        child: Text("Error loading stats: $error", style: const TextStyle(color: Colors.red)),
      );
    }

    // Grid for the numerical statistics
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _StatMiniCard("Total Vehicles", stats!.totalVehicles.toString(), Icons.bus_alert, Colors.orange),
        _StatMiniCard("Active", stats!.activeVehicles.toString(), Icons.check_circle, Colors.green),
        _StatMiniCard("Locations", stats!.totalLocations.toString(), Icons.pin_drop, Colors.blue),
        _StatMiniCard("New Updates", stats!.todayLocations.toString(), Icons.history, Colors.grey),
      ],
    );
  }

  // Small UI card for showing a single stat value
  Widget _StatMiniCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// Keep your existing _DashboardCard as is
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}