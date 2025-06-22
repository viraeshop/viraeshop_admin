import 'dart:io';
import 'dart:math';
import 'dart:typed_data';import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/gradients.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/advert/ads_provider.dart';

import '../../components/styles/text_styles.dart';

class AdsCard extends StatelessWidget {
  final bool? isEdit;
  final String? image;
  final String? imagePath;
  final void Function()? onEdit;
  final void Function()? onEditDone;
  final void Function()? onDelete;
  final void Function()? onUpdateImage;
 const  AdsCard({
    this.isEdit,
    required this.image,
    this.imagePath,
    this.onEdit,
    this.onEditDone,
    this.onDelete,
    this.onUpdateImage,
    super.key,
    });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 150.0,
          width: 250.0,
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: imagePath != null
                  ? FileImage(File(imagePath!))
                  : image != null && image!.isNotEmpty
                      ? CachedNetworkImageProvider(image!)
                      : const AssetImage('assets/images/placeholder.png')
                          as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: isEdit! ? Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: onUpdateImage,
              icon: const Icon(Icons.edit),
              iconSize: 30.0,
              color: kSubMainColor,
            ),
          ) : null,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Column(
          children: [
            IconButton(
              onPressed: isEdit! ? onEditDone : onEdit,
              icon: Icon(isEdit! ? Icons.done : Icons.edit_note_rounded),
              iconSize: 30.0,
              color: kSubMainColor,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              iconSize: 30.0,
              color: kRedColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _curvedCard() {
    return Container(
      padding: const EdgeInsets.all(5.0),
      // height: 20.0,
      // width: 30.0,
      decoration: BoxDecoration(
        color: kNewYellowColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: const Center(
        child: Text(
          'See Details',
          style: kDrawerTextStyle2,
        ),
      ),
    );
  }
}

class CustomTextStyle extends StatelessWidget {
  const CustomTextStyle({
    Key? key,
    required this.title1Controller,
    required this.textStyle,
    required this.hintText,
    this.lines = 1,
    this.height = 30.0,
    this.width = 100.0,
  }) : super(key: key);

  final TextEditingController title1Controller;
  final TextStyle textStyle;
  final String hintText;
  final int lines;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: TextField(
        controller: title1Controller,
        style: textStyle,
        cursorColor: kBackgroundColor,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textStyle,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
