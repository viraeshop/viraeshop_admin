import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/product_table.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/editable_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DesktopProductCard1 extends StatefulWidget {
  final Map produtInfo;
  DesktopProductCard1({required this.produtInfo});
  @override
  State<DesktopProductCard1> createState() => _DesktopProductCard1State();
}

class _DesktopProductCard1State extends State<DesktopProductCard1> {
  static List<String> categoryNames = [];
  getCategories() async {
    var categories =
        await FirebaseFirestore.instance.collection('products').get();
    final categoryName = categories.docs.toList();
    categoryName.forEach((element) {
      setState(() {
        categoryNames.add(element.id);
      });
    });
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  static List<String> sellType = [
    'Unit ',
    'Sft',
    'Rft',
    'Kilo',
    'Kg',
    'CM',
    'Pisce'
  ];
  List<DropdownMenuItem> dropDownNames = List.generate(
    categoryNames.length,
    (index) => DropdownMenuItem(
      child: Text(
       categoryNames.isEmpty ? '...' : categoryNames[index],
        style: kCategoryNameStyle,
      ),
      value: categoryNames[index],
    ),
  );
  List<DropdownMenuItem> dropDownItems = List.generate(
    sellType.length,
    (index) => DropdownMenuItem(
      child: Text(
        sellType[index],
        style: kCategoryNameStyle,
      ),
      value: sellType[index],
    ),
  );
  @override
  Widget build(BuildContext context) {
    String _sellBy = widget.produtInfo['sell_by'];
    String category = widget.produtInfo['category'];
    final TextEditingController _nameController = TextEditingController(
      text: widget.produtInfo['name'],
    );
    final TextEditingController _categController =
        TextEditingController(text: widget.produtInfo['category']);
    final TextEditingController _priceController =
        TextEditingController(text: widget.produtInfo['price']);
    final TextEditingController _descController =
        TextEditingController(text: widget.produtInfo['description']);
    final TextEditingController _costController =
        TextEditingController(text: widget.produtInfo['cost']);
    final TextEditingController _quantityController =
        TextEditingController(text: widget.produtInfo['quantity']);
    bool isNotEmpty() {
      if (_sellBy.isNotEmpty &&
          _nameController.text.isNotEmpty &&
          _categController.text.isNotEmpty &&
          _priceController.text.isNotEmpty &&
          _descController.text.isNotEmpty &&
          _costController.text.isNotEmpty &&
          _quantityController.text.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      // margin: EdgeInsets.all(10.0),
      height: MediaQuery.of(context).size.height * 0.95,
      width: MediaQuery.of(context).size.width * 0.35,
      // padding: EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              'Archtylic Sheets',
              style: kCategoryNameStyle,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            onMaxLine: false,
            controller: _nameController,
            heading: 'Product name: ',
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            controller: _priceController,
            onMaxLine: false,
            heading: 'Product price: ',
          ),
          // SizedBox(
          //   height: 10.0,
          // ),
          Text(
            'Details',
            style: kCategoryNameStylePro,
          ),
          SizedBox(
            height: 10.0,
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            controller: _descController,
            onMaxLine: true,
            heading: 'Description: ',
          ),
          Row(
            children: [
              Text(
                'Category: ',
                style: kProductPriceStylePro,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  items: dropDownNames,
                  value: category,
                  style: kCategoryNameStyle,
                  onChanged: (dynamic value) {
                    setState(() {
                      category = value;
                    });
                  },
                ),
              ),
            ],
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            controller: _costController,
            onMaxLine: false,
            heading: 'Cost: ',
          ),
          Row(
            children: [
              Text(
                'Sell by: ',
                style: kProductPriceStylePro,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  items: dropDownItems,
                  value: _sellBy,
                  hint: Text(
                    'Sell by',
                    style: kCategoryNameStyle,
                  ),
                  onChanged: (dynamic value) {
                    setState(() {
                      _sellBy = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            'Stocks',
            style: kCategoryNameStylePro,
          ),
          // SizedBox(
          //   height: 10.0,
          // ),

          SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: kMainColor, 
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Save",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  if (isNotEmpty() == true) {
                    FirebaseFirestore.instance
                        .collection('products')
                        .doc(category)
                        .collection('products')
                        .doc(widget.produtInfo['docId'])
                        .update({
                      'name': _nameController.text,
                      'description': _descController.text,
                      'category': _categController.text,
                      'selling_price': _priceController.text,
                      'cost_price': _costController.text,
                      'quantity': _quantityController.text,
                      'sell_by': _sellBy,
                    });
                  } else {}
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
