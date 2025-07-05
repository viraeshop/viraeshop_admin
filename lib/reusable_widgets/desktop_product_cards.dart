import 'package:flutter/material.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/reusable_widgets/editable_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DesktopProductCard1 extends StatefulWidget {
  final Map produtInfo;
  const DesktopProductCard1({super.key, required this.produtInfo});
  @override
  State<DesktopProductCard1> createState() => _DesktopProductCard1State();
}

class _DesktopProductCard1State extends State<DesktopProductCard1> {
  static List<String> categoryNames = [];
  getCategories() async {
    var categories =
        await FirebaseFirestore.instance.collection('products').get();
    final categoryName = categories.docs.toList();
    for (var element in categoryName) {
      setState(() {
        categoryNames.add(element.id);
      });
    }
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
      value: categoryNames[index],
      child: Text(
       categoryNames.isEmpty ? '...' : categoryNames[index],
        style: kCategoryNameStyle,
      ),
    ),
  );
  List<DropdownMenuItem> dropDownItems = List.generate(
    sellType.length,
    (index) => DropdownMenuItem(
      value: sellType[index],
      child: Text(
        sellType[index],
        style: kCategoryNameStyle,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    String sellBy = widget.produtInfo['sell_by'];
    String category = widget.produtInfo['category'];
    final TextEditingController nameController = TextEditingController(
      text: widget.produtInfo['name'],
    );
    final TextEditingController categController =
        TextEditingController(text: widget.produtInfo['category']);
    final TextEditingController priceController =
        TextEditingController(text: widget.produtInfo['price']);
    final TextEditingController descController =
        TextEditingController(text: widget.produtInfo['description']);
    final TextEditingController costController =
        TextEditingController(text: widget.produtInfo['cost']);
    final TextEditingController quantityController =
        TextEditingController(text: widget.produtInfo['quantity']);
    bool isNotEmpty() {
      if (sellBy.isNotEmpty &&
          nameController.text.isNotEmpty &&
          categController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          descController.text.isNotEmpty &&
          costController.text.isNotEmpty &&
          quantityController.text.isNotEmpty) {
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
          const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
              'Archtylic Sheets',
              style: kCategoryNameStyle,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            onMaxLine: false,
            controller: nameController,
            heading: 'Product name: ',
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            controller: priceController,
            onMaxLine: false,
            heading: 'Product price: ',
          ),
          // SizedBox(
          //   height: 10.0,
          // ),
          const Text(
            'Details',
            style: kCategoryNameStylePro,
          ),
          const SizedBox(
            height: 10.0,
          ),
          EditableTextField(
            textStyle: kProductNameStylePro,
            controller: descController,
            onMaxLine: true,
            heading: 'Description: ',
          ),
          Row(
            children: [
              const Text(
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
            controller: costController,
            onMaxLine: false,
            heading: 'Cost: ',
          ),
          Row(
            children: [
              const Text(
                'Sell by: ',
                style: kProductPriceStylePro,
              ),
              Expanded(
                child: DropdownButtonFormField(
                  items: dropDownItems,
                  value: sellBy,
                  hint: const Text(
                    'Sell by',
                    style: kCategoryNameStyle,
                  ),
                  onChanged: (dynamic value) {
                    setState(() {
                      sellBy = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            'Stocks',
            style: kCategoryNameStylePro,
          ),
          // SizedBox(
          //   height: 10.0,
          // ),

          const SizedBox(
            height: 10.0,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: kMainColor, 
                      borderRadius: BorderRadius.circular(15)),
                  child: const Row(
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
                      'name': nameController.text,
                      'description': descController.text,
                      'category': categController.text,
                      'selling_price': priceController.text,
                      'cost_price': costController.text,
                      'quantity': quantityController.text,
                      'sell_by': sellBy,
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
