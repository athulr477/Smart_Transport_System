// lib/admin/data/user_data.dart

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'admin' or 'user'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });
}

class UserData {
  static List<User> users = [];

  static String generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}