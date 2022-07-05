import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/functions.dart';
import 'package:viraeshop_admin/screens/shops.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class ImageCarousel extends StatefulWidget {
  final bool isUpdate;
  final List? images;
  ImageCarousel({this.isUpdate = false, this.images});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  List<Uint8List> imagesBytes = [];
  List<String> filesNames = [];
  List productImages = [];
  bool loading = false;
  int incrementer = 0, index = -1;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.isUpdate) {
      setState(() {
        productImages = widget.images! != null ? widget.images! : [];
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loading,
      progressIndicator: CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Photos',
            style: kAppBarTitleTextStyle,
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(15.0),
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
                          getImageWeb();
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            widget.isUpdate && productImages.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: productImages[0],
                                    fit: BoxFit.cover,
                                    errorWidget: (context, url, childs) {
                                      return Image.asset(
                                        'assets/default.jpg',
                                      );
                                    },
                                  )
                                : imagesBytes.isEmpty
                                    ? Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 25.0,
                                        ),
                                      )
                                    : Image.memory(
                                        imagesBytes[0],
                                        fit: BoxFit.cover,
                                      ),
                            topCancelButton(onTap: () {
                              snackBar(
                                text: 'Deleting...',
                                context: context,
                                duration: 10,
                              );
                              if (widget.isUpdate && productImages.isNotEmpty) {
                                deleteImage(productImages[0]).then((value) {
                                  productImages.removeAt(0);
                                  snackBar(
                                    text: 'Deleted',
                                    context: context,
                                    duration: 10,
                                  );
                                }).catchError((error) {
                                  snackBar(
                                    text: 'Operation failed. please try again',
                                    context: context,
                                    duration: 20,
                                  );
                                });
                              } else {
                                setState(() {
                                  imagesBytes.removeAt(0);
                                });
                              }
                            }),
                          ],
                        )),
                    SizedBox(
                      height: 10.0,
                    ),
                    LimitedBox(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: widget.isUpdate && productImages.isNotEmpty
                            ? productImages.length + incrementer
                            : imagesBytes.length,
                        itemBuilder: (context, i) {
                          if (widget.isUpdate && productImages.isNotEmpty) {
                            if (i == 0) {
                              return showImage(
                                onTap: () {
                                  getImageWeb();
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 25.0,
                                  ),
                                ),
                              );
                            } else {
                              return showImage(
                                  onTap: () {},
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      i >= productImages.length
                                          ? Image.memory(
                                              imagesBytes[
                                                  i - productImages.length],
                                              fit: BoxFit.cover,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: productImages[i],
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, childs) {
                                                return Image.asset(
                                                  'assets/default.jpg',
                                                );
                                              },
                                            ),
                                      topCancelButton(onTap: () {
                                        if (i >= productImages.length) {
                                          setState(() {
                                            imagesBytes.removeAt(
                                                i - productImages.length);
                                            incrementer -= 1;
                                          });
                                        } else {
                                          deleteImage(productImages[i])
                                              .then((value) =>
                                                  productImages.removeAt(i))
                                              .catchError((error) {
                                            snackBar(
                                              text:
                                                  'Operation failed. please try again',
                                              context: context,
                                              duration: 10,
                                            );
                                          });
                                        }
                                      }),

                                      /// top cancel button
                                    ],
                                  ));
                            }
                          } else {
                            if (i == 0) {
                              return showImage(
                                onTap: () {
                                  getImageWeb();
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 25.0,
                                  ),
                                ),
                              );
                            } else {
                              return showImage(
                                onTap: () {},
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.memory(
                                      imagesBytes[i],
                                      fit: BoxFit.cover,
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            imagesBytes.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          height: 25.0,
                                          width: 25.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100.0),
                                            color:
                                                Colors.white.withOpacity(0.8),
                                          ),
                                          child: Icon(
                                            Icons.cancel,
                                            color: kSubMainColor,
                                            size: 15.0,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              FractionallySizedBox(
                heightFactor: 0.12,
                alignment: Alignment.bottomCenter,
                child: sendButton(title: 'Save',onTap: () async {
                  for (int i = 0; i < filesNames.length; i++) {
                    setState(() {
                      loading = true;
                    });
                    await AdminCrud()
                        .uploadWebImage(imagesBytes[i], filesNames[i])
                        .then((imageUrl) {
                      setState(() {
                        productImages.add(imageUrl);
                        loading = false;
                      });
                    }).catchError((error) {
                      setState(() {
                        loading = false;
                      });
                    });
                  }
                  Hive.box('images').put('imagesBytes', imagesBytes);
                  Hive.box('images')
                      .put('productImages', productImages)
                      .whenComplete(
                        () => snackBar(text: 'Saved', context: context),
                      );
                  print(productImages);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getImageWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? imageBytes = result.files.first.bytes;
      String? fileName = result.files.first.name;
      setState(() {
        imagesBytes.add(imageBytes!);
        filesNames.add(fileName);
        incrementer += 1;
      });
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
        child: Icon(
          Icons.cancel,
          color: kSubMainColor,
          size: 15.0,
        ),
      ),
    ),
  );
}
