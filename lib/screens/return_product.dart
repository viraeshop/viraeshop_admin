import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/return/return_event.dart';
import 'package:viraeshop/return/return_state.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/non_inventory_product.dart';
import 'package:viraeshop_admin/settings/general_crud.dart';

import '../configs/configs.dart';
import 'customers/preferences.dart';
import 'new_non_inventory.dart';
import 'shops.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop/return/return_bloc.dart';


class ReturnProduct extends StatefulWidget {
  const ReturnProduct({Key? key}) : super(key: key);

  @override
  _ReturnProductState createState() => _ReturnProductState();
}

class _ReturnProductState extends State<ReturnProduct> {
  Uint8List? images;
  Map<String, dynamic> productImage = {};
  String imagePath = '';
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());
  bool isLoading = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return BlocListener<ReturnBloc, ReturnState>(
      listener: (context, state){
        if(state is OnErrorReturnState){
          setState(() {
            isLoading = false;
          });
          snackBar(text: state.message, context: context, color: kRedColor, duration: 50);
        }else if(state is RequestFinishedReturnState){
          setState(() {
            isLoading = false;
            controllers[0].clear();
            controllers[1].clear();
            controllers[2].clear();
            controllers[3].clear();
          });
          toast(context: context, title: 'Created successfully');
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(FontAwesomeIcons.chevronLeft),
                color: kSubMainColor,
                iconSize: 20.0),
            title: const Text(
              'Return Product',
              style: kAppBarTitleTextStyle,
            ),
          ),
          body: Container(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  imagePickerWidget(
                    onTap: () {
                      try {
                        if(kIsWeb){
                          // getImageWeb('returns').then((value) {
                          //   setState(() {
                          //     images = value.item1;
                          //     productImage = value.item2 ?? '';
                          //   });
                          // });
                        }else{
                          getImageNative('returns').then((value){
                            setState(() {
                              imagePath = value['path'];
                              productImage = value['imageData'];
                            });
                          });
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    images: images,
                    imagePath: imagePath,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  NewTextField(
                      controller: controllers[0],
                      prefixIcon:
                          const Icon(Icons.person, color: kNewTextColor, size: 20.0),
                      hintText: 'Customer\'s name/Id'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  NewTextField(
                      controller: controllers[1],
                      prefixIcon:
                          const Icon(Icons.inventory_2, color: kNewTextColor, size: 20.0),
                      hintText: 'Product\'s name'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  NewTextField(
                      controller: controllers[2],
                      prefixIcon:
                          const Icon(Icons.sell, color: kNewTextColor, size: 20.0),
                      hintText: 'Product\'s price'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  NewTextField(
                      controller: controllers[3],
                      prefixIcon:
                          const Icon(Icons.note_alt, color: kNewTextColor, size: 20.0),
                      hintText: 'Reason of return',
                      lines: 3),
                  const SizedBox(
                    height: 20.0,
                  ),
                  sendButton(title: 'Return', onTap: () {
                    if (controllers[0].text != null &&
                        controllers[1].text != null &&
                        controllers[2].text != null &&
                        controllers[3].text != null) {
                      setState(() {
                        isLoading = true;
                      });
                      final returnBloc = BlocProvider.of<ReturnBloc>(context);
                      Map<String, dynamic> data = {
                        'customerId': controllers[0].text,
                        'productName': controllers[1].text,
                        'productPrice': num.parse(controllers[2].text),
                        'reason': controllers[3].text,
                        'image': productImage['url'] ?? '',
                        'imageKey': productImage['key'] ?? '',
                      };
                      returnBloc.add(AddReturnEvent(
                          token: jWTToken,
                          returnModel: data));
                      } else {
                        showMyDialog('Fields can\'t be empty', context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
