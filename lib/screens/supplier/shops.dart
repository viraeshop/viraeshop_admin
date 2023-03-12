import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/suppliers/barrel.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_api/models/suppliers/suppliers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Shops extends StatefulWidget {
  final bool isUpdate;
  final Map<String, dynamic>? data;
  const Shops({Key? key, this.isUpdate = false, this.data}) : super(key: key);

  @override
  _ShopsState createState() => _ShopsState();
}

class _ShopsState extends State<Shops> {
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  bool isLoading = false;
  bool imageUpdated = false;
  Uint8List bundleImage = Uint8List(0);
  Map<String, dynamic> imageUrlData = {};
  String imagePath = '';
  final jWTToken = Hive.box('adminInfo').get('token');

  @override
  void initState() {
    // TODO: implement initState
    if (widget.isUpdate && widget.data != null) {
      controllers[0].text = widget.data!['supplierName'];
      controllers[1].text = widget.data!['businessName'];
      controllers[2].text = widget.data!['mobile'];
      controllers[3].text = widget.data!['optionalPhone'];
      controllers[4].text = widget.data!['email'];
      controllers[5].text = widget.data!['address'];
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              final supplierBloc = BlocProvider.of<SuppliersBloc>(context);
              supplierBloc.add(GetSuppliersEvent(token: jWTToken));
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: Text(
            widget.isUpdate ? 'Update Supplier' : 'Register Supplier',
            style: kAppBarTitleTextStyle,
          ),
        ),
        body: BlocListener<SuppliersBloc, SupplierState>(
          listenWhen: (context, state) {
            if (state is RequestFinishedSupplierState ||
                state is OnErrorSupplierState) {
              return true;
            } else {
              return false;
            }
          },
          listener: (context, state) {
            if (state is OnErrorSupplierState) {
              setState(() {
                isLoading = false;
              });
              snackBar(
                text: state.message,
                context: context,
                color: kRedColor,
                duration: 400,
              );
            } else if (state is RequestFinishedSupplierState) {
              setState(() {
                isLoading = false;
              });
              toast(
                context: context,
                title: widget.isUpdate ? 'Updated' : 'Created',
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(15.0),
            height: screenSize.height,
            width: screenSize.width,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (kIsWeb) {
                              // getImageWeb('suppliers').then((value) {
                              //   setState(() {
                              //     bundleImage = value.item1!;
                              //     imageUrlData = value.item2!;
                              //   });
                              // });
                            } else {
                              getImageNative('suppliers').then((value) {
                                setState(() {
                                  imagePath = value['path'];
                                  imageUrlData = value['imageData'];
                                  if (widget.isUpdate) {
                                    imageUpdated = true;
                                  }
                                });
                              });
                            }
                          },
                          child: Container(
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              image: widget.isUpdate && !imageUpdated
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          widget.data!['profileImage'] ?? ''),
                                    )
                                  : imageBG(
                                      bundleImage,
                                      imagePath,
                                      'assets/images/man.png',
                                    ),
                              color: kBackgroundColor,
                              borderRadius: BorderRadius.circular(100.0),
                              border: Border.all(
                                color: kSubMainColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: Column(
                            children: [
                              NewTextField(
                                controller: controllers[0],
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: kNewTextColor,
                                  size: 20,
                                ),
                                hintText: 'Enter name of supplier',
                                labelText: 'Supplier name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter supplier name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              NewTextField(
                                controller: controllers[1],
                                prefixIcon: const Icon(
                                  Icons.business,
                                  color: kNewTextColor,
                                  size: 20,
                                ),
                                hintText: 'Enter business name here',
                                labelText: 'Business name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter business name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    NewTextField(
                      controller: controllers[2],
                      maxLength: 11,
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(10),
                        width: 100.0,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.phone_android,
                              color: kNewTextColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '+880',
                              style: kTableCellStyle,
                            ),
                          ],
                        ),
                      ),
                      hintText: 'Enter mobile number',
                      labelText: 'Phone',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),

                    /// Optional number
                    NewTextField(
                      controller: controllers[3],
                      maxLength: 11,
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(10),
                        width: 100.0,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.phone_android,
                              color: kNewTextColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '+88',
                              style: kTableCellStyle,
                            ),
                          ],
                        ),
                      ),
                      hintText: 'Enter optional Phone',
                      labelText: 'Optional Phone',
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    NewTextField(
                      controller: controllers[4],
                      prefixIcon: const Icon(
                        Icons.email,
                        color: kNewTextColor,
                        size: 20,
                      ),
                      hintText: 'Enter email address',
                      labelText: 'Email',
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter email';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    NewTextField(
                      controller: controllers[5],
                      prefixIcon: const Icon(
                        Icons.room,
                        color: kNewTextColor,
                        size: 20,
                      ),
                      hintText: 'Enter your address',
                      labelText: 'Address',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    sendButton(
                      title: widget.isUpdate ? 'Update' : 'Create',
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          final supplierBloc =
                              BlocProvider.of<SuppliersBloc>(context);
                          Map<String, dynamic> supplier = {
                            'supplierName': controllers[0].text,
                            'businessName': controllers[1].text,
                            'mobile': controllers[2].text,
                            'optionalPhone': controllers[3].text,
                            'email': controllers[4].text,
                            'address': controllers[5].text,
                            if (!widget.isUpdate || imageUpdated)
                              'profileImage': imageUrlData['url'] ?? '',
                            if (!widget.isUpdate || imageUpdated)
                              'imageKey': imageUrlData['key'] ?? '',
                          };
                          if (widget.isUpdate) {
                            debugPrint('Done moving');
                            supplierBloc.add(
                              UpdateSupplierEvent(
                                  token: jWTToken,
                                  supplierModel: supplier,
                                  supplierId: widget.data!['supplierId'].toString() ?? ''),
                            );
                          } else {
                            supplierBloc.add(AddSupplierEvent(
                                token: jWTToken, supplierModel: supplier));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget sendButton(
    {required String title,
    void Function()? onTap,
    double width = double.infinity,
    height = 50.0,
    Color color = kNewTextColor}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: color,
      ),
      child: Center(
        child: Text(
          title,
          style: kTableHeadingStyle,
        ),
      ),
    ),
  );
}
