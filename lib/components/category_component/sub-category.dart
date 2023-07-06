import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop/category/category_bloc.dart';
import 'package:viraeshop/category/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/products/add_category.dart';
import '../styles/colors.dart';
import '../styles/text_styles.dart';

Future<void> getSubCategoryDialog({
  required BuildContext buildContext,
  required int categoryId,
}) async {
  return showDialog<void>(
    context: buildContext,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        actionsPadding: const EdgeInsets.all(10.0),
        actions: [
          TextButton(
            child: const Text(
              'Add Sub-Category',
              style: TextStyle(
                color: kIconColor1,
                fontSize: 15.0,
                fontFamily: 'Montserrat',
                letterSpacing: 1.3,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCategory(
                    isSubCategory: true,
                    categoryId: categoryId,
                  ),
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Sub-Categories'),
        titleTextStyle: kProductNameStyle,
        // ignore: dead_code
        content: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is OnErrorCategoryState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    state.message,
                    style: kSansTextStyle1,
                  ),
                ),
              );
            } else if (state is FetchedCategoryState) {
              final data = state.categories;
              List categories = [];
              for (var element in data) {
                categories.add(element.toJson());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: List.generate(
                    categories.length,
                        (index) {
                      return InkWell(
                        onTap: () {
                          Hive.box('subCategory').putAll({
                            'name': categories[index]['category'],
                            'subCategoryId': categories[index]['subCategoryId'],
                            'categoryId': categories[index]['categoryId'],
                          }).whenComplete(() => Navigator.pop(context));
                        },
                        child: SizedBox(
                          height: 40.0,
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Icon(
                                Icons.category,
                                color: kIconColor1,
                                size: 15.0,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                categories[index]['category'],
                                style: kProductNameStylePro,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              return const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              );
            }
          },
        ),
      );
    },
  );
}