import 'dart:io';

class AppConfig {
  static const String androidBaseUrl = "http://10.0.2.2:8000";
  static const String iosBaseUrl = "http://127.0.0.1:8000";

  static String get baseUrl {
    if (Platform.isAndroid) {
      return androidBaseUrl;
    } else {
      return iosBaseUrl;
    }
  }
}
