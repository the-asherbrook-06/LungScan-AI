// Packages
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<String> saveImageLocally(File image) async {
  final dir = await getApplicationDocumentsDirectory();

  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  final savedImage = await image.copy('${dir.path}/$fileName.jpg');

  return savedImage.path;
}

class PhotoPickerController {
  final ImagePicker _picker = ImagePicker();

  // Camera
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print("Camera error: $e");
      return null;
    }
  }

  // Gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print("Gallery error: $e");
      return null;
    }
  }
}
