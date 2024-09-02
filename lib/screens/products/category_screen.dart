import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_bloc/category/category_bloc.dart';
import 'package:viraeshop_bloc/category/category_event.dart';
import 'package:viraeshop_bloc/category/category_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_api/models/products/product_category.dart';
import 'add_category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen(
      {this.isSubCategory = false, this.categoryId = 0, Key? key})
      : super(key: key);

  final bool isSubCategory;
  final int categoryId;
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    final categoryBloc = BlocProvider.of<CategoryBloc>(context);
    categoryBloc.add(
        GetCategoriesEvent(
          isSubCategory: widget.isSubCategory,
          categoryId: widget.categoryId,
        ),);
    super.initState();
  }

  final jWTToken = Hive.box('adminInfo').get('token');
  bool isLoaded = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: false,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: kSelectedTileColor),
          elevation: 0.0,
          backgroundColor: kBackgroundColor,
          title: Text(
            widget.isSubCategory ? 'Sub-Categories' : 'Categories',
            style: kAppBarTitleTextStyle,
          ),
          centerTitle: true,
          titleTextStyle: kTextStyle1,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategory(
                          isSubCategory: widget.isSubCategory,
                          categoryId: widget.categoryId,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.add)),
            )
          ],
        ),
        body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is FetchedCategoryState) {
            List<ProductCategory> myCategories = state.categories.result;
            List categoryList = [];
            for (var element in myCategories) {
              categoryList.add(element.toJson());
            }
            // isLoaded = true;
            return ListView.builder(
              itemCount: myCategories.length,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: kBackgroundColor,
                    border: Border(
                      bottom: BorderSide(color: kStrokeColor),
                    ),
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: kCategoryBackgroundColor,
                              backgroundImage: CachedNetworkImageProvider(
                                  '${categoryList[i]['image']}'),
                              radius: 50.0,
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              '${categoryList[i]['category']}',
                              style: kProductNameStyle,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddCategory(
                                      isEdit: true,
                                      isSubCategory: widget.isSubCategory,
                                      category: categoryList[i],
                                      categoryId: categoryList[i]['categoryId'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              color: kSubMainColor,
                              iconSize: 20.0,
                            ),
                            // SizedBox(
                            //   width: 5.0,
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is OnErrorCategoryState) {
            return Center(
              child: Text(
                state.message,
                style: kProductNameStylePro,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
