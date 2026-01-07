class SystemStats {
  final int totalVehicles;
  final int totalLocations;
  final int activeVehicles;
  final int inactiveVehicles;
  final int todayLocations;
  final String? lastUpdate;
  final String serverTime;

  SystemStats({
    required this.totalVehicles,
    required this.totalLocations,
    required this.activeVehicles,
    required this.inactiveVehicles,
    required this.todayLocations,
    required this.lastUpdate,
    required this.serverTime,
  });

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      totalVehicles: json["total_vehicles"],
      totalLocations: json["total_locations"],
      activeVehicles: json["active_vehicles"],
      inactiveVehicles: json["inactive_vehicles"],
      todayLocations: json["today_locations"],
      lastUpdate: json["last_update"],
      serverTime: json["server_time"],
    );
  }
}
