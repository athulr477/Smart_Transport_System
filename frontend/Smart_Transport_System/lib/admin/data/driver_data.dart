class Driver {
  final String id;
  final String name;
  final String licenseNumber;
  final String password; // ADDED: Admin sets this
  final String? assignedBusId;

  Driver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.password,
    this.assignedBusId,
  });
}

class DriverData {
  static List<Driver> drivers = [];
  

  // Helper to generate a simple ID like "DRV001" for demo purposes
  // or just use timestamp if preferred.
  static String generateDriverId() {
    return "DRV${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}"; 
  }
}