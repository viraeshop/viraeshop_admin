import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/buttons/dialog_button.dart';
import 'package:viraeshop_admin/screens/add_category.dart';
import 'package:viraeshop_admin/screens/general_provider.dart';
import 'package:viraeshop_admin/screens/layout_screen/modal_view.dart';
import 'package:viraeshop_admin/screens/home_screen.dart';
import 'package:viraeshop_admin/screens/login_page.dart';
import 'package:viraeshop_admin/screens/shops.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_admin/settings/login_preferences.dart';

class Configs extends ChangeNotifier {
  Widget currentScreen = const ModalWidget();
  String? sellBy;
  String category = '';
  String? productFor;
  bool enableFields = false;
  bool updating = false;
  bool isGeneralDiscount = false;
  bool isAgentDiscount = false;
  bool isArchitectDiscount = false;
  String indicatorText = 'Update';
  String selectedSellby = 'Unit';

  void updateSellBy(String value) {
    selectedSellby = value;
    notifyListeners();
  }

  void onGeneralDiscount(bool value) {
    isGeneralDiscount = value;
    notifyListeners();
  }

  void onAgentDiscount(bool value) {
    isAgentDiscount = value;
    notifyListeners();
  }

  void onArchitectDiscount(bool value) {
    isArchitectDiscount = value;
    notifyListeners();
  }

  void updateText(String enable) {
    indicatorText = enable;
    notifyListeners();
  }

  void enable(bool enable) {
    enableFields = enable;
    notifyListeners();
  }

  void updateCategory(String newCategory) {
    category = newCategory;
    notifyListeners();
  }

  void updateProductFor(String newUserType) {
    productFor = newUserType;
    notifyListeners();
  }

  void updateWidget(Widget newWidget) {
    currentScreen = newWidget;
    notifyListeners();
  }
}

void snackBar(
    {required String text,
    required BuildContext context,
    int duration = 6,
    color = kNewTextColor}) {
  final snacks = SnackBar(
    duration: const Duration(milliseconds: 6),
    backgroundColor: color,
    content: Text(
      text,
      style: kDrawerTextStyle2,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snacks);
}

Container headerContainer({required String heading}) {
  return Container(
      height: 90.0,
      width: double.infinity,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: kBackgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: kCategoryNameStylePro,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              const Text(
                'Home > ',
                style: kProductNameStylePro,
              ),
              Text(
                heading,
                style: kHeadingStyle,
              ),
            ],
          ),
        ],
      ));
}

