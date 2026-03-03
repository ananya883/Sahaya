import 'dart:convert';
import 'package:http/http.dart' as http;

class CampService {
  static const String baseUrl = "http://192.168.1.6:5001/api/camps";

  static Future<List<dynamic>> fetchCamps() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Failed to load camps");
      }
    } catch (e) {
      throw Exception("Error fetching camps: $e");
    }
  }
}
