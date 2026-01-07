class Vehicle {
  final int id;
  final String vehicleId;
  final String? licensePlate;
  final String? vehicleType;
  final String status;

  Vehicle({
    required this.id,
    required this.vehicleId,
    this.licensePlate,
    this.vehicleType,
    required this.status,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["id"],
      vehicleId: json["vehicle_id"],
      licensePlate: json["license_plate"],
      vehicleType: json["vehicle_type"],
      status: json["status"],
    );
  }
}
