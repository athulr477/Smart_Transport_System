import '../core/api/api_client.dart';
import '../models/vehicle.dart';

class VehicleService {
  static Future<List<Vehicle>> fetchVehicles() async {
    final response = await ApiClient.getList("/api/vehicles");

    return (response)
        .map((json) => Vehicle.fromJson(json))
        .toList();
  }

  // --- ADDED: Create Vehicle ---
  static Future<void> createVehicle({
    required String vehicleId,
    String? vehicleType,
  }) async {
    await ApiClient.post(
      "/api/vehicles",
      {
        "vehicle_id": vehicleId,
        "vehicle_type": vehicleType ?? "bus",
        "status": "active",
      },
    );
  }

  // --- ADDED: Delete Vehicle ---
  static Future<void> deleteVehicle(String vehicleId) async {
    await ApiClient.delete("/api/vehicles/$vehicleId");
  }
}