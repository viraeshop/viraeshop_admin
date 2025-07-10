import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';

class HomeButtonAdvert extends StatelessWidget {
  const HomeButtonAdvert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: kSubMainColor,),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the home screen
          },
        ),
        title: const Text('Home Button Advert', style: kProductNameStylePro,),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: returnImageWidget(
              isFileImage: false,
              isPlaceHolder: true,
              imagePath: 'https://via.placeholder.com/150', // Replace with your image URL or file path
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      );
  }
  Widget returnImageWidget ({required bool isFileImage, required bool isPlaceHolder, required String imagePath}) {
    if (isFileImage || isPlaceHolder) {
      if (isPlaceHolder) {
        return Image.asset(
          'assets/images/placeholder.png', // Replace with your placeholder image path
          fit: BoxFit.cover,
          height: 150,
          width: 100,
        );
      }
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        height: 150,
        width: 100,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        height: 150,
        width: 100,
      );
    }

  }
}

