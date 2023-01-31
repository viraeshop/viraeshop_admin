import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:viraeshop/category/category_bloc.dart';
import 'package:viraeshop/category/category_event.dart';
import 'package:viraeshop/category/category_state.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_api/models/products/product_category.dart';
import 'add_category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    final categoryBloc = BlocProvider.of<CategoryBloc>(context);
    categoryBloc.add(GetCategoriesEvent());
    super.initState();
  }
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'Category',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddCategory()));
                },
                child: const Icon(Icons.add)),
          )
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(builder: (context, state) {
        if (state is FetchedCategoryState) {
          List<ProductCategory> myCategories = state.categories;
          // List<String> agentId = [];
          int counter = 0;
          List categoryList = [];
          for (var element in myCategories) {
            categoryList.add(element.toJson());
          }
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
                                          category: categoryList[i]
                                              ['category'],
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
                                // ),
                                IconButton(
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Delete Category'),
                                          content: const Text(
                                            'Are you sure you want to remove this Category?',
                                            softWrap: true,
                                            style: kSourceSansStyle,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                final categoryBloc =
                                                    BlocProvider.of<CategoryBloc>(context);
                                                categoryBloc.add(
                                                  DeleteCategoryEvent(
                                                    token: jWTToken,
                                                      categoryId: categoryList[i]['category'],
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
                          ],
                        ),
                      ),
                    );
                  },
                );
        }
        else if(state is OnErrorCategoryState){
          return Center(
            child: Text(state.message, style: kProductNameStylePro,),
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
