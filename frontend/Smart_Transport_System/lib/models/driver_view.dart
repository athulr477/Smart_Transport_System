import 'vehicle.dart';

class DriverView {
  final String id;
  final String name;
  final String status;

  DriverView({
    required this.id,
    required this.name,
    required this.status,
  });

  factory DriverView.fromVehicle(Vehicle v) {
    return DriverView(
      id: v.vehicleId,
      name: v.vehicleId, // temporary display name
      status: v.status,
    );
  }
}
