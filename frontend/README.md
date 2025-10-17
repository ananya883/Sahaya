import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
// Replace with your backend IP
static const String baseUrl = "http://10.0.2.2:5000/api/auth";

// Login
static Future<Map<String, dynamic>> login(String email, String password) async {
final url = Uri.parse("$baseUrl/login");
final response = await http.post(
url,
headers: {"Content-Type": "application/json"},
body: jsonEncode({"email": email, "password": password}),
);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed: ${response.body}");
    }
}

// Register
static Future<Map<String, dynamic>> register(String name, String email, String password) async {
final url = Uri.parse("$baseUrl/register");
final response = await http.post(
url,
headers: {"Content-Type": "application/json"},
body: jsonEncode({"name": name, "email": email, "password": password}),
);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Register failed: ${response.body}");
    }
}
}
