import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/reusable_widgets/image/image_picker_service.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:viraeshop_bloc/category/category_event.dart';
import 'package:viraeshop_bloc/category/category_state.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/products/category_screen.dart';
import 'package:viraeshop_bloc/category/category_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../configs/boxes.dart';

class AddCategory extends StatefulWidget {
  final bool isEdit;
  final int categoryId;
  final bool isSubCategory;
  final Map<String, dynamic>? category;
  const AddCategory(
      {super.key,
      this.isEdit = false,
      this.category,
      this.isSubCategory = false,
      this.categoryId = 0});

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
  TextEditingController categoryController = TextEditingController();
  bool onDelete = false;
  final ImagePickerService imagePickerService = ImagePickerService();
  @override
  void initState() {
    print(widget.category);
    if (widget.isEdit == true) {
      imagePath = widget.category!['image'] ?? '';
      nameController.text = widget.category!['category'] ?? '';
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
          List categories = Hive.box(productsBox).get(catKey);
          setState(() {
            load = false;
          });
          if (widget.isEdit) {
            toast(
              context: context,
              title: onDelete
                  ? 'Category deleted successfully'
                  : 'Category updated successfully',
            );
            for (int i = 0; i < categories.length; i++) {
              if (categories[i]['categoryId'] == widget.categoryId) {
                if (onDelete) {
                  if (!widget.isSubCategory) {
                    categories.removeAt(i);
                  } else {
                    print('This onDelete on sub-category');
                    List subCatgs = categories[i]['subCategories'] ?? [];
                    for (int j = 0; j < subCatgs.length; j++) {
                      if (subCatgs[j]['subCategoryId'] ==
                          widget.category!['subCategoryId']) {
                        print('This is the sub-category to be deleted');
                        subCatgs.removeAt(j);
                        categories[i]['subCategories'] = subCatgs;
                      }
                    }
                  }
                } else {
                  if (!widget.isSubCategory) {
                    print('This is main category editing');
                    categories[i]['category'] = nameController.text;
                    if (imageData.isNotEmpty) {
                      categories[i]['image'] = imageData['url'];
                      categories[i]['imageKey'] = imageData['key'];
                    }
                  } else {
                    print('This is sub-category editing');
                    List subCatgs = categories[i]['subCategories'] ?? [];
                    for (int j = 0; j < subCatgs.length; j++) {
                      if (subCatgs[j]['subCategoryId'] ==
                          widget.category!['subCategoryId']) {
                        subCatgs[j]['category'] = nameController.text;
                        if (imageData.isNotEmpty) {
                          subCatgs[j]['image'] = imageData['url'];
                          subCatgs[j]['imageKey'] = imageData['key'];
                        }
                        categories[i]['subCategories'] = subCatgs;
                      }
                    }
                  }
                }
              }
            }
          } else {
            nameController.clear();
            toast(context: context, title: 'Category created successfully');
            if (!widget.isSubCategory) {
              categories.add({
                'category': nameController.text,
                'image': imageData['url'] ?? '',
                'imageKey': imageData['key'] ?? '',
              });
            } else {
              for (int i = 0; i < categories.length; i++) {
                if (categories[i]['categoryId'] == widget.categoryId) {
                  categories[i]['subCategories'] = [
                    {
                      'category': nameController.text,
                      'image': imageData['url'] ?? '',
                      'imageKey': imageData['key'] ?? '',
                      'categoryId': widget.categoryId,
                    }
                  ];
                }
              }
            }
          }
          Hive.box(productsBox).put(catKey, categories);
          setState(() {
            onDelete = false;
          });
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: load,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                final categoryBloc = BlocProvider.of<CategoryBloc>(context);
                categoryBloc.add(GetCategoriesEvent(
                  isSubCategory: widget.isSubCategory,
                  categoryId: widget.categoryId,
                ));
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
              widget.isEdit
                  ? widget.category!['category']
                  : widget.isSubCategory
                      ? 'Sub-Category'
                      : 'New Category',
              style: kAppBarTitleTextStyle,
            ),
            actions: [
              if (widget.isEdit)
                IconButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Category'),
                          content: const Text(
                            'Are you sure you want to remove this Category?',
                            softWrap: true,
                            style: kSourceSansStyle,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  onDelete = true;
                                });
                                final categoryBloc =
                                    BlocProvider.of<CategoryBloc>(context);
                                categoryBloc.add(
                                  DeleteCategoryEvent(
                                    token: jWTToken,
                                    categoryId: widget.category![
                                            widget.isSubCategory
                                                ? 'subCategoryId'
                                                : 'categoryId']
                                        .toString(),
                                    body: {
                                      'isSubCategory': widget.isSubCategory,
                                    },
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Yes',
                                softWrap: true,
                                style: kSourceSansStyle,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'No',
                                softWrap: true,
                                style: kSourceSansStyle,
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),
                  color: kSubMainColor,
                  iconSize: 20.0,
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
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
                          onTap: () async {
                            try {
                              PlatformFile? imageResult =
                                  await imagePickerService.pickImage(context);
                              if (imageResult == null) return;
                              final imageData =
                                  await NetworkUtility.uploadImageFromNative(
                                      file: imageResult,
                                      folder: 'category_images');
                              setState(() {
                                imagePath = imageResult.path ?? '';
                                this.imageData = imageData;
                              });
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                              showToast('msg: $e', backgroundColor: kRedColor);
                            }
                          },
                          imagePath: imagePath,
                          showBottomCard: !widget.isEdit,
                          height: 70,
                          width: 150,
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
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
                        const SizedBox(
                          height: 15.0,
                        ),
                        const SizedBox(
                          height: 70,
                        ),
                        if (widget.isEdit && !widget.isSubCategory)
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryScreen(
                                    isSubCategory: true,
                                    categoryId: widget.categoryId,
                                  ),
                                ),
                              );
                            },
                            tileColor: kSelectedTileColor,
                            title: const Text(
                              'Sub-Categories',
                              style: kTableHeadingStyle,
                            ),
                            trailing: const Icon(
                              FontAwesomeIcons.chevronRight,
                              color: kBackgroundColor,
                              size: 20.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
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
                          categoryId: widget.category![widget.isSubCategory
                                      ? 'subCategoryId'
                                      : 'categoryId']
                                  .toString() ??
                              '',
                          categoryModel: {
                            'category': nameController.text,
                            'image': imageData['url'],
                            'imageKey': imageData['key'],
                            'categoryId': widget.categoryId,
                            if (widget.isSubCategory) 'isSubCategory': true,
                          }));
                    } else {
                      Map<String, dynamic> data = {
                        'category': nameController.text,
                        'image': imageData['url'] ?? '',
                        'imageKey': imageData['key'] ?? '',
                        if (widget.isSubCategory)
                          'categoryId': widget.categoryId,
                        if (widget.isSubCategory) 'isSubCategory': true,
                      };
                      if (kDebugMode) {
                        print('data to go: $data');
                      }
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
      ),
    );
  }
}
