import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

import 'functions.dart';

Widget imagePickerWidget({
  void Function()? onTap,
  required Uint8List? images,
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
        image: imageBG(images),
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

DecorationImage imageBG(Uint8List? images, [String asset = 'assets/default.jpg']) {
  return images == null || images.isEmpty
      ? DecorationImage(
          image: AssetImage(asset), fit: BoxFit.cover)
      : DecorationImage(image: MemoryImage(images), fit: BoxFit.cover);
}

Future<Tuple2<Uint8List?, String?>> getImageWeb() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  Uint8List? imageBytes;
  String? productImageLink;
  if (result != null) {
    imageBytes = result.files.first.bytes ?? Uint8List(0);
    String fileName = result.files.first.name;
    await AdminCrud().uploadWebImage(imageBytes, fileName).then((imageUrl) {
      productImageLink = imageUrl;
    });
  }
  return Tuple2<Uint8List?, String?>(imageBytes, productImageLink);
}

Future<String>? deleteProductImages(List image) async{
    String message = 'Deleted successfully';
    List images = image;
    if(images.isNotEmpty){
      images.forEach((element) async {
      await deleteImage(element).catchError((error) {
        message = error;
      });
    });
    }else{
      message = 'No image';
    }   
    return message;
  }