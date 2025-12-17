import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static const String baseUrl = "http://192.168.143.38:5000";

  static Future<http.Response> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // ----------------- Send OTP -----------------
  static Future<http.Response> sendOtp(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/send-verification-otp');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email}),
    );
  }

  // ----------------- Verify OTP -----------------
  static Future<http.Response> verifyOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/api/auth/verify-email-otp');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
  }

  // ----------------- Register User -----------------
  static Future<http.Response> registerUser({
    required String Name,
    required String gender,
    required String dob,
    required String mobile,
    required String email,
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

  // ----------------- Forgot Password -----------------
  static Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/api/auth/forgot-password');
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email}),
    );
  }

  // ----------------- Send SOS -----------------
  static Future<http.Response> sendSos({
    required String emergencyType,
    String? disasterType,
    String? latitude,
    String? longitude,
    XFile? imageFile,        // mobile
    Uint8List? imageBytes,   // web
  }) async {
    final Uri uri = Uri.parse('$baseUrl/api/sos');
    final request = http.MultipartRequest('POST', uri);

    request.fields['emergency_type'] = emergencyType;
    request.fields['disaster_type'] = disasterType ?? '';
    request.fields['latitude'] = latitude ?? '';
    request.fields['longitude'] = longitude ?? '';
    request.fields['timestamp'] = DateTime.now().toUtc().toIso8601String();

    // Mobile: XFile -> File
    if (!kIsWeb && imageFile != null) {
      final file = File(imageFile.path);
      final fileName = path.basename(file.path);
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: fileName,
      ));
    }

    // Web: Uint8List -> multipart bytes
    if (kIsWeb && imageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'sos_image.jpg',
      ));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
