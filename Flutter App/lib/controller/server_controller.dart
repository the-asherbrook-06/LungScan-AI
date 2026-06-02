// Packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Setup
import 'package:lungscan_ai/setup.dart';

class ServerController {
  // Check Server Health
  Future<String> checkServerStatus() async {
    final url = Uri.parse("${ENDPOINT}check");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "Connection failed: $e";
    }
  }

  // Upload X-ray Image
  Future<Map<String, dynamic>?> uploadXray(File imageFile) async {
    final url = Uri.parse("${ENDPOINT}predict");

    try {
      var request = http.MultipartRequest('POST', url);

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("Upload successful: $responseBody");
        return jsonDecode(responseBody);
      } else {
        print("Upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
