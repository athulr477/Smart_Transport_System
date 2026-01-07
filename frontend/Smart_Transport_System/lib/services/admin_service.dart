import '../core/api/api_client.dart';
import '../models/stats.dart';

class AdminService {
  static Future<SystemStats> fetchStats() async {
    final response = await ApiClient.get("/api/stats");
    return SystemStats.fromJson(response);
  }
}
