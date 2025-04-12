import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import 'functions.dart';

Widget imagePickerWidget({
  void Function()? onTap,
  required String imagePath,
  width = 150.0,
  height = 150.0,
  showBottomCard = true,
  backgroundColor = kProductCardColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        image: imageBG(imagePath: imagePath),
        borderRadius: showBottomCard
            ? BorderRadius.circular(10.0)
            : const BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)),
      ),
      child: showBottomCard
          ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: kSubMainColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: const [
                      Text('Upload Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kBackgroundColor,
                              fontWeight: FontWeight.bold)),
                      Text(
                        '+',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kBackgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox(),
    ),
  );
}

DecorationImage imageBG(
    {required String imagePath, String asset = 'assets/default.jpg'}) {
  if (imagePath.contains('http') && imagePath.isNotEmpty) {
    return DecorationImage(
      image: CachedNetworkImageProvider(imagePath),
      fit: BoxFit.cover,
    );
  } else {
    return imagePath.isEmpty
        ? DecorationImage(image: AssetImage(asset), fit: BoxFit.cover)
        : DecorationImage(
            image: FileImage(
              File(imagePath),
            ),
            fit: BoxFit.cover,
          );
  }
}

Future<Tuple2<Uint8List?, String?>> getImageWeb(String folder) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  Uint8List? imageBytes;
  String? productImageLink;
  if (result != null) {
    imageBytes = result.files.first.bytes ?? Uint8List(0);
    String fileName = result.files.first.name;
    productImageLink =
        await AdminCrud().uploadWebImage(imageBytes, fileName, folder);
  }
  return Tuple2<Uint8List?, String?>(imageBytes, productImageLink);
}

Future<Map<String, dynamic>> getImageNative(String folder) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  String? path;
  Map<String, dynamic> productImageLink = {};
  if (result != null) {
    path = result.paths.first;
    String fileName = result.files.first.name;
    productImageLink = await NetworkUtility.uploadImageFromNative(
      file: result.files.first,
      folder: folder,
    );
  }
  if (kDebugMode) {
    print(path);
  }
  return {
    'path': path ?? '',
    'imageData': productImageLink,
  };
}

Future<FilePickerResult?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: false,

// Ensure to get file stream for better performance
    withReadStream: true,
//allowedExtensions: ['jpg', 'png', 'gif'],
  );
  return result;
}

Future<Map<String, dynamic>> uploadFile(
    {required PlatformFile file,
    required String fileName,
    required String folder}) async {
  return await NetworkUtility.uploadImageFromNative(
    file: file,
    folder: folder,
  );
}
