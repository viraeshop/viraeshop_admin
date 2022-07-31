import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({Key? key}) : super(key: key);

  @override
  _NewExpenseState createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense>
    with SingleTickerProviderStateMixin {
  ImagePicker _picker = ImagePicker();
  File? _imageFile;
  TextEditingController expenseTitle = TextEditingController();
  TextEditingController expenseDescription = TextEditingController();
  TextEditingController expenseCost = TextEditingController();
  AdminCrud adminCrud = AdminCrud();
  String imagePath = '';
  late TabController _tabController;

  var currdate = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Uint8List? images;
  String? productImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kSelectedTileColor),
        elevation: 0.0,
        backgroundColor: kBackgroundColor,
        title: const Text(
          'New Expense',
          style: kAppBarTitleTextStyle,
        ),
        centerTitle: true,
        titleTextStyle: kTextStyle1,
        // bottom: TabBar(
        //   tabs: tabs,
        // ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imagePickerWidget(

              onTap: () {
                try {
                  if(kIsWeb){
                    getImageWeb('expenses').then((value) {
                      setState(() {
                        images = value.item1;
                        productImage = value.item2;
                      });
                    });
                  }else{
                    getImageNative('expenses').then((value){
                      setState(() {
                        imagePath = value.item1!;
                        productImage = value.item2;
                      });
                    });
                  }
                } catch (e) {
                  print(e);
                }
              },
              images: images,
              imagePath: imagePath,
            ),
            const SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: expenseTitle,
              decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: expenseCost,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Cost",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: expenseDescription,
              decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 58,
                decoration: BoxDecoration(
                    color: kSelectedTileColor, //Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(15)),
                child: const Center(
                  child: const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              onTap: () {
                if (expenseTitle.text != '' && expenseCost.text != '') {
                  String adminId = Hive.box('adminInfo').get('adminId');
                  var expenseData = {
                    'title': expenseTitle.text,
                    'cost': expenseCost.text != null ? num.parse(expenseCost.text) : 0,
                    'description': expenseDescription.text != null
                        ? expenseDescription.text
                        : '',
                    'image': productImage,
                    'added_by': adminId,
                    'date': Timestamp.now(),
                  };
                  // print(jsonEncode(expenseData));
                  if (adminCrud.addExpenses(expenseData)) {
                    popDialog(
                        widget: const Text(
                          'Expense Added',
                          textAlign: TextAlign.center,
                        ),
                        title: 'Success',
                        context: context);
                  } else {
                    popDialog(
                        widget: const Text(
                          'Could Not Add Expense',
                          textAlign: TextAlign.center,
                        ),
                        title: 'Error',
                        context: context);
                  }
                } else {
                  popDialog(
                      widget: const Text(
                        'FIelds Cannot Be Empty',
                        textAlign: TextAlign.center,
                      ),
                      title: 'Error',
                      context: context);
                }
                // addProduct();
              },
            ),
          ],
        ),
      ),
    );
  }

  //
}

