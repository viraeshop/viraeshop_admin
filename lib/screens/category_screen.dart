import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'add_category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: Text(
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
                child: Icon(Icons.add)),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: AdminCrud().getCategories(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final myCategories = snapshot.data!.docs;
              // List<String> agentId = [];
              int counter = 0;
              List categoryList = [];
              myCategories.forEach((element) {
                categoryList.add(element.data());
                categoryList[counter]['docId'] = element.id;
                counter += 1;
              });
              return Container(
                child: categoryList.isNotEmpty
                    ? ListView.builder(
                        itemCount: myCategories.length,
                        itemBuilder: (BuildContext context, int i) {
                          return Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: kBackgroundColor,
                              border: Border(
                                bottom: BorderSide(color: kStrokeColor),
                              ),
                            ),
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            kCategoryBackgroundColor,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                '${categoryList[i]['image']}'),
                                        radius: 50.0,
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        '${categoryList[i]['category_name']}',
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
                                                    ['category_name'],
                                                docId: categoryList[i]['docId'],
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.edit),
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
                                                title: Text('Delete Category'),
                                                content: Text(
                                                  'Are you sure you want to remove this Category?',
                                                  softWrap: true,
                                                  style: kSourceSansStyle,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      AdminCrud()
                                                          .deleteCategory(
                                                              myCategories[i]
                                                                  .id)
                                                          .then((value) {
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Text(
                                                      'Yes',
                                                      softWrap: true,
                                                      style: kSourceSansStyle,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
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
                                        icon: Icon(Icons.delete),
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
                      )
                    : Text('Loading'),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
