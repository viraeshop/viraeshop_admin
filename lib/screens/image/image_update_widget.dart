import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageFromUpdate extends StatelessWidget {
  const ImageFromUpdate({Key? key, required this.image, required this.isUpdate, this.imageBytes}) : super(key: key);
  final String image;
  final bool isUpdate;
  final Uint8List? imageBytes;
  @override
  Widget build(BuildContext context) {
    if(image.contains('http') && isUpdate){
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        errorWidget: (context, url, childs) {
          return Image.asset(
            'assets/default.jpg',
          );
        },
      );
    }else{
      if(kIsWeb){
        return Image.memory(
          imageBytes!,
          fit: BoxFit.cover,
        );
      }else{
        return Image.file(
          File(image),
          fit: BoxFit.cover,
        );
      }
    }
  }
}
