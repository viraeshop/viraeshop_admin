
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';

import '../../components/styles/text_styles.dart';

class AdsCard extends StatelessWidget {
  final bool? isEdit;
  final String image;
  final String imagePath;
  final void Function()? onEdit;
  final void Function()? onEditDone;
  final void Function()? onDelete;
  final void Function()? onUpdateImage;
  final TextEditingController textController;
  final String searchTerm;
  const AdsCard({
    this.isEdit,
    required this.image,
    required this.imagePath,
    required this.searchTerm,
    this.onEdit,
    this.onEditDone,
    this.onDelete,
    this.onUpdateImage,
    required this.textController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 150.0,
          width: MediaQuery.of(context).size.width * 0.7,
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: imagePath.isNotEmpty
                  ? FileImage(File(imagePath))
                  : CachedNetworkImageProvider(image),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
                  children: [
                    if(isEdit!) Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: onUpdateImage,
                        icon: const Icon(Icons.edit),
                        iconSize: 30.0,
                        color: kSubMainColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: CustomTextField(
                        enabled: isEdit!,
                        title1Controller: textController,
                        textStyle: kDrawerTextStyle2,
                        hintText: searchTerm,
                        height: 30.0,
                        width: 100.0,
                      ),
                    ),
                  ],
                ),
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

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.title1Controller,
    required this.textStyle,
    required this.hintText,
    this.enabled = true,
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
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    print(hintText);
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: kBlackColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: height,
      //width: width,
      child: TextField(
        enabled: enabled,
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
