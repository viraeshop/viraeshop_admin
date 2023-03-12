import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/category/category_event.dart';
import 'package:viraeshop/category/category_state.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop/category/category_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/boxes.dart';

class AddCategory extends StatefulWidget {
  final bool isEdit;
  final String category;
  const AddCategory({this.isEdit = false, this.category = ''});

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController nameController = TextEditingController();
  bool load = false;
  Uint8List images = Uint8List(0);
  Map<String, dynamic> imageData = {};
  String imagePath = '';
  final _formKey = GlobalKey<FormState>();
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  void initState() {
    // TODO: implement initState
    if (widget.isEdit == true) {
      setState(() {
        nameController.text = widget.category;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is OnErrorCategoryState) {
          setState(() {
            load = false;
          });
          snackBar(text: state.message, context: context, duration: 50);
        } else if (state is RequestFinishedCategoryState) {
          setState(() {
            load = false;
          });
          if (widget.isEdit) {
            toast(context: context, title: 'Category updated successfully');
          } else {
            nameController.clear();
            toast(context: context, title: 'Category created successfully');
          }
          List categories = Hive.box(productsBox).get(catKey);
          categories.add({
            'category': nameController.text,
            'image': imageData['url'],
            'imageKey': imageData['key'],
          });
          Hive.box(productsBox).put(catKey, categories);
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: load,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                final categoryBloc = BlocProvider.of<CategoryBloc>(context);
                categoryBloc.add(GetCategoriesEvent());
                Navigator.pop(context);
              },
              icon: const Icon(FontAwesomeIcons.chevronLeft),
              color: kSubMainColor,
              iconSize: 20.0,
            ),
            iconTheme: const IconThemeData(color: kSelectedTileColor),
            elevation: 0.0,
            backgroundColor: kBackgroundColor,
            centerTitle: true,
            title: Text(
              widget.isEdit ? widget.category : 'New Category',
              style: kAppBarTitleTextStyle,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      imagePickerWidget(
                        onTap: () {
                          if (kIsWeb) {
                            // getImageWeb('category_images').then((value) {
                            //   setState(() {
                            //     images = value.item1!;
                            //     imageData = value.item2!;
                            //   });
                            // });
                          } else {
                            getImageNative('category_images').then((value) {
                              setState(() {
                                imagePath = value['path'];
                                imageData = value['imageData'];
                              });
                            });
                          }
                        },
                        images: images,
                        imagePath: imagePath,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value!.isEmpty || value == null) {
                            return 'enter category name';
                          }
                          return null;
                        },
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Enter name.'),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Max. 20 Characters.',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10),
            child: bottomCard(
              context: context,
              text: 'Add Category',
              onTap: () {
                final categoryBloc = BlocProvider.of<CategoryBloc>(context);
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    load = true;
                  });
                  if (widget.isEdit) {
                    categoryBloc.add(UpdateCategoryEvent(
                        token: jWTToken,
                        categoryId: widget.category,
                        categoryModel: {
                          'category': nameController.text,
                          'image': imageData['url'],
                          'imageKey': imageData['key'],
                        }));
                  } else {
                    Map<String, dynamic> data = {
                      'category': nameController.text,
                      'image': imageData['url'],
                      'imageKey': imageData['key'],
                    };
                    print('data to go: $data');
                    categoryBloc.add(
                      AddCategoryEvent(
                        token: jWTToken,
                        categoryModel: data,
                      ),
                    );
                  }
                } else {
                  showDialogBox(
                      buildContext: context, msg: 'Fields Cannot Be Empty');
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
