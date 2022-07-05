import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/product_table.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'form_field.dart';

class DesktopProductCard2 extends StatefulWidget {
  final TextEditingController nameController, priceController, costController;
  final bool fromInfo;
  DesktopProductCard2({
    required this.nameController,
    required this.costController,
    required this.priceController,
    this.fromInfo = false,
  });
  @override
  State<DesktopProductCard2> createState() => _DesktopProductCard2State();
}

class _DesktopProductCard2State extends State<DesktopProductCard2> {
  static List<String> categoryNames = ['arcylic sheets'];
  getCategories() async {
    var categories =
        await FirebaseFirestore.instance.collection('products').get();
    final categoryName = categories.docs.toList();
    categoryName.forEach((element) {
      if (element.id != categoryNames[0]) {
        setState(() {
          categoryNames.add(element.id);
        });
      }
    });
    print('names: $categoryNames');
  }

  @override
  void initState() {
    // getCategories();
    // print('names: $categoryNames');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    // getCategories();
    super.didChangeDependencies();
  }

  static List<String> userType = [
    'general',
    'agent',
    'architect',
  ];
  List<DropdownMenuItem> userTypesDropdown = List.generate(
    userType.length,
    (index) => DropdownMenuItem(
      child: Text(
        userType[index],
        style: kCategoryNameStyle,
      ),
      value: userType[index],
    ),
  );

  List<DropdownMenuItem> dropDownNames = List.generate(
    categoryNames.length,
    (index) => DropdownMenuItem(
      child: Text(
        categoryNames[index],
        style: kCategoryNameStyle,
      ),
      value: categoryNames[index],
    ),
  );
  @override
  Widget build(BuildContext context) {
    List<String> sellBy = ['Unit ', 'Sft', 'Rft', 'Kilo', 'Kg', 'CM', 'Pisce'];
    List<DropdownMenuItem> dropDownItem = List.generate(
      sellBy.length,
      (index) => DropdownMenuItem(
        child: Text(
          sellBy[index],
          style: kCategoryNameStyle,
        ),
        value: sellBy[index],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      // margin: EdgeInsets.all(10.0),
      height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 15.0),
            child: Text(
              'New Product',
              style: kCategoryNameStyle,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Divider(
              color: kScaffoldBackgroundColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Consumer<Configs>(
                  builder: (context, configs, childs) => HeadingTextField(
                    onMaxLine: false,
                    controller: widget.nameController,
                    heading: 'Product name: ',
                    enable: widget.fromInfo ? configs.enableFields : true,
                  ),
                ),
                Consumer<Configs>(
                  builder: (context, configs, childs) => HeadingTextField(
                    controller: widget.priceController,
                    onMaxLine: false,
                    heading: 'Product price: ',
                    enable: widget.fromInfo ? configs.enableFields : true,
                  ),
                ),
                // SizedBox(
                //   height: 10.0,
                // ),            
                Consumer<Configs>(
                  builder: (context, configs, childs) => HeadingTextField(
                    controller: widget.costController,
                    onMaxLine: false,
                    heading: 'Cost: ',
                    enable: widget.fromInfo ? configs.enableFields : true,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sell by: ',
                      style: kProductPriceStylePro,
                    ),
                    Container(
                      height: 46.0,
                      width: MediaQuery.of(context).size.width * 0.4,
                      margin: EdgeInsets.all(10.0),
                      child: Center(
                        child: Consumer<Configs>(
                          builder: (context, configs, childs) =>
                              DropdownButtonFormField(
                            items: dropDownItem,
                            value: configs.sellBy,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kMainColor),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: kMainColor),
                              ),
                              focusColor: kMainColor,
                            ),
                            // hint: Text(
                            //   'Sell by',
                            //   style: kCategoryNameStyle,
                            // ),
                            onChanged: (dynamic value) {
                              Provider.of<Configs>(context, listen: false)
                                  .updateSellBy(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product for: ',
                      style: kProductPriceStylePro,
                    ),
                    Center(
                      child: Container(
                        height: 46.0,
                        width: MediaQuery.of(context).size.width * 0.4,
                        margin: EdgeInsets.all(10.0),
                        child: Consumer<Configs>(
                          builder: (context, configs, childs) =>
                              DropdownButtonFormField(
                            items: userTypesDropdown,
                            value: configs.productFor,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: kMainColor),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: kMainColor),
                              ),
                              focusColor: kMainColor,
                            ),
                            onChanged: (dynamic value) {
                              Provider.of<Configs>(context, listen: false)
                                  .updateProductFor(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),

          // Text(
          //   'Stocks',
          //   style: kCategoryNameStylePro,
          // ),
          // SizedBox(
          //   height: 10.0,
          // ),

          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
