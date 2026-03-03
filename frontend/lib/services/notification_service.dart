import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl =
      "http://192.168.1.6:5001/api/notifications";

  static Future<List<dynamic>> fetchNotifications(String userId) async {
    final res = await http.get(Uri.parse("$baseUrl/$userId"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load notifications");
    }
  }
}