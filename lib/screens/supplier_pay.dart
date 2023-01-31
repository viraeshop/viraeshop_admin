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
import 'package:viraeshop/supplier_invoice/supplier_invoice_event.dart';
import 'package:viraeshop/supplier_invoice/supplier_invoice_state.dart';
import 'package:viraeshop/suppliers/suppliers_bloc.dart';
import 'package:viraeshop/suppliers/suppliers_event.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/configs/image_picker.dart';
import 'package:viraeshop_admin/reusable_widgets/text_field.dart';
import 'package:viraeshop_admin/screens/customers/preferences.dart';
import 'package:viraeshop_admin/screens/transactions/user_transaction_screen.dart';
import 'package:viraeshop_admin/utils/network_utilities.dart';
import 'package:viraeshop_api/utils/utils.dart';

import '../components/styles/text_styles.dart';
import '../configs/configs.dart';
import 'transactions/non_inventory_transaction_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viraeshop/supplier_invoice/supplier_invoice_bloc.dart';

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
  List payList = [];
  List images = [];
  String updatingImage = '';
  num paidAmount = 0;
  final jWTToken = Hive.box('adminInfo').get('token');
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener<SupplierInvoiceBloc, SupplierInvoiceState>(
      listener: (context, state) {
        if (state is OnErrorSupplierInvoiceState) {
          setState(() {
            isLoading = false;
            if (state.message == 'Invoice not found') {
              invoiceExist = false;
            }
          });
          if (state.message != 'Invoice not found') {
            snackBar(
              text: state.message,
              context: context,
              color: kRedColor,
              duration: 500,
            );
          }
        } else if (state is FetchedSupplierInvoiceState) {
          Hive.box('shops').clear();
          setState(() {
            isLoading = false;
            invoiceExist = true;
            supplierInvoice = state.supplierInvoiceModel.toJson();
            dueAmountCont.text = supplierInvoice['due'].toString();
            payAmountCont.text = supplierInvoice['paid'].toString();
            paidAmount = supplierInvoice['paid'];
            invoiceAmountCont.text = supplierInvoice['buyPrice'].toString();
            refCont.text = supplierInvoice['refNo'];
            noteCont.text = supplierInvoice['description'];
            for (var image in supplierInvoice['images']) {
              images.add(image['imageLink']);
            }
            payList = supplierInvoice['payList'];
          });
        } else if (state is RequestFinishedSupplierInvoiceState) {
          setState(() {
            isLoading = false;
          });
          toast(context: context, title: state.response.message);
        }
      },
      child: ModalProgressHUD(
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
                                updatingImage = images.item2 ?? '';
                              });
                            } else {
                              final Tuple2<String?, String?> images =
                                  await getImageNative('supplier_payments');
                              setState(() {
                                imageFilePath = images.item1;
                                updatingImage = images.item2 ?? '';
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
                                updatingImage = images.item2 ?? '';
                              });
                            } else {
                              final Tuple2<String?, String?> images =
                                  await getImageNative('supplier_payments');
                              setState(() {
                                imageFilePath = images.item1;
                                updatingImage = images.item2 ?? '';
                              });
                            }
                          },
                        ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      final supplierBloc =
                          BlocProvider.of<SuppliersBloc>(context);
                      supplierBloc.add(GetSuppliersEvent(
                        token: jWTToken,
                      ));
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
                              if (!supplierInvoice
                                      .containsKey('supplierInfos') &&
                                  box.isNotEmpty) {
                                supplierInvoice.addAll({
                                  'supplierInfos': {
                                    'businessName': box.get('businessName'),
                                    'supplierId': box.get('supplierId'),
                                  },
                                  'supplierId': box.get('supplierId'),
                                });
                              }
                              if (supplierInvoice.isNotEmpty &&
                                  box.isNotEmpty) {
                                if (supplierInvoice['supplierInfos']
                                        ['businessName'] !=
                                    box.get('businessName')) {
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
                                  ? box.get('businessName',
                                      defaultValue: 'Supplier')
                                  : supplierInvoice['supplierInfos']
                                          ['businessName'] ??
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
                                onSubmitted: (value) {
                                  final supplierInvoiceBloc =
                                      BlocProvider.of<SupplierInvoiceBloc>(
                                          context);
                                  setState(() {
                                    isLoading = true;
                                  });
                                  supplierInvoiceBloc.add(
                                      GetSupplierInvoiceEvent(
                                        token: jWTToken,
                                        invoiceNo: value,
                                      ));
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
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          final supplierInvoiceBloc =
                              BlocProvider.of<SupplierInvoiceBloc>(context);
                          if ((num.parse(invoiceAmountCont.text) -
                                  (paidAmount +=
                                      num.parse(payAmountCont.text ?? '0'))) >=
                              0) {
                            paidAmount += num.parse(payAmountCont.text ?? '0');
                            payList.add({
                              'paid': num.parse(payAmountCont.text ?? '0'),
                              'createdAt': dateToJson(Timestamp.now()),
                              'invoiceNo': invoiceCont.text,
                            });
                          }
                          supplierInvoice['payList'] = payList;
                          supplierInvoice['images'].add({
                            'invoiceNo': invoiceCont.text,
                            'imageLink': updatingImage,
                            'createdAt': dateToJson(Timestamp.now()),
                          });
                          Map<String, dynamic> data = {
                            'invoiceNo': invoiceCont.text,
                            'paid': paidAmount,
                            'due': num.parse(dueAmountCont.text ?? '0'),
                            'buyPrice':
                                num.parse(invoiceAmountCont.text ?? '0'),
                            'refNo': refCont.text,
                            'description': noteCont.text,
                            'supplierId': supplierInvoice['supplierId'],
                            'payList': {
                              'paid': num.parse(payAmountCont.text ?? '0'),
                              'createdAt': dateToJson(Timestamp.now()),
                              'invoiceNo': invoiceCont.text,
                            },
                            'images': {
                              'invoiceNo': invoiceCont.text,
                              'imageLink': updatingImage,
                              'createdAt': dateToJson(Timestamp.now()),
                            },
                          };
                          print(invoiceExist);
                          if (invoiceExist) {
                            supplierInvoiceBloc.add(
                              UpdateSupplierInvoiceEvent(
                                token: jWTToken,
                                  invoiceNo: invoiceCont.text,
                                  supplierInvoiceModel: data),
                            );
                          } else {
                            supplierInvoiceBloc.add(AddSupplierInvoiceEvent(
                              token: jWTToken,
                                supplierInvoiceModel: data));
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
                                isSupplierPay: true,
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
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
