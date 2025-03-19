import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/image/image_update_widget.dart';
import 'package:viraeshop_admin/screens/supplier/shops.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

class ImageCarousel extends StatefulWidget {
  final bool isUpdate;
  final List? images;
  final String thumbnail;
  final String thumbnailKey;
  const ImageCarousel(
      {super.key,
      this.isUpdate = false,
      this.images,
      required this.thumbnail,
      required this.thumbnailKey,
      });

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  Map<String, Uint8List> imagesBytes = {};
  Map filesPath = {};
  Map platformFiles = {};
  List allImages = [];
  List deletedImages = [];
  bool loading = false;
  String thumbnail = '';
  String thumbnailKey = '';
  PlatformFile? thumbnailFile;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.isUpdate) {
      allImages = widget.images!.toList();
      print(allImages.length);
      thumbnail = widget.thumbnail;
      thumbnailKey = widget.thumbnailKey;
      //print(allImages);
      //   this.productImage = widget.images!;
      //   print('Init State');
      // print('All Images: $allImages');
      //   print('Product Images: $productImage');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Photos',
            style: kAppBarTitleTextStyle,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(15.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                heightFactor: 0.88,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    showImage(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: double.infinity,
                        onTap: () {
                          getImageWeb(true);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            thumbnail.isNotEmpty || thumbnailFile != null
                                ? ImageFromUpdate(
                                    image: thumbnail.isNotEmpty &&
                                            thumbnailFile == null
                                        ? thumbnail
                                        : thumbnailFile!.path!,
                                    isUpdate: widget.isUpdate,
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 25.0,
                                    ),
                                  ),
                            topCancelButton(onTap: () async {
                              if (thumbnail.contains('http')) {
                                try {
                                  await NetworkUtility.deleteImage(
                                    key: thumbnailKey,
                                  );
                                  setState(() {
                                    thumbnail = '';
                                    thumbnailKey = '';
                                  });
                                } on FirebaseException catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              } else {
                                setState(() {
                                  thumbnailFile = null;
                                });
                              }
                              // setState(() {
                              //   deletedImages.add(allImages[0]);
                              //   allImages.removeAt(0);
                              // });
                            }),
                          ],
                        )),
                    const SizedBox(
                      height: 10.0,
                    ),
                    LimitedBox(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: allImages.length + 1,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return showImage(
                              onTap: () {
                                getImageWeb();
                              },
                              child: const Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 25.0,
                                ),
                              ),
                            );
                          }
                          return Stack(fit: StackFit.expand, children: [
                            ImageFromUpdate(
                              image: allImages[i-1] is Map<String, dynamic>
                                  ? allImages[i-1]['imageLink']
                                  : allImages[i-1] is String
                                      ? allImages[i-1]
                                      : '',
                              isUpdate: widget.isUpdate,
                            ),
                            topCancelButton(onTap: () async {
                              if (allImages[i-1] is Map<String, dynamic>) {
                                try {
                                  await NetworkUtility.deleteImage(
                                    key: allImages[i-1]['imageKey'],
                                  );
                                } on FirebaseException catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              } else if (allImages[i-1] is String) {
                                filesPath.removeWhere(
                                    (key, value) => value == allImages[i-1]);
                                platformFiles.removeWhere(
                                    (key, value) => key == allImages[i-1]);
                              } else {
                                imagesBytes.removeWhere(
                                    (key, value) => value == allImages[i-1]);
                              }
                              setState(() {
                                deletedImages.add(allImages[i-1]);
                                allImages.removeAt(i-1);
                              });
                            }),
                          ]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.12,
                alignment: Alignment.bottomCenter,
                child: sendButton(
                    title: 'Save',
                    onTap: () async {
                      final imageBox = Hive.box('images');
                      List filesNames = filesPath.keys.toList();
                      List filesPaths = filesPath.values.toList();
                      List productImage = imageBox.get('productImages', defaultValue: []);
                      Map<String, dynamic> thumbnailImage = {};
                      try {
                        setState(() {
                          loading = true;
                        });
                        if (thumbnailFile != null) {
                          final imageUrlData =
                              await NetworkUtility.uploadImageFromNative(
                            file: thumbnailFile!,
                            fileName: thumbnailFile!.name,
                            folder: 'product_images',
                          );
                          thumbnailImage = {
                            'thumbnailLink': imageUrlData['url'],
                            'thumbnailKey': imageUrlData['key'],
                          };
                        }
                        for (int i = 0; i < filesNames.length; i++) {
                          Map<String, dynamic> imageUrlData =
                              await NetworkUtility.uploadImageFromNative(
                            file: platformFiles[filesNames[i]],
                            fileName: filesNames[i],
                            folder: 'product_images',
                          );
                          if (kDebugMode) {
                            print('imageUrl: $imageUrlData');
                          }
                          productImage.add({
                            'imageLink': imageUrlData['url'],
                            'imageKey': imageUrlData['key'],
                          });
                        }
                        imageBox.put('imagesPath', filesPaths);
                        imageBox.put('productImages', productImage);
                        imageBox.put('thumbnailImage', thumbnailImage);
                        imageBox.put('deletedImages', deletedImages)
                            .then((value) => Navigator.pop(context));
                        // if (kDebugMode) {
                        //   print(productImages);
                        // }
                      } catch (e) {
                        if (kDebugMode) {
                          print(e);
                        }
                      } finally {
                        setState(() {
                          loading = false;
                        });
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getImageWeb([bool isFirst = false]) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (kDebugMode) {
      print('image: ${result?.files.first}');
    }
    if (result != null) {
      String? fileName = result.files.first.name;

      /// Replacing the first image
      if (isFirst && thumbnail.isNotEmpty) {
        try {
          await NetworkUtility.deleteImage(key: thumbnailKey);
        } on FirebaseException catch (e) {
          if (context.mounted) {
            snackBar(
              text: e.message!,
              context: context,
              duration: 600,
            );
          }
          if (kDebugMode) {
            print(e.message);
          }
        }
      }
      String filePath = result.paths.first!;
      setState(() {
        if (isFirst) {
          thumbnailFile = result.files.first;
        } else {
          allImages.add(filePath);
          filesPath[fileName] = filePath;
          platformFiles[filePath] = result.files.first;
        }
      });
      if (kDebugMode) {
        print('total images: $filePath');
      }
    }
  }
}

Widget showImage({
  required void Function() onTap,
  required Widget child,
  double height = 100,
  width,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: kspareColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: child,
    ),
  );
}

Widget topCancelButton({required Function()? onTap}) {
  return Align(
    alignment: Alignment.topRight,
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 30.0,
        width: 30.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.white.withOpacity(0.8),
        ),
        child: const Icon(
          Icons.cancel,
          color: kSubMainColor,
          size: 15.0,
        ),
      ),
    ),
  );
}
