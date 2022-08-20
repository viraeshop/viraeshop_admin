import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tuple/tuple.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/transactions/user_transaction_screen.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';

import '../components/styles/text_styles.dart';
import '../configs/configs.dart';
import 'transactions/non_inventory_transaction_info.dart';

class SupplierPay extends StatefulWidget {
  const SupplierPay({Key? key}) : super(key: key);

  @override
  State<SupplierPay> createState() => _SupplierPayState();
}

class _SupplierPayState extends State<SupplierPay> {
  Uint8List? imageBytes;
  String? profileLink;
  String? imageFilePath;
  final TextEditingController invoiceCont = TextEditingController();
  final TextEditingController refCont = TextEditingController();
  final TextEditingController invoiceAmountCont = TextEditingController();
  final TextEditingController payAmountCont = TextEditingController();
  final TextEditingController dueAmountCont = TextEditingController();
  final TextEditingController noteCont = TextEditingController();
  Timestamp timestamp = Timestamp.now();
  Map<String, dynamic> supplierInvoice = {};
  bool isLoading = false;
  bool invoiceExist = false;
  StreamSubscription? boxStream;
  List payList = [];
  List images = [];
  num paidAmount = 0;
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
          title: const Text(
            'Supplier Pay',
            style: kAppBarTitleTextStyle,
          ),
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
                images.isNotEmpty
                    ? GestureDetector(
                        onTap: () async {
                          if (kIsWeb) {
                            final Tuple2<Uint8List?, String?> images =
                                await getImageWeb('supplier_payments');
                            setState(() {
                              imageBytes = images.item1;
                              this.images.add(images.item2);
                            });
                          } else {
                            final Tuple2<String?, String?> images =
                                await getImageNative('supplier_payments');
                            setState(() {
                              imageFilePath = images.item1;
                              this.images.add(images.item2);
                            });
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: images[0],
                            fit: BoxFit.cover,
                            height: 150,
                            width: 150,
                          ),
                        ),
                      )
                    : imagePickerWidget(
                        imagePath: imageFilePath,
                        images: imageBytes,
                        onTap: () async {
                          if (kIsWeb) {
                            final Tuple2<Uint8List?, String?> images =
                                await getImageWeb('supplier_payments');
                            setState(() {
                              imageBytes = images.item1;
                              this.images.add(images.item2);
                            });
                          } else {
                            final Tuple2<String?, String?> images =
                                await getImageNative('supplier_payments');
                            setState(() {
                              imageFilePath = images.item1;
                              this.images.add(images.item2);
                            });
                          }
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
                            if (!supplierInvoice.containsKey('business_name') && box.isNotEmpty) {
                              supplierInvoice.addAll({
                                'business_name': box.get('business_name'),
                                'name': box.get('supplier_name'),
                                'address': box.get('address'),
                                'mobile': box.get('mobile'),
                                'email': box.get('email'),
                              });
                            }
                            if (supplierInvoice.isNotEmpty && box.isNotEmpty) {
                              if (supplierInvoice['business_name'] !=
                                  box.get('business_name')) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((timeStamp) {
                                  setState(() {
                                    supplierInvoice.clear();
                                    images.clear();
                                    payList.clear();
                                    imageBytes?.clear();
                                    invoiceCont.clear();
                                    invoiceAmountCont.clear();
                                    dueAmountCont.clear();
                                    payAmountCont.clear();
                                    refCont.clear();
                                    noteCont.clear();
                                    paidAmount = 0;
                                    invoiceExist = false;
                                    imageFilePath = '';
                                  });
                                });
                              }
                            }
                            String shopName = supplierInvoice.isEmpty
                                ? box.get('business_name',
                                    defaultValue: 'Supplier')
                                : supplierInvoice['business_name'] ??
                                    'Supplier';
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
                              onSubmitted: (value) async {
                                setState(() {
                                  isLoading = true;
                                });
                                try {
                                  final supplierInvoice =
                                      await NetworkUtility.getSupplierPayment(
                                          value);
                                  Hive.box('shops').clear();
                                  if (supplierInvoice.exists) {
                                    if(supplierInvoice.get('isSupplierInvoice')){
                                      setState(() {
                                        invoiceExist = supplierInvoice.exists;
                                        this.supplierInvoice = supplierInvoice
                                            .data() as Map<String, dynamic>;
                                        dueAmountCont.text =
                                            supplierInvoice.get('due').toString();
                                        payAmountCont.text =
                                            supplierInvoice.get('paid')
                                                .toString();
                                        paidAmount = supplierInvoice.get('paid');
                                        invoiceAmountCont.text = supplierInvoice
                                            .get('buy_price')
                                            .toString();
                                        refCont.text =
                                            supplierInvoice.get('ref_no');
                                        noteCont.text =
                                            supplierInvoice.get('description');
                                        images
                                            .addAll(
                                            supplierInvoice.get('images'));
                                        payList = supplierInvoice.get('pay_list');
                                      });
                                    }
                                  }
                                } on FirebaseException catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
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
                              onChanged: (value) {
                                num due =
                                    num.parse(invoiceAmountCont.text ?? '0') -
                                        (num.parse(value) + paidAmount);
                                setState(() {
                                  dueAmountCont.text =
                                      due >= 0 ? due.toString() : '0';
                                });
                              },
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
                        setState(() {
                          isLoading = true;
                        });
                        if ((num.parse(invoiceAmountCont.text) -
                                (paidAmount +=
                                    num.parse(payAmountCont.text ?? '0'))) >=
                            0) {
                          paidAmount += num.parse(payAmountCont.text ?? '0');
                          payList.add({
                            'paid': num.parse(payAmountCont.text ?? '0'),
                            'date': Timestamp.now(),
                          });
                        }
                        supplierInvoice['pay_list'] = payList;
                        supplierInvoice['images'] = images;
                        Map<String, dynamic> data = {
                          'invoice_id': invoiceCont.text,
                          'isSupplierInvoice': true,
                          'paid': paidAmount,
                          'due': num.parse(dueAmountCont.text ?? '0'),
                          'buy_price': num.parse(invoiceAmountCont.text ?? '0'),
                          'ref_no': refCont.text,
                          'description': noteCont.text,
                          'business_name': supplierInvoice['business_name'],
                          'name': supplierInvoice['name'],
                          'date': invoiceExist
                              ? supplierInvoice['date']
                              : Timestamp.now(),
                          'address': supplierInvoice['address'],
                          'mobile': supplierInvoice['mobile'],
                          'email': supplierInvoice['email'],
                          'pay_list': payList,
                          'images': images,
                        };
                        try {
                          await NetworkUtility.supplierPayment(
                              invoiceCont.text, data);
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                    ),
                    buttons(
                      width: 150.0,
                      title: 'View',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return NonInventoryInfo(
                              data: supplierInvoice,
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
