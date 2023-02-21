import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop/expense/expense_event.dart';
import 'package:viraeshop/expense/expense_state.dart';
import 'package:viraeshop_admin/components/custom_widgets.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/configs/configs.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/settings/admin_CRUD.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop/expense/expense_bloc.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({Key? key}) : super(key: key);

  @override
  _NewExpenseState createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense>{
  TextEditingController expenseTitle = TextEditingController();
  TextEditingController expenseDescription = TextEditingController();
  TextEditingController expenseCost = TextEditingController();
  AdminCrud adminCrud = AdminCrud();
  String imagePath = '';
  Uint8List? images;
  Map<String, dynamic> productImageData = {};
  bool isLoading = false;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state){
        if(state is OnErrorExpenseState){
          setState(() {
            isLoading = false;
          });
          snackBar(text: state.message, context: context, color: kRedColor, duration: 50);
        }else if(state is RequestFinishedExpenseState){
          setState(() {
            isLoading = false;
          });
          toast(context: context, title: 'Created successfully');
        }
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: kMainColor,
        ),
        child: Scaffold(
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
              children: [
                imagePickerWidget(
                  onTap: () {
                    try {
                      if(kIsWeb){
                        // getImageWeb('expenses').then((value) {
                        //   setState(() {
                        //     images = value.item1;
                        //     productImageData = value.item2 ?? '';
                        //   });
                        // });
                      }else{
                        getImageNative('expenses').then((value){
                          setState(() {
                            imagePath = value['path'];
                            productImageData = value['imageData'];
                          });
                        });
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print(e);
                      }
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
                          borderRadius: BorderRadius.circular(15),
                      ),
                  ),
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
                      child: Text(
                        "Add Expense",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  onTap: () {
                    if (expenseTitle.text != '' && expenseCost.text != '') {
                      setState(() {
                        isLoading = true;
                      });
                      String adminId = Hive.box('adminInfo').get('adminId');
                      final expenseBloc = BlocProvider.of<ExpenseBloc>(context);
                      Map<String, dynamic> expenseData = {
                        'title': expenseTitle.text,
                        'cost': expenseCost.text != null ? num.parse(expenseCost.text) : 0,
                        'description': expenseDescription.text ?? '',
                        'image': productImageData['url'],
                        'imageKey': productImageData['key'],
                        'adminId': adminId,
                      };
                      expenseBloc.add(
                        AddExpenseEvent(
                            token: jWTToken,
                            expenseModel: expenseData)
                      );
                    } else {
                      popDialog(
                          widget: const Text(
                            'Fields Cannot Be Empty',
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
        ),
      ),
    );
  }
}