Future<void> showDialogBox(
    {required BuildContext buildContext,
    String title = "Error",
    msg = ''}) async {
  return showDialog<void>(
    context: buildContext,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Alert'),
        titleTextStyle: kProductNameStyle,
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: ListBody(
            children: <Widget>[
              Text(
                msg,
                style: kProductNameStylePro,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: kMainColor,
              ),
              child: const Center(
                child: Text(
                  'OK',
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: kBackgroundColor,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> loginDialogBox({required BuildContext buildContext}) async {
  return showDialog<void>(
    context: buildContext,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Alert'),
        titleTextStyle: kProductNameStyle,
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Sorry you need to log in',
                softWrap: true,
                style: kProductNameStylePro,
              ),
              const SizedBox(
                height: 10.0,
              ),
              contains()
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: <Widget>[
          DialogButton(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            title: 'Go To Login',
          ),
        ],
      );
    },
  );
}

Widget contains() {
  return ValueListenableBuilder(
    valueListenable: Hive.box('userType').listenable(),
    builder: (context, Box box, childs) {
      String userType = box.get('userType');
      return Container(
        // width: 150.0,
        // height: 50.0,
        padding: const EdgeInsets.all(7.0),
        decoration: const BoxDecoration(
          color: kBackgroundColor,
        ),
        child: Center(
          child: DropdownButtonFormField(
            iconEnabledColor: kSubMainColor,
            //dropdownColor: kMainColor,
            onChanged: (dynamic value) {
              saveUserType(value);
            },
            hint: const Text('Select User type', style: kProductNameStylePro),
            isExpanded: true,
            value: userType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: kSubMainColor),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            items: <DropdownMenuItem>[
              const DropdownMenuItem(
                value: 'agents',
                child: const Text(
                  'Agent',
                  style: kProductNameStylePro,
                ),
              ),
              const DropdownMenuItem(
                value: 'general',
                child: Text(
                  'General',
                  style: kProductNameStylePro,
                ),
              ),
              const DropdownMenuItem(
                value: 'architect',
                child: Text(
                  'Architect',
                  style: kProductNameStylePro,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Future<void> addInvoiceIdDialog(
//     {required BuildContext context,
//     required TextEditingController controller}) {
//   return showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text('Add Invoice number/Id'),
//         titleTextStyle: kProductNameStyle,
//         content: Container(
//           width: MediaQuery.of(context).size.width,
//           height: 60.0,
//           padding: EdgeInsets.all(7.0),
//           decoration: BoxDecoration(
//             color: kBackgroundColor,
//           ),
//           child: Center(
//             child: TextField(
//               controller: controller,
//               style: kProductNameStylePro,
//               textAlign: TextAlign.center,
//               cursorColor: kSubMainColor,
//               decoration: InputDecoration(
//                 hintText: 'Enter invoice number/Id',
//                 hintStyle: kProductNameStylePro,
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(color: kSubMainColor),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: kSubMainColor),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: kSubMainColor),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         actionsAlignment: MainAxisAlignment.end,
//         actions: <Widget>[
//           DialogButton(
//             onTap: () {
//               Hive.box('cartDetails')
//                   .put('invoiceId', controller.text)
//                   .whenComplete(
//                     () => Navigator.pop(context),
//                   );
//             },
//             title: 'Add',
//           ),
//         ],
//       );
//     },
//   );
// }

Future<void> getCategoryDialog({
  required BuildContext buildContext,
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
              'Add Category',
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
                  builder: (context) => AddCategory(),
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Categories'),
        titleTextStyle: kProductNameStyle,
        // ignore: dead_code
        content: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .doc('category')
              .collection('categories')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              List categories = [];
              for (var element in data) {
                categories.add(element.data());
              }
              print(categories);
              return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      children: List.generate(categories.length, (index) {
                    return InkWell(
                      onTap: () {
                        Hive.box('category')
                            .put('name', categories[index]['category_name'])
                            .whenComplete(() => Navigator.pop(context));
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
                              categories[index]['category_name'],
                              style: kProductNameStylePro,
                            ),
                          ],
                        ),
                      ),
                    );
                  })));
            } else {
              return const Text('Oops an error occured');
            }
          },
        ),
      );
    },
  );
}

Future<void> getAdvertsDialog({
  required BuildContext buildContext,
}) async {
  return showDialog<void>(
    context: buildContext,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        actionsPadding: const EdgeInsets.all(10.0),
        // actions: [
        //   TextButton(
        //     child: Text(
        //       'Select adverts',
        //       style: TextStyle(
        //         color: kIconColor1,
        //         fontSize: 15.0,
        //         fontFamily: 'Montserrat',
        //         letterSpacing: 1.3,
        //       ),
        //     ),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => AddCategory(),
        //         ),
        //       );
        //     },
        //   ),
        // ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Advertisements'),
        titleTextStyle: kProductNameStyle,
        // ignore: dead_code
        content: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('adverts')
              .doc('adverts')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.data() != null) {
              final data = snapshot.data!.get('adverts');
              List advertList = [];
              data.forEach((element) {
                advertList.add(element['adsCategory']);
              });
              List adverts = Set.from(advertList).toList();
              print(adverts);
              return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                      children: List.generate(adverts.length, (index) {
                    return Consumer<GeneralProvider>(
                        builder: (context, provider, childs) {
                      List advert = provider.advertSelected;
                      String adName = adverts[index];
                      return InkWell(
                        onTap: () {
                          if (advert.contains(adName)) {
                            Provider.of<GeneralProvider>(context, listen: false)
                                .removeAdvert(adName);
                          } else {
                            Provider.of<GeneralProvider>(context, listen: false)
                                .addAdvert(adName);
                          }
                        },
                        child: SizedBox(
                          height: 40.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    color: kNewMainColor,
                                    size: 15.0,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(
                                    adName,
                                    style: kProductNameStylePro,
                                  ),
                                ],
                              ),
                              advert.contains(adName)
                                  ? const Icon(
                                      Icons.done_rounded,
                                      color: kNewMainColor,
                                      size: 15.0,
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      );
                    });
                  })));
            } else {
              return const Text('Oops an error occured');
            }
          },
        ),
      );
    },
  );
}

