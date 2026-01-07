import '../core/api/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> driverLogin(
    String driverId,
    String password,
  ) async {
    return await ApiClient.post(
      "/driver-login",
      {
        "driver_id": driverId,
        "password": password,
      },
    );
  }
}
