import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000"; // Android emulator

  static Future<http.Response> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  static Future<http.Response> registerUser({
    required String Name,
    required String gender,
    required String dob,
    required String mobile,
    required String email,
    required String password,
    required String address,
    required String houseNo,
    required String guardianName,
    required String guardianRelation,
    required String guardianMobile,
    required String guardianEmail,
    required String guardianAddress,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    final body = jsonEncode({
      'Name': Name,
      'gender': gender,
      'dob': dob,
      'mobile': mobile,
      'email': email,
      'password': password,
      'address': address,
      'houseNo': houseNo,
      'guardianName': guardianName,
      'guardianRelation': guardianRelation,
      'guardianMobile': guardianMobile,
      'guardianEmail': guardianEmail,
      'guardianAddress': guardianAddress,
    });

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
  }

  static Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/forgot-password');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email}),
    );
  }
}
