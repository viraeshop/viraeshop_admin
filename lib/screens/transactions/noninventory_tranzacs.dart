import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:viraeshop_admin/components/styles/colors.dart';
import 'package:viraeshop_admin/components/styles/text_styles.dart';
import 'package:viraeshop_admin/screens/transactions/transaction_details.dart';
import 'package:viraeshop_api/utils/utils.dart';
import 'non_inventory_transactions.dart';
import 'user_transaction_screen.dart';
import 'package:tuple/tuple.dart';

class NonInventoryTransactionShops extends StatefulWidget {
  final List data;
  final bool isSupplier;
  const NonInventoryTransactionShops(
      {required this.data, this.isSupplier = false, Key? key})
      : super(key: key);

  @override
  _NonInventoryTransactionShopsState createState() =>
      _NonInventoryTransactionShopsState();
}

class _NonInventoryTransactionShopsState
    extends State<NonInventoryTransactionShops> {
  Map<String, List> transactionData = {};
  Map<String, Tuple2> balances = {};
  Map<String, Tuple2> balancesTemp = {};
  Tuple2 totalBalance = const Tuple2<num, num>(0, 0);
  Tuple2 totalBalanceTemp = const Tuple2<num, num>(0, 0);
  DateTime begin = DateTime.now();
  DateTime end = DateTime.now();
  Set employees = {};
  @override
  void initState() {
    // TODO: implement initState
    List shops = [];
    for (var element in widget.data) {
      if (widget.isSupplier) {
        shops.add(element['supplierInfos']['businessName']);
      } else {
        shops.add(element['supplierInfo']['businessName']);
      }
    }
    Set shopSet = Set.from(shops);
    for (var shop in shopSet) {
      List items = [];
      for (var element in widget.data) {
        if (widget.isSupplier) {
          if (element['supplierInfos']['businessName'] == shop) {
            items.add(element);
          }
        } else {
          if (element['supplierInfo']['businessName'] == shop) {
            items.add(element);
          }
        }
      }
      setState(() {
        transactionData[shop] = items;
      });
    }
    setState(() {
      balances = {
        for (var element in shopSet) element: tuple(transactionData[element] ?? [], widget.isSupplier)
      };
      balancesTemp = balances;
      totalBalance = tuple(widget.data, widget.isSupplier);
      totalBalanceTemp = totalBalance;
      employees = shopSet;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: balancesTemp.isEmpty,
      progressIndicator: const SizedBox(
        height: 100.0,
        width: 100.0,
        child: LoadingIndicator(
          indicatorType: Indicator.lineScale,
          colors: [kMainColor, kBlueColor, kRedColor, kYellowColor],
          strokeWidth: 2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(FontAwesomeIcons.chevronLeft),
            color: kSubMainColor,
            iconSize: 20.0,
          ),
          title: Text(
            widget.isSupplier ? 'Supplier Transactions' : 'Non Inventory',
            style: kAppBarTitleTextStyle,
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  balancesTemp = balances;
                  totalBalanceTemp = totalBalance;
                });
              },
              icon: const Icon(Icons.refresh),
              color: kSubMainColor,
              iconSize: 30.0,
            ),
          ],
        ),
        body: balancesTemp.isEmpty
            ? Container()
            : Stack(
                fit: StackFit.expand,
                children: [
                  FractionallySizedBox(
                    heightFactor: 0.7,
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: balancesTemp.keys.toList().length,
                        itemBuilder: (context, i) {
                          return InfoWidget(
                              textWidget: rowWidget(
                                  balancesTemp[balancesTemp.keys.toList()[i]]!
                                      .item1
                                      .toString(),
                                  balancesTemp[balancesTemp.keys.toList()[i]]!
                                      .item2
                                      .toString()),
                              title: balancesTemp.keys.toList()[i],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return NonInventoryTransactions(
                                      data: transactionData[
                                          transactionData.keys.toList()[i]]!,
                                      name: transactionData.keys.toList()[i],
                                      isSupplier: widget.isSupplier,
                                    );
                                  }),
                                );
                              });
                        }),
                  ),
                  FractionallySizedBox(
                    heightFactor: 0.25,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: kBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 0),
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              dateWidget(
                                title: begin.toString().split(' ')[0],
                                onTap: () {
                                  buildMaterialDatePicker(context, true);
                                },
                              ),
                              const Icon(
                                Icons.arrow_forward,
                                color: kSubMainColor,
                                size: 20.0,
                              ),
                              dateWidget(
                                  onTap: () {
                                    buildMaterialDatePicker(context, false);
                                  },
                                  title: end.isAtSameMomentAs(DateTime.now())
                                      ? 'To this date..'
                                      : end.toString().split(' ')[0]),
                              const SizedBox(
                                width: 20.0,
                              ),
                              roundedTextButton(onTap: () {
                                setState(() {
                                  balancesTemp = {
                                    for (var element in employees)
                                      element: dateTuple(
                                          transactionData[element]!, begin, end, widget.isSupplier)
                                  };
                                  totalBalanceTemp =
                                      dateTuple(widget.data, begin, end, widget.isSupplier);
                                });
                              }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpecialContainer(
                                height: 110.0,
                                width: 150.0,
                                value: totalBalanceTemp.item1.toString(),
                                title: widget.isSupplier
                                    ? 'Total Payments'
                                    : 'Total Sales',
                                color: kYellowColor,
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                              SpecialContainer(
                                height: 110.0,
                                width: 150.0,
                                value: totalBalanceTemp.item2.toString(),
                                title: 'Total Due',
                                color: kRedColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  buildMaterialDatePicker(BuildContext context, bool isBegin) async {
    DateTime date = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      fieldHintText: 'Month/Date/Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != begin) {
      if (isBegin) {
        setState(() {
          begin = picked;
        });
      } else {
        setState(() {
          end = picked;
        });
      }
    }
  }
}

Tuple2 tuple(List items, bool isSupplierPay) {
  num salesOrPaid = 0, due = 0;
  for (var element in items) {
    if(isSupplierPay) {
      salesOrPaid += element['paid'];
      due += element['due'];
    }else{
      salesOrPaid += element['price'];
      due += element['due'];
    }
  }
  Tuple2 data = Tuple2<num, num>(salesOrPaid, due);
  return data;
}

Tuple2 dateTuple(List items, DateTime begin, DateTime end, bool isSupplierPay) {
  num salesOrPaid = 0, due = 0;
  for (var element in items) {
    Timestamp timestamp = dateFromJson(element['createdAt']);
    DateTime date = timestamp.toDate();
    begin = DateTime(begin.year, begin.month, begin.day);
    end = DateTime(end.year, end.month, end.day);
    DateTime dateFormatted = DateTime(date.year, date.month, date.day);
    if ((begin.isAfter(dateFormatted) ||
            begin.isAtSameMomentAs(dateFormatted)) &&
        (end.isBefore(dateFormatted) || end.isAtSameMomentAs(dateFormatted))) {
      if(isSupplierPay){
        salesOrPaid += element['paid'];
        due += element['due'];
      }else{
        salesOrPaid += element['price'];
        due += element['due'];
      }
      // if(element.containsKey('isSupplierInvoice')){
      //   salesOrPaid += element['paid'];
      //   due += element['due'];
      // }else{
      //   element['shop'].forEach((shop) {
      //
      //   });
      // }
    }
  }
  Tuple2 data = Tuple2<num, num>(salesOrPaid, due);
  return data;
}
