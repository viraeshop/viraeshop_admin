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
  ImageCarousel({this.isUpdate = false, this.images});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  Map<String, Uint8List> imagesBytes = {};
  Map filesPath = {};
  List allImages = [];
  List deletedImages = [];
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.isUpdate) {
      allImages = widget.images!.toList();
      print(allImages);
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
                            allImages.isNotEmpty
                                ? ImageFromUpdate(
                                    image: allImages[0] is Map<String, dynamic>
                                        ? allImages[0]['imageLink']
                                        : allImages[0] is String
                                            ? allImages[0]
                                            : '',
                                    isUpdate: widget.isUpdate,
                                    imageBytes: allImages[0] is Uint8List
                                        ? allImages[0]
                                        : Uint8List(0),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.add_a_photo,
                                      size: 25.0,
                                    ),
                                  ),
                            topCancelButton(onTap: () async {
                              if (allImages[0] is Map<String, dynamic>) {
                                try {
                                  await NetworkUtility.deleteImage(
                                      key: allImages[0]['imageKey']);
                                } on FirebaseException catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              } else if (allImages[0] is String) {
                                filesPath.removeWhere(
                                    (key, value) => value == allImages[0]);
                              } else {
                                imagesBytes.removeWhere(
                                    (key, value) => value == allImages[0]);
                              }
                              setState(() {
                                deletedImages.add(allImages[0]);
                                allImages.removeAt(0);
                              });
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
                        itemCount: allImages.length,
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
                                image: allImages[i] is Map<String, dynamic>
                                    ? allImages[i]['imageLink']
                                    : allImages[i] is String
                                    ? allImages[i]
                                    : '',
                              isUpdate: widget.isUpdate,
                            ),
                            topCancelButton(onTap: () async {
                              if (kDebugMode) {
                                print('initial List: $filesPath');
                              }
                              if (allImages[i] is Map<String, dynamic>) {
                                try {
                                  await NetworkUtility.deleteImage(
                                    key: allImages[i]['imageKey'],
                                  );
                                } on FirebaseException catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              } else if (allImages[i] is String) {
                                filesPath.removeWhere(
                                    (key, value) => value == allImages[i]);
                              } else {
                                imagesBytes.removeWhere(
                                    (key, value) => value == allImages[i]);
                              }
                              setState(() {
                                deletedImages.add(allImages[i]);
                                allImages.removeAt(i);
                              });
                              if (kDebugMode) {
                                print('final List: $filesPath');
                              }
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
                      List filesNames = filesPath.keys.toList();
                      List filesPaths = filesPath.values.toList();
                      List productImage = [];
                      // for (var image in allImages) {
                      //   if (image is String) {
                      //     if (image.contains('https')) {
                      //       productImage.add(image);
                      //     }
                      //   }
                      // }
                      // print('Thumbnail: $filesPaths');
                      // print('First Image: ${filesPath[filesNames[0]]}');
                      try {
                        setState(() {
                          loading = true;
                        });
                        if (kIsWeb) {
                          for (int i = 0; i < filesNames.length; i++) {
                            String imageUrl = await AdminCrud().uploadWebImage(
                                imagesBytes[filesNames[i]]!,
                                filesNames[i],
                                'product_images');
                            productImage.add(imageUrl);
                          }
                        } else {
                          for (int i = 0; i < filesNames.length; i++) {
                            Map<String, dynamic> imageUrlData =
                                await NetworkUtility.uploadImageFromNative(
                              file: File(filesPath[filesNames[i]]),
                              fileName: filesNames[i],
                              folder: 'product_images',
                            );
                            print('imageUrl: $imageUrlData');
                            productImage.add({
                              'imageLink': imageUrlData['url'],
                              'imageKey': imageUrlData['key'],
                            });
                          }
                        }
                        Hive.box('images')
                            .put('imagesBytes', imagesBytes.values.toList());
                        Hive.box('images').put('imagesPath', filesPaths);

                        Hive.box('images').put('productImages', productImage);
                        Hive.box('images').put('deletedImages', deletedImages);
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
      if (isFirst && allImages.isNotEmpty) {
        try {
          if (allImages[0] is Map<String, dynamic>) {
            await NetworkUtility.deleteImage(key: allImages[0]['imageKey']);
          }
        } on FirebaseException catch (e) {
          snackBar(
            text: e.message!,
            context: context,
            duration: 600,
          );
          if (kDebugMode) {
            print(e.message);
          }
        }
      }

      /// check if the running platform is web
      if (kIsWeb) {
        Uint8List imageBytes = result.files.first.bytes!;
        setState(() {
          if (isFirst) {
            if (allImages.isNotEmpty) {
              allImages[0] = imageBytes;
            } else {
              allImages.add(imageBytes);
            }
          } else {
            allImages.add(imageBytes);
          }
          imagesBytes[fileName] = imageBytes;
        });
      } else {
        String filePath = result.paths.first!;
        setState(() {
          if (isFirst) {
            if (allImages.isNotEmpty) {
              allImages[0] = filePath;
            } else {
              allImages.add(filePath);
            }
          } else {
            allImages.add(filePath);
          }
          filesPath[fileName] = filePath;
        });
        print('total images: $filePath');
        // print('Replaced: $isReplaced');
      }
    }
  }
}

Widget showImage(
    {required void Function() onTap,
    required Widget child,
    double height = 100,
    width}) {
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
