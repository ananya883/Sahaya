import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UnknownPersonService {
  static const String baseUrl = "http://10.49.2.38:5001/api/unknown";

  static Future<void> registerUnknownPerson({
    required String gender,
    required String age,
    required String height,
    required String weight,
    required String foundLocation,
    required String foundDate,
    required File image,
    required String reportedBy,
  }) async {
    final uri = Uri.parse("$baseUrl/upload");

    final request = http.MultipartRequest("POST", uri);

    // Form fields
    request.fields["gender"] = gender;
    request.fields["age"] = age;
    request.fields["height"] = height;
    request.fields["weight"] = weight;
    request.fields["foundLocation"] = foundLocation;
    request.fields["foundDate"] = foundDate;
    request.fields["reportedBy"] = reportedBy;

    // Image file
    request.files.add(
      await http.MultipartFile.fromPath(
        "photo",
        image.path,
        filename: basename(image.path),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception("Unknown person registration failed: $responseBody");
    }
  }
}