Future<void> getNonInventoryDialog({
  required BuildContext buildContext,
}) async {
  TextEditingController controller = TextEditingController();
  AdminCrud adminCrud = AdminCrud();
  return showDialog<void>(
    context: buildContext,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Suppliers'),
        titleTextStyle: kProductNameStyle,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Shops(),
                ),
              );
            },
            child: const Text(
              'Create Supplier',
              style: kTotalTextStyle,
            ),
          ),
        ],
        // ignore: dead_code
        content: FutureBuilder<QuerySnapshot>(
          future: adminCrud.getShop(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: CircularProgressIndicator(
                    color: kMainColor,
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!.docs;
              List shops = [];
              for (var element in data) {
                shops.add(element.data());
              }
              if (kDebugMode) {
                print(shops);
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(shops.length, (index) {
                    return InkWell(
                        onTap: () {
                          Hive.box('shops')
                              .putAll(shops[index])
                              .whenComplete(() => Navigator.pop(context));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  shops[index]['profileImage'],
                                ),
                                radius: 35.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shops[index]['business_name'],
                                    style: kTableCellStyle,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    shops[index]['supplier_name'],
                                    style: kTableCellStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ));
                  }),
                ),
              );
            } else {
              return const Text('Oops an error occurred');
            }
          },
        ),
      );
    },
  );
}

Future<void> createCategoryDialog({
  required BuildContext buildContext,
}) async {
  TextEditingController controller = TextEditingController();
  AdminCrud adminCrud = AdminCrud();
  return showDialog<void>(
    context: buildContext,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Add new category'),
        titleTextStyle: kProductNameStyle,
        // ignore: dead_code
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: ListBody(
            children: <Widget>[
              Container(
                height: 40.0,
                // width: MediaQuery.of(context).size.width * 0.4,
                margin: const EdgeInsets.all(15.0),
                child: Center(
                  child: TextFormField(
                    controller: controller,
                    cursorColor: kMainColor,
                    style: kProductNameStylePro,
                    textInputAction: TextInputAction.done,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: kMainColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: kMainColor),
                      ),
                      focusColor: kMainColor,
                    ),
                    // onFieldSubmitted: (value) {
                    //   setState(() => {isEditable = false, title = value});
                    // }
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              adminCrud.addCategory({'category_name': controller.text});
              Navigator.pop(context);
            },
            child: Container(
              width: 80.0,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                color: kMainColor,
              ),
              child: const Center(
                child: const Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: kBackgroundColor,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

num percent(num discount, price) {
  num percent = (discount / price) * 100;
  return percent.round();
}

Widget discountPercentWidget(String text) {
  return Container(
    padding: const EdgeInsets.all(1.0),
    margin: const EdgeInsets.all(2.50),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
      color: kIconColor2,
    ),
    child: Text(
      '-$text%',
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 12.50,
        color: kBackgroundColor,
        letterSpacing: 1.3,
      ),
    ),
  );
}
