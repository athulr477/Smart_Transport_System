import '../models/driver_view.dart';
import 'vehicle_service.dart';

class DriverService {
  static Future<List<DriverView>> fetchDrivers() async {
    final vehicles = await VehicleService.fetchVehicles();
    return vehicles.map(DriverView.fromVehicle).toList();
  }
}
