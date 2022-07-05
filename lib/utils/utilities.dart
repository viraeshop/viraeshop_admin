import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

// Future<File?> imagePath () async{
//   FilePickerResult? result = await FilePicker.platform.pickFiles();
//   File? file;
//   if(result != null) {
//     file = File(result.files.single.path!);
//   } else {
// // User canceled the picker
//   }
//   return file;
// }
uploadFile(String filePath) async {
  File file = File(filePath);

  try {
    await firebase_storage.FirebaseStorage.instance
        .ref('uploads/file-to-upload.png')
        .putFile(file);
    return true;
  } on firebase_core.FirebaseException catch (e) {
    // e.g, e.code == 'canceled'
    return false;
  }
}
