import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/user_transaction_screen.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../components/styles/text_styles.dart';
import '../configs/configs.dart';
import 'non_inventory_transaction_info.dart';

class SupplierPay extends StatefulWidget {
  const SupplierPay({Key? key}) : super(key: key);

  @override
  State<SupplierPay> createState() => _SupplierPayState();
}

class _SupplierPayState extends State<SupplierPay> {
  Tuple2<Uint8List?, String?> imageInfo = Tuple2<Uint8List?, String?>(Uint8List(0), '');
  final TextEditingController invoiceCont = TextEditingController();
  final TextEditingController refCont = TextEditingController();
  final TextEditingController invoiceAmountCont = TextEditingController();
  final TextEditingController payAmountCont = TextEditingController();
  final TextEditingController dueAmountCont = TextEditingController();
  final TextEditingController noteCont = TextEditingController();
  Timestamp timestamp = Timestamp.now();
  Map shop = {};
  List<Map> paymentInfo = [];
  bool isLoading = false;
  StreamSubscription? boxStream;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const CircularProgressIndicator(
        color: kNewMainColor,
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Hive.box('shops').clear();
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            iconSize: 20.0,
            color: kSubMainColor,
          ),
          title: const Text('Supplier Pay', style: kAppBarTitleTextStyle,),
        ),
        body: Container(
          color: kBackgroundColor,
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                imagePickerWidget(
                  images: imageInfo.item1,
                  onTap: () async {
                    final images = await getImageWeb();
                    setState((){
                      imageInfo = images;
                    });
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () {
                    getNonInventoryDialog(buildContext: context);
                  },
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        //width: 3.0,
                        color: kSubMainColor,
                      ),
                    ),
                    child: Center(
                      child: ValueListenableBuilder(
                          valueListenable: Hive.box('shops').listenable(),
                          builder: (context, Box box, childs) {
                            shop = box.toMap();
                            String shopName =
                                box.get('business_name', defaultValue: 'Shops');
                           boxStream =  box.watch().listen((event) async {
                             setState(() {
                                isLoading = true;
                              });
                              try {
                                final data =
                                    await NetworkUtility.getSupplierPayment(
                                        shopName);
                                if (data.exists) {
                                  List<Map> paymentInfo = data.get('payments');
                                  List payList = [];
                                  List images = [];
                                  for (var info in paymentInfo) {
                                    payList.add({
                                      'date': info['date'],
                                      'paid': info['pay_amount'],
                                    });
                                    images.add(info['image']);
                                  }
                                  setState(() {
                                    this.paymentInfo = paymentInfo;
                                    shop['pay_list'] = payList;
                                    shop['images'] = images;
                                  });
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            });
                            return Text(
                              shopName,
                              style: kTotalTextStyle,
                            );
                          }),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Invoice No',
                              style: kProductNameStylePro,
                            ),
                            NewTextField(
                              controller: invoiceCont,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reference No',
                              style: kProductNameStylePro,
                            ),
                            NewTextField(
                              controller: refCont,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: size.width * 0.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invoice Amount',
                            style: kProductNameStylePro,
                          ),
                          NewTextField(
                            controller: invoiceAmountCont,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pay Amount',
                              style: kProductNameStylePro,
                            ),
                            NewTextField(
                              controller: payAmountCont,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Due Amount',
                              style: kProductNameStylePro,
                            ),
                            NewTextField(
                              controller: dueAmountCont,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                NewTextField(
                  controller: noteCont,
                  lines: 3,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buttons(
                      width: 150.0,
                      title: 'Update',
                      onTap: () async {
                        setState((){
                          isLoading = true;
                        });
                        Map data = {
                          'invoice_no': invoiceCont.text,
                          'pay_amount': payAmountCont.text,
                          'due_amount': dueAmountCont.text,
                          'invoice_amount': invoiceAmountCont.text,
                          'ref_no': refCont.text,
                          'note': noteCont.text,
                          'business_name': shop['business_name'],
                          'supplier_name': shop['supplier_name'],
                          'image': imageInfo.item2,
                          'date': Timestamp.now(),
                        };
                        print(paymentInfo);
                        paymentInfo.add(data);
                        try{
                          await NetworkUtility.supplierPayment(shop['business_name'], {
                            'payments': paymentInfo,
                          });
                        }catch (e){
                          if (kDebugMode) {
                            print(e);
                          }
                        }finally{
                          setState((){
                            isLoading = false;
                          });
                        }
                      },
                    ),
                    buttons(
                      width: 150.0,
                      title: 'View',
                      onTap: paymentInfo.isEmpty ? null :  () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return NonInventoryInfo(
                              isSupplierPay: true,
                              data: shop,
                              invoiceId: invoiceCont.text,
                              date: timestamp,
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    boxStream!.cancel();
    super.dispose();
  }
}
