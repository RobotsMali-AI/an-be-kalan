import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String> imageUrlToBase64(String imageUrl) async {
  try {
    // Step 1: Download the image from the URL
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      // Step 2: Save the image as a temporary file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp_image.jpg';
      final imageFile = File(filePath);
      await imageFile.writeAsBytes(response.bodyBytes);

      // Step 3: Convert the file into a Uint8List
      Uint8List imageBytes = await imageFile.readAsBytes();

      // Step 4: Encode the bytes as a Base64 string
      String base64String = base64Encode(imageBytes);

      return base64String;
    } else {
      throw Exception('Failed to download image');
    }
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
