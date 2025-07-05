import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Opens a dialog to choose between Camera and Gallery
  Future<PlatformFile?> pickImage(BuildContext context) async {
    return await showModalBottomSheet<PlatformFile?>(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () async {
                  Navigator.pop(bc, await _pickImage(ImageSource.camera));
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 20, left: 16, right: 16,),
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(bc, await _pickImage(ImageSource.gallery));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Picks an image from the given source (Camera or Gallery)
  Future<PlatformFile?> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return null;

    String fileName = path.basename(image.path); // Extract filename

    int? size = await image.length(); // Get file size in bytes

    final bytes = await image.readAsBytes(); // Read bytes from the image

    return PlatformFile(
      path: image.path,
      name: fileName,
      size: size,
      bytes: bytes,
    );
  }
}