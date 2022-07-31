import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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
  final TextEditingController? title1Controller;
  final TextEditingController? title2Controller;
  final TextEditingController? title3Controller;
  final String title1;
  final String title2;
  final String title3;
  final String? image;
  final String? imagePath;
  final Uint8List? imageBytes;
  final void Function()? onEdit;
  final void Function()? onEditDone;
  final void Function()? onDelete;
  final void Function()? getImage;
  AdsCard({
    this.isEdit,
    this.title1Controller,
    this.title2Controller,
    this.title3Controller,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.image,
    this.imageBytes,
    this.imagePath,
    this.onEdit,
    this.onEditDone,
    this.onDelete,
    this.getImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 150.0,
          width: 250.0,
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: kLinearGradient,
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              // width: 100.0,
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  isEdit!
                      ? CustomTextStyle(
                        hintText: 'Text Here',
                          title1Controller: title1Controller!,
                          textStyle: kShadowStyle,
                        )
                      : Text(
                          '$title1',
                          style: kShadowStyle,
                        ),
                  isEdit!
                      ? CustomTextStyle(
                        hintText: 'Text here',
                          title1Controller: title2Controller!,
                          textStyle: TextStyle(
                            shadows: [
                              Shadow(
                                color: kNewYellowColor,
                                blurRadius: 0.5,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: kBackgroundColor,
                            fontSize: 30.0,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.3,
                          ),
                        )
                      : Text(
                          '$title2',
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                color: kNewYellowColor,
                                blurRadius: 0.5,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: kBackgroundColor,
                            fontSize: 30.0,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.3,
                          ),
                        ),
                  isEdit!
                      ? CustomTextStyle(
                        hintText: 'Description',
                          title1Controller: title3Controller!,
                          textStyle: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 12.0,
                            fontFamily: 'Montserrat',
                          ),
                        )
                      : Text(
                          '$title3',
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 12.0,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                  _curvedCard(),
                ],
              ),
            ),
            SizedBox(width: 10.0),
            Container(
              decoration: BoxDecoration(
                color: kNewYellowColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: image!.isEmpty
                  ? imagePickerWidget(
                      width: 100.0,
                      onTap: isEdit! ? getImage : null,
                      images: imageBytes,
                      imagePath: imagePath,
                      showBottomCard: false,
                      backgroundColor: kNewYellowColor,
                    )
                  : CachedNetworkImage(
                      imageUrl: '$image',
                      height: double.infinity,
                      width: 100.0,
                      fit: BoxFit.cover,
                    ),
            ),
          ]),
        ),
        SizedBox(
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
              icon: Icon(Icons.delete),
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
      padding: EdgeInsets.all(5.0),
      // height: 20.0,
      // width: 30.0,
      decoration: BoxDecoration(
        color: kNewYellowColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
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
