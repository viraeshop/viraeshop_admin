import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class AddCategory extends StatefulWidget {
  final bool isEdit;
  final String category;
  final String docId;
  AddCategory({this.isEdit = false, this.category = '', this.docId = ''});

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController nameController = TextEditingController();
  bool load = false;
  Uint8List images = Uint8List(0);
  String imageLink = '';
  String imagePath = '';
  final _formKey = GlobalKey<FormState>();
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
    return ModalProgressHUD(
      inAsyncCall: load,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: kSelectedTileColor),
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
                        if(kIsWeb){
                          getImageWeb('category_images').then((value) {
                            setState(() {
                              images = value.item1!;
                              imageLink = value.item2!;
                            });
                          });
                        }else{
                          getImageNative('category_images').then((value){
                            setState(() {
                              imagePath = value.item1!;
                              imageLink = value.item2!;
                            });
                          });
                        }
                      },
                      images: images,
                      imagePath: imagePath,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty || value == null)
                          return 'enter category name';
                        return null;
                      },
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Enter name.'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
          padding: EdgeInsets.all(10),
          child: bottomCard(
            context: context,
            text: 'Add Category',
            onTap: () {
              AdminCrud adminCrud = AdminCrud();
              if (_formKey.currentState!.validate()) {
                setState(() {
                  load = true;
                });
                if (widget.isEdit) {
                  adminCrud.updateCategory({
                    'category_name': nameController.text,
                    'image': imageLink,
                  }, widget.docId).then((value) {
                    setState(() {
                      load = false;
                    });
                    snackBar(text: 'Updated', context: context);
                  });
                } else {
                  adminCrud.addCategory({
                    'category_name': nameController.text,
                    'image': imageLink,
                  }).then(
                    (v) {
                      setState(() {
                        load = false;
                      });
                      nameController.clear();
                      showDialogBox(
                          buildContext: context, msg: 'Category Added');
                    },
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
    );
  }
}
