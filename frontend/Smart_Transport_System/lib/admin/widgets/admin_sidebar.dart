import 'package:flutter/material.dart';
import '../dashboard/admin_dashboard.dart';
import '../users/user_list.dart';
import '../drivers/driver_list.dart';
import '../buses/bus_list.dart';
import '../routes/routes_list.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 32),
                ),
                SizedBox(height: 10),
                Text(
                  "Admin Panel",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          _menuItem(context, Icons.dashboard, "Dashboard", const AdminDashboard()),
          _menuItem(context, Icons.people, "Users", const UserListScreen()),
          _menuItem(context, Icons.badge, "Bus Drivers", const DriverListScreen()),
          _menuItem(context, Icons.directions_bus, "Buses", const BusListScreen()),
          _menuItem(context, Icons.route, "Routes", const RouteListScreen()),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
      BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
